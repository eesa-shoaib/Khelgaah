import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BookingDateChip extends StatelessWidget {
  final String day;
  final String date;
  final bool isSelected;
  final VoidCallback onTap;

  const BookingDateChip({
    super.key,
    required this.day,
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 112,
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                day,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              date,
              textAlign: TextAlign.right,
              style: theme.textTheme.titleLarge?.copyWith(
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
