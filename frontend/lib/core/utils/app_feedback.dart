import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/theme/app_theme.dart';

enum AppFeedbackType { tap, selection, success }

class AppFeedback {
  static void haptic(AppFeedbackType type) {
    switch (type) {
      case AppFeedbackType.tap:
        HapticFeedback.lightImpact();
        break;
      case AppFeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
      case AppFeedbackType.success:
        HapticFeedback.mediumImpact();
        break;
    }
  }

  static void pulseMessage(
    BuildContext context, {
    required String message,
    IconData icon = Icons.check_circle_outline,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.surfaceContainer,
          duration: const Duration(milliseconds: 1400),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppTheme.primary),
            borderRadius: BorderRadius.zero,
          ),
          content: Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: AppTheme.onSurface),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
