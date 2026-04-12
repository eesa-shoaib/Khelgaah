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

  final List<(String, String, String)> _facilities = const [
    ('Tennis Court', 'Outdoor', '08 slots open'),
    ('Swimming Pool', 'Indoor', '05 slots open'),
    ('Gym', 'Strength', 'Walk-ins available'),
    ('Badminton', 'Court', '06 slots open'),
    ('Padel Arena', 'Outdoor', '03 slots open'),
    ('Cricket Nets', 'Practice', '04 slots open'),
  ];

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _facilities.where((facility) {
      final searchSpace = '${facility.$1} ${facility.$2} ${facility.$3}'
          .toLowerCase();
      return searchSpace.contains(_query.toLowerCase());
    }).toList();

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
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
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
                  color: AppTheme.textSecondary,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _query.isEmpty ? 'Suggested results' : 'Search results',
              style: const TextStyle(
                color: AppTheme.textPrimary,
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
            if (results.isEmpty)
              const BookingSummaryCard(
                title: 'No matches found',
                subtitle:
                    'Try broader terms like court, pool, or gym to explore available facilities.',
                meta: 'SEARCH EMPTY STATE',
              ),
            for (final facility in results)
              AppActionTile(
                title: '${facility.$1}  •  ${facility.$2}',
                trailingIcon: Icons.arrow_forward_ios_sharp,
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
