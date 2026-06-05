// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
