import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/models/app_model.dart';
import '../../../../core/models/adobe_app_model.dart';
import '../providers/app_details_provider.dart';

class AppHeroSection extends ConsumerWidget {
  final AppModel app;

  const AppHeroSection({super.key, required this.app});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    final statsAsync = ref.watch(appStatsProvider(app.slug));

    AdobeAppItem? appItem;
    try {
      appItem = AdobeAppRegistry.featuredApps.firstWhere((a) => a.slug == app.slug);
    } catch (_) {}

    String description = '';
    if (appItem != null) {
      switch (appItem.slug.toLowerCase()) {
        case 'photoshop': description = strings.photoshopDesc; break;
        case 'illustrator': description = strings.illustratorDesc; break;
        case 'after-effects': description = strings.afterEffectsDesc; break;
        case 'premiere-pro': description = strings.premiereProDesc; break;
        case 'lightroom': description = strings.lightroomDesc; break;
        case 'indesign': description = strings.indesignDesc; break;
        case 'audition': description = strings.auditionDesc; break;
        case 'davinci-resolve': description = strings.davinciResolveDesc; break;
        case 'fl-studio': description = strings.flStudioDesc; break;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          if (appItem != null && appItem.svgPath.isNotEmpty)
            SvgPicture.asset(appItem.svgPath, width: 80, height: 80)
          else
            Icon(Icons.apps, size: 80, color: theme.colorScheme.primary),
          
          const SizedBox(height: 24),
          Text(
            app.name,
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (description.isNotEmpty)
            Text(
              description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 32),
          
          // Stats Row
          statsAsync.when(
            data: (stats) {
              final List<String> parts = [];
              parts.add(strings.appShortcutsCount.replaceAll('{count}', stats.totalShortcuts.toString()));
              parts.add(strings.appCategoriesCount.replaceAll('{count}', stats.categories.length.toString()));
              
              if (stats.windowsSupported && stats.macSupported) {
                parts.add(strings.supportedOn.replaceAll('{platform}', '${strings.windows} + ${strings.macOS}'));
              } else if (stats.windowsSupported) {
                parts.add(strings.supportedOn.replaceAll('{platform}', strings.windows));
              } else if (stats.macSupported) {
                parts.add(strings.supportedOn.replaceAll('{platform}', strings.macOS));
              }

              return Text(
                parts.join(' • '),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              );
            },
            loading: () => const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)),
            error: (_, stack) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
