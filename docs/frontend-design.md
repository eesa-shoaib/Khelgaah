# Khelgaah Frontend Design

## Start Here

If you are onboarding onto the frontend, read these in order:

1. `frontend/lib/main.dart`
2. `frontend/lib/app.dart`
3. `frontend/lib/features/main_layout.dart`
4. the screens under `frontend/lib/features`
5. the shared widgets under `frontend/lib/core/widgets`

## Purpose

This document explains the current Flutter frontend in depth:

- how the app is structured
- what each screen is responsible for
- how navigation works
- how shared widgets are used
- what is currently hardcoded
- how the frontend should eventually integrate with the backend

The frontend currently acts as a product prototype with a polished UI and clearly defined user flows, even though most business data is still static.

## Current Maturity Level

The frontend should currently be read as:

- a real UI shell
- a prototype data layer
- a strong specification of intended user journeys

That means new developers should expect to find:

- hardcoded arrays
- placeholder values
- local widget state
- direct navigation where async backend flows will eventually exist

This is intentional at the current stage.

## Folder Map

The most important frontend directories are:

```text
frontend/lib/core/theme        global visual setup
frontend/lib/core/widgets      reusable UI components
frontend/lib/features          user-facing screens and flows
frontend/assets                logos and fonts
frontend/test                  widget tests
```

## Technology Choice

The frontend is built with Flutter.

Flutter is a good fit here because:

- the product is UI-heavy and screen-flow driven
- the same codebase can target Android, iOS, web, desktop, and other platforms
- custom theming and reusable widgets are straightforward
- the booking flow benefits from a consistent cross-platform UI

The current frontend lives in:

```text
frontend/lib
```

## App Entry Point

### `frontend/lib/main.dart`

This is the first file executed by Flutter.

It calls:

```dart
runApp(const MyApp());
```

This means the full application is rooted in `MyApp`.

### `frontend/lib/app.dart`

This file defines `MyApp`, which sets up:

- the global `MaterialApp`
- the app title
- the theme
- the first screen

Right now the first screen is:

- `AuthScreen`

That means the frontend assumes authentication is the first step in the user journey.

## How to Read the Frontend

A new developer should read the frontend from product flow to shared pieces:

1. app entry
2. main shell
3. individual feature screens
4. shared widgets used by those screens
5. theme definitions

## Frontend Structure

The frontend is organized into:

- `core/`
- `features/`

This is a common and sensible split.

### `core/`

This contains reusable app-wide pieces:

- theme
- common widgets
- shared UI primitives

The goal of `core` is to avoid repeating styling and component logic across screens.

### `features/`

This contains product-level screens and flows:

- auth
- home
- search
- booking
- profile
- main layout

Each feature represents a user-facing area of the product.

## Theme and Visual System

### `frontend/lib/core/theme/app_theme.dart`

This file defines the app’s look and feel.

It centralizes:

- colors
- theme data
- reusable design constants

This matters because the rest of the UI reads from the theme rather than scattering design values across screens.

From a system design perspective, the theme layer does not hold business logic. Its job is consistency:

- make the UI visually coherent
- reduce duplication
- keep design changes localized

## Shared Widget Layer

The shared widget layer lives mostly under:

```text
frontend/lib/core/widgets
```

These widgets form the building blocks of the screens.

### Important Shared Widgets

#### `app_logo.dart`

Encapsulates the brand/logo presentation. This prevents every screen from implementing the logo manually.

#### `parallelogram_btn.dart`

Defines the app’s main button style. It appears throughout the app and establishes a consistent call-to-action pattern.

Because it supports variants, the same button primitive can be reused for:

- primary actions
- surface actions
- destructive actions

#### `app_text_field.dart`

Wraps text input styling and interaction. This is used in forms like the auth screen.

#### `booking_summary_card.dart`

A reusable display widget for booking-related summaries or empty states. It appears in several places, including home and search.

#### `booking_date_chip.dart`

Used in the booking screen to render selectable day options.

#### `app_selectable_tile.dart`

Used for choices like duration selection in the booking flow.

#### `app_action_tile.dart`

Used to render tappable list-style actions, such as facility search results.

#### `profile_action_icon.dart`

Encapsulates profile-related navigation from top app bars.

### Why This Shared Layer Matters

Without the shared widgets, each feature screen would manually recreate controls, spacing, and visual behavior. That would make the app inconsistent and harder to maintain.

The shared widget layer gives the frontend:

- consistent design
- faster screen development
- fewer style regressions
- clearer UI composition

### Design Rule

These shared widgets are mostly presentational. They should not become the place where API calls or business rules accumulate.

## Feature-Level Architecture

The feature layer contains the actual app flows.

### Authentication Feature

File:

- `frontend/lib/features/auth/auth_screen.dart`

#### What It Does

This screen is the authentication entry point. It supports two modes:

