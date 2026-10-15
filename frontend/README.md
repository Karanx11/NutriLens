# NutriLens — Flutter app

This folder is the Flutter frontend of NutriLens. The full project README — status, what is real vs. simulated, setup, Android build notes, project structure and the backend contract — lives one level up in [`../README.md`](../README.md).

Quick start:

```bash
flutter pub get
flutter run
flutter test
```

The app runs in demo mode by default (`useMockData = true` in `lib/core/constants/api_constants.dart`): no backend, camera or API keys are needed.
