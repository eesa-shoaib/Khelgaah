I have a Flutter app "Khelgaah" for a facility booking system.

CURRENT STATE:
- Existing Flutter screens and widgets in frontend/lib/
- UI is already styled with app theme, colors, fonts
- Existing widgets: app_logo.dart, app_action_tile.dart, app_text_field.dart, parallelogram_btn.dart, booking_summary_card.dart, etc.
- Current screens: auth_screen.dart, home_screen.dart, booking_screen.dart, bookings_screen.dart, profile_screen.dart, search_screen.dart

BACKEND IMPLEMENTED:
- Role-based auth (customer, venue_owner, admin)
- Venue owner endpoints: /api/v1/venue-owner/venues, /facilities, /time-slots, /bookings, /dashboard, /analytics
- Admin endpoints: /api/v1/admin/users, /venues, /bookings, /payments, /dashboard, /analytics
- JWT Bearer token authentication

WHAT I NEED:

### PART 1: UPDATE AUTH FLOW
Update frontend/lib/features/auth/auth_screen.dart to:
- Add role selection dropdown (customer, venue_owner, admin signup)
- Redirect user to correct dashboard after login based on role:
  - customer → home_screen (existing)
  - venue_owner → venue_owner_dashboard
  - admin → admin_dashboard

### PART 2: CREATE VENUE OWNER SCREENS

Create these screens in frontend/lib/features/venue_owner/:

**1. venue_owner_dashboard.dart**
- Display welcome message with venue owner name
- Show stats cards: Total Bookings, Total Revenue, Occupancy Rate, Pending Approvals
- Recent bookings list (latest 5)
- Quick action buttons: Add Venue, View Bookings, Manage Availability
- Use same card/tile styling as existing screens

**2. venues_list_screen.dart**
- List all venues owned by this user
- Each venue card shows: venue name, city, number of facilities, status (pending/approved/suspended)
- Add Venue button (FAB or top button)
- Swipe/tap to delete or view details
- Status badge (green for approved, yellow for pending)

**3. venue_details_screen.dart**
- Show venue info: name, address, city, latitude/longitude
- Edit button to update venue details
- List of facilities in this venue
- Add Facility button
- Delete venue button (with confirmation)

**4. facilities_list_screen.dart**
- List all facilities for a selected venue
- Each facility card: name, capacity, price per hour, status
- Add Facility button
- Tap to edit facility details
- Delete facility button
- Upload facility image button

**5. facility_details_screen.dart**
- Show facility: name, description, capacity, price, amenities
- Edit facility button
- Manage time slots button
- View bookings for this facility button
- Delete facility button

**6. time_slots_management_screen.dart**
- Calendar view showing available dates
- For selected date: show time slots
- Add new time slot button
- Block date button (for maintenance)
- Delete time slot button
- Bulk upload time slots option

**7. venue_owner_bookings_screen.dart**
- List all bookings for venue owner's facilities
- Filter by: status (pending, confirmed, rejected, cancelled), date range, facility
- Each booking card: customer name, facility, date, time, status
- Status badge (red=pending, green=confirmed, gray=rejected/cancelled)
- Tap to view booking details
- Approve/Reject buttons (if pending)
- Cancel button (if confirmed)
- View customer info button

**8. booking_details_screen.dart (for venue owner)**
- Show full booking details: customer info, facility, date, time, notes
- Payment info: total amount, payment status
- Approve button (if pending)
- Reject button (if pending)
- Cancel button (if confirmed, with reason)
- Notes section

**9. venue_owner_analytics_screen.dart**
- Charts/graphs showing:
  - Revenue over time (line chart)
  - Bookings by facility (bar chart)
  - Occupancy rate by facility
  - Peak hours analysis
- Date range filter
- Export to PDF/Excel button (optional for MVP)

**10. venue_owner_profile_screen.dart**
- Show owner details: name, email, phone
- Edit profile button
- Bank details section (for payments)
- Change password button
- Notification preferences
- Logout button

### PART 3: CREATE ADMIN SCREENS

