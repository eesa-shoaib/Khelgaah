import 'package:flutter/material.dart';
import 'package:frontend/core/api/api_models.dart';
import 'package:frontend/core/app_controller.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/parallelogram_btn.dart';
import 'package:frontend/core/widgets/profile_action_icon.dart';
import 'package:frontend/core/utils/app_feedback.dart';
import 'package:frontend/features/auth/auth_screen.dart';
import 'package:frontend/features/profile/widgets/profile_header.dart';
import 'package:frontend/features/profile/widgets/profile_menu_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = AppScope.of(context).session;
    final name = session?.user.fullName ?? 'Player';
    final email = session?.user.email ?? 'Not signed in';
    final role = session?.user.role ?? 'customer';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            ProfileHeader(name: name, email: email),
            const SizedBox(height: 10),
            const Divider(color: AppTheme.outlineVariant),
            ProfileMenuItem(
              icon: Icons.history,
              title: 'Booking History',
              onTap: () => _navigateToBookings(context),
              isDestructive: false,
            ),
            ProfileMenuItem(
              icon: Icons.sports,
              title: 'My Sports',
              onTap: () => _showInfoDialog(
                context,
                title: 'My Sports',
                description: 'Preferred sports and activity tracking coming soon.',
              ),
              isDestructive: false,
            ),
            if (role == 'venue_owner')
              ProfileMenuItem(
                icon: Icons.dashboard,
                title: 'Owner Dashboard',
                onTap: () => _navigateToOwnerDashboard(context),
                isDestructive: false,
              ),
            if (role == 'admin')
              ProfileMenuItem(
                icon: Icons.admin_panel_settings,
                title: 'Admin Panel',
                onTap: () => _navigateToAdminDashboard(context),
                isDestructive: false,
              ),
            ProfileMenuItem(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () => _showInfoDialog(
                context,
                title: 'Settings',
                description: 'Notifications, preferred sports, and payment methods will be managed here.',
              ),
              isDestructive: false,
            ),
            ProfileMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              isDestructive: true,
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToBookings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BookingHistoryScreen()),
    );
  }

  void _navigateToOwnerDashboard(BuildContext context) {
    Navigator.pushNamed(context, '/venue-owner');
  }

  void _navigateToAdminDashboard(BuildContext context) {
    Navigator.pushNamed(context, '/admin');
  }

  void _showInfoDialog(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    AppFeedback.haptic(AppFeedbackType.tap);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          ParallelogramButton(
            onPressed: () => Navigator.pop(context),
            text: 'Close',
            variant: ParallelogramButtonVariant.surface,
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    AppFeedback.haptic(AppFeedbackType.tap);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          ParallelogramButton(
            onPressed: () => Navigator.pop(context),
            text: 'Cancel',
            variant: ParallelogramButtonVariant.surface,
          ),
          ParallelogramButton(
            onPressed: () async {
              await AppScope.of(context).logout();
              if (!context.mounted) {
                return;
              }
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
              );
            },
            text: 'Logout',
            variant: ParallelogramButtonVariant.destructive,
          ),
        ],
      ),
    );
  }
}

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  List<BookingDto> _bookings = [];
  String? _selectedStatus;
  bool _isLoading = true;
  String? _error;

  final _filters = ['all', 'pending', 'confirmed', 'completed', 'cancelled', 'rejected'];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bookings = await controller.apiClient
          .listBookings(token: token)
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      setState(() {
        _bookings = bookings;
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
        _error = 'Failed to load bookings.';
        _isLoading = false;
      });
    }
  }

  List<BookingDto> get _filteredBookings {
    if (_selectedStatus == null || _selectedStatus == 'all') {
      return _bookings;
    }
    return _bookings.where((b) => b.status == _selectedStatus).toList();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.amber;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return AppTheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking History'),
        actions: const [ProfileActionIcon()],
      ),
      body: Column(
        children: [
          _buildStatusFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _ErrorState(message: _error!, onRetry: _loadBookings)
                    : _buildBookingsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: _filters.map((filter) {
          final isSelected = _selectedStatus == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedStatus = filter),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.surfaceContainer,
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.outlineVariant,
                ),
              ),
              child: Center(
                child: Text(
                  filter[0].toUpperCase() + filter.substring(1),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppTheme.onPrimary : AppTheme.onSurface,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBookingsList() {
    final bookings = _filteredBookings;

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48, color: AppTheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              'No bookings found',
              style: TextStyle(color: AppTheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              border: Border(
                left: BorderSide(
                  color: _statusColor(booking.status),
                  width: 3,
                ),
                top: BorderSide(color: AppTheme.outlineVariant),
                bottom: BorderSide(color: AppTheme.outlineVariant),
                right: BorderSide(color: AppTheme.outlineVariant),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Booking #${booking.id}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onSurface,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusColor(booking.status).withValues(alpha: 0.2),
                      ),
                      child: Text(
                        booking.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _statusColor(booking.status),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: AppTheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(booking.startTime),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.onSurface,
                          ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 14, color: AppTheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatTime(booking.startTime)} - ${_formatTime(booking.endTime)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.onSurface,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.confirmation_number, size: 14, color: AppTheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(
                      'Facility #${booking.facilityId}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
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
          ParallelogramButton(
            onPressed: onRetry,
            text: 'Retry',
            variant: ParallelogramButtonVariant.primary,
          ),
        ],
      ),
    );
  }
}
