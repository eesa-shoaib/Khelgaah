import 'package:flutter/material.dart';
import 'package:frontend/core/api/api_models.dart';
import 'package:frontend/core/app_controller.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/utils/app_feedback.dart';
import 'package:frontend/core/widgets/app_widgets.dart';
import 'package:frontend/features/booking/models/booked_facility_details.dart';
import 'package:frontend/features/booking/widgets/duration_stepper.dart';
import 'package:frontend/features/booking/widgets/time_slot_item.dart';

class BookingScreen extends StatefulWidget {
  final FacilityDto facility;

  const BookingScreen({super.key, required this.facility});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _selectedDayIndex = 0;
  int _selectedDuration = 60;
  SlotDto? _selectedSlot;
  bool _isLoadingSlots = true;
  bool _isSubmitting = false;
  String? _loadError;
  List<SlotDto> _slots = const [];
  bool _didLoadInitialSlots = false;

  List<DateTime> get _bookingDays {
    final today = DateTime.now();
    return List<DateTime>.generate(
      7,
      (index) => DateTime(today.year, today.month, today.day + index),
      growable: false,
    );
  }

  DateTime get _selectedDay => _bookingDays[_selectedDayIndex];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadInitialSlots) {
      return;
    }
    _didLoadInitialSlots = true;
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    final controller = AppScope.of(context);

    setState(() {
      _isLoadingSlots = true;
      _loadError = null;
      _selectedSlot = null;
    });

    try {
      final slots = await controller.apiClient.listAvailability(
        facilityId: widget.facility.id,
        date: _selectedDay,
        durationMinutes: _selectedDuration,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _slots = slots;
        _isLoadingSlots = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadError = error.message;
        _slots = const [];
        _isLoadingSlots = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadError = 'Could not load live availability.';
        _slots = const [];
        _isLoadingSlots = false;
      });
    }
  }

  Future<void> _createBooking() async {
    final slot = _selectedSlot;
    if (slot == null || _isSubmitting) {
      return;
    }

    final session = AppScope.of(context).session;
    if (session == null) {
      AppFeedback.pulseMessage(
        context,
        message: 'Sign in again before making a booking.',
        icon: Icons.lock_outline,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final booking = await AppScope.of(context).apiClient.createBooking(
        token: session.token,
        facilityId: widget.facility.id,
        startTime: slot.startTime,
        endTime: slot.endTime,
      );

      if (!mounted) {
        return;
      }

      AppFeedback.haptic(AppFeedbackType.success);
      Navigator.pop(
        context,
        BookedFacilityDetails(
          facilityName: widget.facility.name,
          facilityType: '${widget.facility.sport} • ${widget.facility.type}',
          facilitySummary: widget.facility.openSummary,
          startTime: booking.startTime.toLocal(),
          endTime: booking.endTime.toLocal(),
          durationMinutes: booking.endTime
              .difference(booking.startTime)
              .inMinutes,
          bookingId: booking.id.toString(),
          status: booking.status,
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      AppFeedback.pulseMessage(
        context,
        message: error.message,
        icon: Icons.error_outline,
      );
      await _loadSlots();
    } catch (_) {
      if (!mounted) {
        return;
      }

      AppFeedback.pulseMessage(
        context,
        message: 'Could not create booking.',
        icon: Icons.error_outline,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _formatDay(DateTime value) {
    const labels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return labels[value.weekday - 1];
  }

  String _formatTimeRange(SlotDto slot) {
    return '${_formatTime(slot.startTime.toLocal())} - ${_formatTime(slot.endTime.toLocal())}';
  }

  String _formatTime(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final suffix = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.facility.name),
        actions: const [ProfileActionIcon()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BookingSummaryCard(
            title: widget.facility.name,
            subtitle: '${widget.facility.sport} • ${widget.facility.type}',
            meta: widget.facility.openSummary.isEmpty
                ? 'LIVE BOOKING'
                : widget.facility.openSummary.toUpperCase(),
          ),
          const SizedBox(height: 20),
          const Text(
            'Pick a day',
            style: TextStyle(
              color: AppTheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 68,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _bookingDays.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final date = _bookingDays[index];

                return BookingDateChip(
                  day: _formatDay(date),
                  date: date.day.toString().padLeft(2, '0'),
                  isSelected: _selectedDayIndex == index,
                  onTap: () {
                    setState(() {
                      _selectedDayIndex = index;
                    });
                    _loadSlots();
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Duration',
            style: TextStyle(
              color: AppTheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          DurationStepper(
            duration: _selectedDuration,
            onChanged: (newDuration) {
              setState(() {
                _selectedDuration = newDuration;
              });
              _loadSlots();
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Available Slots',
            style: TextStyle(
              color: AppTheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoadingSlots)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_loadError != null)
            BookingSummaryCard(
              title: 'Availability unavailable',
              subtitle: _loadError!,
              meta: 'LIVE DATA',
            )
          else if (_slots.isEmpty)
            const BookingSummaryCard(
              title: 'No slots returned',
              subtitle:
                  'This facility has no operating hours or no slots for that day.',
              meta: 'LIVE DATA',
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _slots.length,
              itemBuilder: (context, index) {
                final slot = _slots[index];
                final available = slot.status == 'available';

                return TimeSlotItem(
                  time: available
                      ? _formatTimeRange(slot)
                      : '${_formatTimeRange(slot)}\n(Unavailable)',
                  isSelected: available && _selectedSlot == slot,
                  isAvailable: available,
                  onTap: () {
                    if (!available) {
                      return;
                    }
                    setState(() {
                      _selectedSlot = slot;
                    });
                  },
                );
              },
            ),
          const SizedBox(height: 16),
          ParallelogramButton(
            text: _isSubmitting
                ? 'Booking...'
                : (_selectedSlot == null ? 'Select a Slot' : 'Confirm Booking'),
            onPressed: _createBooking,
            fullWidth: true,
            icon: Icons.arrow_forward,
            enabled: _selectedSlot != null && !_isSubmitting,
          ),
        ],
      ),
    );
  }
}
