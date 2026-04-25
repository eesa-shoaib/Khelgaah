import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    final backgroundColor = _backgroundColor(context);
    final foregroundColor = _foregroundColor(context);

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

  Color _backgroundColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (!enabled) {
      return colorScheme.surfaceContainerHigh;
    }

    switch (variant) {
      case ParallelogramButtonVariant.primary:
        return colorScheme.primary;
      case ParallelogramButtonVariant.secondary:
        return colorScheme.tertiary;
      case ParallelogramButtonVariant.surface:
        return colorScheme.surface;
      case ParallelogramButtonVariant.destructive:
        return colorScheme.error;
    }
  }

  Color _foregroundColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (!enabled) {
      return colorScheme.onSurfaceVariant;
    }

    switch (variant) {
      case ParallelogramButtonVariant.primary:
        return colorScheme.onPrimary;
      case ParallelogramButtonVariant.secondary:
        return colorScheme.onTertiary;
      case ParallelogramButtonVariant.destructive:
        return colorScheme.onError;
      case ParallelogramButtonVariant.surface:
        return colorScheme.onSurface;
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
