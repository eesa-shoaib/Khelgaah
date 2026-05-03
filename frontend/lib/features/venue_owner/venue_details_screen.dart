import 'package:flutter/material.dart';
import 'package:frontend/core/api/api_models.dart';
import 'package:frontend/core/app_controller.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/status_badge_widget.dart';
import 'package:frontend/core/widgets/profile_action_icon.dart';
import 'package:frontend/core/widgets/parallelogram_btn.dart';
import 'package:frontend/features/venue_owner/facilities_list_screen.dart';
import 'package:frontend/features/venue_owner/facility_details_screen.dart';

class VenueDetailsScreen extends StatefulWidget {
  final VenueDto venue;

  const VenueDetailsScreen({super.key, required this.venue});

  @override
  State<VenueDetailsScreen> createState() => _VenueDetailsScreenState();
}

class _VenueDetailsScreenState extends State<VenueDetailsScreen> {
  late VenueDto _venue;
  List<VenueOwnerFacilityDto> _facilities = [];
  bool _isLoading = true;
  String? _error;
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      _hasLoaded = true;
      Future.microtask(() {
        if (!mounted) return;
        _loadFacilities();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _venue = widget.venue;
  }

  Future<void> _loadFacilities() async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final facilities = await controller.apiClient
          .listFacilitiesForVenue(token: token, venueId: _venue.id)
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      setState(() {
        _facilities = facilities;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load facilities.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_venue.name),
        actions: const [ProfileActionIcon()],
      ),
      body: Stack(
        children: [
          _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorState(message: _error!, onRetry: _loadFacilities)
              : RefreshIndicator(
                  onRefresh: _loadFacilities,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _VenueInfoCard(venue: _venue),
                      const SizedBox(height: 20),
                      Text(
                        'Facilities (${_facilities.length})',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 12),
                      if (_facilities.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('No facilities found'),
                          ),
                        )
                      else
                        for (final facility in _facilities)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FacilityDetailsScreen(
                                    facility: facility,
                                  ),
                                ),
                              ).then((_) => _loadFacilities());
                            },
                            child: _FacilityCard(
                              facility: facility,
                            ),
                          ),
                    ],
                  ),
                ),
          Positioned(
            bottom: 16,
            right: 16,
            child: SafeArea(
              child: ParallelogramButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FacilityEditScreen(venueId: _venue.id),
                    ),
                  ).then((_) => _loadFacilities());
                },
                text: 'Add Facility',
                icon: Icons.add,
                variant: ParallelogramButtonVariant.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VenueInfoCard extends StatelessWidget {
  final VenueDto venue;

  const _VenueInfoCard({required this.venue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        border: Border(
          left: BorderSide(
            color: _statusColor(venue.status),
            width: 3,
          ),
          bottom: BorderSide(color: AppTheme.outlineVariant, width: 1),
          top: BorderSide(color: AppTheme.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  venue.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurface,
                      ),
                ),
              ),
              StatusBadge(status: venue.status, size: StatusBadgeSize.small),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            venue.address,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
          ),
          Text(
            venue.city,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.sports, size: 16, color: AppTheme.primary),
              const SizedBox(width: 4),
              Text(
                '${venue.facilityCount} facilities',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'approved' || s == 'active') return Colors.greenAccent;
    if (s == 'pending') return Colors.amberAccent;
    return AppTheme.error;
  }
}

class _FacilityCard extends StatelessWidget {
  final VenueOwnerFacilityDto facility;

  const _FacilityCard({required this.facility});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        border: Border(
          left: BorderSide(
            color: _statusColor(facility.status),
            width: 3,
          ),
          bottom: BorderSide(color: AppTheme.outlineVariant, width: 1),
          top: BorderSide(color: AppTheme.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  facility.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface,
                      ),
                ),
              ),
              StatusBadge(status: facility.status, size: StatusBadgeSize.small),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Sport: ${facility.sport}',
            style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Type: ${facility.type}',
            style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
          ),
          if (facility.openSummary.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              facility.openSummary,
              style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.currency_rupee, size: 14, color: AppTheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                '${facility.pricePerHour}/hr',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'approved' || s == 'active' || s == 'available') return Colors.greenAccent;
    if (s == 'pending') return Colors.amberAccent;
    return AppTheme.error;
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: const TextStyle(color: AppTheme.error)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
