# LC App

Administrative dashboard for managing students, courses, attendance, and payments for the Learning Center platform. Built with Flutter, Riverpod, and a REST API backend to deliver a responsive experience across mobile, desktop, and web.

## Features
- **Authentication** – token-based login with secure storage and automatic sign-out on expired credentials.
- **Dashboard insights** – high-level stats and charts sourced from remote analytics endpoints.
- **Student management** – search, detail pages, archival view, and modal-driven student creation.
- **Course management** – list, filter, create, edit, and delete courses with configurable weekday schedules.
- **Payments & attendance** – review payment history and attendance records for each learner.
- **User administration** – manage staff and admin accounts through dedicated screens.
- **Consistent design system** – shared theme, typography, and widgets for a cohesive UI.

## Tech Stack
- Flutter (Material 3)
- Riverpod (`flutter_riverpod`) for state management
- Dio for networking with interceptors and retry logic
- Flutter Secure Storage for auth token persistence
- Hive for lightweight local caching
- `json_serializable` + `build_runner` for model generation
- `intl` for currency and date formatting

## Project Structure
```
lib/
	core/          # Theme, constants, API client, helpers
	models/        # Data models with generated *.g.dart files
	providers/     # Riverpod providers bridging services and UI
	services/      # API integrations (auth, courses, students, etc.)
	screens/       # Feature screens for each app section
	widgets/       # Reusable UI components (drawer, cards, forms)
```

## Prerequisites
- Flutter SDK 3.24+ (Dart 3.8+)
- Android Studio / Xcode toolchains for native builds (optional if targeting web only)
- Access to a Learning Center-compatible REST API

Confirm toolchain readiness:
```bash
flutter doctor
```

## Configuration
The base API URL is read from the `API_BASE_URL` compile-time environment value. Default: `https://avernalc-production.up.railway.app`.

Override it when running or building:
```bash
flutter run -d chrome --dart-define API_BASE_URL=https://your-api.example.com
# or
flutter build apk --dart-define API_BASE_URL=https://your-api.example.com
```

## Setup & Run
1. Install dependencies
	 ```bash
	 flutter pub get
	 ```
2. Generate JSON model helpers (needed whenever model annotations change)
	 ```bash
	 dart run build_runner build --delete-conflicting-outputs
	 ```
3. Launch the app on your target device
	 ```bash
	 flutter run -d chrome
	 # alternate targets: flutter run -d android / -d ios / -d windows
	 ```

## Useful Commands
- Format & analyze
	```bash
	flutter format .
	flutter analyze
	```
- Run tests
	```bash
	flutter test
	```
- Watch for code generation changes
	```bash
	dart run build_runner watch --delete-conflicting-outputs
	```

## Troubleshooting
- **401 Unauthorized** – tokens are cleared and you will be returned to the login screen. Re-authenticate or confirm backend availability.
- **Network / SSL issues** – ensure the API host is reachable from the device. Self-signed certificates require additional platform setup.
- **Android native builds** – install the NDK version specified in `android/app/build.gradle.kts` if Gradle prompts for it.

## Contributing
1. Create a feature branch.
2. Implement changes and add tests where applicable.
3. Run `flutter analyze` and `flutter test` before submitting a pull request.

## Team Avocado
- **Abdulhafiz** – Product Manager
- **Laylo** – Backend Engineer, Dashboard 
- **Kamron** – Backend Engineer, Student & `students_screen` 
- **Gulyuz** – UI/UX Designer, Attendance experience
- **Samirakhon** – Frontend Engineer, Payments experience + Login

---
For backend credentials or product questions, contact the Learning Center platform team.
