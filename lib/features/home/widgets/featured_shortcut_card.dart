// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/models/shortcut_model.dart';
import '../../../core/models/adobe_app_model.dart';
import '../../../core/theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/bookmarks_provider.dart';

class FeaturedShortcutCard extends StatefulWidget {
  final ShortcutModel item;
  final ThemeData theme;
  final dynamic strings;
  final String languageCode;
  final String? platform;

  const FeaturedShortcutCard({
    super.key,
    required this.item,
    required this.theme,
    required this.strings,
    required this.languageCode,
    this.platform,
  });

  @override
  State<FeaturedShortcutCard> createState() => _FeaturedShortcutCardState();
}

class _FeaturedShortcutCardState extends State<FeaturedShortcutCard> {
  bool _isHovered = false;

  String _getCategoryLabel() {
    return widget.item.category;
  }

  AdobeAppItem? _getAppItem() {
    try {
      return AdobeAppRegistry.featuredApps.firstWhere(
        (a) => a.slug == widget.item.app,
      );
    } catch (e) {
      debugPrint(
        'Icon mapping failed for app: ${widget.item.app}. Using fallback.',
      );
      return null;
    }
  }

  Widget _buildCombination(String combination, ThemeData theme) {
    final keys = combination.split(' + ');
    final List<Widget> children = [];
    for (int i = 0; i < keys.length; i++) {
      children.add(_Keycap(label: keys[i], theme: theme));
      if (i < keys.length - 1) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '+',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        );
      }
    }
    return Directionality(
      textDirection: TextDirection.ltr,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }

  Widget _buildPlatformBlock(
    String badgeText,
    String shortcut,
    ThemeData theme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: Text(
            badgeText,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: _buildCombination(shortcut, theme)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.item.function;
    final appItem = _getAppItem();
    final svgPath = appItem?.svgPath ?? '';
    final appName = appItem?.name ?? widget.item.app;
    final effectivePlatform = widget.platform ?? 'both';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(24),
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: widget.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.theme.colorScheme.outline.withOpacity(
              _isHovered ? 0.3 : 0.1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: widget.theme.shadowColor.withOpacity(
                _isHovered ? 0.08 : 0.02,
              ),
              blurRadius: _isHovered ? 24 : 8,
              offset: Offset(0, _isHovered ? 12 : 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  scale: _isHovered ? 1.05 : 1.0,
                  child: svgPath.isNotEmpty
                      ? SvgPicture.asset(svgPath, width: 48, height: 48)
                      : Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: widget.theme.colorScheme.onSurface
                                .withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.apps,
                            color: widget.theme.colorScheme.onSurface
                                .withOpacity(0.4),
                            size: 24,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.theme.colorScheme.onSurface
                            .withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getCategoryLabel(),
                        style: widget.theme.textTheme.labelSmall
                            ?.copyWith(
                              color: widget.theme.colorScheme.onSurface
                                  .withOpacity(0.6),
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _BookmarkButton(
                  item: widget.item,
                  theme: widget.theme,
                  strings: widget.strings,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: widget.theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: widget.theme.colorScheme.onSurface,
                fontSize: 20,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              appName,
              style: widget.theme.textTheme.bodyMedium?.copyWith(
                color: widget.theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            if (effectivePlatform == 'windows')
              _buildPlatformBlock(
                widget.strings.windows,
                widget.item.windows,
                widget.theme,
              )
            else if (effectivePlatform == 'macos')
              _buildPlatformBlock(
                widget.strings.macOS,
                widget.item.mac,
                widget.theme,
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPlatformBlock(
                    widget.strings.windows,
                    widget.item.windows,
                    widget.theme,
                  ),
                  const SizedBox(height: 8),
                  _buildPlatformBlock(
                    widget.strings.macOS,
                    widget.item.mac,
                    widget.theme,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Keycap extends StatelessWidget {
  final String label;
  final ThemeData theme;

  const _Keycap({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(isDark ? 0.5 : 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(isDark ? 0.4 : 0.15),
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(isDark ? 0.05 : 0.8),
            offset: const Offset(0, 1),
            blurRadius: 1,
            spreadRadius: 0,
            blurStyle: BlurStyle.inner,
          ),
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(isDark ? 0.2 : 0.08),
            offset: const Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Text(
        label,
        style: AppTypography.monospace.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          height: 1.0,
        ),
      ),
    );
  }
}

class _BookmarkButton extends ConsumerStatefulWidget {
  final ShortcutModel item;
  final ThemeData theme;
  final dynamic strings;

  const _BookmarkButton({
    required this.item,
    required this.theme,
    required this.strings,
  });

  @override
  ConsumerState<_BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends ConsumerState<_BookmarkButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.95), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.10, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookmarks = ref.watch(bookmarksProvider);
    final isSaved = bookmarks.contains(widget.item.id);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!isSaved) {
            _controller.forward(from: 0.0);
          }
          ref
              .read(bookmarksProvider.notifier)
              .toggleBookmark(widget.item.id, context, widget.strings);
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Icon(
                isSaved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: isSaved
                    ? widget.theme.colorScheme.primary
                    : widget.theme.colorScheme.onSurface.withOpacity(0.4),
                size: 24,
              ),
            );
          },
        ),
      ),
    );
  }
}
