// lib/features/booking/booking_screen.dart
import 'package:flutter/material.dart';
import 'widgets/time_slot_item.dart'; // Assuming you created this in the widgets folder

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // We store the selected time here to update the UI
  String? selectedTime;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Time Slot')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Available Slots",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Use GridView for the selectable boxes
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 boxes per row
                  childAspectRatio: 2.5, // Adjusts the height/width ratio
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: timeSlots.length,
                itemBuilder: (context, index) {
                  final time = timeSlots[index];
                  return TimeSlotItem(
                    time: time,
                    isSelected: selectedTime == time, // Logic to highlight
                    onTap: () {
                      setState(() {
                        selectedTime = time; // Update selection
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
