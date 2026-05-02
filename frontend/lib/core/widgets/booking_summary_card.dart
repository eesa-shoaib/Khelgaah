import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';

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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        border: Border(
          left: BorderSide(color: colorScheme.primary, width: 3),
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
          top: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.tertiary, width: 1),
            ),
            child: Text(
              meta,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.tertiary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 17,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
