// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/localization_provider.dart';
import '../../../core/providers/apps_provider.dart';
import '../../../shared/widgets/shared_empty_state.dart';
import '../../../shared/widgets/shared_error_state.dart';
import '../../../shared/widgets/shared_grid_skeleton.dart';
import 'featured_app_card.dart';

class FeaturedAppsSection extends ConsumerWidget {
  const FeaturedAppsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);

    final isMobile = MediaQuery.of(context).size.width < 600;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            strings.featuredAppsTitle,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            strings.featuredAppsDesc,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 64),
          ref.watch(featuredAppsProvider).when(
            data: (apps) {
              if (apps.isEmpty) {
                return SharedEmptyState(
                  message: strings.noFeaturedApps,
                  iconData: Icons.grid_view_outlined,
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
                    itemCount: apps.length,
                    itemBuilder: (context, index) {
                      return FeaturedAppCard(
                        key: ValueKey(apps[index].slug),
                        app: apps[index],
                        theme: theme,
                        strings: strings,
                        onTap: () {
                          context.go('/apps/${apps[index].slug}');
                        },
                      );
                    },
                  );
                },
              );
            },
            loading: () => const SharedGridSkeleton(rows: 1, isAppCard: true),
            error: (err, stack) => SharedErrorState(
              message: '${strings.errorPrefix} $err',
              onRetry: () => ref.invalidate(featuredAppsProvider),
            ),
          ),
        ],
      ),
    );
  }
}
