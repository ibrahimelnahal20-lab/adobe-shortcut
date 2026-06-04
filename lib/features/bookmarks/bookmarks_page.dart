import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/localization_provider.dart';
import '../../core/providers/bookmarks_provider.dart';
import '../../features/shortcuts/providers/shortcuts_providers.dart';
import '../../core/providers/apps_provider.dart';
import '../../core/models/shortcut_model.dart';
import '../../core/providers/platform_provider.dart';
import '../home/widgets/featured_shortcut_card.dart';
import '../../shared/widgets/shared_empty_state.dart';
import '../../shared/widgets/shared_error_state.dart';
import '../../shared/widgets/shared_grid_skeleton.dart';
import '../../features/shortcuts/widgets/text_search_bar.dart';
import '../../features/shortcuts/widgets/search_mode_switch.dart';
import '../../features/shortcuts/widgets/key_recorder_widget.dart';
import '../../shared/widgets/shared_translation_notice.dart';

class BookmarksPage extends ConsumerWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    final languageCode = ref.watch(localizationProvider);
    final bookmarks = ref.watch(bookmarksProvider);
    final selectedApp = ref.watch(bookmarksSelectedAppProvider);

    return CustomScrollView(
      slivers: [
        const SliverPadding(padding: EdgeInsets.only(top: 140)),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                strings.bookmarks,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${bookmarks.length} ${strings.savedShortcuts}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: Consumer(
            builder: (context, ref, child) {
              final platform = ref.watch(platformProvider);
              final baseAsync = ref.watch(bookmarkedShortcutsProvider);
              final filteredAsync = ref.watch(filteredBookmarkedShortcutsProvider);

              return baseAsync.when(
                data: (baseShortcuts) {
                    if (baseShortcuts.isEmpty) {
                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(vertical: 64),
                        sliver: SliverToBoxAdapter(
                          child: SharedEmptyState(
                            message: strings.noSavedShortcuts,
                            description: strings.noSavedShortcutsDesc,
                            iconPath: 'assets/Icons/bookmark.svg',
                          ),
                        ),
                      );
                    }

                    final uniqueAppsCount = baseShortcuts.map((s) => s.app).toSet().length;
                    final shouldShowFilter = baseShortcuts.length > 10 && uniqueAppsCount >= 3;
                    final shouldShowSearch = baseShortcuts.length >= 25;

                    // Fallback logic
                    if (selectedApp != 'all') {
                      final hasBookmarks = baseShortcuts.any((s) => s.app == selectedApp);
                      if (!hasBookmarks || !shouldShowFilter) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ref.read(bookmarksSelectedAppProvider.notifier).setApp('all');
                        });
                      }
                    }

                    if (!shouldShowSearch) {
                      final currentQuery = ref.read(searchQueryProvider);
                      final currentMode = ref.read(searchModeProvider);
                      if (currentQuery.isNotEmpty || currentMode != SearchMode.text) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ref.read(searchQueryProvider.notifier).update('');
                          ref.read(searchModeProvider.notifier).setMode(SearchMode.text);
                        });
                      }
                    }

                    return SliverMainAxisGroup(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                child: shouldShowSearch
                                    ? Column(
                                        children: [
                                          const SearchModeSwitch(),
                                          const SizedBox(height: 32),
                                          Consumer(
                                            builder: (context, ref, child) {
                                              final mode = ref.watch(searchModeProvider);
                                              if (mode == SearchMode.keys) {
                                                return const KeyRecorderWidget();
                                              }
                                              return const TextSearchBar();
                                            },
                                          ),
                                          const SharedTranslationNotice(),
                                          const SizedBox(height: 32),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              if (shouldShowFilter) ...[
                                BookmarksAppFilterChips(bookmarkedShortcuts: baseShortcuts),
                                const SizedBox(height: 32),
                              ],
                            ],
                          ),
                        ),
                        filteredAsync.when(
                          data: (displayedResults) {
                            if (displayedResults.isEmpty) {
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

                            return SliverLayoutBuilder(
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
                                    mainAxisSpacing: 24,
                                    crossAxisSpacing: 24,
                                    mainAxisExtent: 280,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      return FeaturedShortcutCard(
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
                            );
                          },
                          loading: () => const SliverToBoxAdapter(child: SharedGridSkeleton(rows: 2)),
                          error: (err, stack) {
                            return SliverToBoxAdapter(
                              child: SharedErrorState(
                                message: strings.failedToLoad,
                                onRetry: () => ref.invalidate(filteredBookmarkedShortcutsProvider),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                  loading: () => const SliverToBoxAdapter(child: SharedGridSkeleton(rows: 2)),
                  error: (err, stack) {
                    return SliverToBoxAdapter(
                      child: SharedErrorState(
                        message: strings.failedToLoad,
                        onRetry: () => ref.invalidate(bookmarkedShortcutsProvider),
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

class BookmarksAppFilterChips extends ConsumerWidget {
  final List<ShortcutModel> bookmarkedShortcuts;

  const BookmarksAppFilterChips({super.key, required this.bookmarkedShortcuts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedApp = ref.watch(bookmarksSelectedAppProvider);
    final appsAsync = ref.watch(featuredAppsProvider);

    return appsAsync.when(
      data: (apps) {
        final Map<String, int> counts = {};
        for (final s in bookmarkedShortcuts) {
          counts[s.app] = (counts[s.app] ?? 0) + 1;
        }

        final availableApps = apps.where((a) => (counts[a.slug] ?? 0) > 0).toList();

        final allChips = [
          _buildChip(context, ref, theme, 'All', 'all', selectedApp == 'all'),
          ...availableApps.map((app) => _buildChip(context, ref, theme, '${app.name} (${counts[app.slug]})', app.slug, selectedApp == app.slug)),
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
        ref.read(bookmarksSelectedAppProvider.notifier).setApp(slug);
      },
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
