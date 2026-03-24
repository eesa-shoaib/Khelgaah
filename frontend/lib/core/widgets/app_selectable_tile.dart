import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/theme/app_theme.dart';

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
    final borderColor = isSelected
        ? AppTheme.orangePrimary
        : isAvailable
        ? AppTheme.textSecondary
        : AppTheme.error;
    final backgroundColor = isSelected
        ? AppTheme.orangePrimary
        : AppTheme.surface;
    final textColor = isSelected
        ? Colors.black
        : isAvailable
        ? AppTheme.textPrimary
        : AppTheme.error;

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
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
