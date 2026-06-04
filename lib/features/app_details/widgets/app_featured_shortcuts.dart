import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/providers/platform_provider.dart';
import '../../home/widgets/featured_shortcut_card.dart';
import '../../../shared/widgets/shared_grid_skeleton.dart';
import '../providers/app_details_provider.dart';

class AppFeaturedShortcuts extends ConsumerWidget {
  final String appSlug;

  const AppFeaturedShortcuts({super.key, required this.appSlug});

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

    if (selectedCategory.toLowerCase() != 'all') {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return Consumer(
      builder: (context, ref, child) {
        final platform = ref.watch(platformProvider);
        
        // OPTIMIZATION: Use .value to prevent skeleton loaders during reload!
        final results = resultsAsync.value;
        
        if (results != null) {
          if (results.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
          
          final displayResults = results.take(5).toList();

          return SliverMainAxisGroup(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 24),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    strings.featuredShortcutsTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
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
                            item: displayResults[index],
                            theme: theme,
                            strings: strings,
                            languageCode: languageCode,
                            platform: platform,
                          );
                        },
                        childCount: displayResults.length,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        // Only show skeleton on first load or hard error
        if (resultsAsync.isLoading) {
          return const SliverPadding(
            padding: EdgeInsets.only(top: 24, left: 24, right: 24),
            sliver: SliverToBoxAdapter(child: SharedGridSkeleton(rows: 1)),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }
    );
  }
}
