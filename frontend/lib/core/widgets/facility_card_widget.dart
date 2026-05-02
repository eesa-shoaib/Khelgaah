import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';

class FacilityCard extends StatelessWidget {
  final String name;
  final String description;
  final int capacity;
  final double pricePerHour;
  final String status;
  final bool showActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const FacilityCard({
    super.key,
    required this.name,
    this.description = '',
    required this.capacity,
    required this.pricePerHour,
    required this.status,
    this.showActions = false,
    this.onEdit,
    this.onDelete,
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
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                _StatusDot(status: status),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.people, size: 14, color: AppTheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  'Capacity: $capacity',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.currency_rupee, size: 14, color: AppTheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  '$pricePerHour/hr',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                _StatusLabel(status: status),
              ],
            ),
            if (showActions)
              Padding(
                padding: const EdgeInsets.only(top: 10),
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
    if (s == 'approved' || s == 'active' || s == 'available') return Colors.greenAccent;
    if (s == 'pending') return Colors.amberAccent;
    return AppTheme.error;
  }
}

class _StatusDot extends StatelessWidget {
  final String status;

  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: _color,
        shape: BoxShape.circle,
      ),
    );
  }

  Color get _color {
    final s = status.toLowerCase();
    if (s == 'approved' || s == 'active' || s == 'available') return Colors.greenAccent;
    if (s == 'pending') return Colors.amberAccent;
    return AppTheme.error;
  }
}

class _StatusLabel extends StatelessWidget {
  final String status;

  const _StatusLabel({required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status[0].toUpperCase() + status.substring(1).toLowerCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: _color, width: 1),
      ),
      child: Text(
        s,
        style: TextStyle(
          color: _color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color get _color {
    final s = status.toLowerCase();
    if (s == 'approved' || s == 'active' || s == 'available') return Colors.greenAccent;
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
