// ignore_for_file: deprecated_member_use
import 'dart:ui';
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
                  if (width < 600) {
                    final itemWidth = (width * 0.75).clamp(200.0, 280.0);
                    return SizedBox(
                      height: 240,
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                            PointerDeviceKind.trackpad,
                          },
                        ),
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          itemCount: apps.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: itemWidth,
                            child: FeaturedAppCard(
                              key: ValueKey(apps[index].slug),
                              app: apps[index],
                              theme: theme,
                              strings: strings,
                              onTap: () {
                                context.go('/apps/${apps[index].slug}');
                              },
                            ),
                          );
                        },
                      ),
                     ),
                    );
                  }

                  int columns = 1;
                  if (width >= 1200) {
                    columns = 5;
                  } else if (width >= 900) {
                    columns = 3;
                  } else {
                    columns = 2;
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 24,
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
