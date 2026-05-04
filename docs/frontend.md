# Khelgaah Frontend Documentation

## Overview
Flutter-based mobile/web application for Khelgaah. Provides interfaces for Customers, Venue Owners, and Admins.

## Tech Stack
- **Framework:** Flutter (Dart)
- **State Management:** (Likely GetX or Provider based on `app_controller.dart` presence, needs verification)
- **Design System:** Custom theme with Satoshi font.

## Directory Structure
- `lib/main.dart`: Entrypoint.
- `lib/app.dart`: App configuration.
- `lib/core/`: Shared logic.
  - `api/`: API client and endpoint definitions.
  - `theme/`: Styling and design tokens.
  - `utils/`: Helpers and formatters.
  - `widgets/`: Reusable UI components.
- `lib/features/`: Feature-based modules.
  - `auth/`: Login, Registration, Password recovery.
  - `home/`: Dashboard/Landing page for users.
  - `search/`: Venue and facility search.
  - `booking/`: Booking flow and checkout.
  - `profile/`: User settings and booking history.
  - `venue_owner/`: Owner dashboard and venue management.
  - `admin/`: Admin panels and analytics.
  - `bootstrap/`: Initial loading and initialization logic.
  - `main_layout.dart`: Shell/Navigation layout.

## Environment & Run
- **Default Base URL:** `http://localhost:8080` (Web) or `http://10.0.2.2:8080` (Android Emulator).
- **Run with custom API URL:**
  ```bash
  flutter run --dart-define=API_BASE_URL=http://<your-ip>:8080
  ```
- **Android Physical Device:**
  ```bash
  adb reverse tcp:8080 tcp:8080
  flutter run --dart-define=API_USE_ADB_REVERSE=true
  ```
