import 'package:flutter/material.dart';
import 'package:frontend/core/app_controller.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/app_widgets.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AppScope.of(context).session?.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        actions: const [ProfileActionIcon()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BookingSummaryCard(
            title: 'Welcome, ${user?.fullName ?? 'Admin'}',
            subtitle:
                'Role-based auth is live. Admin dashboard routing now works.',
            meta: 'ADMIN',
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
            title: 'Approve Venues',
            leadingIcon: Icons.approval_outlined,
            onTap: () {},
          ),
          AppActionTile(
            title: 'Manage Users',
            leadingIcon: Icons.group_outlined,
            onTap: () {},
          ),
          AppActionTile(
            title: 'View Reports',
            leadingIcon: Icons.analytics_outlined,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
