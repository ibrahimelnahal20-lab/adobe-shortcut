import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/models/app_model.dart';
import '../../../../core/providers/apps_provider.dart';
import '../../home/widgets/featured_app_card.dart';
import '../../../shared/widgets/shared_grid_skeleton.dart';

class AppRelatedApps extends ConsumerWidget {
  final AppModel currentApp;

  const AppRelatedApps({super.key, required this.currentApp});

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
    final appsAsync = ref.watch(featuredAppsProvider);

    return appsAsync.when(
      data: (apps) {
        // Filter out current app
        var related = apps.where((a) => a.slug != currentApp.slug).toList();
        
        // Priority logic could be complex (e.g. video to video), for now just take top 4
        final displayApps = related.take(4).toList();

        if (displayApps.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 80, left: 24, right: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.relatedApps,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, constraints) {
                  int columns = _getColumns(constraints.maxWidth);
                  if (columns > displayApps.length) columns = displayApps.length;
                  if (columns == 0) columns = 1;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 24,
                      mainAxisExtent: 280,
                    ),
                    itemCount: displayApps.length,
                    itemBuilder: (context, index) {
                      return FeaturedAppCard(
                        key: ValueKey(displayApps[index].slug),
                        app: displayApps[index],
                        theme: theme,
                        strings: strings,
                        onTap: () => context.push('/apps/${displayApps[index].slug}'),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 80, left: 24, right: 24),
        child: SharedGridSkeleton(rows: 1, isAppCard: true),
      ),
      error: (_, stack) => const SizedBox.shrink(),
    );
  }
}
