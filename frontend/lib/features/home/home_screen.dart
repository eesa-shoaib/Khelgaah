import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/utils/app_feedback.dart';
import 'package:frontend/core/widgets/app_widgets.dart';
import 'package:frontend/features/booking/booked_facility_screen.dart';
import 'package:frontend/features/booking/models/booked_facility_details.dart';
import 'package:frontend/features/search/search_screen.dart';
import '../booking/booking_screen.dart';
import 'widgets/facility_card.dart';

class HomeScreen extends StatelessWidget {
  final BookedFacilityDetails? latestBooking;
  final ValueChanged<BookedFacilityDetails> onBookingUpdated;

  const HomeScreen({
    super.key,
    required this.latestBooking,
    required this.onBookingUpdated,
  });

  final List<String> facilities = const [
    'Tennis Court',
    'Swimming Pool',
    'Gym',
    'Badminton',
  ];

  Future<void> _openBooking(BuildContext context, String facility) async {
    AppFeedback.haptic(AppFeedbackType.tap);
    final bookedDetails = await Navigator.push<BookedFacilityDetails>(
      context,
      MaterialPageRoute(builder: (_) => BookingScreen(facilityName: facility)),
    );

    if (!context.mounted || bookedDetails == null) {
      return;
    }

    onBookingUpdated(bookedDetails);
  }

  Future<void> _openBookedFacility(BuildContext context) async {
    if (latestBooking == null) {
      return;
    }

    AppFeedback.haptic(AppFeedbackType.tap);
    final updatedDetails = await Navigator.push<BookedFacilityDetails>(
      context,
      MaterialPageRoute(
        builder: (_) => BookedFacilityScreen(details: latestBooking!),
      ),
    );

    if (!context.mounted || updatedDetails == null) {
      return;
    }

    onBookingUpdated(updatedDetails);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(width: 170, textAlign: TextAlign.left),
        actions: const [ProfileActionIcon()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          const Text(
            'Book your next session without the clutter.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: latestBooking == null
                ? null
                : () => _openBookedFacility(context),
            child: BookingSummaryCard(
              title: latestBooking?.facilityName ?? 'Next reservation',
              subtitle:
                  latestBooking?.scheduleLabel ??
                  'Book a facility to open its reservation, payment, and access details here.',
              meta: latestBooking == null
                  ? 'NO ACTIVE BOOKING'
                  : '${latestBooking!.paymentStatusLabel}  |  TAP TO OPEN',
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Choose a facility',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (final facility in facilities)
            FacilityCard(
              name: facility,
              onTap: () => _openBooking(context, facility),
            ),
          const SizedBox(height: 16),
          ParallelogramButton(
            text: 'Open Search',
            onPressed: () {
              AppFeedback.pulseMessage(
                context,
                message: 'Search is ready. Swipe back anytime.',
                icon: Icons.swipe_outlined,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      SearchScreen(onBookingUpdated: onBookingUpdated),
                ),
              );
            },
            fullWidth: true,
            icon: Icons.search,
            variant: ParallelogramButtonVariant.surface,
          ),
        ],
      ),
    );
  }
}
