# Khelgaah Frontend Documentation

## Overview
Flutter-based mobile application for Khelgaah - a tripartite sports ecosystem & venue management platform. Provides interfaces for Customers, Venue Owners, and Admins.

**Tech Stack:** Flutter (Dart), Material Design 3, Custom Dark Theme

## Features & Screens

### Authentication
- **Login Screen:** Email/password authentication with JWT token storage
- **Signup Screen:** Register as `customer` or `venue_owner` (admin not available via signup)
- **Loading Screen:** Animated branding splash screen

### Customer Features
- **Home Screen:** Sport categories, featured facilities, latest booking summary
- **Search Screen:** Filter facilities by sport, rating, venue
- **Booking Flow:**
  - Day selection (7-day view)
  - Duration stepper (30-120 min)
  - Time slot selection (from venue owner-created slots only)
  - Booking confirmation with facility details
- **Booking Details:** View/cancel pending or confirmed bookings
- **Profile Screen:** User info, booking history, role-based navigation

### Venue Owner Features
- **Dashboard:** Stats overview (venues, facilities, bookings, revenue, occupancy)
- **Venues List:** View/add/edit/delete venues
- **Venue Details:** View/edit venue info
- **Facilities List:** View/add/edit/delete facilities per venue
- **Facility Details:** Edit pricing, operating hours, slot duration
- **Time Slots Management:** Create/delete time slots for customers to book
- **Bookings:** List/approve/reject/cancel bookings for owned facilities
- **Analytics:** Revenue charts, booking trends, popular times

### Admin Features
- **Dashboard:** System-wide stats (users, venues, bookings, revenue, pending items)
- **User Management:** List/filter users by role/status, change role, suspend, delete
- **Venue Management:** List/filter venues by status, approve/reject/suspend
- **Booking Management:** List/filter bookings, force cancel, resolve disputes
- **Payments:** List/filter payments by status, process refunds
- **Analytics:** Active customers/owners, confirmed bookings, refunded amounts

## Directory Structure

```
lib/
├── main.dart                    # Entrypoint
├── app.dart                     # MaterialApp configuration
├── core/
│   ├── api/
│   │   ├── api_client.dart      # HTTP client, all API methods
│   │   └── api_models.dart      # DTOs (VenueDto, BookingDto, etc.)
│   ├── app_controller.dart      # Global state (GetIt singleton)
│   ├── theme/
│   │   └── app_theme.dart       # Dark theme, color tokens
│   ├── utils/
│   │   └── app_feedback.dart    # Snackbar/toast helpers
│   └── widgets/
│       ├── app_logo.dart        # Brand logo widget
│       ├── app_widgets.dart     # Exports all reusable widgets
│       ├── app_facility_card.dart
│       ├── booking_summary_card.dart
│       ├── parallelogram_btn.dart
│       ├── stats_card_widget.dart
│       ├── filter_chips_widget.dart
│       └── ... (more widgets)
├── features/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── category_facilities_screen.dart
│   ├── search/
│   │   └── search_screen.dart
│   ├── booking/
│   │   ├── booking_screen.dart      # Main booking flow
│   │   ├── booked_facility_screen.dart
│   │   ├── booking_screen.dart
│   │   ├── booking_confirmation_screen.dart
│   │   └── widgets/
│   ├── profile/
│   │   └── profile_screen.dart
│   ├── venue_owner/
│   │   ├── venue_owner_layout.dart   # Tab navigation shell
│   │   ├── venue_owner_dashboard.dart
│   │   ├── venues_list_screen.dart
│   │   ├── venue_details_screen.dart
│   │   ├── facilities_list_screen.dart
│   │   ├── facility_details_screen.dart
│   │   ├── time_slots_management_screen.dart
│   │   ├── venue_owner_bookings_screen.dart
│   │   ├── booking_details_screen.dart
│   │   └── venue_owner_analytics_screen.dart
│   ├── admin/
│   │   ├── admin_dashboard.dart     # Tab-based management
│   │   └── ... (management screens)
│   ├── bootstrap/
│   │   └── loading_screen.dart
│   └── main_layout.dart             # Bottom nav shell
```

## Design System

### Theme
- **Mode:** Dark theme with orange accent
- **Primary Color:** Orange (#FF6B35)
- **Surface:** Dark grays
- **Typography:** System fonts (no custom fonts bundled)

### Key Widgets
- `AppLogo`: Brand logo with italic text effect
- `AppFacilityCard`: Facility listing card
- `AppRatingBadge`: Star rating display
- `BookingSummaryCard`: Booking info summary
- `ParallelogramButton`: Styled action button
- `StatsCard`: Dashboard stat display
- `FilterChipsWidget`: Toggle filter chips
- `ErrorStateWidget`: Error state with retry

### Navigation
- **Customer:** Bottom nav (Home, Search, Bookings, Profile)
- **Venue Owner:** Tab nav (Dashboard, Venues, Bookings, Analytics)
- **Admin:** Tab nav (Overview, Users, Venues, Bookings, Payments, Analytics)

## Environment & Run

```bash
cd frontend

# Default: http://localhost:8080 (web) or http://10.0.2.2:8080 (Android emulator)
flutter run

# Custom API URL
flutter run --dart-define=API_BASE_URL=http://<your-ip>:8080

# Android physical device
adb reverse tcp:8080 tcp:8080
flutter run
```

## Code Quality

**Flutter Analyze:** Passes with no errors or warnings

- All `MaterialState*` deprecated APIs updated to `WidgetState*`
- Unnecessary imports cleaned up
- Unused classes removed
- Code follows Dart style guide

## Build Status

| Platform | Status |
|----------|--------|
| Android | ✅ Ready |
| Web | ✅ Ready |
| iOS | Not tested |

## API Integration

The frontend communicates with the backend via `ApiClient` class:

```dart
// Get instance
final client = AppScope.of(context).apiClient;

// Example: Load facilities
final facilities = await client.listFacilities();

// Example: Create booking
await client.createBooking(
  token: token,
  facilityId: 1,
  startTime: start,
  endTime: end,
);

// Example: Venue owner time slots
await client.addTimeSlot(
  token: token,
  facilityId: 1,
  startsAt: '2026-05-02T09:00:00Z',
  endsAt: '2026-05-02T10:00:00Z',
  slotType: 'available',
);
```

## Notes

- Uses `GetIt` for dependency injection via `AppScope`
- JWT token stored in `AppSession` and injected into API client
- All API calls return typed DTOs from `api_models.dart`
- Error handling via `ApiException` with status codes
- Flutter `mounted` checks before `setState()` in async operations
