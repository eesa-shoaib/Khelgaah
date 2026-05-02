import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';

enum StatusBadgeSize { small, medium, large }

class StatusBadge extends StatelessWidget {
  final String status;
  final StatusBadgeSize size;

  const StatusBadge({
    super.key,
    required this.status,
    this.size = StatusBadgeSize.medium,
  });

  Color get _color {
    final s = status.toLowerCase();
    if (s == 'approved' || s == 'confirmed' || s == 'active' || s == 'success') {
      return Colors.greenAccent;
    }
    if (s == 'pending') return Colors.amberAccent;
    if (s == 'rejected' || s == 'cancelled' || s == 'suspended' || s == 'failed') {
      return AppTheme.error;
    }
    if (s == 'refunded') return Colors.orangeAccent;
    return AppTheme.onSurfaceVariant;
  }

  IconData? get _icon {
    final s = status.toLowerCase();
    if (s == 'approved' || s == 'confirmed' || s == 'active') {
      return Icons.check_circle_outline;
    }
    if (s == 'pending') return Icons.pending_outlined;
    if (s == 'rejected' || s == 'cancelled' || s == 'suspended') {
      return Icons.cancel_outlined;
    }
    return null;
  }

  double get _fontSize {
    switch (size) {
      case StatusBadgeSize.small:
        return 10;
      case StatusBadgeSize.large:
        return 14;
      case StatusBadgeSize.medium:
        return 12;
    }
  }

  double get _iconSize {
    switch (size) {
      case StatusBadgeSize.small:
        return 12;
      case StatusBadgeSize.large:
        return 16;
      case StatusBadgeSize.medium:
        return 14;
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = status[0].toUpperCase() + status.substring(1).toLowerCase();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size == StatusBadgeSize.small ? 6 : 10,
        vertical: size == StatusBadgeSize.small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: _color, width: 1),
        color: _color.withValues(alpha: 0.08),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_icon != null) ...[
            Icon(_icon, size: _iconSize, color: _color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: _color,
              fontSize: _fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
