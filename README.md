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

## Implemented Features

### Frontend (Flutter)
- **Home Screen** - Category-based facility discovery with sport icons
- **Search Screen** - Facility search with category filtering and ratings
- **Booking Flow**
  - Day selection with date chips
  - Duration stepper (30-min increments, min 30min, max 180min)
  - Dynamic timeslot availability based on selected duration
  - Timeslots show start-end times with clear unavailable states
- **Booking Confirmation** - Facility details, payment summary, access info
- **Loading Screen** - Animated launch screen with brand gradient effects
- **UI Components** - Reusable widgets (AppFacilityCard, AppRatingBadge, AppSelectableTile, etc.)
- **Dark Theme** - Consistent dark mode design system with orange accent colors

### Backend (Go)
- RESTful API structure
- PostgreSQL database integration

## License

This project is licensed under the MIT License.

## Author
__Eesa Shoaib__ Solo Architect & Developer
