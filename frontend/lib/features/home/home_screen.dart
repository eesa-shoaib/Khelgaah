import 'package:flutter/material.dart';
import 'package:frontend/core/api/api_models.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/app_widgets.dart';
import 'package:frontend/features/booking/booked_facility_screen.dart';
import 'package:frontend/features/booking/booking_screen.dart';
import 'package:frontend/features/booking/models/booked_facility_details.dart';
import 'package:frontend/features/home/category_facilities_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<FacilityDto> facilities;
  final bool isLoading;
  final BookedFacilityDetails? latestBooking;
  final ValueChanged<BookedFacilityDetails> onBookingUpdated;

  const HomeScreen({
    super.key,
    required this.facilities,
    required this.isLoading,
    required this.latestBooking,
    required this.onBookingUpdated,
  });

  List<String> get _categories {
    final categories = facilities
        .map((facility) => facility.sport)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  Future<void> _openCategoryFacilities(
    BuildContext context,
    String category,
  ) async {
    final filtered = facilities
        .where(
          (facility) => facility.sport.toLowerCase() == category.toLowerCase(),
        )
        .toList(growable: false);

    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryFacilitiesScreen(
          category: category,
          facilities: filtered,
          onBookingUpdated: onBookingUpdated,
        ),
      ),
    );
  }

  Future<void> _openBooking(BuildContext context, FacilityDto facility) async {
    final bookedDetails = await Navigator.push<BookedFacilityDetails>(
      context,
      MaterialPageRoute(builder: (_) => BookingScreen(facility: facility)),
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
    final categories = _categories;

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
                  'Your next confirmed booking will appear here once it is created.',
              meta: latestBooking == null
                  ? 'NO ACTIVE BOOKING'
                  : '${latestBooking!.statusLabel}  |  TAP TO OPEN',
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
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (categories.isEmpty)
            const BookingSummaryCard(
              title: 'No facilities loaded',
              subtitle: 'The backend did not return any facilities.',
              meta: 'LIVE DATA',
            )
          else
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
                    onTap: () => _openCategoryFacilities(context, category),
                  );
                },
              ),
            ),
          const SizedBox(height: 20),
          const Text(
            'Available now',
            style: TextStyle(
              color: AppTheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (!isLoading && facilities.isEmpty)
            const BookingSummaryCard(
              title: 'No facilities available',
              subtitle: 'Check the backend seed data or database connection.',
              meta: 'LIVE DATA',
            ),
          for (final facility in facilities.take(6))
            AppFacilityCard(
              name: facility.name,
              category: facility.sport,
              detail: facility.type,
              onTap: () => _openBooking(context, facility),
            ),
        ],
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CategoryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainer,
            border: Border.all(color: AppTheme.primary, width: 2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