Create these screens in frontend/lib/features/admin/:

**1. admin_dashboard.dart**
- Show system-wide stats: Total Users, Total Venues, Total Bookings, Total Revenue
- Active users count, New venues (pending approval)
- Charts: Revenue trend, Booking trend
- Recent activities feed (latest 10 actions)
- Quick action buttons: Approve Venues, Resolve Disputes, View Reports

**2. users_management_screen.dart**
- List all users with filters: role (customer, venue_owner), status (active, suspended)
- User card: name, email, role, status, join date
- Status badge (green=active, red=suspended)
- Tap to view user details
- Suspend/activate button
- Delete user button (with confirmation)

**3. user_details_screen.dart**
- Show user info: name, email, phone, role, status, join date
- User's booking history (if customer)
- User's venues (if venue owner)
- Change role button
- Suspend/activate button
- Delete button

**4. venues_approval_screen.dart**
- List all venues with status: pending, approved, rejected, suspended
- Filter by status
- Each venue card: name, city, owner name, status, created date
- Status badge colors: yellow=pending, green=approved, red=rejected, gray=suspended
- Tap to view venue details
- Approve button (if pending)
- Reject button (if pending)
- Suspend button (if approved)

**5. venue_approval_details_screen.dart**
- Show venue info: name, address, city, owner contact
- Facilities list
- Approve button (if pending)
- Reject button (if pending) with reason text field
- Suspend button with reason

**6. admin_bookings_screen.dart**
- List ALL bookings system-wide
- Filter by: status (pending, confirmed, rejected, cancelled, completed), date range, venue
- Each booking card: booking ID, customer, facility, venue, date, status
- Status badges with colors
- Tap to view details
- Cancel button (force cancel with reason)
- Mark as completed button (if confirmed)

**7. booking_dispute_screen.dart**
- Show booking details
- Dispute reason text (if disputed)
- Admin notes section
- Options: Approve booking, Cancel with refund, Custom resolution
- Process refund button
- Notes text field
- Submit button

**8. payments_management_screen.dart**
- List all transactions
- Filter by: status (pending, success, failed, refunded), date range
- Each transaction: booking ID, amount, method, status, date
- Status badges: green=success, red=failed, orange=refunded
- Tap to view details
- Process refund button
- Generate receipt button

**9. payment_details_screen.dart**
- Show payment info: booking details, amount, method, status
- Customer info
- Refund section (if needed)
- Refund reason text field
- Process refund button

**10. admin_analytics_screen.dart**
- System-wide analytics:
  - Revenue chart (line graph)
  - Bookings chart (bar graph)
  - Users growth chart
  - Top venues by revenue
  - User satisfaction metrics
- Date range filter
- Download reports button (CSV/PDF optional)

**11. admin_profile_screen.dart**
- Admin details: name, email, phone
- Edit profile button
- Change password button
- Activity logs (last 20 actions by this admin)
- Notification preferences
- Logout button

### PART 4: CREATE NEW REUSABLE WIDGETS
Place all new widgets in frontend/lib/core/widgets/:

**1. status_badge_widget.dart**
- Display status with appropriate color/icon
- Props: status (string), size (small, medium, large)
- Colors: pending=yellow, confirmed=green, rejected=red, cancelled=gray, approved=green, suspended=red
- Usage: `StatusBadge(status: 'confirmed')`

**2. stats_card_widget.dart**
- Display stat with icon, value, label
- Props: icon, label, value, color
- Usage: `StatsCard(icon: Icons.booking, label: 'Total Bookings', value: '45')`

**3. filter_chips_widget.dart**
- Horizontal scrollable filter chips
- Props: filters (list), onSelected
- Usage: For status filters, date filters

**4. date_range_picker_widget.dart**
- Pick date range (from date - to date)
- Props: onDateRangeSelected
- Usage: For analytics date range

**5. booking_card_widget.dart**
- Display booking summary
- Props: booking object, showActions (bool), onApprove, onReject, onCancel
- Usage: In booking lists

**6. venue_card_widget.dart**
- Display venue summary
- Props: venue object, showActions (bool), onEdit, onDelete, onView
- Usage: In venue lists

