# Khelgaah
### _The Ultimate Tripartite Sports Ecosystem & Venue Management Platform_

## Overview

Khelgaah (Urdu for "Playground") is a centralized digital bridge designed to solve the fragmentation in amateur sports. It replaces manual, error-prone booking systems with a high-performance marketplace connecting Players, Venue Owners, and Tournament Organizers.

Most booking apps fail at concurrency. Khelgaah is built with a "Consistency-First" philosophy, utilizing atomic transactions and robust database locking to eliminate double-bookings and streamline community-led competition.

## Tech Stack

| Component | Technology |
| --------- | ---------- |
| Frontend | Flutter (Dart) |
| Backend | Go (Golang) |
| Database | PostgreSQL |

## Running the Project

### Backend
```bash
cd backend
go run ./cmd/api
```

### Frontend (with Android Emulator)
```bash
# Set up port forwarding for local backend
adb reverse tcp:8080 tcp:8080

cd frontend
flutter run --dart-define=API_USE_ADB_REVERSE=true
```

## Implemented Features

### Frontend (Flutter)
- **Customer Portal** - Book time slot for a facility
- **Venue Owner Portal** - Venue approval state, booking approval/rejection, and timeslot management
- **Admin Portal** - User, venue, booking, and analytics management

### Backend (Go)
- RESTful API structure
- PostgreSQL database integration

## License

This project is licensed under the MIT License.

## Author
__Eesa Shoaib__ Solo Architect & Developer
