import 'package:flutter/material.dart';
import 'package:frontend/core/app_controller.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/app_widgets.dart';

class VenueOwnerDashboard extends StatelessWidget {
  const VenueOwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AppScope.of(context).session?.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Venue Owner'),
        actions: const [ProfileActionIcon()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BookingSummaryCard(
            title: 'Welcome, ${user?.fullName ?? 'Owner'}',
            subtitle:
                'Role-based auth is live. Venue owner dashboard routing now works.',
            meta: 'VENUE OWNER',
          ),
          const SizedBox(height: 20),
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: AppTheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          AppActionTile(
            title: 'Add Venue',
            leadingIcon: Icons.add_business_outlined,
            onTap: () {},
          ),
          AppActionTile(
            title: 'View Bookings',
            leadingIcon: Icons.event_note_outlined,
            onTap: () {},
          ),
          AppActionTile(
            title: 'Manage Availability',
            leadingIcon: Icons.schedule_outlined,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
