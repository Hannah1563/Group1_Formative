# ALU Academic Assistant

A Flutter mobile application that helps ALU students manage assignments, track class schedules, and monitor attendance. Built as a group project for the Mobile Development course.

## Features

- **Dashboard** — Overview of today's sessions, upcoming assignments, and attendance percentage
- **Assignments** — Create, edit, delete, and mark assignments as complete
- **Schedule** — Plan academic sessions (Class, Mastery Session, Study Group, PSL Meeting) and record attendance
- **Local Storage** — Data persists between app restarts using `shared_preferences`

## Project Structure

```
lib/
├── main.dart                  # App entry point, HomeWrapper with IndexedStack navigation
├── constants/
│   └── app_colors.dart        # ALU brand colors (navy, yellow, red)
├── models/
│   ├── assignment.dart        # Assignment model with JSON serialization
│   └── session.dart           # Session model with JSON serialization
├── screens/
│   ├── dashboard_screen.dart  # Home dashboard with summaries
│   ├── assignments_screen.dart # Assignment CRUD interface
│   └── schedule_screen.dart   # Session scheduling and attendance
├── services/
│   └── storage_service.dart   # Local persistence with shared_preferences
└── widgets/
    ├── bottom_nav_bar.dart    # Reusable 3-tab bottom navigation bar
```

## Architecture

- **State management**: Top-level state in `HomeWrapper` (main.dart) passed down to screens via constructor parameters. Screens notify the parent via callbacks when data changes.
- **Navigation**: `IndexedStack` with a shared `BottomNavigationBar` — keeps all three screens alive so they don't lose state when switching tabs.
- **Persistence**: `StorageService` uses `shared_preferences` to save/load assignments and sessions as JSON strings.

## How to Run

1. Make sure you have Flutter installed ([flutter.dev/docs/get-started](https://flutter.dev/docs/get-started))
2. Clone the repo:
   ```
   git clone https://github.com/Hannah1563/Group1_Formative.git
   ```
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Run on an emulator or physical device:
   ```
   flutter run
   ```

## Team

| Name | Role |
|---|---|
| Hannah Tuyishimire | Owner — Dashboard screen |
| Gentil Iradukunda | Navigation, local storage, code quality |
| Hugues Munezero | Schedule screen, attendance tracking |
| Promesse Irakoze | Assignments screen, demo video |
