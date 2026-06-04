import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SharedEmptyState extends StatelessWidget {
  final String message;
  final String? description;
  final String? iconPath;
  final IconData? iconData;

  const SharedEmptyState({
    super.key,
    required this.message,
    this.description,
    this.iconPath,
    this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconPath != null)
              SvgPicture.asset(
                iconPath!,
                width: 48,
                height: 48,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  BlendMode.srcIn,
                ),
              )
            else
              Icon(
                iconData ?? Icons.inbox_outlined,
                size: 48,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
