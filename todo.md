# Khelgaah Project - Remaining Tasks

## Project Overview

- **Project Name**: Khelgaah (Urdu for "Playground")
- **Type**: Tripartite Sports Ecosystem & Venue Management Platform
- **Tech Stack**: Flutter (Frontend), Go (Backend), PostgreSQL (Database)
- **Roles**: Customer, Venue Owner, Admin

---

## Implemented Components

### Backend (Go) - Mostly Complete

- **Auth**: Signup/Login with JWT tokens, role-based auth (customer/venue_owner only - admin creation via admin panel only)
- **Users**: Profile management, user status management
- **Venues**: Public listing, venue discovery
- **Facilities**: Search, filtering, facility listing
- **Availability**: Slot generation, availability checks with date/duration params
- **Bookings**: Create, list, approve/reject/cancel booking flow
- **Venue Owner Portal**: Dashboard stats, venue CRUD, facility CRUD, time slots management, booking management, analytics
- **Admin Portal**: User management, venue approval/suspension, booking management, system analytics, dashboard branding with AppLogo
- **Payments**: Model, repository, service, admin routes (integration incomplete)

**Availability rule update:** customer booking availability now only shows venue-owner-created `time_slots`. If a venue owner has not created slots for a facility/day, customers see no bookable timeslots.

### Frontend (Flutter) - Mostly Complete

- Home Screen with category-based facility discovery
- Search Screen with category filtering and ratings
- Booking Flow (day selection, duration stepper, timeslot availability)
- Booking Confirmation screen
- Booking Details Screen with cancel functionality (for pending/confirmed bookings)
- Loading Screen with animated branding
- Reusable UI components (AppFacilityCard, AppRatingBadge, etc.)
- Dark theme with orange accent
- Venue Owner Portal (Dashboard, Venues List, Facilities List, Bookings with approve/reject, Analytics) with AppLogo branding
- Venue Owner Booking Details Screen with approve/reject actions
- Admin Portal (Dashboard with real stats, AppLogo branding, User Management, Venue Management, Booking Management, Analytics)
- Profile Screen with Booking History (real API data), role-based navigation

---

## Remaining Tasks

## 0. Customer Booking Functionality (COMPLETED)

**Backend:**
- Added GET /api/v1/bookings/{id} endpoint for customers to view booking details
- Verified POST /api/v1/bookings/{id}/cancel endpoint works for customers

**Frontend:**
- Added getBookingById API method
- Added cancelBooking API method for customers
- Updated BookedFacilityScreen to show cancel button for pending/confirmed bookings
- Added confirmation dialog before cancellation
- Fixed venue owner approve/reject API calls to use PUT instead of POST

---

## 1. Frontend - Admin Portal (FUNCTIONAL)

The admin portal is wired to the backend routes and includes the operational flows the server supports.

**Implemented Components:**
- Admin dashboard with real stats from `/api/v1/admin/dashboard`
- User management: list users, filter by role/status, change role, suspend, delete
- Venue management: list venues, filter by status, approve/reject/suspend
- Booking management: list bookings, cancel, resolve disputes
- Payments management: list payments and process refunds
- Analytics screen: active customers/owners, confirmed bookings, refunded amount

**Design:**
- Dark theme consistent with existing frontend
- Filter chips for role/status filtering
- Action buttons for CRUD operations
- Loading states and error handling
- Color-coded status badges

---

## 2. Frontend - Venue Owner Portal (COMPLETE)

The venue owner backend is fully implemented and frontend owner screens exist.

**Already Implemented:**
- Owner Dashboard (stats: total venues, facilities, bookings, revenue, pending approvals)
- My Venues Screen (list owned venues, add new venue, edit venue, delete venue)
- Venue Details Screen (view/edit venue info)
- My Facilities Screen (list facilities per venue, add facility, edit facility, delete facility)
- Facility Details Screen (edit facility pricing, availability, operating hours)
- Time Slots Management (view slots, add custom slots, block dates)
- My Bookings Screen (list bookings for owned facilities, filter by status)
- Booking Details Screen (approve/reject/cancel bookings with notes)
- Analytics Screen (revenue charts, booking trends, popular times)

**Status:** All venue owner functionality is complete and integrated with backend.

---

## 3. Payment Integration

Backend has payment models/repos/services but actual payment gateway integration is incomplete.

**Backend Tasks:**
- Integrate with payment gateway (Razorpay/Stripe suggested)
- Implement payment creation, verification, webhook handling
- Add refund processing endpoint
- Add payment status tracking

**Frontend Tasks:**
- Add payment method selection in booking confirmation
- Integrate payment SDK in Flutter
- Handle payment success/failure callbacks
- Show payment history in user profile

---

## 4. Push Notifications

Not yet implemented.

**Required:**
- Firebase Cloud Messaging (FCM) integration
- Notification triggers for:
  - Booking confirmed
  - Booking approved/rejected
  - Booking reminder (1 hour before)
  - Payment received
- Backend endpoint to store FCM tokens
- Frontend notification handling and display

---

## 5. Image Upload for Venues/Facilities

Currently no image support.

**Required:**
- Backend: Image upload endpoint (S3 or local storage)
- Frontend: Image picker in venue/facility forms
- Image display in venue and facility cards/details

---

## 6. User Reviews and Ratings

Not yet implemented.

