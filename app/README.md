# Finans Koçu Flutter App

A Flutter implementation of the Finans Koçu personal finance coach designed for Android and iOS with Supabase integration hooks, multi-language support, and AI-ready surfaces.

## Getting Started

1. Install Flutter (3.19+ recommended) and run `flutter doctor`.
2. Navigate into the `app/` directory and fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Provide Supabase credentials via `--dart-define` when running or building:
   ```bash
   flutter run \
     --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co \
     --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
   ```
4. To enable localization assets, ensure `flutter gen-l10n` is not required; JSON assets are loaded at runtime.

> ℹ️ **Plan & Feature Tracking:** See [`../docs/IMPLEMENTATION_STATUS.md`](../docs/IMPLEMENTATION_STATUS.md) for a
> requirement-by-requirement snapshot. Many flows are scaffolded but still need real Supabase, OCR, and AI integrations.

### Testing

Run the Flutter analyzer and tests:

```bash
flutter analyze
flutter test
```

### Platform Setup

- **Android**: configure `android/app/src/main/AndroidManifest.xml` with internet permissions.
- **iOS**: update `ios/Runner/Info.plist` to allow network access and camera usage for OCR imports.

The project ships with modular feature folders, GoRouter-based navigation, Hive persistence for preferences, Supabase bootstrap, and placeholder UI for dashboards, analytics, AI assistant, and admin tooling as described in the PRD. The current implementation focuses on providing an end-to-end shell; production usage requires wiring in live services, security layers, and QA as outlined in the status document.

### Known Limitations

- Supabase sync, authentication, OCR, and AI providers return mock data—replace the placeholders with your chosen services.
- Notification scheduling, export watermarking, and admin payment workflows still need concrete implementations.
- UI flows compile and run in debug mode, but they are not yet hardened for production or App/Play Store submission without the integrations above.
