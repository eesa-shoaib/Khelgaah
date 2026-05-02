import 'package:flutter/material.dart';
import 'package:frontend/core/api/api_models.dart';
import 'package:frontend/core/app_controller.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/app_widgets.dart';
import 'package:frontend/core/widgets/booking_card_widget.dart';
import 'package:frontend/core/widgets/app_facility_card.dart';
import 'package:frontend/core/widgets/profile_action_icon.dart';
import 'package:frontend/core/widgets/stats_card_widget.dart';
import 'package:frontend/features/venue_owner/venue_owner_bookings_screen.dart';
import 'package:frontend/features/venue_owner/venue_owner_layout.dart';
import 'package:frontend/features/venue_owner/venues_list_screen.dart';

class VenueOwnerDashboard extends StatefulWidget {
  const VenueOwnerDashboard({super.key});

  @override
  State<VenueOwnerDashboard> createState() => _VenueOwnerDashboardState();
}

class _VenueOwnerDashboardState extends State<VenueOwnerDashboard> {
  DashboardStats? _stats;
  int? _venuesCount;

  final _sampleStats = const DashboardStats(
    totalBookings: 24,
    totalRevenue: 45000,
    occupancyRate: 68.5,
    pendingApprovals: 3,
    recentBookings: [],
  );

  @override
  void initState() {
    super.initState();
    _stats = _sampleStats;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadDashboard();
        _loadVenuesCount();
      }
    });
  }

  Future<void> _loadDashboard() async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) return;

    try {
      final stats = await controller.apiClient
          .getVenueOwnerDashboard(token: token)
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      setState(() => _stats = stats);
    } catch (_) {
      // Keep showing sample data on error
    }
  }

  Future<void> _loadVenuesCount() async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) return;

    try {
      final venues = await controller.apiClient
          .listVenues(token: token)
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      setState(() => _venuesCount = venues.length);
    } catch (_) {
      // Keep showing sample data on error
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AppScope.of(context).session?.user;
    final stats = _stats!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: const [ProfileActionIcon()],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadDashboard();
          await _loadVenuesCount();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _WelcomeCard(user: user),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 400;
                return GridView.count(
                  crossAxisCount: isWide ? 3 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: isWide ? 1.4 : 1.6,
                  children: [
                    StatsCard(
                      icon: Icons.business,
                      label: 'Venues',
                      value: '${_venuesCount ?? '...'}',
                    ),
                    StatsCard(
                      icon: Icons.event_note,
                      label: 'Bookings',
                      value: '${stats.totalBookings}',
                    ),
                    StatsCard(
                      icon: Icons.pending_actions,
                      label: 'Pending',
                      value: '${stats.pendingApprovals}',
                      color: Colors.amber,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            AppFacilityCard(
              name: 'View All Bookings',
              category: 'Bookings',
              onTap: () {
                final layout = context
                    .findAncestorStateOfType<VenueOwnerLayoutState>();
                if (layout != null) {
                  layout.navigateToTab(2);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VenueOwnerBookingsScreen(),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            AppFacilityCard(
              name: 'Manage Venues',
              category: "Venues",
              onTap: () {
                final layout = context
                    .findAncestorStateOfType<VenueOwnerLayoutState>();
                if (layout != null) {
                  layout.navigateToTab(1);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VenuesListScreen()),
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent Bookings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _RecentBookingsList(stats: stats),
          ],
        ),
      ),
    );
  }
}

class _RecentBookingsList extends StatelessWidget {
  final DashboardStats stats;

  const _RecentBookingsList({required this.stats});

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bookings = stats.recentBookings;
    if (bookings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainer,
          border: Border(
            left: BorderSide(color: AppTheme.primary, width: 3),
            bottom: BorderSide(color: AppTheme.outlineVariant, width: 1),
            top: BorderSide(color: AppTheme.outlineVariant, width: 1),
          ),
        ),
        child: const Center(
          child: Text(
            'No recent bookings',
            style: TextStyle(color: AppTheme.onSurfaceVariant),
          ),
        ),
      );
    }

    return Column(
      children: bookings.take(5).map((booking) {
        return BookingCard(
          key: ValueKey(booking.id),
          customerName: booking.customerName,
          facilityName: booking.facilityName,
          date: _formatDate(booking.startTime),
          time:
              '${_formatTime(booking.startTime)} - ${_formatTime(booking.endTime)}',
          status: booking.status,
        );
      }).toList(),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final UserProfile? user;

  const _WelcomeCard({this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        border: Border(
          left: BorderSide(color: AppTheme.primary, width: 3),
          bottom: BorderSide(color: AppTheme.outlineVariant, width: 1),
          top: BorderSide(color: AppTheme.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.tertiary, width: 1),
            ),
            child: Text(
              'VENUE OWNER',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.tertiary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Welcome, ${user?.fullName ?? 'Owner'}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}
