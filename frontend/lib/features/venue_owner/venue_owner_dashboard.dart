import 'package:flutter/material.dart';
import 'package:frontend/core/api/api_models.dart';
import 'package:frontend/core/app_controller.dart';
import 'package:frontend/core/theme/app_theme.dart';
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
  int _venuesCount = 0;
  bool _isLoading = true;
  String? _error;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    try {
      final controller = AppScope.of(context);
      final token = controller.session?.token;

      if (token == null) {
        if (mounted) {
          setState(() {
            _error = 'Authentication token not found';
            _isLoading = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      // Load dashboard stats
      try {
        final stats = await controller.apiClient
            .getVenueOwnerDashboard(token: token)
            .timeout(const Duration(seconds: 10));
        if (mounted) {
          setState(() {
            _stats = stats ??
                const DashboardStats(
                  totalBookings: 0,
                  totalRevenue: 0.0,
                  occupancyRate: 0.0,
                  pendingApprovals: 0,
                  recentBookings: [],
                );
          });
        }
      } catch (e) {
        debugPrint('Dashboard error: $e');
        if (mounted) {
          setState(() {
            _error = 'Failed to load dashboard';
          });
        }
      }

      // Load venues count (non-critical)
      try {
        final venues = await controller.apiClient
            .listVenues(token: token)
            .timeout(const Duration(seconds: 10));
        if (mounted) {
          setState(() {
            _venuesCount = venues.length;
          });
        }
      } catch (e) {
        debugPrint('Venues count error: $e');
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Load data error: $e');
      if (mounted) {
        setState(() {
          _error = 'An unexpected error occurred';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AppScope.of(context).session?.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: const [ProfileActionIcon()],
      ),
      body: _buildBody(user),
    );
  }

  Widget _buildBody(UserProfile? user) {
    if (_isLoading && _stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _stats == null) {
      return _ErrorState(message: _error!, onRetry: _loadData);
    }

    if (_stats != null) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: _buildDashboard(user),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildDashboard(UserProfile? user) {
    final stats = _stats!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _WelcomeCard(user: user),
        const SizedBox(height: 20),
        _StatsGrid(
          venuesCount: _venuesCount,
          totalBookings: stats.totalBookings,
          pendingApprovals: stats.pendingApprovals,
        ),
        const SizedBox(height: 24),
        AppFacilityCard(
          name: 'View All Bookings',
          category: 'Bookings',
          onTap: () => _navigateToTab(2),
        ),
        const SizedBox(height: 12),
        AppFacilityCard(
          name: 'Manage Venues',
          category: 'Venues',
          onTap: () => _navigateToTab(1),
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
        _RecentBookingsList(bookings: stats.recentBookings),
      ],
    );
  }

  void _navigateToTab(int tabIndex) {
    final layout = context.findAncestorStateOfType<VenueOwnerLayoutState>();
    if (layout != null) {
      layout.navigateToTab(tabIndex);
    } else {
      if (tabIndex == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VenuesListScreen()),
        );
      } else if (tabIndex == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VenueOwnerBookingsScreen()),
        );
      }
    }
  }
}

class _StatsGrid extends StatelessWidget {
  final int venuesCount;
  final int totalBookings;
  final int pendingApprovals;

  const _StatsGrid({
    required this.venuesCount,
    required this.totalBookings,
    required this.pendingApprovals,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 400;
        return GridView.count(
          crossAxisCount: isWide ? 3 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: isWide ? 1.4 : 1.6,
          children: [
            StatsCard(
              icon: Icons.business,
              label: 'Venues',
              value: '$venuesCount',
            ),
            StatsCard(
              icon: Icons.event_note,
              label: 'Bookings',
              value: '$totalBookings',
            ),
            StatsCard(
              icon: Icons.pending_actions,
              label: 'Pending',
              value: '$pendingApprovals',
              color: Colors.amber,
            ),
          ],
        );
      },
    );
  }
}

class _RecentBookingsList extends StatelessWidget {
  final List<VenueOwnerBookingDto> bookings;

  const _RecentBookingsList({required this.bookings});

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
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
          time: '${_formatTime(booking.startTime)} - ${_formatTime(booking.endTime)}',
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
          Icon(Icons.error_outline, color: AppTheme.error, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: AppTheme.onSurface, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