- sign in
- sign up

The screen toggles modes with local UI state.

#### UI Responsibilities

In sign in mode, it collects:

- email
- password

In sign up mode, it collects:

- full name
- email
- password
- phone

It also shows:

- branding
- mode toggle buttons
- explanatory text
- a CTA button
- a value proposition card

#### Navigation Behavior

When the user taps the primary action, the screen navigates directly to `MainLayout`.

This tells us something important about the current frontend:

- auth is not yet connected to a backend
- there is no token handling yet
- the app assumes success and proceeds

#### What It Should Eventually Do

In a fully integrated system, this screen should:

1. validate the form locally
2. call the backend auth endpoint
3. receive a token and user payload
4. store the token securely
5. initialize authenticated app state
6. navigate into the main application shell

This screen is therefore already correct in terms of product flow, but incomplete in terms of real data flow.

#### Important Onboarding Note

Do not treat the current auth button callback as the final architecture. It skips:

- real API calls
- token persistence
- session initialization
- failure handling

If you integrate auth, add a frontend data/session layer instead of embedding everything directly in the widget.

### Main Application Shell

File:

- `frontend/lib/features/main_layout.dart`

#### What It Does

This screen acts as the main container after authentication.

It uses:

- `IndexedStack`
- `BottomNavigationBar`

to switch between top-level screens.

#### Why `IndexedStack` Matters

`IndexedStack` keeps child screens alive even when they are not currently visible. That is useful because it preserves the state of each tab.

For example:

- search text can stay intact
- scroll positions can be preserved
- tab content does not rebuild from scratch on every switch

#### Current Tabs

The main shell currently includes:

- `HomeScreen`
- `SearchScreen`

The structure is intentionally simple right now, but it is easy to extend later with:

- bookings tab
- profile tab
- map tab

#### Why This File Matters

`MainLayout` is the post-login shell. If the app later adds route guards, persistent auth, or deeper navigation, this file will likely be part of that work.

### Home Feature

File:

- `frontend/lib/features/home/home_screen.dart`

#### What It Does

The home screen acts as a lightweight dashboard. It currently shows:

- brand header
- profile icon
- a short product message
- a "next reservation" summary
- a list of facilities
- a button to open search

#### Current Data Model

The facility list is hardcoded as a simple list of strings:

- Tennis Court
- Swimming Pool
- Gym
- Badminton

This tells us the screen is currently demonstrating UI behavior rather than reading live data.

#### Navigation Behavior

Tapping a facility opens:

- `BookingScreen`

with the chosen facility name passed in.

This is a key part of the app’s current interaction model:

- discovery begins on home
- booking begins immediately from a selected facility

#### Future Backend Integration

This screen will eventually need backend-backed data for:

- featured facilities
- the user’s next booking
- maybe venue recommendations

#### Integration Gap

The home screen currently passes `facilityName` into the booking screen, while the backend expects stable `facility_id` values. A new developer should expect this to change during integration.

That likely means the home screen will eventually compose data from multiple endpoints, not just one.

### Search Feature

File:

- `frontend/lib/features/search/search_screen.dart`

#### What It Does

This screen allows the user to search facilities by text.

It currently contains:

- a search field
- local in-memory search state
- a suggested results state
- a no-results state
- tappable result items

#### Current Search Strategy

A static list of tuples is stored inside the widget state. The screen filters that list on each text change.

This gives the UI the correct shape, but it is not the final architecture.

#### Why This Screen Is Important

This screen defines how the product thinks about discovery:

- search by facility name
- search by category or type
- search by sport context

The backend should support that exact interaction model.

#### Future Backend Integration

In the real system, typing into this screen should trigger:

- debounced backend requests
- pagination if the dataset grows
- optional filters later

At that point this screen becomes a remote query UI rather than a local filter UI.

#### Expected Next Step

Once integrated, search should likely use:

- debounced input
- loading state
- empty/error state
- facility IDs instead of display-only labels

### Booking Feature

File:

- `frontend/lib/features/booking/booking_screen.dart`

#### What It Does

This is the core transactional flow in the app.

The screen lets the user:

- choose a date
- choose a duration
- choose a time slot
- confirm a booking

#### Current State Management

The booking screen holds local widget state for:

- selected day index
- selected time
- selected duration

It also contains static data:

- booking day labels
- candidate time slots
- unavailable slots

That means the booking screen currently simulates availability entirely on the client.

#### Why This Screen Is the Most Critical

This is the point where a UI prototype must eventually become a real system. Booking availability cannot remain hardcoded, because:

- multiple users can attempt the same slot
- availability changes over time
- the UI can become stale

The frontend can display availability, but it must not be the source of truth.

#### What the Real Data Flow Should Be

When integrated with the backend, this screen should:

1. receive a real facility ID
2. ask the backend for available slots for a specific date and duration
3. render those slots
4. let the user pick one
5. send the final booking request to the backend
6. handle success or conflict states

