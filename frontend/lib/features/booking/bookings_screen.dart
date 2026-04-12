import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/app_widgets.dart';
import 'package:frontend/features/booking/models/booked_facility_details.dart';
import 'package:frontend/features/booking/widgets/booked_facility_details_view.dart';

class BookingsScreen extends StatelessWidget {
  final BookedFacilityDetails? latestBooking;
  final VoidCallback? onPayNow;

  const BookingsScreen({super.key, required this.latestBooking, this.onPayNow});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        actions: const [ProfileActionIcon()],
      ),
      body: latestBooking == null
          ? const _EmptyBookingsState()
          : BookedFacilityDetailsView(
              details: latestBooking!,
              onPayNow: onPayNow,
            ),
    );
  }
}

class _EmptyBookingsState extends StatelessWidget {
  const _EmptyBookingsState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        BookingSummaryCard(
          title: 'No bookings yet',
          subtitle:
              'Book any facility and it will appear here with payment and access details.',
          meta: 'BOOKINGS HUB',
        ),
        SizedBox(height: 20),
        _HintCard(
          icon: Icons.event_available,
          title: 'Track reservations',
          subtitle:
              'Your booked slots will stay one tap away from the bottom bar.',
        ),
        SizedBox(height: 12),
        _HintCard(
          icon: Icons.payment,
          title: 'Check payment status',
          subtitle:
              'Pending and paid reservations will be visible without opening another flow.',
        ),
      ],
    );
  }
}

class _HintCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _HintCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.orangePrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
