import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/localization_provider.dart';
import '../constants/app_version.dart';
import '../utils/web_utils.dart';

class UpdateWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const UpdateWrapper({super.key, required this.child});

  @override
  ConsumerState<UpdateWrapper> createState() => _UpdateWrapperState();
}

class _UpdateWrapperState extends ConsumerState<UpdateWrapper> {
  bool _updateAvailable = false;
  String _latestVersion = '';

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    final serverVersion = await fetchServerVersion();
    debugPrint('Current Version: $appVersion');
    debugPrint('Server Version: $serverVersion');
    if (serverVersion != null && serverVersion != appVersion) {
      if (mounted) {
        setState(() {
          _updateAvailable = true;
          _latestVersion = serverVersion;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_updateAvailable)
          Positioned(
            bottom: 24,
            right: MediaQuery.of(context).size.width >= 600 ? 24 : null,
            left: MediaQuery.of(context).size.width < 600 ? 24 : null,
            child: Material(
              color: Colors.transparent,
              child: _UpdateBanner(latestVersion: _latestVersion),
            ),
          ),
      ],
    );
  }
}

class _UpdateBanner extends ConsumerStatefulWidget {
  final String latestVersion;
  const _UpdateBanner({required this.latestVersion});

  @override
  ConsumerState<_UpdateBanner> createState() => _UpdateBannerState();
}

class _UpdateBannerState extends ConsumerState<_UpdateBanner> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      width: isMobile ? MediaQuery.of(context).size.width - 48 : 340,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.system_update_rounded, color: theme.colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  strings.newVersionAvailable,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  strings.releaseReady,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      strings.currentVersionLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      appVersion,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      strings.latestVersionLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      widget.latestVersion,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            strings.newerVersionReady,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            strings.newVersionDescription.split('\n').last,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () async {
                setState(() => _isLoading = true);
                await reloadPage();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isLoading 
                  ? SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary)
                    )
                  : Text(
                      strings.refreshNow, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
