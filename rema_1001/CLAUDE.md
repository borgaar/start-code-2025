# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter application for Rema 1001 (Norwegian grocery store chain) with a companion backend. The app includes shopping lists, trips tracking, and store maps functionality.

**Tech Stack:**
- Frontend: Flutter (Dart SDK ^3.9.2)
- State Management: flutter_bloc ^9.1.1
- Routing: go_router ^16.2.5
- Backend: Located in sibling `../backend/` directory (Hono + Prisma + PostgreSQL)

## Common Commands

### Flutter (Frontend)

```bash
# Run the app
flutter run

# Run on specific device
flutter run -d chrome
flutter run -d macos
flutter run -d ios

# Build for production
flutter build apk
flutter build ios
flutter build web

# Run tests
flutter test

# Analyze code
flutter analyze

# Install/update dependencies
flutter pub get
flutter pub upgrade
```

### Backend (in ../backend/)

The backend is a separate project in a sibling directory. Switch to `../backend/` to work with backend code.

## Architecture

### Navigation Architecture

The app uses **go_router** with a **ShellRoute** pattern that wraps all main screens with a persistent bottom navigation bar (`RoutedNavBar`).

- **Router configuration:** `lib/router/router.dart`
- **Route names:** `lib/router/route_names.dart` (centralized route name constants)
- **Custom transitions:** `lib/router/fade_transition_page.dart` (fade-in transitions with 150ms duration)
- **Navigation bar:** `lib/router/nav_bar.dart` (custom bottom nav with 4 destinations, badge support)

The ShellRoute wraps these main routes:
- `/home` - Home screen with quick access buttons
- `/trips` - Shopping trips with map visualization
- `/lists` - Shopping lists management
- `/profile` - User profile

### Page Structure

All screens are located in `lib/page/`:
- `home.dart` - HomeScreen (welcome screen with navigation buttons)
- `map.dart` - TripsScreen (about page renamed, shows maps)
- `about.dart` - ListsScreen (shopping lists)
- `profile.dart` - ProfileScreen (user profile)

Note: There's a naming mismatch where `about.dart` contains `ListsScreen` and `map.dart` contains `TripsScreen` (shown as "about" in old git history).

### Custom Components

**FadeTransitionPage** (`lib/router/fade_transition_page.dart`):
- Custom page transition wrapper for go_router
- Uses opacity animation for smooth fade-in/fade-out
- Default 150ms duration for both directions

**RoutedNavBar** (`lib/router/nav_bar.dart`):
- Custom bottom navigation with 4 destinations (Norwegian labels: "Hjem", "Handleturer", "Dine lister", "Profil")
- Dark theme (#2D2D2D background)
- Badge support (e.g., "12" badge on home screen)
- Active route detection using GoRouterState
- 102px height with SafeArea

**Map Components** (`lib/map/`):
- `map_painter.dart` - Custom painter for store map visualizations

### State Management

The project uses `flutter_bloc` for state management (version ^9.1.1) but BLoC classes are not yet implemented in the visible codebase. When adding new features with state:
- Create BLoCs in appropriate feature folders
- Follow BLoC pattern: Events, States, and BLoC classes
- Use `equatable` (already included) for value equality in events/states

## Code Style

- Uses `flutter_lints` package for linting rules
- Standard Flutter conventions apply
- Lint configuration in `analysis_options.yaml`
- Norwegian language used in UI labels (see nav_bar.dart)

## Project Context

Based on git history, this project includes:
- Prisma backend with seeding scripts (in sibling backend directory)
- PostgreSQL database in Docker
- Scalar API documentation
- Mock dataset for seeding
