import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/theme/app_theme.dart';

enum ParallelogramButtonVariant { primary, secondary, surface, destructive }

class ParallelogramButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ParallelogramButtonVariant variant;
  final IconData? icon;
  final bool fullWidth;
  final bool enabled;
  final EdgeInsetsGeometry padding;

  const ParallelogramButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ParallelogramButtonVariant.primary,
    this.icon,
    this.fullWidth = false,
    this.enabled = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _backgroundColor;
    final foregroundColor = _foregroundColor;

    return GestureDetector(
      onTap: enabled
          ? () {
              HapticFeedback.lightImpact();
              onPressed();
            }
          : null,
      child: ClipPath(
        clipper: ParallelogramClipper(),
        child: Container(
          width: fullWidth ? double.infinity : null,
          padding: padding,
          color: backgroundColor,
          child: Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: foregroundColor),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _backgroundColor {
    if (!enabled) {
      return AppTheme.surface;
    }

    switch (variant) {
      case ParallelogramButtonVariant.primary:
        return AppTheme.orangePrimary;
      case ParallelogramButtonVariant.secondary:
        return AppTheme.orangeAccent;
      case ParallelogramButtonVariant.surface:
        return AppTheme.surface;
      case ParallelogramButtonVariant.destructive:
        return AppTheme.error;
    }
  }

  Color get _foregroundColor {
    if (!enabled) {
      return AppTheme.textSecondary;
    }

    switch (variant) {
      case ParallelogramButtonVariant.primary:
      case ParallelogramButtonVariant.secondary:
      case ParallelogramButtonVariant.destructive:
        return Colors.black;
      case ParallelogramButtonVariant.surface:
        return AppTheme.textPrimary;
    }
  }
}

class ParallelogramClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const skew = 10.0;

    return Path()
      ..moveTo(skew, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width - skew, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