The backend must always make the final decision.

#### Important Data Translation Issue

The booking UI currently works with:

- day labels
- display strings
- locally defined slots

The backend works with:

- `facility_id`
- ISO dates
- RFC3339 timestamps

So this screen will need a translation layer when integration begins.

### Profile Feature

File:

- `frontend/lib/features/profile/profile_screen.dart`

#### What It Does

The profile screen currently shows:

- a profile header
- booking history placeholder
- settings placeholder
- logout action

#### Current State

The screen is mostly static and illustrative. It uses:

- a hardcoded user name
- a hardcoded email
- dialog placeholders for settings and booking history

This means the UI is structurally ready, but the data layer is still missing.

#### What It Should Eventually Become

This screen should eventually display:

- the authenticated user profile
- upcoming and past bookings
- app settings
- maybe notifications and preferences later

Logout should clear local auth state and return the user to the auth screen.

#### Current Limitation

There is no centralized session store yet. Right now logout is mainly a navigation action, not a full session teardown.

## Navigation Design

The navigation style is currently straightforward:

- the app starts at auth
- successful auth moves into the main shell
- home/search can navigate to booking
- profile is reachable from app bar actions

At this stage the navigation is screen-based and imperative, using `Navigator.push` and `MaterialPageRoute`.

That is acceptable for the current app size.

As the app grows, navigation may need stronger routing conventions, especially if:

- deep links are introduced
- maps are added
- nested owner flows are introduced
- tournament features appear

## State Management Strategy Today

The frontend currently uses local widget state and hardcoded in-memory data.

This is a valid early-stage choice because:

- the number of screens is still small
- the product flows are still being shaped
- backend integration was not yet in place

The downside is that state is not yet centralized. That means:

- auth state is not persisted
- API responses are not modeled yet
- there is no shared data layer
- screens cannot react to real backend changes

## Missing Frontend Application Layer

The largest structural gap in the frontend is the absence of a dedicated data/application layer for:

- API clients
- request/response models
- repositories or services
- session storage
- error normalization

Without that layer, direct backend integration will become hard to maintain.

## Recommended Near-Term Structure

A reasonable next structure would be:

```text
frontend/lib/
  core/
  features/
  data/
    api/
    models/
    repositories/
  session/
```

This does not exist yet, but it is the most natural evolution from the current design.

## What Is Missing in the Frontend Right Now

The frontend is strong as a product prototype, but several integration layers are still absent.

### No API Client Layer

There is currently no dedicated service/repository layer on the Flutter side for:

- HTTP requests
- request serialization
- response deserialization
- token injection
- error mapping

This layer will be necessary before the UI can use the backend cleanly.

### No Persistent Auth State

The frontend does not yet:

- store auth tokens
- remember logged-in users across restarts
- attach auth headers to requests

### No Data Models

Most data is still represented as:

- raw strings
- tuples
- hardcoded widget constants

Eventually the app should define explicit frontend models for:

- user
- venue
- facility
- slot
- booking

### No Loading/Error Handling Pattern

The screens currently assume success because they are static.

Once integrated, each screen will need to represent:

- loading state
- empty state
- success state
- error state

## How the Frontend Should Interact With the Backend

The frontend should eventually add a data access layer between widgets and HTTP.

The ideal interaction pattern is:

```text
Screen -> frontend service/repository -> HTTP client -> Go backend
```

That layer should:

- keep widgets simple
- isolate networking logic
- make testing easier
- standardize auth and error handling

## Recommended Frontend Evolution

The next logical frontend steps are:

1. add API models
2. add an HTTP client layer
3. add auth token persistence
4. replace hardcoded facility/search/booking data with backend data
5. show loading and error states
6. centralize session state

The current frontend already gives a strong UI and interaction foundation. The main remaining work is converting it from a static prototype into a real client for the backend.

## Testing State

The frontend currently has minimal automated protection. As integration grows, the highest-value tests will likely be:

- auth form behavior
- search rendering from mocked API responses
- booking availability rendering
- success and failure handling during booking confirmation

## Summary

The frontend is currently a clean Flutter prototype with a sensible separation between reusable UI and feature screens.

Its main strengths are:

- clear product flows
- reusable components
- coherent visual system
- straightforward navigation

Its current limitations are:

- static data
- no API integration
- no persistent auth state
- no real domain models yet

From a system perspective, the frontend is already doing the right thing conceptually. It defines the user journey. The next stage is to connect that journey to real data from the backend.

## Onboarding Checklist

If you are starting frontend work:

1. identify whether your change is presentational or data-driven
2. look in `core/widgets` before creating duplicate UI
3. inspect the owning screen in `features/...`
4. check whether the screen currently uses hardcoded data
5. avoid placing networking logic directly inside widgets
6. keep backend IDs separate from display labels
