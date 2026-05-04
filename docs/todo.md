# Khelgaah Project Todo List

## High Priority
- [ ] Complete payment gateway integration in backend (`internal/payments`).
- [ ] Implement actual payment processing in frontend (`features/booking`).
- [ ] Fix availability slot generation edge cases (overlapping slots).
- [ ] Add unit tests for `internal/venue_owner` and `internal/admin` services.
- [ ] Implement push notifications for booking confirmations.

## Medium Priority
- [ ] Add image upload support for Venues and Facilities (S3 or local storage).
- [ ] Implement user reviews and ratings system.
- [ ] Add map integration in search feature (Google Maps / Leaflet).
- [ ] Optimize database queries for facility search.
- [ ] Implement soft delete for venues and users.

## Low Priority
- [ ] Export analytics data to CSV/PDF for Admins.
- [ ] Refactor `main_layout.dart` for better responsiveness on tablet.

## Done
- [x] Basic Auth (Signup/Login) flow.
- [x] Venue and Facility listing APIs.
- [x] Basic Booking creation flow.
- [x] Customer and Venue Owner basic dashboards.
- [x] Initial database schema and migrations.
