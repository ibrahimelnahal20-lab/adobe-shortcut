import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/localization/localization_provider.dart';
import '../providers/shortcuts_providers.dart';
import 'dart:async';

class TextSearchBar extends ConsumerStatefulWidget {
  const TextSearchBar({super.key});

  @override
  ConsumerState<TextSearchBar> createState() => _TextSearchBarState();
}

class _TextSearchBarState extends ConsumerState<TextSearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller.text = ref.read(searchQueryProvider);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        ref.read(searchQueryProvider.notifier).update(value);
        ref.read(displayLimitProvider.notifier).reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    final currentQuery = ref.watch(searchQueryProvider);

    ref.listen(searchQueryProvider, (previous, next) {
      if (_controller.text != next) {
        _controller.text = next;
      }
    });

    return Container(
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
              controller: _controller,
              onChanged: _onChanged,
              decoration: InputDecoration(
                hintText: strings.smartSearchPlaceholder,
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
          if (currentQuery.isNotEmpty)
            IconButton(
              icon: Icon(Icons.close, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              onPressed: () {
                _controller.clear();
                _onChanged('');
              },
            ),
        ],
      ),
    );
  }
}
