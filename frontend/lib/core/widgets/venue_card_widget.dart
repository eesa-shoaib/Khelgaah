import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/status_badge_widget.dart';

class VenueCard extends StatelessWidget {
  final String name;
  final String city;
  final int facilityCount;
  final String status;
  final bool showActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onView;

  const VenueCard({
    super.key,
    required this.name,
    required this.city,
    required this.facilityCount,
    required this.status,
    this.showActions = false,
    this.onEdit,
    this.onDelete,
    this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onView,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainer,
          border: Border(
            left: BorderSide(
              color: _statusColor,
              width: 3,
            ),
            bottom: BorderSide(color: AppTheme.outlineVariant, width: 1),
            top: BorderSide(color: AppTheme.outlineVariant, width: 1),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                StatusBadge(status: status, size: StatusBadgeSize.small),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_city, size: 16, color: AppTheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  city,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 20),
                Icon(Icons.sports, size: 16, color: AppTheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  '$facilityCount ${facilityCount == 1 ? 'facility' : 'facilities'}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            if (showActions)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
                      _ActionButton(
                        label: 'Edit',
                        color: AppTheme.primary,
                        onTap: onEdit!,
                      ),
                    if (onDelete != null) ...[
                      const SizedBox(width: 8),
                      _ActionButton(
                        label: 'Delete',
                        color: AppTheme.error,
                        onTap: onDelete!,
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color get _statusColor {
    final s = status.toLowerCase();
    if (s == 'approved' || s == 'active') return Colors.greenAccent;
    if (s == 'pending') return Colors.amberAccent;
    return AppTheme.error;
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
