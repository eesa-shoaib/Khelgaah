import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../booking/booking_screen.dart';
import 'widgets/facility_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<String> facilities = const [
    'Tennis Court',
    'Swimming Pool',
    'Gym',
    'Badminton',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: facilities.length,
        itemBuilder: (context, index) {
          return FacilityCard(
            name: facilities[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookingScreen()),
              );
            },
          );
        },
      ),
    );
  }
}
