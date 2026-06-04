import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/localization_provider.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/providers/platform_provider.dart';
import '../../../core/providers/theme_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'onboarding_modal.dart';
import '../../../shared/widgets/app_navbar.dart';

class HomeFooter extends ConsumerWidget {
  const HomeFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    final isArabic = ref.watch(localizationProvider) == 'ar';

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 768;
                  
                  if (isMobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBrand(theme, strings),
                        const SizedBox(height: 48),
                        _buildLinks(context, theme, strings, isMobile: true),
                      ],
                    );
                  }
                  
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildBrand(theme, strings)),
                      const SizedBox(width: 64),
                      Expanded(flex: 3, child: _buildLinks(context, theme, strings, isMobile: false)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 48),
              Divider(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                height: 1,
              ),
              const SizedBox(height: 32),
              _buildMetaRow(context, theme, strings, isArabic, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrand(ThemeData theme, AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/logos/adobe.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(theme.colorScheme.primary, BlendMode.srcIn),
            ),
            const SizedBox(width: 12),
            Text(
              'Adobe Shortcut',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          strings.footerDesc,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLinks(BuildContext context, ThemeData theme, AppStrings strings, {required bool isMobile}) {
    final links = [
      _FooterLink(title: strings.home, onTap: () => context.go(RoutePaths.home)),
      _FooterLink(title: strings.apps, onTap: () => showDialog(context: context, builder: (context) => const AppsModal())), 
      _FooterLink(title: strings.shortcuts, onTap: () => context.go(RoutePaths.shortcuts)), 
      _FooterLink(title: strings.bookmarks, onTap: () => context.go(RoutePaths.bookmarks)),
      _FooterLink(title: strings.about, onTap: () => context.go(RoutePaths.about)),
    ];

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: links.map((link) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _LinkWidget(link: link, theme: theme),
        )).toList(),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: links.map((link) => Padding(
        padding: const EdgeInsets.only(left: 32.0),
        child: _LinkWidget(link: link, theme: theme),
      )).toList(),
    );
  }

  Widget _buildMetaRow(BuildContext context, ThemeData theme, AppStrings strings, bool isArabic, WidgetRef ref) {
    final currentYear = DateTime.now().year;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        
        final metaContent = [
          Text(
            '© $currentYear Adobe Shortcut',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          if (!isMobile) _buildDot(theme),
          Text(
            strings.footerBuiltWith,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          if (!isMobile) _buildDot(theme),
          Text(
            strings.footerVersion,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ];

        final preferencesContent = Consumer(
          builder: (context, ref, _) {
            final themeMode = ref.watch(themeProvider);
            final platformStr = ref.watch(platformProvider) ?? 'both';
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPreferenceChip(theme, themeMode == ThemeMode.dark ? strings.dark : (themeMode == ThemeMode.light ? strings.light : 'System')),
                const SizedBox(width: 8),
                _buildPreferenceChip(theme, isArabic ? 'العربية' : 'English'),
                const SizedBox(width: 8),
                _buildPreferenceChip(theme, platformStr == 'windows' ? 'Windows' : (platformStr == 'macos' ? 'macOS' : strings.both)),
                const SizedBox(width: 16),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                      width: 1.0,
                    ),
                  ),
                  child: IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/setting.svg',
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(
                        theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const OnboardingModal(isSettingsMode: true),
                      );
                    },
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    splashRadius: 24,
                    hoverColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    tooltip: 'Settings',
                  ),
                ),
              ],
            );
          }
        );

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...metaContent.whereType<Text>().map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: e,
              )),
              const SizedBox(height: 16),
              preferencesContent,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: metaContent,
            ),
            preferencesContent,
          ],
        );
      }
    );
  }

  Widget _buildDot(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildPreferenceChip(ThemeData theme, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FooterLink {
  final String title;
  final VoidCallback onTap;

  _FooterLink({required this.title, required this.onTap});
}

class _LinkWidget extends StatefulWidget {
  final _FooterLink link;
  final ThemeData theme;

  const _LinkWidget({required this.link, required this.theme});

  @override
  State<_LinkWidget> createState() => _LinkWidgetState();
}

class _LinkWidgetState extends State<_LinkWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.link.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: widget.theme.textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w600,
            color: _isHovered 
                ? widget.theme.colorScheme.primary 
                : widget.theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          child: Text(widget.link.title),
        ),
      ),
    );
  }
}
