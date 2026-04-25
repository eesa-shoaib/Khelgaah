import 'package:flutter/material.dart';

class BookingSummaryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String meta;

  const BookingSummaryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.meta,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.primary, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            meta,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.tertiary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
