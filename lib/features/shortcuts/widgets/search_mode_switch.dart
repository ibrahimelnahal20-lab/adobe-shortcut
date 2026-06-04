import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/localization_provider.dart';
import '../providers/shortcuts_providers.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchModeSwitch extends ConsumerWidget {
  final SearchMode? currentModeOverride;
  final ValueChanged<SearchMode>? onModeChanged;

  const SearchModeSwitch({super.key, this.currentModeOverride, this.onModeChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    final currentMode = currentModeOverride ?? ref.watch(searchModeProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeButton(
            title: strings.searchByText,
            svgPath: 'assets/Icons/search.svg',
            isSelected: currentMode == SearchMode.text,
            onTap: () {
              if (onModeChanged != null) {
                onModeChanged!(SearchMode.text);
              } else {
                ref.read(searchModeProvider.notifier).setMode(SearchMode.text);
              }
            },
            theme: theme,
          ),
          const SizedBox(width: 4),
          _ModeButton(
            title: strings.searchByKeys,
            svgPath: 'assets/Icons/keyboard.svg',
            isSelected: currentMode == SearchMode.keys,
            onTap: () {
              if (onModeChanged != null) {
                onModeChanged!(SearchMode.keys);
              } else {
                ref.read(searchModeProvider.notifier).setMode(SearchMode.keys);
              }
            },
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String title;
  final String svgPath;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _ModeButton({
    required this.title,
    required this.svgPath,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              svgPath,
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(
                isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                BlendMode.srcIn
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
