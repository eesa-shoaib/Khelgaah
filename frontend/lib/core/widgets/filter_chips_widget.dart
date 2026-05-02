import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';

class FilterChipsWidget extends StatelessWidget {
  final List<String> filters;
  final String? selected;
  final ValueChanged<String?> onSelected;
  final String? allLabel;

  const FilterChipsWidget({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelected,
    this.allLabel = 'All',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildChip(theme, allLabel ?? 'All', selected == null || selected == allLabel),
          for (final filter in filters)
            _buildChip(theme, filter, selected == filter),
        ],
      ),
    );
  }

  Widget _buildChip(ThemeData theme, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => onSelected(label == allLabel ? null : label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.outlineVariant,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isSelected ? AppTheme.onPrimary : AppTheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
