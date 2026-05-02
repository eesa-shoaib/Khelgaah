I have a Flutter app "Khelgaah" for facility booking. I need minimal venue owner and admin screens.

BACKEND READY:
- Venue owner endpoints: /api/v1/venue-owner/venues, /bookings, /dashboard
- Admin endpoints: /api/v1/admin/users, /venues, /bookings
- JWT Bearer token auth working

CURRENT APP:
- Uses AppScope, AppController, ApiClient
- Theme: app_theme.dart with colors/fonts
- Widgets: parallelogram_btn.dart, app_action_tile.dart, etc.
- Screens: auth_screen.dart, home_screen.dart, booking_screen.dart

WHAT I NEED:

## VENUE OWNER SCREENS (5 screens):

1. **venue_owner_dashboard.dart**
   - Welcome message + user name
   - 3 stat cards: Total Venues, Total Bookings, Pending Approvals
   - Recent 5 bookings list
   - Button: "View All Bookings"

2. **venues_list_screen.dart**
   - List of venues (name, city, facility count, status badge)
   - FAB: Add new venue
   - Actions per venue: View, Edit, Delete
   - Empty state: "No venues yet"

3. **venue_bookings_screen.dart**
   - List all bookings for this venue owner
   - Filter chips: All, Pending, Confirmed, Rejected
   - Booking card: customer name, facility, date, time, status
   - If pending: Approve/Reject buttons
   - Tap to view details

4. **booking_approval_screen.dart**
   - Show booking details: customer, facility, date, time, amount
   - Button: Approve (green)
   - Button: Reject (red)
   - Auto-close after action

5. **venue_owner_profile_screen.dart**
   - Show: name, email, phone, role
   - Button: Change Password
   - Button: Logout

## ADMIN SCREENS (5 screens):

1. **admin_dashboard.dart**
   - 4 stat cards: Total Users, Total Venues, Total Bookings, Total Revenue
   - Pending venues count
   - Recent 5 activities list
   - Button: "Approve Venues"

2. **admin_users_screen.dart**
   - List all users with filters: Role (customer/venue_owner), Status (active/suspended)
   - User card: name, email, role, status
   - Actions: View, Suspend/Activate, Delete

3. **admin_venues_screen.dart**
   - List all venues with filters: Status (pending/approved/rejected)
   - Venue card: name, city, owner, status badge
   - If pending: Approve button, Reject button
   - If approved: Suspend button

4. **admin_bookings_screen.dart**
   - List all bookings system-wide
   - Filter: Status (pending/confirmed/rejected/completed)
   - Booking card: ID, customer, facility, date, status
   - Actions: Cancel, Mark Complete

5. **admin_profile_screen.dart**
   - Show: name, email, phone
   - Button: Change Password
   - Button: Logout

## NEW WIDGETS (create in frontend/lib/core/widgets/):

1. **status_badge.dart** - Shows status with color (pending=yellow, confirmed=green, rejected=red, suspended=red)
2. **stats_card.dart** - Shows stat: icon + value + label
3. **filter_chips.dart** - Horizontal scrollable filter chips

## REQUIREMENTS:

- Use existing app theme colors/fonts
- Match existing widget styles
- Use AppScope for controller/token
- Use ApiClient for all API calls
- Show user-friendly error messages
- Simple loading states (CircularProgressIndicator)
- Pull-to-refresh on list screens
- Null safety throughout
- Comments for complex logic

## API ENDPOINTS TO CALL:

**Venue Owner:**
- GET /api/v1/venue-owner/dashboard
- GET /api/v1/venue-owner/venues
- GET /api/v1/venue-owner/bookings
- PUT /api/v1/venue-owner/bookings/{id}/approve
- PUT /api/v1/venue-owner/bookings/{id}/reject
- GET /api/v1/venue-owner/profile

**Admin:**
- GET /api/v1/admin/dashboard
- GET /api/v1/admin/users
- GET /api/v1/admin/venues
- GET /api/v1/admin/bookings
- PUT /api/v1/admin/venues/{id}/approve
- PUT /api/v1/admin/venues/{id}/reject
- PUT /api/v1/admin/bookings/{id}/cancel
- GET /api/v1/admin/profile

## OUTPUT FORMAT:

For EACH screen, provide:
1. Complete working code (copy-paste ready)
2. All necessary imports
3. No external dependencies beyond what's already used

Deliver in this order:
1. All 3 new widgets first
2. All 5 venue owner screens
3. All 5 admin screens

Keep code SIMPLE, READABLE, and WORKING.
