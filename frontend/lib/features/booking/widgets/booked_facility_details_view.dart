import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/app_widgets.dart';
import 'package:frontend/features/booking/models/booked_facility_details.dart';

class BookedFacilityDetailsView extends StatelessWidget {
  final BookedFacilityDetails details;
  final VoidCallback? onPayNow;

  const BookedFacilityDetailsView({
    super.key,
    required this.details,
    this.onPayNow,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BookingSummaryCard(
          title: details.facilityName,
          subtitle: details.scheduleLabel,
          meta:
              '${details.paymentStatusLabel}  |  BOOKING ID ${details.bookingId}',
        ),
        const SizedBox(height: 20),
        _StatusStrip(
          status: details.reservationStateLabel,
          paymentStatus: details.paymentStatusLabel,
          accentColor: details.paymentStatusColor,
        ),
        const SizedBox(height: 20),
        _SectionCard(
          title: 'Payment',
          child: Column(
            children: [
              _DetailRow(
                label: 'Facility charge',
                value: '\$${details.subtotal.toStringAsFixed(2)}',
              ),
              _DetailRow(
                label: 'Service fee',
                value: '\$${details.serviceFee.toStringAsFixed(2)}',
              ),
              const Divider(color: AppTheme.divider, height: 24),
              _DetailRow(
                label: 'Total',
                value: '\$${details.total.toStringAsFixed(2)}',
                highlight: true,
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
              _DetailRow(label: 'Note', value: details.accessNote),
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
        const SizedBox(height: 20),
        ParallelogramButton(
          text: details.isPaid ? 'Payment Received' : 'Pay Now',
          onPressed: details.isPaid ? () {} : (onPayNow ?? () {}),
          fullWidth: true,
          icon: details.isPaid ? Icons.check : Icons.payment,
          enabled: !details.isPaid && onPayNow != null,
        ),
      ],
    );
  }
}

class _StatusStrip extends StatelessWidget {
  final String status;
  final String paymentStatus;
  final Color accentColor;

  const _StatusStrip({
    required this.status,
    required this.paymentStatus,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
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
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  paymentStatus,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
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
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
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
  final bool highlight;

  const _DetailRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final valueStyle = TextStyle(
      color: highlight ? AppTheme.orangeAccent : AppTheme.textPrimary,
      fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
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
                color: AppTheme.textSecondary,
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
