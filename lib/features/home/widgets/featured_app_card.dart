// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/models/app_model.dart';

class FeaturedAppCard extends StatefulWidget {
  final AppModel app;
  final ThemeData theme;
  final dynamic strings;
  final VoidCallback onTap;

  const FeaturedAppCard({
    super.key,
    required this.app,
    required this.theme,
    required this.strings,
    required this.onTap,
  });

  @override
  State<FeaturedAppCard> createState() => _FeaturedAppCardState();
}

class _FeaturedAppCardState extends State<FeaturedAppCard> {
  bool _isHovered = false;

  String _getDescription() {
    switch (widget.app.slug.toLowerCase()) {
      case 'photoshop': return widget.strings.photoshopDesc;
      case 'illustrator': return widget.strings.illustratorDesc;
      case 'after-effects': return widget.strings.afterEffectsDesc;
      case 'premiere-pro': return widget.strings.premiereProDesc;
      case 'lightroom': return widget.strings.lightroomDesc;
      case 'indesign': return widget.strings.indesignDesc;
      case 'audition': return widget.strings.auditionDesc;
      case 'davinci-resolve': return widget.strings.davinciResolveDesc;
      case 'fl-studio': return widget.strings.flStudioDesc;
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(24),
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          decoration: BoxDecoration(
            color: widget.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.theme.colorScheme.outline.withOpacity(_isHovered ? 0.3 : 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.theme.shadowColor.withOpacity(_isHovered ? 0.08 : 0.02),
                blurRadius: _isHovered ? 24 : 8,
                offset: Offset(0, _isHovered ? 12 : 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedScale(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    scale: _isHovered ? 1.05 : 1.0,
                    child: SvgPicture.asset(
                      'assets/Icons/${widget.app.icon}',
                      width: 48,
                      height: 48,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                widget.app.name,
                style: widget.theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  _getDescription(),
                  style: widget.theme.textTheme.bodyMedium?.copyWith(
                    color: widget.theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.strings.explore,
                    style: widget.theme.textTheme.labelLarge?.copyWith(
                      color: widget.theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isHovered ? 1.0 : 0.0,
                    child: AnimatedPadding(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      padding: EdgeInsets.only(left: _isHovered ? 4 : 0),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: widget.theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
