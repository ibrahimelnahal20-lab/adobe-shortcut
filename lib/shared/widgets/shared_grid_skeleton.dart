import 'package:flutter/material.dart';

class SharedGridSkeleton extends StatelessWidget {
  final int rows;
  final bool isAppCard;

  const SharedGridSkeleton({super.key, this.rows = 2, this.isAppCard = false});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int columns = 1;
        if (width >= 1200) {
          columns = 5;
        } else if (width >= 900) {
          columns = 3;
        } else if (width >= 600) {
          columns = 2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            mainAxisExtent: 280,
          ),
          itemCount: columns * rows,
          itemBuilder: (context, index) => SharedSkeletonCard(isAppCard: isAppCard),
        );
      },
    );
  }
}

class SharedSkeletonCard extends StatelessWidget {
  final bool isAppCard;

  const SharedSkeletonCard({super.key, this.isAppCard = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.onSurface.withValues(alpha: 0.08);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(8))),
              const Spacer(),
              Container(width: isAppCard ? 80 : 60, height: 24, decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(12))),
            ],
          ),
          const SizedBox(height: 16),
          Container(width: 120, height: 20, color: baseColor),
          const SizedBox(height: 8),
          Container(width: 80, height: 14, color: baseColor),
          const Spacer(),
          Container(width: double.infinity, height: isAppCard ? 24 : 40, color: baseColor),
        ],
      ),
    );
  }
}
