import 'package:flutter/material.dart';
import 'package:frontend/core/api/api_models.dart';
import 'package:frontend/core/widgets/app_widgets.dart';
import 'package:frontend/features/booking/booking_screen.dart';
import 'package:frontend/features/booking/models/booked_facility_details.dart';

class CategoryFacilitiesScreen extends StatelessWidget {
  final String category;
  final List<FacilityDto> facilities;
  final ValueChanged<BookedFacilityDetails> onBookingUpdated;

  const CategoryFacilitiesScreen({
    super.key,
    required this.category,
    required this.facilities,
    required this.onBookingUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        actions: const [ProfileActionIcon()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (facilities.isEmpty)
            const BookingSummaryCard(
              title: 'No facilities found',
              subtitle: 'No live facilities match this sport right now.',
              meta: 'LIVE DATA',
            ),
          for (final facility in facilities)
            AppFacilityCard(
              name: facility.name,
              category: facility.sport,
              detail: facility.type,
              onTap: () async {
                final bookedDetails =
                    await Navigator.push<BookedFacilityDetails>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingScreen(facility: facility),
                      ),
                    );
                if (bookedDetails != null) {
                  onBookingUpdated(bookedDetails);
                }
              },
            ),
        ],
      ),
    );
  }
}
