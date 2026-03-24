// lib/features/booking/booking_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/app_widgets.dart';
import 'package:frontend/features/booking/widgets/time_slot_item.dart';

class BookingScreen extends StatefulWidget {
  final String facilityName;

  const BookingScreen({super.key, this.facilityName = 'Selected Facility'});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int selectedDayIndex = 0;
  String? selectedTime;
  int selectedDuration = 60;

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

  final List<int> durations = const [30, 60, 90];

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
              color: AppTheme.textPrimary,
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
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Duration',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: durations.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final duration = durations[index];

                return SizedBox(
                  width: 112,
                  child: AppSelectableTile(
                    label: '$duration MIN',
                    isSelected: selectedDuration == duration,
                    onTap: () {
                      setState(() {
                        selectedDuration = duration;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Available Slots',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: timeSlots.length,
            itemBuilder: (context, index) {
              final time = timeSlots[index];
              final isAvailable = !unavailableSlots.contains(time);
              return TimeSlotItem(
                time: time,
                isSelected: isAvailable && selectedTime == time,
                isAvailable: isAvailable,
                onTap: () {
                  if (!isAvailable) {
                    return;
                  }

                  setState(() {
                    selectedTime = time;
                  });
                },
              );
            },
          ),
          const SizedBox(height: 16),
          ParallelogramButton(
            text: selectedTime == null ? 'Select a Slot' : 'Continue',
            onPressed: () {
              if (selectedTime == null) {
                return;
              }

              showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Booking Ready'),
                  content: Text(
                    '${widget.facilityName}\n${bookingDays[selectedDayIndex].$1} ${bookingDays[selectedDayIndex].$2} • $selectedTime\n$selectedDuration minutes',
                  ),
                  actions: [
                    ParallelogramButton(
                      text: 'Close',
                      onPressed: () => Navigator.pop(context),
                      variant: ParallelogramButtonVariant.surface,
                    ),
                    ParallelogramButton(
                      text: 'Confirm',
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Booked ${widget.facilityName} at $selectedTime for $selectedDuration minutes.',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
            fullWidth: true,
            icon: Icons.arrow_forward,
            enabled: selectedTime != null,
          ),
        ],
      ),
    );
  }
}
