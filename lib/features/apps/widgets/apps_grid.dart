import 'package:adobeshortcuts/core/localization/localization_provider.dart'
    show appStringsProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/adobe_app_model.dart';
import '../../../shared/widgets/premium_app_card.dart';

class AppsGrid extends ConsumerWidget {
  final bool isMobile;
  final VoidCallback? onAppSelected;

  const AppsGrid({super.key, required this.isMobile, this.onAppSelected});

  Color _getAppColor(String slug) {
    switch (slug) {
      case 'photoshop':
        return const Color(0xFF31A8FF);
      case 'illustrator':
        return const Color(0xFFFF9A00);
      case 'after-effects':
        return const Color(0xFF9999FF);
      case 'premiere-pro':
        return const Color(0xFFEA77FF);
      case 'lightroom':
        return const Color(0xFF31A8FF);
      case 'indesign':
        return const Color(0xFFFF3366);
      case 'audition':
        return const Color(0xFF00E676);
      case 'davinci-resolve':
        return const Color(0xFFE57373);
      case 'fl-studio':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF31A8FF);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);

    if (isMobile) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          mainAxisExtent: 160,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: AdobeAppRegistry.featuredApps.length,
        itemBuilder: (context, index) {
          final appItem = AdobeAppRegistry.featuredApps[index];
          return PremiumAppCard(
            key: ValueKey(appItem.slug),
            assetPath: appItem.svgPath,
            label: appItem.name,
            color: _getAppColor(appItem.slug),
            exploreText: strings.explore,
            onTap: () {
              onAppSelected?.call();
              context.go('/apps/${appItem.slug}');
            },
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = 4;
        final spacing = 8.0;
        final availableWidth = constraints.maxWidth;
        final itemWidth =
            (availableWidth - (spacing * (crossAxisCount - 1))) /
            crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.center,
          children: AdobeAppRegistry.featuredApps.map((appItem) {
            return SizedBox(
              width: itemWidth,
              child: PremiumAppCard(
                assetPath: appItem.svgPath,
                label: appItem.name,
                color: _getAppColor(appItem.slug),
                exploreText: strings.explore,
                onTap: () {
                  onAppSelected?.call();
                  context.go('/apps/${appItem.slug}');
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
