// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import '../../../core/localization/localization_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_paths.dart';

class HeroSection extends ConsumerStatefulWidget {
  const HeroSection({super.key});

  @override
  ConsumerState<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends ConsumerState<HeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedAppSlug;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
          ),
        );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildBadge(ThemeData theme, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, dynamic strings, {bool isMobile = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBadge(theme, strings.heroBadge),
        const SizedBox(height: 24),
        Text(
          strings.heroHeading,
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            height: 1.4,
            fontSize: isMobile ? 32 : null,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          strings.heroDescription,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.secondary,
            height: 1.6,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 40),
        _HeroSearchField(
          theme: theme,
          placeholder: strings.heroSearchPlaceholder,
          controller: _searchController,
          onSubmitted: _handleSearch,
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          clipBehavior: Clip.none,
          children: [
            _HeroAppChip(
              theme: theme,
              label: "Photoshop",
              svgPath: "assets/Icons/photoshop.svg",
              isSelected: _selectedAppSlug == 'photoshop',
              onTap: () => _toggleApp('photoshop'),
            ),
            _HeroAppChip(
              theme: theme,
              label: "Illustrator",
              svgPath: "assets/Icons/illustrator.svg",
              isSelected: _selectedAppSlug == 'illustrator',
              onTap: () => _toggleApp('illustrator'),
            ),
            _HeroAppChip(
              theme: theme,
              label: "After Effects",
              svgPath: "assets/Icons/aftereffects.svg",
              isSelected: _selectedAppSlug == 'after-effects',
              onTap: () => _toggleApp('after-effects'),
            ),
            _HeroAppChip(
              theme: theme,
              label: "Premiere Pro",
              svgPath: "assets/Icons/premiere.svg",
              isSelected: _selectedAppSlug == 'premiere-pro',
              onTap: () => _toggleApp('premiere-pro'),
            ),
            _HeroAppChip(
              theme: theme,
              label: "Lightroom",
              svgPath: "assets/Icons/lightroom.svg",
              isSelected: _selectedAppSlug == 'lightroom',
              onTap: () => _toggleApp('lightroom'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLottie(double maxWidth) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: RepaintBoundary(child: Lottie.asset('assets/lottie/hero.json', fit: BoxFit.contain)),
    );
  }

  void _toggleApp(String slug) {
    setState(() {
      if (_selectedAppSlug == slug) {
        _selectedAppSlug = null;
      } else {
        _selectedAppSlug = slug;
      }
    });
  }

  void _handleSearch(String query) {
    final q = query.trim();
    if (_selectedAppSlug == null) {
      if (q.isEmpty) {
        context.go(RoutePaths.shortcuts);
      } else {
        context.go('${RoutePaths.shortcuts}?q=$q');
      }
    } else {
      if (q.isEmpty) {
        context.go('/apps/$_selectedAppSlug');
      } else {
        context.go('/apps/$_selectedAppSlug?q=$q');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1024;
            final isTablet =
                constraints.maxWidth >= 768 && constraints.maxWidth < 1024;

            if (isDesktop || isTablet) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 64.0 : 32.0,
                  vertical: 64.0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildContent(context, theme, strings),
                    ),
                    SizedBox(width: isDesktop ? 48 : 32),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.center,
                        child: _buildLottie(isDesktop ? 520 : 420),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Mobile
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 48.0,
              ),
              child: Column(
                children: [
                  _buildContent(context, theme, strings, isMobile: true),
                  const SizedBox(height: 48),
                  _buildLottie(420),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeroSearchField extends StatefulWidget {
  final ThemeData theme;
  final String placeholder;
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  const _HeroSearchField({
    required this.theme,
    required this.placeholder,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  State<_HeroSearchField> createState() => _HeroSearchFieldState();
}

class _HeroSearchFieldState extends State<_HeroSearchField> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.text,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 64,
        decoration: BoxDecoration(
          color: widget.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: _isHovered
                ? widget.theme.colorScheme.primary
                : widget.theme.colorScheme.outline.withValues(alpha: 0.5),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? widget.theme.colorScheme.primary.withValues(alpha: 0.1)
                  : widget.theme.shadowColor.withValues(alpha: 0.05),
              blurRadius: _isHovered ? 24 : 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/Icons/search.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                _isHovered
                    ? widget.theme.colorScheme.primary
                    : widget.theme.colorScheme.secondary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: widget.controller,
                onSubmitted: widget.onSubmitted,
                textInputAction: TextInputAction.search,
                style: widget.theme.textTheme.bodyLarge?.copyWith(
                  color: widget.theme.colorScheme.onSurface,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: widget.theme.textTheme.bodyLarge?.copyWith(
                    color: widget.theme.colorScheme.tertiary,
                    fontSize: 18,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_isHovered)
              GestureDetector(
                onTap: () => widget.onSubmitted(widget.controller.text),
                child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: widget.theme.colorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Search',
                  style: widget.theme.textTheme.labelMedium?.copyWith(
                    color: widget.theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
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

class _HeroAppChip extends StatefulWidget {
  final ThemeData theme;
  final String label;
  final String svgPath;
  final bool isSelected;
  final VoidCallback onTap;

  const _HeroAppChip({
    required this.theme,
    required this.label,
    required this.svgPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_HeroAppChip> createState() => _HeroAppChipState();
}

class _HeroAppChipState extends State<_HeroAppChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected || _isHovered
                ? widget.theme.colorScheme.primary.withValues(alpha: widget.isSelected ? 0.15 : 0.05)
                : widget.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.isSelected || _isHovered
                  ? widget.theme.colorScheme.primary.withValues(alpha: widget.isSelected ? 0.5 : 0.3)
                  : widget.theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(widget.svgPath, width: 16, height: 16),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: widget.theme.textTheme.labelMedium?.copyWith(
                  color: widget.isSelected || _isHovered
                      ? widget.theme.colorScheme.primary
                      : widget.theme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
