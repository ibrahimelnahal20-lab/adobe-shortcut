// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/localization_provider.dart';
import '../../../core/providers/featured_shortcuts_provider.dart';
import '../../../core/providers/platform_provider.dart';
import '../../../shared/widgets/shared_empty_state.dart';
import '../../../shared/widgets/shared_error_state.dart';
import '../../../shared/widgets/shared_grid_skeleton.dart';
import 'featured_shortcut_card.dart';

class FeaturedShortcutsSection extends ConsumerWidget {
  const FeaturedShortcutsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    final languageCode = ref.watch(localizationProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            strings.featuredShortcutsTitle,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            strings.featuredShortcutsDesc,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 64),
          Consumer(
            builder: (context, ref, child) {
              final platform = ref.watch(platformProvider);
              final shortcutsAsync = ref.watch(featuredShortcutsProvider);

              return shortcutsAsync.when(
                data: (allShortcuts) {
                  if (allShortcuts.isEmpty) {
                    return SharedEmptyState(
                      message: strings.noResultsFound,
                      iconData: Icons.search_off,
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      int columns = 1;
                      if (width >= 1200) {
                        columns = 5;
                      } else if (width >= 900) {
                        columns = 3;
                      } else if (width >= 600) {
                        columns = 2;
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: columns == 1 ? 16 : 24,
                          crossAxisSpacing: columns == 1 ? 16 : 24,
                          mainAxisExtent: 280,
                        ),
                        itemCount: allShortcuts.length,
                        itemBuilder: (context, index) {
                          return FeaturedShortcutCard(
                            key: ValueKey(allShortcuts[index].id),
                            item: allShortcuts[index],
                            theme: theme,
                            strings: strings,
                            languageCode: languageCode,
                            platform: platform,
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const SharedGridSkeleton(rows: 2),
                error: (err, stack) {
                  debugPrint(err.toString());
                  return SharedErrorState(
                    message: strings.failedToLoad,
                    onRetry: () => ref.invalidate(featuredShortcutsProvider),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
