import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/localization_provider.dart';
import '../providers/app_details_provider.dart';

class AppCategoryFilter extends ConsumerWidget {
  final String appSlug;

  const AppCategoryFilter({super.key, required this.appSlug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    final statsAsync = ref.watch(appStatsProvider(appSlug));
    final selectedCategory = ref.watch(appCategoryProvider);

    return statsAsync.when(
      data: (stats) {
        if (stats.categories.isEmpty) return const SizedBox.shrink();

        final allChips = [
          _buildChip(context, ref, theme, strings.allCategory, 'all', selectedCategory == 'all'),
          ...stats.categories.map((c) => _buildChip(context, ref, theme, c, c, selectedCategory.toLowerCase() == c.toLowerCase())),
        ];

        return Padding(
          padding: const EdgeInsets.only(top: 32),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: allChips.map((chip) => Padding(padding: const EdgeInsets.only(right: 8.0), child: chip)).toList(),
            ),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 32),
        child: SizedBox(height: 40, child: Center(child: CircularProgressIndicator())),
      ),
      error: (_, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildChip(BuildContext context, WidgetRef ref, ThemeData theme, String label, String value, bool isSelected) {
    return InkWell(
      onTap: () => ref.read(appCategoryProvider.notifier).update(value),
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
