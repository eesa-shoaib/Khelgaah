import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/app_widgets.dart';
import 'package:frontend/features/search/search_screen.dart';
import '../booking/booking_screen.dart';
import 'widgets/facility_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<String> facilities = const [
    'Tennis Court',
    'Swimming Pool',
    'Gym',
    'Badminton',
  ];

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
          const BookingSummaryCard(
            title: 'Next reservation',
            subtitle:
                'Badminton Court 02 at 06:00 PM. Arrive 10 minutes early for check-in.',
            meta: 'MARCH 24  |  EVENING BLOCK',
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingScreen(facilityName: facility),
                  ),
                );
              },
            ),
          const SizedBox(height: 16),
          ParallelogramButton(
            text: 'Open Search',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
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
