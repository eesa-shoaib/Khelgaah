import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/status_badge_widget.dart';

class BookingCard extends StatelessWidget {
  final String customerName;
  final String facilityName;
  final String date;
  final String time;
  final String status;
  final bool showActions;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onCancel;
  final VoidCallback? onTap;

  const BookingCard({
    super.key,
    required this.customerName,
    required this.facilityName,
    required this.date,
    required this.time,
    required this.status,
    this.showActions = false,
    this.onApprove,
    this.onReject,
    this.onCancel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    customerName,
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
            const SizedBox(height: 6),
            Text(
              facilityName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: AppTheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  date,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 14, color: AppTheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  time,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (showActions && (onApprove != null || onReject != null || onCancel != null))
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onReject != null)
                      _ActionButton(
                        label: 'Reject',
                        color: AppTheme.error,
                        onTap: onReject!,
                      ),
                    if (onApprove != null) ...[
                      const SizedBox(width: 8),
                      _ActionButton(
                        label: 'Approve',
                        color: Colors.greenAccent,
                        onTap: onApprove!,
                      ),
                    ],
                    if (onCancel != null) ...[
                      const SizedBox(width: 8),
                      _ActionButton(
                        label: 'Cancel',
                        color: AppTheme.tertiary,
                        onTap: onCancel!,
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
    if (s == 'approved' || s == 'confirmed') return Colors.greenAccent;
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
