import 'package:flutter/material.dart';
import 'package:frontend/core/app_controller.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/utils/app_feedback.dart';
import 'package:frontend/core/widgets/app_widgets.dart';
import 'package:frontend/features/booking/models/booked_facility_details.dart';
import 'package:frontend/features/booking/widgets/booked_facility_details_view.dart';

class BookedFacilityScreen extends StatefulWidget {
  final BookedFacilityDetails details;

  const BookedFacilityScreen({super.key, required this.details});

  @override
  State<BookedFacilityScreen> createState() => _BookedFacilityScreenState();
}

class _BookedFacilityScreenState extends State<BookedFacilityScreen> {
  late BookedFacilityDetails _details;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _details = widget.details;
  }

  bool get _canCancel {
    final status = _details.statusLabel.toLowerCase();
    return status == 'pending' || status == 'confirmed';
  }

  Future<void> _cancelBooking() async {
    final controller = AppScope.of(context);
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Cancel Booking',
      message: 'Are you sure you want to cancel this booking? This action cannot be undone.',
      confirmText: 'Cancel Booking',
      isDestructive: true,
    );

    if (!confirmed) return;

    final token = controller.session?.token;
    if (token == null) return;

    setState(() => _isCancelling = true);

    try {
      final bookingId = int.parse(_details.bookingId);
      await controller.apiClient
          .cancelMyBooking(token: token, bookingId: bookingId)
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      AppFeedback.pulseMessage(
        context,
        message: 'Booking cancelled successfully',
        icon: Icons.check_circle_outline,
      );

      setState(() {
        _details = BookedFacilityDetails(
          facilityName: _details.facilityName,
          facilityType: _details.facilityType,
          facilitySummary: _details.facilitySummary,
          startTime: _details.startTime,
          endTime: _details.endTime,
          durationMinutes: _details.durationMinutes,
          bookingId: _details.bookingId,
          status: 'cancelled',
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCancelling = false);
      AppFeedback.pulseMessage(
        context,
        message: 'Error: $e',
        icon: Icons.error_outline,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<BookedFacilityDetails>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }

        Navigator.of(context).pop(_details);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_details.facilityName),
          actions: const [ProfileActionIcon()],
        ),
        body: BookedFacilityDetailsView(details: _details),
        bottomNavigationBar: _canCancel
            ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  border: Border(
                    top: BorderSide(color: AppTheme.outlineVariant),
                  ),
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isCancelling ? null : _cancelBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: _isCancelling
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.cancel_outlined),
                      label: Text(
                        _isCancelling ? 'Cancelling...' : 'Cancel Booking',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
