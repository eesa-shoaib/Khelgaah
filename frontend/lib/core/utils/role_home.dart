import 'package:flutter/widgets.dart';
import 'package:frontend/core/api/api_models.dart';
import 'package:frontend/features/admin/admin_dashboard.dart';
import 'package:frontend/features/main_layout.dart';
import 'package:frontend/features/venue_owner/venue_owner_dashboard.dart';

Widget buildHomeForRole(UserProfile user) {
  switch (user.role) {
    case 'venue_owner':
      return const VenueOwnerDashboard();
    case 'admin':
      return const AdminDashboard();
    case 'customer':
    default:
      return const MainLayout();
  }
}
