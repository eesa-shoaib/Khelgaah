import 'package:flutter/material.dart';
import 'package:frontend/core/api/api_models.dart';
import 'package:frontend/core/app_controller.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/status_badge_widget.dart';
import 'package:frontend/core/widgets/confirmation_dialog_widget.dart';
import 'package:frontend/core/widgets/parallelogram_btn.dart';
import 'package:frontend/core/utils/app_feedback.dart';

class BookingApprovalScreen extends StatefulWidget {
  final int bookingId;

  const BookingApprovalScreen({super.key, required this.bookingId});

  @override
  State<BookingApprovalScreen> createState() => _BookingApprovalScreenState();
}

class _BookingApprovalScreenState extends State<BookingApprovalScreen> {
  VenueOwnerBookingDto? _booking;
  bool _isLoading = true;
  bool _isProcessing = false;

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      _hasLoaded = true;
      Future.microtask(() {
        if (!mounted) return;
        _loadBookingDetails();
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadBookingDetails() async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) return;

    setState(() => _isLoading = true);

    try {
      final booking = await controller.apiClient
          .getBookingDetails(token: token, bookingId: widget.bookingId)
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      setState(() {
        _booking = booking;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppFeedback.pulseMessage(
        context,
        message: 'Error loading booking: $e',
        icon: Icons.error_outline,
      );
    }
  }

  Future<void> _updateStatus(String status) async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) return;

    if (status == 'rejected') {
      final confirmed = await ConfirmationDialog.show(
        context,
        title: 'Reject Booking',
        message: 'Are you sure you want to reject this booking?',
        confirmText: 'Reject',
        isDestructive: true,
      );
      if (!confirmed) return;
    }

    setState(() => _isProcessing = true);

    try {
      if (status == 'confirmed') {
        await controller.apiClient
            .approveBooking(token: token, bookingId: widget.bookingId)
            .timeout(const Duration(seconds: 10));
      } else {
        await controller.apiClient
            .rejectBooking(token: token, bookingId: widget.bookingId)
            .timeout(const Duration(seconds: 10));
      }

      if (!mounted) return;
      AppFeedback.pulseMessage(
        context,
        message: 'Booking $status successfully',
        icon: Icons.check_circle_outline,
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      AppFeedback.pulseMessage(
        context,
        message: 'Error: $e',
        icon: Icons.error_outline,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _booking == null
              ? const Center(child: Text('Booking not found'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainer,
                        border: Border.all(color: AppTheme.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Customer: ${_booking!.customerName}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.onSurface,
                                      ),
                                ),
                              ),
                              StatusBadge(
                                status: _booking!.status,
                                size: StatusBadgeSize.medium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _DetailRow(
                            icon: Icons.sports,
                            label: 'Facility',
                            value: _booking!.facilityName,
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.calendar_today,
                            label: 'Date',
                            value: _formatDate(_booking!.startTime),
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.access_time,
                            label: 'Time',
                            value:
                                '${_formatTime(_booking!.startTime)} - ${_formatTime(_booking!.endTime)}',
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.currency_rupee,
                            label: 'Amount',
                            value: 'PKR ${_booking!.totalAmount}',
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.payment,
                            label: 'Payment',
                            value: _booking!.paymentStatus,
                          ),
                          if (_booking!.notes != null) ...[
                            const SizedBox(height: 12),
                            _DetailRow(
                              icon: Icons.note,
                              label: 'Notes',
                              value: _booking!.notes!,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (_booking!.status == 'pending') ...[
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ParallelogramButton(
                              onPressed: _isProcessing
                                  ? () {}
                                  : () => _updateStatus('confirmed'),
                              text: 'Approve',
                              variant: ParallelogramButtonVariant.primary,
                              enabled: !_isProcessing,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ParallelogramButton(
                              onPressed: _isProcessing
                                  ? () {}
                                  : () => _updateStatus('rejected'),
                              text: 'Reject',
                              variant: ParallelogramButtonVariant.destructive,
                              enabled: !_isProcessing,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
