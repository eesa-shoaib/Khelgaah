import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class AppSelectableTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isAvailable;
  final VoidCallback onTap;

  const AppSelectableTile({
    super.key,
    required this.label,
    required this.isSelected,
    this.isAvailable = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderColor = isSelected
        ? colorScheme.primary
        : isAvailable
        ? colorScheme.onSurfaceVariant
        : colorScheme.error;
    final backgroundColor = isSelected
        ? colorScheme.primary
        : colorScheme.surface;
    final textColor = isSelected
        ? colorScheme.onPrimary
        : isAvailable
        ? colorScheme.onSurface
        : colorScheme.error;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isAvailable
            ? () {
                HapticFeedback.selectionClick();
                onTap();
              }
            : null,
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
