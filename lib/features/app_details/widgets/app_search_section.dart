import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/models/app_model.dart';
import '../../shortcuts/providers/shortcuts_providers.dart';
import '../../shortcuts/widgets/search_mode_switch.dart';
import '../../shortcuts/widgets/key_recorder_widget.dart';
import '../providers/app_details_provider.dart';
import 'dart:async';

class AppSearchSection extends ConsumerStatefulWidget {
  final AppModel app;
  final TextEditingController searchController;

  const AppSearchSection({
    super.key,
    required this.app,
    required this.searchController,
  });

  @override
  ConsumerState<AppSearchSection> createState() => _AppSearchSectionState();
}

class _AppSearchSectionState extends ConsumerState<AppSearchSection> {
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        ref.read(appSearchQueryProvider.notifier).update(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    final searchMode = ref.watch(appSearchModeProvider);
    final searchQuery = ref.watch(appSearchQueryProvider);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          if (!isMobile) ...[
            SearchModeSwitch(
              currentModeOverride: searchMode,
              onModeChanged: (mode) => ref.read(appSearchModeProvider.notifier).setMode(mode),
            ),
            const SizedBox(height: 16),
          ],

          // Search Input
          if (searchMode == SearchMode.text || isMobile)
            Container(
              constraints: const BoxConstraints(maxWidth: 600),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.05),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      'assets/Icons/search.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(theme.colorScheme.onSurface.withValues(alpha: 0.5), BlendMode.srcIn),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: widget.searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: strings.searchAppShortcuts.replaceAll('{app}', widget.app.name),
                        hintStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        border: InputBorder.none,
                      ),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (searchQuery.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.close, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      onPressed: () {
                        widget.searchController.clear();
                        ref.read(appSearchQueryProvider.notifier).update('');
                      },
                    ),
                ],
              ),
            )
          else
            KeyRecorderWidget(
              customShortcuts: ref.watch(appShortcutsProvider(widget.app.slug)).value,
              initialQuery: searchQuery,
              onQueryChanged: (query) => ref.read(appSearchQueryProvider.notifier).update(query),
            ),
        ],
      ),
    );
  }
}
