import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/utils/app_feedback.dart';
import 'package:frontend/core/widgets/app_widgets.dart';
import 'package:frontend/features/booking/booked_facility_screen.dart';
import 'package:frontend/features/booking/models/booked_facility_details.dart';
import '../booking/booking_screen.dart';
import 'category_facilities_screen.dart';

class HomeScreen extends StatelessWidget {
  final BookedFacilityDetails? latestBooking;
  final ValueChanged<BookedFacilityDetails> onBookingUpdated;

  const HomeScreen({
    super.key,
    required this.latestBooking,
    required this.onBookingUpdated,
  });

  static const List<String> categories = [
    'Football',
    'Tennis',
    'Padel',
    'Badminton',
    'Cricket',
  ];

  static const Map<String, List<(String, double)>> categoryFacilities = {
    'Football': [
      ('Elite Turf Arena', 4.8),
      ('City Kickers Hub', 4.1),
      ('Goal Master Fields', 4.5),
    ],
    'Tennis': [
      ('Rally Court Club', 4.6),
      ('Ace Tennis Center', 4.3),
      ('Serve & Volley Arena', 4.7),
    ],
    'Padel': [
      ('Smash Padel Club', 4.5),
      ('The Glass Court', 4.9),
      ('Padel Pro Arena', 4.4),
    ],
    'Badminton': [
      ('Shuttle Star Hub', 4.6),
      ('Smash Zone Arena', 4.2),
      ('Badminton Bay', 4.7),
    ],
    'Cricket': [
      ('Cricket Nexus', 4.5),
      ('Pitch Perfect Arena', 4.3),
      ('Bat & Ball Club', 4.6),
    ],
  };

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'football':
        return Icons.sports_soccer;
      case 'tennis':
        return Icons.sports_tennis;
      case 'padel':
        return Icons.sports_handball;
      case 'badminton':
        return Icons.sports;
      case 'cricket':
        return Icons.sports_cricket;
      default:
        return Icons.sports;
    }
  }

  Future<void> _openCategoryFacilities(
    BuildContext context,
    String category,
  ) async {
    final facilities = categoryFacilities[category] ?? [];
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryFacilitiesScreen(
          category: category,
          facilities: facilities,
          onBookingUpdated: onBookingUpdated,
        ),
      ),
    );
  }

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
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          const Text(
            'Book your next session without the clutter.',
            style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14),
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
            'Choose a sport',
            style: TextStyle(
              color: AppTheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final category = categories[index];
                return _CategoryButton(
                  label: category,
                  icon: _getCategoryIcon(category),
                  onTap: () => _openCategoryFacilities(context, category),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Recent',
            style: TextStyle(
              color: AppTheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (final category in categories)
            for (final (name, rating)
                in (categoryFacilities[category] ?? []).take(1))
              AppFacilityCard(
                name: name,
                category: category,
                rating: rating,
                onTap: () => _openBooking(context, name),
              ),
        ],
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AppFeedback.haptic(AppFeedbackType.tap);
          onTap();
        },
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainer,
            border: Border.all(color: AppTheme.primary),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppTheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
