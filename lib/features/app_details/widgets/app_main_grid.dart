import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/models/shortcut_model.dart';
import '../../../../core/providers/platform_provider.dart';
import '../../home/widgets/featured_shortcut_card.dart';
import '../../../shared/widgets/shared_empty_state.dart';
import '../../../shared/widgets/shared_error_state.dart';
import '../../../shared/widgets/shared_grid_skeleton.dart';
import '../providers/app_details_provider.dart';

class AppMainGrid extends ConsumerWidget {
  final String appSlug;

  const AppMainGrid({super.key, required this.appSlug});

  int _getColumns(double width) {
    if (width >= 1200) return 5;
    if (width >= 900) return 3;
    if (width >= 600) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    final languageCode = ref.watch(localizationProvider);
    final resultsAsync = ref.watch(filteredAppShortcutsProvider(appSlug));
    final selectedCategory = ref.watch(appCategoryProvider);
    
    return Consumer(
      builder: (context, ref, child) {
        final platform = ref.watch(platformProvider);

        // OPTIMIZATION: Use .value to prevent skeleton loaders during reload!
        final results = resultsAsync.value;

        if (results != null) {
          bool isFeaturedVisible = selectedCategory.toLowerCase() == 'all';
          
          List<ShortcutModel> remaining;
          if (isFeaturedVisible) {
            remaining = results.skip(5).toList();
          } else {
            remaining = results;
          }

          if (results.isEmpty) {
            final app = ref.read(currentAppProvider(appSlug)).value;
            final appName = app?.name ?? 'App';
            return SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 64),
              sliver: SliverToBoxAdapter(
                child: SharedEmptyState(
                  message: strings.noAppShortcutsFound.replaceAll('{app}', appName),
                  iconData: Icons.search_off,
                ),
              ),
            );
          }

          if (remaining.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink()); // All results fit in featured

          return SliverMainAxisGroup(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(top: isFeaturedVisible ? 0 : 32, left: 24, right: 24),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Text(
                        selectedCategory.toLowerCase() == 'all'
                            ? strings.browseAllShortcuts
                            : strings.browseCategoryShortcuts.replaceAll('{category}', selectedCategory),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        strings.resultsFound.replaceAll('{count}', remaining.length.toString()),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(left: 24, right: 24),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    int columns = _getColumns(constraints.crossAxisExtent);
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
                            key: ValueKey(remaining[index].id),
                            item: remaining[index],
                            theme: theme,
                            strings: strings,
                            languageCode: languageCode,
                            platform: platform,
                          );
                        },
                        childCount: remaining.length,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        if (resultsAsync.isLoading) {
          return const SliverPadding(
            padding: EdgeInsets.only(top: 24, left: 24, right: 24),
            sliver: SliverToBoxAdapter(child: SharedGridSkeleton(rows: 2)),
          );
        }

        return SliverToBoxAdapter(
          child: SharedErrorState(
            message: strings.failedToLoad,
            onRetry: () => ref.invalidate(filteredAppShortcutsProvider(appSlug)),
          ),
        );
      },
    );
  }
}
