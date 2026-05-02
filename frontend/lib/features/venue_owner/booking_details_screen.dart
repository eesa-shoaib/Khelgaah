import 'package:flutter/material.dart';
import 'package:frontend/core/api/api_models.dart';
import 'package:frontend/core/app_controller.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/utils/app_feedback.dart';
import 'package:frontend/core/widgets/status_badge_widget.dart';
import 'package:frontend/core/widgets/confirmation_dialog_widget.dart';
import 'package:frontend/core/widgets/parallelogram_btn.dart';
import 'package:frontend/core/widgets/profile_action_icon.dart';

class BookingDetailsScreen extends StatefulWidget {
  final int bookingId;

  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  bool _isLoading = true;
  VenueOwnerBookingDto? _booking;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
  }

  Future<void> _loadBookingDetails() async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final booking = await controller.apiClient.getBookingDetails(
        token: token,
        bookingId: widget.bookingId,
      );
      if (!mounted) return;
      setState(() {
        _booking = booking;
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
        _error = 'Failed to load booking details.';
        _isLoading = false;
      });
    }
  }

  Future<void> _approveBooking() async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null || _booking == null) return;

    try {
      await controller.apiClient.approveBooking(
        token: token,
        bookingId: _booking!.id,
      );
      if (!mounted) return;
      AppFeedback.pulseMessage(
        context,
        message: 'Booking approved successfully.',
        icon: Icons.check_circle_outline,
      );
      _loadBookingDetails();
    } on ApiException catch (e) {
      if (!mounted) return;
      AppFeedback.pulseMessage(
        context,
        message: e.message,
        icon: Icons.error_outline,
      );
    }
  }

  Future<void> _rejectBooking() async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null || _booking == null) return;

    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Reject Booking',
      message: 'Are you sure you want to reject this booking?',
      confirmText: 'Reject',
      isDestructive: true,
    );

    if (!confirmed) return;

    try {
      await controller.apiClient.rejectBooking(
        token: token,
        bookingId: _booking!.id,
      );
      if (!mounted) return;
      AppFeedback.pulseMessage(
        context,
        message: 'Booking rejected.',
        icon: Icons.check_circle_outline,
      );
      _loadBookingDetails();
    } on ApiException catch (e) {
      if (!mounted) return;
      AppFeedback.pulseMessage(
        context,
        message: e.message,
        icon: Icons.error_outline,
      );
    }
  }

  Future<void> _cancelBooking() async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null || _booking == null) return;

    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to cancel this booking?'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'Enter cancellation reason',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          ParallelogramButton(
            onPressed: () => Navigator.pop(context, false),
            text: 'Back',
            variant: ParallelogramButtonVariant.surface,
          ),
          ParallelogramButton(
            onPressed: () => Navigator.pop(context, true),
            text: 'Cancel Booking',
            variant: ParallelogramButtonVariant.secondary,
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await controller.apiClient.cancelBooking(
        token: token,
        bookingId: _booking!.id,
        reason: reasonController.text.trim().isNotEmpty
            ? reasonController.text.trim()
            : null,
      );
      if (!mounted) return;
      AppFeedback.pulseMessage(
        context,
        message: 'Booking cancelled.',
        icon: Icons.check_circle_outline,
      );
      _loadBookingDetails();
    } on ApiException catch (e) {
      if (!mounted) return;
      AppFeedback.pulseMessage(
        context,
        message: e.message,
        icon: Icons.error_outline,
      );
    }
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
        title: const Text('Booking Details'),
        actions: [ProfileActionIcon()],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorState(message: _error!, onRetry: _loadBookingDetails)
              : _booking == null
                  ? const Center(child: Text('Booking not found.'))
                  : _buildBody(),
    );
  }

  Widget _buildBody() {
    final booking = _booking!;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatusCard(theme, booking),
        const SizedBox(height: 20),
        _buildSectionTitle(theme, 'Customer Info'),
        _buildInfoRow(theme, Icons.person_outline, 'Customer', booking.customerName),
        const SizedBox(height: 20),
        _buildSectionTitle(theme, 'Booking Info'),
        _buildInfoRow(theme, Icons.sports, 'Facility', booking.facilityName),
        _buildInfoRow(
          theme,
          Icons.calendar_today,
          'Date',
          _formatDate(booking.startTime),
        ),
        _buildInfoRow(
          theme,
          Icons.access_time,
          'Time',
          '${_formatTime(booking.startTime)} - ${_formatTime(booking.endTime)}',
        ),
        if (booking.notes != null && booking.notes!.isNotEmpty)
          _buildInfoRow(theme, Icons.note_outlined, 'Notes', booking.notes!),
        const SizedBox(height: 20),
        _buildSectionTitle(theme, 'Payment Info'),
        _buildInfoRow(
          theme,
          Icons.currency_rupee,
          'Total Amount',
          'PKR ${booking.totalAmount.toStringAsFixed(0)}',
        ),
        _buildInfoRow(
          theme,
          Icons.payment_outlined,
          'Payment Status',
          booking.paymentStatus[0].toUpperCase() +
              booking.paymentStatus.substring(1),
        ),
        const SizedBox(height: 24),
        if (booking.status == 'pending') ...[
          Row(
            children: [
              Expanded(
                child: ParallelogramButton(
                  onPressed: _approveBooking,
                  text: 'Approve',
                  variant: ParallelogramButtonVariant.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ParallelogramButton(
                  onPressed: _rejectBooking,
                  text: 'Reject',
                  variant: ParallelogramButtonVariant.destructive,
                ),
              ),
            ],
          ),
        ] else if (booking.status == 'confirmed') ...[
          SizedBox(
            width: double.infinity,
            child: ParallelogramButton(
              onPressed: _cancelBooking,
              text: 'Cancel Booking',
              variant: ParallelogramButtonVariant.secondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusCard(ThemeData theme, VenueOwnerBookingDto booking) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        border: Border(
          left: BorderSide(
            color: booking.status == 'confirmed' || booking.status == 'approved'
                ? Colors.greenAccent
                : booking.status == 'pending'
                    ? Colors.amberAccent
                    : AppTheme.error,
            width: 3,
          ),
          bottom: BorderSide(color: AppTheme.outlineVariant, width: 1),
          top: BorderSide(color: AppTheme.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking #${booking.id}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${booking.facilityName} • ${_formatDate(booking.startTime)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(status: booking.status, size: StatusBadgeSize.medium),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: AppTheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppTheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
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
          Text(message, style: const TextStyle(color: AppTheme.error)),
          const SizedBox(height: 12),
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
