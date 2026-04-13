import 'package:flutter/material.dart';
import 'package:frontend/core/utils/app_feedback.dart';
import 'package:frontend/core/widgets/app_widgets.dart';
import 'package:frontend/features/booking/models/booked_facility_details.dart';
import '../booking/booking_screen.dart';

class CategoryFacilitiesScreen extends StatelessWidget {
  final String category;
  final List<(String, double)> facilities;
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [ProfileActionIcon()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final (name, rating) in facilities)
            AppFacilityCard(
              name: name,
              category: category,
              rating: rating,
              onTap: () async {
                AppFeedback.haptic(AppFeedbackType.tap);
                final bookedDetails =
                    await Navigator.push<BookedFacilityDetails>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingScreen(facilityName: name),
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
