import 'package:flutter/material.dart';
import 'package:frontend/core/api/api_models.dart';
import 'package:frontend/core/app_controller.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/booking_card_widget.dart';
import 'package:frontend/core/widgets/profile_action_icon.dart';
import 'package:frontend/core/widgets/filter_chips_widget.dart';
import 'package:frontend/features/venue_owner/booking_approval_screen.dart';

class VenueOwnerBookingsScreen extends StatefulWidget {
  const VenueOwnerBookingsScreen({super.key});

  @override
  State<VenueOwnerBookingsScreen> createState() =>
      _VenueOwnerBookingsScreenState();
}

class _VenueOwnerBookingsScreenState extends State<VenueOwnerBookingsScreen> {
  List<VenueOwnerBookingDto> _bookings = [];
  String? _selectedFilter;
  bool _isLoading = true;
  String? _error;

  final _filters = ['Pending', 'Confirmed', 'Rejected'];

  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      _hasLoaded = true;
      Future.microtask(() {
        if (!mounted) return;
        _loadBookings();
      });
    }
  }

  @override
  void initState() {
    super.initState();
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
          .listVenueOwnerBookings(token: token)
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

  Future<void> _updateBookingStatus(int bookingId, String status) async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) return;

    try {
      if (status == 'confirmed') {
        await controller.apiClient
            .approveBooking(token: token, bookingId: bookingId)
            .timeout(const Duration(seconds: 10));
      } else {
        await controller.apiClient
            .rejectBooking(token: token, bookingId: bookingId)
            .timeout(const Duration(seconds: 10));
      }
      _loadBookings();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking $status')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

    List<VenueOwnerBookingDto> get _filteredBookings {
    if (_selectedFilter == null) return _bookings;
    final filter = _selectedFilter!.toLowerCase();
    return _bookings.where((b) => b.status == filter).toList();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        actions: const [ProfileActionIcon()],
      ),
      body: Column(
        children: [
          FilterChipsWidget(
            filters: _filters,
            selected: _selectedFilter,
            onSelected: (filter) => setState(() => _selectedFilter = filter),
          ),
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

  Widget _buildBookingsList() {
    final bookings = _filteredBookings;

    if (bookings.isEmpty) {
      return const Center(child: Text('No bookings found'));
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingApprovalScreen(
                    bookingId: booking.id,
                  ),
                ),
              );
              if (result == true) {
                _loadBookings();
              }
            },
            child: BookingCard(
              key: ValueKey(booking.id),
              customerName: booking.customerName,
              facilityName: booking.facilityName,
              date: _formatDate(booking.startTime),
              time:
                  '${_formatTime(booking.startTime)} - ${_formatTime(booking.endTime)}',
              status: booking.status,
              showActions: booking.status == 'pending',
              onApprove: booking.status == 'pending'
                  ? () => _updateBookingStatus(
                        booking.id,
                        'confirmed',
                      )
                  : null,
              onReject: booking.status == 'pending'
                  ? () => _updateBookingStatus(
                        booking.id,
                        'rejected',
                      )
                  : null,
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
          Text(message, style: const TextStyle(color: AppTheme.error)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
