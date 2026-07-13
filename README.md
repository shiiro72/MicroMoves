# MicroMoves

Build a cross-platform mobile application (Flutter) that helps desk workers stay active by sending exercise reminders throughout the workday.

MicroMoves is **notification-first**, **offline-first**, light-weight, and requires absolutely no accounts or logins.

---

## 🚀 How to Find and Download the Built APK

The application uses an automated **GitHub Actions CI/CD pipeline** to build and distribute the app binaries.

### 1. Debug APK (For Testing)
* On every push to the `main` branch or when a Pull Request is opened, the GitHub Actions CI/CD pipeline runs.
* To download the built APK:
  1. Go to the **Actions** tab of the GitHub repository.
  2. Click on the latest workflow run (e.g., "Flutter Build & CI/CD").
  3. Scroll down to the **Artifacts** section at the bottom of the Summary page.
  4. Click on `debug-apk` to download the zip file containing the `app-debug.apk` file.
  5. Transfer and install it directly on any Android device to test the application!

### 2. Release APK & App Bundle (For Releases)
* On version tags (e.g., `v1.0.0`), the pipeline automatically builds a production-ready Release APK and Android App Bundle (.aab).
* If signing keys are configured in the repository's GitHub secrets, the build will be signed with your release credentials.
* These can be found in the **Artifacts** section under `release-artifacts`.

---

## 🛠️ Local Build Instructions

To build the APK locally, ensure you have Flutter installed, then run:

```bash
# Clean project and fetch dependencies
flutter pub get

# Run all test suites
flutter test

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release
```

The output APK will be generated at `build/app/outputs/flutter-apk/app-debug.apk`.

---

## 📱 Features & Highlights

1. **Exercise Library with Progression:**
   * Includes 15 built-in, default desk exercises across 5 categories (Legs, Core, Upper Body, Mobility, Cardio).
   * Fully automated progression (e.g. Squats starts at 12 reps and automatically increases by 2 reps every 5 completions, up to 30 reps).
   * Toggle, edit details, or create custom exercises with unique progression rules.

2. **Custom Reminder Schedule:**
   * Configure workday start and end hours, snooze duration, active weekdays, and reminder intervals.

3. **Smart Exercise Selection Algorithm:**
   * Randomly selects active exercises while strictly avoiding consecutive repetition of the same exercise or category.

4. **In-App Reminder Simulation Banner:**
   * Features a beautiful Material 3 banner to simulate workday stretch reminders directly in-app, supporting cross-platform testing (Web, Linux, Android).

---

## 🧪 Comprehensive Tests

The app is fully verified with 12 unit, widget, and UI integration tests:
* `database_test.dart`: Isolates SQLite CRUD and prepopulation.
* `exercise_selection_test.dart`: Validates the duplicate and category prevention algorithm.
* `app_state_test.dart`: Asserts state tracking, streak progression, and automated increments.
* `widget_test.dart` & `ui_test.dart`: Validates navigation shell, multi-tab layout, and the notification action overlay.
