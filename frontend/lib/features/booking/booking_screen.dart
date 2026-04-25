// lib/features/booking/booking_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/utils/app_feedback.dart';
import 'package:frontend/core/widgets/app_widgets.dart';
import 'package:frontend/features/booking/booked_facility_screen.dart';
import 'package:frontend/features/booking/models/booked_facility_details.dart';
import 'package:frontend/features/booking/widgets/time_slot_item.dart';
import 'package:frontend/features/booking/widgets/duration_stepper.dart';

class BookingScreen extends StatefulWidget {
  final String facilityName;

  const BookingScreen({super.key, this.facilityName = 'Selected Facility'});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int selectedDayIndex = 0;
  String? selectedTime;
  int selectedDuration = 30;

  final List<(String, String)> bookingDays = const [
    ('MON', '24'),
    ('TUE', '25'),
    ('WED', '26'),
    ('THU', '27'),
  ];

  final List<String> timeSlots = const [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
  ];

  final Set<String> unavailableSlots = const {
    '11:00 AM',
    '02:00 PM',
    '04:00 PM',
  };

  bool _canAccommodateDuration(String startTime, int duration) {
    final slotIndex = timeSlots.indexOf(startTime);
    if (slotIndex == -1) return false;

    final slotsNeeded = duration ~/ 30;
    if (slotIndex + slotsNeeded > timeSlots.length) return false;

    for (var i = 0; i < slotsNeeded; i++) {
      if (unavailableSlots.contains(timeSlots[slotIndex + i])) {
        return false;
      }
    }
    return true;
  }

  String _getEndTime(String startTime, int durationMinutes) {
    final timeParts = startTime.split(' ');
    final time = timeParts[0];
    final period = timeParts[1];

    final timeParts2 = time.split(':');
    var hour = int.parse(timeParts2[0]);
    final minute = int.parse(timeParts2[1]);

    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    final start = DateTime(2024, 1, 1, hour, minute);
    final end = start.add(Duration(minutes: durationMinutes));

    final endHour = end.hour;
    final endPeriod = endHour >= 12 ? 'PM' : 'AM';
    final displayEndHour = endHour > 12
        ? endHour - 12
        : (endHour == 0 ? 12 : endHour);

    return '$displayEndHour:${end.minute.toString().padLeft(2, '0')} $endPeriod';
  }

  double get _subtotal {
    final ratePerHour = 32.0;
    return (selectedDuration / 60) * ratePerHour;
  }

  Future<void> _openBookedFacilityScreen() async {
    if (selectedTime == null) {
      return;
    }

    AppFeedback.haptic(AppFeedbackType.success);
    final details = BookedFacilityDetails(
      facilityName: widget.facilityName,
      dayLabel: bookingDays[selectedDayIndex].$1,
      dateLabel: bookingDays[selectedDayIndex].$2,
      timeLabel: selectedTime!,
      durationMinutes: selectedDuration,
      subtotal: _subtotal,
      serviceFee: 3.5,
      bookingId: 'KF-${bookingDays[selectedDayIndex].$2}$selectedDuration',
      accessNote: 'Court assignment is shared at reception after payment.',
    );

    final updatedDetails = await Navigator.push<BookedFacilityDetails>(
      context,
      MaterialPageRoute(builder: (_) => BookedFacilityScreen(details: details)),
    );

    if (!mounted) {
      return;
    }

    Navigator.pop(context, updatedDetails ?? details);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.facilityName),
        actions: const [ProfileActionIcon()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BookingSummaryCard(
            title: widget.facilityName,
            subtitle: selectedTime == null
                ? 'Choose a day, duration, and slot.'
                : '${bookingDays[selectedDayIndex].$1} ${bookingDays[selectedDayIndex].$2} • $selectedTime • $selectedDuration minutes',
            meta: 'BOOKING PANEL',
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
              itemCount: bookingDays.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final (day, date) = bookingDays[index];

                return BookingDateChip(
                  day: day,
                  date: date,
                  isSelected: selectedDayIndex == index,
                  onTap: () {
                    setState(() {
                      selectedDayIndex = index;
                    });
                    AppFeedback.pulseMessage(
                      context,
                      message: 'Day set to $day $date.',
                      icon: Icons.calendar_today_outlined,
                    );
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
            duration: selectedDuration,
            onChanged: (newDuration) {
              setState(() {
                selectedDuration = newDuration;
                selectedTime = null;
              });
              AppFeedback.pulseMessage(
                context,
                message: '$newDuration minute session selected.',
                icon: Icons.timelapse_outlined,
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Available Slots',
            style: TextStyle(
              color: AppTheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (context) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.8,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: timeSlots.length,
                itemBuilder: (context, index) {
                  final time = timeSlots[index];
                  final canAccommodate = _canAccommodateDuration(
                    time,
                    selectedDuration,
                  );
                  final endTime = _getEndTime(time, selectedDuration);
                  final displayText = canAccommodate
                      ? '$time - $endTime'
                      : '$time\n(Unavailable)';

                  return TimeSlotItem(
                    time: displayText,
                    isSelected: canAccommodate && selectedTime == time,
                    isAvailable: canAccommodate,
                    onTap: () {
                      if (!canAccommodate) return;
                      setState(() {
                        selectedTime = time;
                      });
                      AppFeedback.pulseMessage(
                        context,
                        message: '$time locked in.',
                        icon: Icons.schedule,
                      );
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),
          ParallelogramButton(
            text: selectedTime == null ? 'Select a Slot' : 'Continue',
            onPressed: _openBookedFacilityScreen,
            fullWidth: true,
            icon: Icons.arrow_forward,
            enabled: selectedTime != null,
          ),
        ],
      ),
    );
  }
}