**7. facility_card_widget.dart**
- Display facility summary
- Props: facility object, showActions (bool), onEdit, onDelete
- Usage: In facility lists

**8. user_card_widget.dart**
- Display user summary
- Props: user object, showActions (bool), onSuspend, onDelete, onView
- Usage: In user management lists

**9. chart_widget.dart**
- Display line or bar chart
- Props: type (line/bar), data, title
- Use: fl_chart package
- Usage: For analytics graphs

**10. confirmation_dialog_widget.dart**
- Reusable confirmation dialog
- Props: title, message, onConfirm, onCancel
- Usage: Before deleting/cancelling

### PART 5: UPDATE APP ROUTING
Update frontend/lib/app.dart or main.dart route definitions:
- Add route for venue_owner_dashboard
- Add route for admin_dashboard
- Add all new screens as routes
- Update navigation based on user role

### PART 6: UPDATE AUTH SERVICE
Update frontend/lib/core/services/ or relevant auth service:
- Store user role in SharedPreferences
- Implement role-based navigation after login
- Add helper functions: isVenueOwner(), isAdmin(), isCustomer()

### PART 7: API CLIENT
Update HTTP client to include:
- Base URLs for venue_owner endpoints: /api/v1/venue-owner/
- Base URLs for admin endpoints: /api/v1/admin/
- Bearer token in all requests

### REQUIREMENTS:
- Follow EXISTING app theme, colors, fonts, styling
- Use Material Design 3
- Consistent with existing screens (booking_screen.dart, home_screen.dart, etc.)
- Dark mode support (if app supports it)
- Responsive design (works on different screen sizes)
- Error handling with user-friendly messages
- Loading indicators for API calls
- Empty state messages (no data found)
- All new widgets in frontend/lib/core/widgets/
- Comments explaining complex UI logic
- Use null safety (?)
- Proper state management (Provider, Riverpod, or GetX - whatever you use)

### OUTPUT FORMAT:
For each screen, provide:
1. Screen dart file (complete code)
2. Models/DTOs if needed
3. API service calls used
4. Any dependencies needed (add to pubspec.yaml)

### EXAMPLE STRUCTURE:
frontend/lib/
├── core/
│   └── widgets/
│       ├── status_badge_widget.dart
│       ├── stats_card_widget.dart
│       ├── filter_chips_widget.dart
│       ├── booking_card_widget.dart
│       └── ... (all new widgets)
├── features/
│   ├── venue_owner/
│   │   ├── venue_owner_dashboard.dart
│   │   ├── venues_list_screen.dart
│   │   ├── venue_details_screen.dart
│   │   ├── facilities_list_screen.dart
│   │   ├── facility_details_screen.dart
│   │   ├── time_slots_management_screen.dart
│   │   ├── venue_owner_bookings_screen.dart
│   │   ├── booking_details_screen.dart
│   │   ├── venue_owner_analytics_screen.dart
│   │   └── venue_owner_profile_screen.dart
│   ├── admin/
│   │   ├── admin_dashboard.dart
│   │   ├── users_management_screen.dart
│   │   ├── user_details_screen.dart
│   │   ├── venues_approval_screen.dart
│   │   ├── venue_approval_details_screen.dart
│   │   ├── admin_bookings_screen.dart
│   │   ├── booking_dispute_screen.dart
│   │   ├── payments_management_screen.dart
│   │   ├── payment_details_screen.dart
│   │   ├── admin_analytics_screen.dart
│   │   └── admin_profile_screen.dart
│   └── auth/
│       └── auth_screen.dart (updated)
### CONSISTENCY:
- Use existing app colors (check app_theme.dart)
- Use existing fonts and typography
- Use existing widget patterns
- Match button styles (parallelogram_btn.dart)
- Match card styles (booking_summary_card.dart)
- Match input styles (app_text_field.dart)
- Same spacing/padding conventions
- Same error/success message patterns

Please provide COMPLETE, production-ready Flutter code that I can directly copy to my project.
