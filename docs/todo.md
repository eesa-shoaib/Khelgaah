# Khelgaah TODO

## Integration

- Run backend and frontend together in a verified local setup.
- Add backend CORS support for Flutter Web.
- Document frontend `API_BASE_URL` usage for web, Android emulator, and local devices.
- Add a simple end-to-end happy path check: signup, browse, availability, book, view bookings.

## Frontend

- Finish replacing remaining placeholder UI data with backend data.
- Wire venue data into the home/search experience where needed.
- Load the authenticated user profile from `GET /api/v1/me`.
- Improve loading, empty, error, and retry states across API-driven screens.
- Persist auth/session flow cleanly across app restart and logout.
- Add widget/integration tests for auth, search, booking, and profile flows.

## Backend

- Add seed data for venues, facilities, and operating hours.
- Add CORS middleware and preflight handling.
- Add request validation consistency across all handlers.
- Expand test coverage for handlers, repositories, and booking edge cases.
- Add API docs for request/response payloads and error shapes.
- Add health/readiness guidance for local development.

## Booking and Product Gaps

- Implement real payment flow or clearly mark payment as placeholder.
- Support booking cancellation/reschedule.
- Show full booking history, not just latest booking summary.
- Add venue/operator and admin capabilities when MVP player flows are stable.

## Deployment and Ops

- Add environment setup docs for local and production-like runs.
- Add logging, metrics, and tracing basics.
- Add CI for backend tests, frontend tests, and formatting/lint checks.
- Plan Redis, outbox events, workers, and notifications for the next architecture step.
