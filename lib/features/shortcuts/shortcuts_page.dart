import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/localization_provider.dart';
import '../../core/providers/apps_provider.dart';
import '../../core/providers/platform_provider.dart';
import '../home/widgets/featured_shortcut_card.dart';
import 'providers/shortcuts_providers.dart';
import 'widgets/search_mode_switch.dart';
import 'widgets/key_recorder_widget.dart';
import '../../shared/widgets/shared_empty_state.dart';
import '../../shared/widgets/shared_error_state.dart';
import '../../shared/widgets/shared_grid_skeleton.dart';
import '../../shared/widgets/shared_translation_notice.dart';
import 'widgets/text_search_bar.dart';

import 'package:go_router/go_router.dart';

class ShortcutsPage extends ConsumerStatefulWidget {
  final String? initialSearchQuery;

  const ShortcutsPage({super.key, this.initialSearchQuery});

  @override
  ConsumerState<ShortcutsPage> createState() => _ShortcutsPageState();
}

class _ShortcutsPageState extends ConsumerState<ShortcutsPage> {
  @override
  void initState() {
    super.initState();
    if (widget.initialSearchQuery != null && widget.initialSearchQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(searchQueryProvider.notifier).update(widget.initialSearchQuery!);
      });
    }
  }

  @override
  void didUpdateWidget(covariant ShortcutsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSearchQuery != widget.initialSearchQuery) {
      if (ref.read(searchQueryProvider) != (widget.initialSearchQuery ?? '')) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(searchQueryProvider.notifier).update(widget.initialSearchQuery ?? '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    final languageCode = ref.watch(localizationProvider);

    // Setup URL Sync
    ref.listen<String>(searchQueryProvider, (previous, next) {
      if (previous != next && next != (widget.initialSearchQuery ?? '')) {
        final uri = GoRouterState.of(context).uri;
        
        // Build new query parameters map, explicitly removing 'q' if empty
        final Map<String, dynamic> newParams = Map.from(uri.queryParameters);
        if (next.isNotEmpty) {
          newParams['q'] = next;
        } else {
          newParams.remove('q');
        }
        
        final newUri = uri.replace(queryParameters: newParams.isEmpty ? null : newParams);
        context.replace(newUri.toString());
      }
    });

    return CustomScrollView(
      slivers: [
        const SliverPadding(padding: EdgeInsets.only(top: 140)),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                strings.shortcuts,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const SearchModeSwitch(),
              const SizedBox(height: 32),
              // Search Input Area (Text or Keys)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Consumer(
                  builder: (context, ref, child) {
                    final mode = ref.watch(searchModeProvider);
                    if (mode == SearchMode.keys) {
                      return const KeyRecorderWidget();
                    }
                    return const TextSearchBar();
                  },
                ),
              ),
              const SharedTranslationNotice(),
              const SizedBox(height: 32),
              // Bookmarks Filter
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: BookmarksFilterToggle(),
              ),
              const SizedBox(height: 16),
              // App Filter Chips
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: AppFilterChips(),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
        // Results Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: Consumer(
            builder: (context, ref, _) {
              final platform = ref.watch(platformProvider);
              final shortcutsAsync = ref.watch(filteredShortcutsProvider);
              final displayLimit = ref.watch(displayLimitProvider);

              return shortcutsAsync.when(
                data: (results) {
                  if (results.isEmpty) {
                    final mode = ref.watch(searchModeProvider);
                    final isKeyMode = mode == SearchMode.keys;
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(vertical: 64),
                      sliver: SliverToBoxAdapter(
                        child: SharedEmptyState(
                          message: strings.noResultsFound,
                          iconPath: isKeyMode ? 'assets/Icons/keyboard.svg' : 'assets/Icons/search.svg',
                        ),
                      ),
                    );
                  }

                  final displayedResults = results.take(displayLimit).toList();
                  final hasMore = results.length > displayLimit;

                  return SliverMainAxisGroup(
                    slivers: [
                      SliverLayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.crossAxisExtent;
                          int columns = 1;
                          if (width >= 1200) {
                            columns = 5;
                          } else if (width >= 900) {
                            columns = 3;
                          } else if (width >= 600) {
                            columns = 2;
                          }

                          return SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              mainAxisSpacing: columns == 1 ? 16 : 24,
                              crossAxisSpacing: columns == 1 ? 16 : 24,
                              mainAxisExtent: 280,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return FeaturedShortcutCard(
                                  key: ValueKey(displayedResults[index].id),
                                  item: displayedResults[index],
                                  theme: theme,
                                  strings: strings,
                                  languageCode: languageCode,
                                  platform: platform,
                                );
                              },
                              childCount: displayedResults.length,
                            ),
                          );
                        },
                      ),
                      if (hasMore)
                        SliverPadding(
                          padding: const EdgeInsets.only(top: 48),
                          sliver: SliverToBoxAdapter(
                            child: ElevatedButton(
                              onPressed: () {
                                ref.read(displayLimitProvider.notifier).increment(20);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                foregroundColor: theme.colorScheme.primary,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: Text(
                                strings.loadMore,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
                loading: () => const SliverToBoxAdapter(child: SharedGridSkeleton(rows: 2)),
                error: (err, stack) {
                  return SliverToBoxAdapter(
                    child: SharedErrorState(
                      message: strings.failedToLoad,
                      onRetry: () => ref.invalidate(filteredShortcutsProvider),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
      ],
    );
  }
}

class AppFilterChips extends ConsumerWidget {
  const AppFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedApp = ref.watch(selectedAppProvider);
    final appsAsync = ref.watch(featuredAppsProvider);

    return appsAsync.when(
      data: (apps) {
        final allChips = [
          _buildChip(context, ref, theme, 'All', 'all', selectedApp == 'all'),
          ...apps.map((app) => _buildChip(context, ref, theme, app.name, app.slug, selectedApp == app.slug)),
        ];

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: allChips.map((chip) => Padding(padding: const EdgeInsets.only(right: 8.0), child: chip)).toList(),
          ),
        );
      },
      loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator())),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildChip(BuildContext context, WidgetRef ref, ThemeData theme, String label, String slug, bool isSelected) {
    return InkWell(
      onTap: () {
        ref.read(selectedAppProvider.notifier).update(slug);
        ref.read(displayLimitProvider.notifier).reset(); // Reset pagination
      },
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        constraints: const BoxConstraints(minHeight: 48),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class BookmarksFilterToggle extends ConsumerWidget {
  const BookmarksFilterToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    final isBookmarksOnly = ref.watch(bookmarksOnlyProvider);

    return InkWell(
      onTap: () {
        ref.read(bookmarksOnlyProvider.notifier).toggle();
      },
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        constraints: const BoxConstraints(minHeight: 48),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isBookmarksOnly ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isBookmarksOnly ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isBookmarksOnly ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              size: 18,
              color: isBookmarksOnly ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
            Text(
              strings.bookmarksOnly,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isBookmarksOnly ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                fontWeight: isBookmarksOnly ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
