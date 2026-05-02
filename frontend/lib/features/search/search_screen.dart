import 'package:flutter/material.dart';
import 'package:frontend/core/api/api_models.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/app_widgets.dart';
import 'package:frontend/features/booking/booking_screen.dart';
import 'package:frontend/features/booking/models/booked_facility_details.dart';

class SearchScreen extends StatefulWidget {
  final List<FacilityDto> facilities;
  final bool isLoading;
  final ValueChanged<BookedFacilityDetails>? onBookingUpdated;

  const SearchScreen({
    super.key,
    required this.facilities,
    required this.isLoading,
    this.onBookingUpdated,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final filteredFacilities = query.isEmpty
        ? widget.facilities
        : widget.facilities
              .where((facility) {
                return facility.name.toLowerCase().contains(query) ||
                    facility.sport.toLowerCase().contains(query) ||
                    facility.type.toLowerCase().contains(query);
              })
              .toList(growable: false);

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
              'Search live facilities from the backend.',
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
                  _searchController.clear();
                  setState(() => _query = '');
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
              query.isEmpty ? 'All facilities' : 'Search results',
              style: const TextStyle(
                color: AppTheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            if (widget.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (filteredFacilities.isEmpty)
              const BookingSummaryCard(
                title: 'No matches found',
                subtitle: 'No live facilities match that search yet.',
                meta: 'LIVE DATA',
              ),
            for (final facility in filteredFacilities)
              AppFacilityCard(
                name: facility.name,
                category: facility.sport,
                detail: facility.type,
                onTap: () {
                  Navigator.push<BookedFacilityDetails>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingScreen(facility: facility),
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
