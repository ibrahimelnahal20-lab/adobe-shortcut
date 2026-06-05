// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/router/route_paths.dart';
import '../../features/home/widgets/onboarding_modal.dart';
import '../../core/localization/localization_provider.dart';
import '../../core/models/adobe_app_model.dart';

class AppNavbar extends ConsumerStatefulWidget {
  final Widget child;
  const AppNavbar({super.key, required this.child});

  @override
  ConsumerState<AppNavbar> createState() => _AppNavbarState();
}

class _AppNavbarState extends ConsumerState<AppNavbar> {
  final ValueNotifier<bool> _isScrolledNotifier = ValueNotifier<bool>(false);
  

  @override
  void dispose() {
    _isScrolledNotifier.dispose();
    super.dispose();
  }

  

  void _openSettings() {
    showDialog(
      context: context,
      builder: (context) => const OnboardingModal(isSettingsMode: true),
    );
  }

  Widget _buildNavItem(String title, String path) {
    String currentPath = '/';
    try {
      currentPath = GoRouterState.of(context).uri.path;
    } catch (_) {}

    final bool isActive = currentPath == path;

    return PremiumNavItem(
      title: title,
      isActive: isActive,
      onTap: () => context.go(path),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.axis == Axis.vertical) {
                final isScrolled = notification.metrics.pixels > 10;
                if (isScrolled != _isScrolledNotifier.value) {
                  _isScrolledNotifier.value = isScrolled;
                }
              }
              return false;
            },
            child: widget.child,
          ),

          Positioned(
            top: 24,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 32.0, sigmaY: 32.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = MediaQuery.of(context).size.width;
                      final isDesktop = width >= 1024;
                      final isTablet = width >= 768 && width < 1024;
                      final isMobile = width < 768;

                      final logoSize = isDesktop
                          ? 22.0
                          : (isTablet ? 18.0 : 16.0);
                      final logoSpacing = isDesktop
                          ? 64.0
                          : (isTablet ? 32.0 : 16.0);
                      final navSpacing = isDesktop ? 2.0 : 0.0;

                      return ValueListenableBuilder<bool>(
                        valueListenable: _isScrolledNotifier,
                        builder: (context, isScrolled, child) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            constraints: const BoxConstraints(maxWidth: 1000),
                            height: 62,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.colorScheme.surface.withOpacity(
                                    isScrolled ? 0.65 : 0.85,
                                  ),
                                  theme.colorScheme.surface.withOpacity(
                                    isScrolled ? 0.45 : 0.70,
                                  ),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(
                                  isScrolled ? 0.15 : 0.05,
                                ),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.shadowColor.withOpacity(
                                    isScrolled ? 0.12 : 0.04,
                                  ),
                                  blurRadius: 40,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : 24,
                            ),
                            child: Row(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/Logos/adobe.svg",
                                      width: logoSize,
                                      height: logoSize,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "Adobe Shortcut",
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.onSurface,
                                            letterSpacing: 0,
                                            fontSize: isDesktop
                                                ? 26
                                                : (isTablet ? 22 : 18),
                                          ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: logoSpacing),
                                Expanded(
                                  child: Center(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _buildNavItem(
                                            strings.home,
                                            RoutePaths.home,
                                          ),
                                          SizedBox(width: navSpacing),
                                          const AppsMenuToggleBtn(),
                                          SizedBox(width: navSpacing),

                                          _buildNavItem(
                                            strings.shortcuts,
                                            RoutePaths.shortcuts,
                                          ),
                                          SizedBox(width: navSpacing),
                                          _buildNavItem(
                                            strings.bookmarks,
                                            RoutePaths.bookmarks,
                                          ),
                                          SizedBox(width: navSpacing),
                                          _buildNavItem(
                                            strings.about,
                                            RoutePaths.about,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: theme.colorScheme.outline
                                          .withOpacity(0.1),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: SvgPicture.asset(
                                      'assets/Icons/setting.svg',
                                      width: 22,
                                      height: 22,
                                      colorFilter: ColorFilter.mode(
                                        theme.colorScheme.onSurface.withOpacity(0.8),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    onPressed: _openSettings,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.8),
                                    splashRadius: 24,
                                    hoverColor: theme.colorScheme.onSurface
                                        .withOpacity(0.05),
                                    tooltip: 'Settings',
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppsMenuToggleBtn extends ConsumerStatefulWidget {
  const AppsMenuToggleBtn({super.key});

  @override
  ConsumerState<AppsMenuToggleBtn> createState() => _AppsMenuToggleBtnState();
}

class _AppsMenuToggleBtnState extends ConsumerState<AppsMenuToggleBtn> {
  bool _isAppsHovered = false;

  void _openAppsModal() {
    showDialog(
      context: context,
      builder: (context) => const AppsModal(),
    );
  }

  void _precacheModalAssets() {
    for (final app in AdobeAppRegistry.featuredApps) {
      if (app.svgPath.isNotEmpty) {
        final loader = SvgAssetLoader(app.svgPath);
        svg.cache.putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: _openAppsModal,
      onHover: (val) {
        setState(() => _isAppsHovered = val);
        if (val) {
          // Lazy cache assets on first hover
          _precacheModalAssets();
        }
      },
      borderRadius: BorderRadius.circular(100),
      hoverColor: Colors.transparent,
      splashColor: theme.colorScheme.primary.withOpacity(0.05),
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: _isAppsHovered
              ? theme.colorScheme.primary.withOpacity(0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ref.watch(appStringsProvider).apps,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: _isAppsHovered
                    ? FontWeight.bold
                    : FontWeight.w500,
                color: _isAppsHovered
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PremiumNavItem extends StatefulWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const PremiumNavItem({
    super.key,
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<PremiumNavItem> createState() => _PremiumNavItemState();
}

class _PremiumNavItemState extends State<PremiumNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: widget.onTap,
      onHover: (val) => setState(() => _isHovered = val),
      borderRadius: BorderRadius.circular(100),
      hoverColor: Colors.transparent,
      splashColor: theme.colorScheme.primary.withOpacity(0.05),
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: widget.isActive
              ? theme.colorScheme.primary.withOpacity(0.05)
              : _isHovered
              ? theme.colorScheme.onSurface.withOpacity(0.03)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          widget.title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: widget.isActive ? FontWeight.bold : FontWeight.w500,
            color: widget.isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(
                    _isHovered ? 1.0 : 0.8,
                  ),
          ),
        ),
      ),
    );
  }
}

class PremiumAppCard extends StatefulWidget {
  final String assetPath;
  final String label;
  final Color color;
  final String exploreText;
  final VoidCallback? onTap;

  const PremiumAppCard({
    super.key,
    required this.assetPath,
    required this.label,
    required this.color,
    required this.exploreText,
    this.onTap,
  });

  @override
  State<PremiumAppCard> createState() => _PremiumAppCardState();
}

class _PremiumAppCardState extends State<PremiumAppCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: widget.onTap ?? () {},
      onHover: (val) => setState(() => _isHovered = val),
      borderRadius: BorderRadius.circular(24),
      hoverColor: Colors.transparent,
      splashColor: widget.color.withOpacity(0.1),
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        transform: Matrix4.translationValues(0, _isHovered ? -8 : 0, 0),
        decoration: BoxDecoration(
          color: _isHovered
              ? widget.color.withOpacity(0.04)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutCubic,
              scale: _isHovered ? 1.05 : 1.0,
              child: widget.assetPath.isNotEmpty
                  ? SvgPicture.asset(
                      widget.assetPath,
                      width: 48, // Smaller icon
                      height: 48,
                      fit: BoxFit.contain,
                    )
                  : Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.apps, size: 32, color: widget.color),
                    ),
            ),
            const SizedBox(height: 12), // Less spacing
            Text(
              widget.label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: _isHovered ? FontWeight.bold : FontWeight.w600,
                color: _isHovered
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withOpacity(0.85),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isHovered ? 1.0 : 0.0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.exploreText,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: widget.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedPadding(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.only(left: _isHovered ? 4 : 0),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: widget.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class AppsModal extends ConsumerWidget {
  const AppsModal({super.key});

  Color _getAppColor(String slug) {
    switch (slug) {
      case 'photoshop': return const Color(0xFF31A8FF);
      case 'illustrator': return const Color(0xFFFF9A00);
      case 'after-effects': return const Color(0xFF9999FF);
      case 'premiere-pro': return const Color(0xFFEA77FF);
      case 'lightroom': return const Color(0xFF31A8FF);
      case 'indesign': return const Color(0xFFFF3366);
      case 'audition': return const Color(0xFF00E676);
      case 'davinci-resolve': return const Color(0xFFE57373);
      case 'fl-studio': return const Color(0xFFFF9800);
      default: return const Color(0xFF31A8FF);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 960),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 24, 40, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref.watch(appStringsProvider).adobeApplications,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ref.watch(appStringsProvider).accessShortcuts,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: AdobeAppRegistry.featuredApps.map((appItem) {
                  return SizedBox(
                    width: (960 - 48 - 32) / 4 - 8,
                    child: PremiumAppCard(
                      assetPath: appItem.svgPath,
                      label: appItem.name,
                      color: _getAppColor(appItem.slug),
                      exploreText: ref.watch(appStringsProvider).explore,
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go('/apps/${appItem.slug}');
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            Divider(
              height: 1,
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 40.0,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.02),
              ),
              child: Center(
                child: Text(
                  ref.watch(appStringsProvider).chooseAdobeApp,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

