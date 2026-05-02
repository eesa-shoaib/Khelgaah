import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/app_widgets.dart';
import 'package:frontend/features/booking/booked_facility_screen.dart';
import 'package:frontend/features/booking/models/booked_facility_details.dart';

class BookingsScreen extends StatelessWidget {
  final List<BookedFacilityDetails> bookings;

  const BookingsScreen({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        actions: const [ProfileActionIcon()],
      ),
      body: bookings.isEmpty
          ? const _EmptyBookingsState()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final booking in bookings)
                  AppFacilityCard(
                    name: booking.facilityName,
                    category: booking.reservationStateLabel,
                    detail: booking.scheduleLabel,
                    height: 84,
                    onTap: () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              BookedFacilityScreen(details: booking),
                        ),
                      );
                    },
                  ),
              ],
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
        SizedBox(height: 24),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.5,
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
