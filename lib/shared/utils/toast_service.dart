import 'package:flutter/material.dart';

enum ToastType { success, error, info }

class AppToast {
  static OverlayEntry? _currentEntry;

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, type: ToastType.success);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, type: ToastType.error);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, type: ToastType.info);
  }

  static void _show(BuildContext context, String message, {required ToastType type}) {
    // Remove existing toast immediately if one is showing
    _currentEntry?.remove();
    _currentEntry = null;

    final overlayState = Overlay.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    
    _currentEntry = OverlayEntry(
      builder: (context) {
        return _ToastWidget(
          message: message,
          type: type,
          isRTL: isRTL,
          onDismiss: () {
            // Only remove if this entry is still the current one
            if (_currentEntry != null) {
              _currentEntry?.remove();
              _currentEntry = null;
            }
          },
        );
      },
    );

    overlayState.insert(_currentEntry!);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final bool isRTL;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.isRTL,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isDismissing = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 180),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeIn, // For exit it just fades out
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final isMobile = MediaQuery.of(context).size.width < 600;

      _slideAnimation = Tween<Offset>(
        begin: isMobile ? const Offset(0.0, 0.5) : Offset(widget.isRTL ? -0.15 : 0.15, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: const Threshold(0.0), // Snap to 0 on exit so it only fades
      ));

      _controller.forward();

      // Auto dismiss after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && !_isDismissing) {
          _dismiss();
        }
      });
    }
  }

  void _dismiss() {
    _isDismissing = true;
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Positioned(
      top: isMobile ? null : 100, // Below Navbar on desktop
      bottom: isMobile ? 40 : null, // Near bottom on mobile
      left: isMobile ? 0 : (widget.isRTL ? 24 : null),
      right: isMobile ? 0 : (widget.isRTL ? null : 24),
      child: SafeArea(
        child: Align(
          alignment: isMobile ? Alignment.center : (widget.isRTL ? Alignment.topLeft : Alignment.topRight),
          child: Padding(
            padding: isMobile ? const EdgeInsets.symmetric(horizontal: 24) : EdgeInsets.zero,
            child: Material(
              color: Colors.transparent,
              child: Directionality(
                textDirection: widget.isRTL ? TextDirection.rtl : TextDirection.ltr,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      constraints: BoxConstraints(
                        minWidth: isMobile ? double.infinity : 280,
                        maxWidth: isMobile ? double.infinity : 360,
                        minHeight: 56,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: widget.isRTL
                            ? [
                                Expanded(
                                  child: Text(
                                    widget.message,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _buildIcon(theme),
                              ]
                            : [
                                _buildIcon(theme),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.message,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(ThemeData theme) {
    IconData iconData;
    Color color;

    switch (widget.type) {
      case ToastType.success:
        iconData = Icons.check_circle_rounded;
        color = Colors.green; // Standard success color
        break;
      case ToastType.error:
        iconData = Icons.error_rounded;
        color = theme.colorScheme.error;
        break;
      case ToastType.info:
        iconData = Icons.info_rounded;
        color = theme.colorScheme.primary;
        break;
    }

    return Icon(
      iconData,
      color: color,
      size: 22,
    );
  }
}
