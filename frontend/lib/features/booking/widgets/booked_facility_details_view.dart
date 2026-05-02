import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/app_widgets.dart';
import 'package:frontend/features/booking/models/booked_facility_details.dart';

class BookedFacilityDetailsView extends StatelessWidget {
  final BookedFacilityDetails details;

  const BookedFacilityDetailsView({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          BookingSummaryCard(
            title: details.facilityName,
            subtitle: details.scheduleLabel,
            meta: '${details.statusLabel}  |  BOOKING ID ${details.bookingId}',
          ),
          const SizedBox(height: 20),
          _StatusStrip(
            status: details.reservationStateLabel,
            bookingStatus: details.statusLabel,
          ),
          const SizedBox(height: 20),
          _SectionCard(
            title: 'Booking',
            child: Column(
              children: [
                _DetailRow(label: 'Facility', value: details.facilityName),
                _DetailRow(label: 'Type', value: details.facilityType),
                _DetailRow(
                  label: 'Duration',
                  value: '${details.durationMinutes} minutes',
                ),
                _DetailRow(
                  label: 'Status',
                  value: details.reservationStateLabel,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Access',
            child: Column(
              children: [
                const _DetailRow(
                  label: 'Entry',
                  value: 'Show booking ID at desk',
                ),
                const _DetailRow(
                  label: 'Arrival',
                  value: 'Arrive 10 minutes before the slot',
                ),
                _DetailRow(label: 'Hours', value: details.facilitySummary),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Policies',
            child: Column(
              children: const [
                _DetailRow(
                  label: 'Reschedule',
                  value: 'Allowed until 2 hours before start time',
                ),
                _DetailRow(
                  label: 'Cancellation',
                  value: 'Credit is returned to wallet after review',
                ),
                _DetailRow(
                  label: 'Equipment',
                  value: 'Bring your own gear unless stated otherwise',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _StatusStrip extends StatelessWidget {
  final String status;
  final String bookingStatus;

  const _StatusStrip({required this.status, required this.bookingStatus});

  @override
  Widget build(BuildContext context) {
    final accentColor = bookingStatus == 'CONFIRMED'
        ? AppTheme.secondary
        : AppTheme.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        border: Border.all(color: accentColor, width: 1.2),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_outlined, color: accentColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: const TextStyle(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bookingStatus,
                  style: const TextStyle(
                    color: AppTheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        border: Border.all(color: AppTheme.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final valueStyle = TextStyle(
      color: AppTheme.onSurface,
      fontWeight: FontWeight.w500,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(value, textAlign: TextAlign.right, style: valueStyle),
          ),
        ],
      ),
    );
  }
}
