import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../core/localization/localization_provider.dart';

class WhyAdobeShortcutSection extends ConsumerWidget {
  const WhyAdobeShortcutSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              strings.whyAdobeShortcutTitle,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              strings.whyAdobeShortcutSubtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 64),
            
            // Alternating Blocks without connectors
            _buildAlternatingBlock(
              theme,
              title: strings.block1Title,
              problem: strings.block1Problem,
              solution: strings.block1Solution,
              lottiePath: 'assets/lottie/keyboard.json',
              isReversed: false,
            ),
            const SizedBox(height: 64),
            _buildAlternatingBlock(
              theme,
              title: strings.block2Title,
              problem: strings.block2Problem,
              solution: strings.block2Solution,
              lottiePath: 'assets/lottie/bookmarks.json',
              isReversed: true,
            ),
            const SizedBox(height: 64),
            _buildAlternatingBlock(
              theme,
              title: strings.block3Title,
              problem: strings.block3Problem,
              solution: strings.block3Solution,
              lottiePath: 'assets/lottie/search.json',
              isReversed: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlternatingBlock(ThemeData theme, {
    required String title,
    required String problem,
    required String solution,
    required String lottiePath,
    required bool isReversed,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        
        final textContent = Column(
          crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                letterSpacing: 1.2,
              ),
              textAlign: isMobile ? TextAlign.center : TextAlign.left,
            ),
            const SizedBox(height: 12),
            Text(
              problem,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                fontSize: 26, 
              ),
              textAlign: isMobile ? TextAlign.center : TextAlign.left,
            ),
            const SizedBox(height: 12),
            Text(
              solution,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
              textAlign: isMobile ? TextAlign.center : TextAlign.left,
            ),
          ],
        );

        final iconContent = Center(
          child: _LottieFeatureIcon(
            lottiePath: lottiePath,
            isMobile: isMobile,
          ),
        );

        if (isMobile) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                iconContent,
                const SizedBox(height: 32),
                textContent,
              ],
            ),
          );
        }

        return Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: isReversed 
                ? [
                    Expanded(flex: 3, child: textContent), 
                    const SizedBox(width: 64), 
                    Expanded(flex: 2, child: iconContent)
                  ]
                : [
                    Expanded(flex: 2, child: iconContent), 
                    const SizedBox(width: 64), 
                    Expanded(flex: 3, child: textContent)
                  ],
          ),
        );
      },
    );
  }
}

class _LottieFeatureIcon extends StatefulWidget {
  final String lottiePath;
  final bool isMobile;

  const _LottieFeatureIcon({
    required this.lottiePath,
    required this.isMobile,
  });

  @override
  State<_LottieFeatureIcon> createState() => _LottieFeatureIconState();
}

class _LottieFeatureIconState extends State<_LottieFeatureIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!mounted) return;
    
    if (info.visibleFraction > 0.2) {
      if (!_isVisible) {
        _isVisible = true;
        _controller.repeat(); // Loop while visible
      }
    } else {
      if (_isVisible) {
        _isVisible = false;
        _controller.stop(); // Pause when out of viewport
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = MediaQuery.sizeOf(context).width;
        double iconSize;
        if (screenWidth >= 1024) {
          iconSize = 140.0; // Desktop
        } else if (screenWidth >= 768) {
          iconSize = 115.0; // Tablet
        } else {
          iconSize = 90.0; // Mobile
        }

        return VisibilityDetector(
          key: Key(widget.lottiePath),
          onVisibilityChanged: _onVisibilityChanged,
          child: SizedBox(
            width: iconSize,
            height: iconSize,
            child: RepaintBoundary(
              child: Lottie.asset(
                widget.lottiePath,
                controller: _controller,
                fit: BoxFit.contain,
                onLoaded: (composition) {
                  _controller.duration = composition.duration;
                },
              ),
            ),
          ),
        );
      }
    );
  }
}