**Required:**
- Backend: Reviews table, API for submitting/retreiving reviews
- Frontend: Star rating component, reviews list on facility details
- Average rating calculation and display on facility cards

---

## 7. Map Integration

Not yet implemented.

**Required:**
- Frontend: Integrate Google Maps or Leaflet
- Show venue locations on map
- Map-based search/filtering
- Venue detail map view

---

## 8. Backend Enhancements

- Add database query optimization for facility search
- Implement soft delete for venues and users
- Add more unit tests for venue_owner and admin services
- Fix availability slot generation edge cases (overlapping slots)
- Add CORS configuration for frontend integration
- Export analytics data to CSV for admins
- Create seed command for admin user creation and demo data population

### Admin User Creation (TODO)

Currently no bootstrap mechanism exists to create the first admin user. Standard approaches:
- CLI seed command: `go run cmd/seed/main.go --create-admin email@domain.com`
- Env variable bootstrap: Set `ADMIN_EMAIL` + `ADMIN_PASSWORD` on first startup
- Database migration: Insert admin row directly via migration file

Recommended: Seed command that creates admin user and demo data on first run.

---

## 9. Frontend Enhancements

- Refactor main_layout.dart for better tablet responsiveness
- Add onboarding flow for new users
- Add favorite venues feature
- Add facility comparison feature

---

## Project Constraints

### Technical Constraints

1. **Database**: PostgreSQL with pgx/v5 (no ORM, raw SQL with repository pattern)
2. **Backend**: Go 1.26+, net/http (no framework like Gin/Echo)
3. **Frontend**: Flutter with Dart
4. **Authentication**: JWT tokens with role-based access control
5. **API Format**: RFC3339 timestamps, JSON responses

### Design Constraints

1. **Frontend Theme**: Dark mode with orange accent colors (#FF6B35 suggested)
2. **UI Pattern**: Consistent reusable widgets (AppFacilityCard, AppRatingBadge, etc.)
3. **Mobile First**: Design for mobile, then tablet responsiveness
4. **Icons**: Material Icons with sport-specific icons for categories

### Architecture Constraints

1. **Pattern**: Repository pattern in Go backend
2. **Middleware**: Request ID, recovery, auth, role-based guards
3. **Error Handling**: Consistent error responses with proper HTTP status codes
4. **Role-Based Access**:
   - `customer`: Can browse, book, review
   - `venue_owner`: Can manage own venues, facilities, bookings
   - `admin`: Full system access

### Business Constraints

1. **Booking Flow**: Request-based (venue owner approves/rejects), not instant confirmation
2. **Venue Status**: Must be approved by admin before visible to customers
3. **Payment**: Integrated but not real-time (gateway integration pending)
4. **Availability**: Slot-based, owners control time slots
5. **Signup Roles**: Only `customer` and `venue_owner` allowed; admin must be created via admin panel or seed command

### Current API Endpoints Summary

**Public:**
- GET /healthz
- POST /api/v1/auth/signup
- POST /api/v1/auth/login
- GET /api/v1/venues
- GET /api/v1/facilities
- GET /api/v1/facilities/{id}/availability

**Customer (authenticated):**
- GET /api/v1/me
- POST /api/v1/bookings
- GET /api/v1/bookings
- GET /api/v1/bookings/{id} (newly added)
- POST /api/v1/bookings/{id}/cancel

**Venue Owner (authenticated + role):**
- GET /api/v1/venue-owner/dashboard
- GET/POST /api/v1/venue-owner/venues
- GET/PUT/DELETE /api/v1/venue-owner/venues/{id}
- GET/POST /api/v1/venue-owner/venues/{venueID}/facilities
- PUT/DELETE /api/v1/venue-owner/facilities/{id}
- GET/POST /api/v1/venue-owner/time-slots
- GET/PUT/DELETE /api/v1/venue-owner/facilities/{id}/time-slots
- GET/PUT /api/v1/venue-owner/bookings/{id}/approve|reject|cancel
- GET /api/v1/venue-owner/analytics

**Admin (authenticated + admin role):**
- GET /api/v1/admin/dashboard
- GET/PUT/DELETE /api/v1/admin/users
- PUT /api/v1/admin/users/{id}/role|suspend
- GET /api/v1/admin/venues
- PUT /api/v1/admin/venues/{id}/approve|reject|suspend
- GET /api/v1/admin/bookings
- PUT /api/v1/admin/bookings/{id}/cancel|resolve
- GET /api/v1/admin/analytics
- GET/POST /api/v1/admin/payments

---

## Priority Order

### High Priority

1. ~~Frontend Admin Portal~~ (COMPLETED)
2. ~~Frontend Venue Owner Portal~~ (COMPLETED)
3. Payment Integration (backend gateway + frontend checkout)

### Medium Priority

4. Push Notifications (FCM setup + triggers)
5. Image Upload (backend storage + frontend picker)
6. User Reviews and Ratings

### Low Priority

7. Map Integration
8. Backend Optimizations and Tests
9. Frontend Enhancements (tablet, onboarding, favorites)

---

## Notes

- Backend is mostly complete and well-structured
- Frontend customer-facing features are done
- Admin and Venue Owner frontends are now complete
- Payment integration exists structurally but not connected to real gateway
- Profile screen now includes real booking history from API
- All APIs follow consistent patterns and are documented in `backend/API.md`
