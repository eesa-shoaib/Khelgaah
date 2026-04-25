import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/utils/app_feedback.dart';
import 'package:frontend/core/widgets/app_widgets.dart';
import 'package:frontend/features/booking/booking_screen.dart';
import 'package:frontend/features/booking/models/booked_facility_details.dart';

class SearchScreen extends StatefulWidget {
  final ValueChanged<BookedFacilityDetails>? onBookingUpdated;

  const SearchScreen({super.key, this.onBookingUpdated});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

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

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matchingCategories = _query.isEmpty
        ? categories
        : categories
              .where((c) => c.toLowerCase().contains(_query.toLowerCase()))
              .toList();

    final allFacilities = <(String, String, double)>[];
    for (final category in matchingCategories) {
      final facilities = categoryFacilities[category] ?? [];
      for (final (name, rating) in facilities) {
        allFacilities.add((name, category, rating));
      }
    }

    final filteredFacilities = _query.isEmpty
        ? allFacilities
        : allFacilities
              .where(
                (f) =>
                    f.$1.toLowerCase().contains(_query.toLowerCase()) ||
                    f.$2.toLowerCase().contains(_query.toLowerCase()),
              )
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(width: 170, textAlign: TextAlign.left),
        actions: const [ProfileActionIcon()],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            const Text(
              'Search venues, activities, or open time windows.',
              style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 18),
            AppTextField(
              label: 'Search',
              hintText: 'Tennis, pool, gym...',
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              suffixIcon: IconButton(
                onPressed: () {
                  if (_query.isEmpty) {
                    return;
                  }

                  AppFeedback.haptic(AppFeedbackType.selection);
                  _searchController.clear();
                  setState(() => _query = '');
                  AppFeedback.pulseMessage(
                    context,
                    message: 'Search reset.',
                    icon: Icons.restart_alt,
                  );
                },
                icon: const Icon(
                  Icons.close,
                  color: AppTheme.onSurfaceVariant,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _query.isEmpty ? 'Suggested results' : 'Search results',
              style: const TextStyle(
                color: AppTheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            if (_query.isEmpty)
              const BookingSummaryCard(
                title: 'Popular now',
                subtitle:
                    'Badminton, Tennis Court, and Swimming Pool are trending this evening.',
                meta: 'LIVE SEARCH INDEX',
              ),
            if (_query.isEmpty) const SizedBox(height: 14),
            if (filteredFacilities.isEmpty)
              const BookingSummaryCard(
                title: 'No matches found',
                subtitle:
                    'Try broader terms like court, pool, or gym to explore available facilities.',
                meta: 'SEARCH EMPTY STATE',
              ),
            for (final facility in filteredFacilities)
              AppFacilityCard(
                name: facility.$1,
                category: facility.$2,
                rating: facility.$3,
                onTap: () {
                  AppFeedback.haptic(AppFeedbackType.tap);
                  Navigator.push<BookedFacilityDetails>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingScreen(facilityName: facility.$1),
                    ),
                  ).then((bookedDetails) {
                    if (bookedDetails != null) {
                      widget.onBookingUpdated?.call(bookedDetails);
                    }
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
