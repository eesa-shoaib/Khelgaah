import 'package:flutter/material.dart';
import 'package:frontend/core/api/api_models.dart';
import 'package:frontend/core/app_controller.dart';
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

  final _sampleBookings = [
    VenueOwnerBookingDto(
      id: 1,
      userId: 101,
      customerName: 'Ahmed Ali',
      facilityId: 1,
      facilityName: 'Football Turf A',
      startTime: DateTime.now().add(const Duration(days: 1)),
      endTime: DateTime.now().add(const Duration(days: 1, hours: 1)),
      status: 'pending',
      totalAmount: 2000,
      paymentStatus: 'paid',
    ),
    VenueOwnerBookingDto(
      id: 2,
      userId: 102,
      customerName: 'Fatima Khan',
      facilityId: 2,
      facilityName: 'Cricket Pitch',
      startTime: DateTime.now().add(const Duration(days: 2)),
      endTime: DateTime.now().add(const Duration(days: 2, hours: 2)),
      status: 'confirmed',
      totalAmount: 3000,
      paymentStatus: 'paid',
    ),
    VenueOwnerBookingDto(
      id: 3,
      userId: 103,
      customerName: 'Usman Tariq',
      facilityId: 1,
      facilityName: 'Football Turf A',
      startTime: DateTime.now().subtract(const Duration(days: 1)),
      endTime: DateTime.now().subtract(const Duration(days: 1, hours: -1)),
      status: 'rejected',
      totalAmount: 2000,
      paymentStatus: 'pending',
    ),
  ];

  final _filters = ['Pending', 'Confirmed', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _bookings = _sampleBookings;
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) return;

    try {
      final bookings = await controller.apiClient
          .listVenueOwnerBookings(token: token)
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      setState(() => _bookings = bookings);
    } catch (_) {
      // Keep showing sample data on error
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
    final bookings = _filteredBookings;

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
            child: RefreshIndicator(
              onRefresh: _loadBookings,
              child: bookings.isEmpty
                  ? const Center(child: Text('No bookings found'))
                  : ListView.builder(
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
            ),
          ),
        ],
      ),
    );
  }
}
