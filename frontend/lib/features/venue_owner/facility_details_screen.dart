import 'package:flutter/material.dart';
import 'package:frontend/core/api/api_models.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/profile_action_icon.dart';

class FacilityDetailsScreen extends StatelessWidget {
  final VenueOwnerFacilityDto facility;

  const FacilityDetailsScreen({super.key, required this.facility});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(facility.name),
        actions: const [ProfileActionIcon()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              border: Border.all(color: AppTheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        facility.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onSurface,
                            ),
                      ),
                    ),
                    _StatusBadge(status: facility.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  facility.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: AppTheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '${facility.capacity} people',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.currency_rupee, size: 16, color: AppTheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '${facility.pricePerHour.toStringAsFixed(0)}/hr',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                if (facility.amenities.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    children: facility.amenities
                        .map(
                          (a) => Chip(
                            label: Text(a),
                            labelStyle: const TextStyle(fontSize: 10),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  Color _color(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      color: _color(status).withValues(alpha: 0.2),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _color(status),
        ),
      ),
    );
  }
}
