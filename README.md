# NutriLens 🥗📱

**NutriLens** is an AI-powered product scanner that helps users make healthier purchasing decisions. Simply scan a barcode or capture a product image to instantly view ingredients, nutritional facts, harmful additives, allergens, manufacturing and expiry details (via OCR), an AI-generated health analysis, and an overall health score with interactive charts.

### ✨ Features

* 📷 Barcode & product image scanning
* 🤖 AI-powered ingredient analysis
* 🧪 Detection of potentially harmful additives
* 🥗 Nutrition facts and health score
* 📊 Interactive health insights and charts
* 📅 OCR-based manufacturing & expiry date extraction
* ⚠️ Allergen and dietary warnings

**Tech Stack:** Flutter • Node.js • Express.js • MongoDB • OCR • AI APIs • Barcode Scanner

---

## Frontend (Flutter)

The `frontend/` app is fully runnable today in a self-contained **demo mode** — it
simulates the AI analysis on-device with a curated product catalog, so no backend,
API keys, camera or network are required to explore every screen.

### Run it

```bash
cd frontend
flutter pub get
flutter run           # pick a device, or use -d chrome for web
```

Run the tests with `flutter test`.

### Android build notes

- Build with a **JDK 17 or 21**. Newer Android Studio builds bundle JDK 25,
  which this project's Gradle 8.14 cannot run on — the build fails with only a
  version string (e.g. `25.0.3`) as the error. Point Flutter at a supported
  JDK: `flutter config --jdk-dir <path-to-jdk-21>`.
- On Windows, `flutter pub get` may demand Developer Mode to create desktop
  plugin symlinks. If you don't target Windows/Linux desktop, disable those
  targets instead: `flutter config --no-enable-windows-desktop --no-enable-linux-desktop`.
- `flutter_secure_storage` 11 declares `compileSdk = 37`, but AGP 8.11 cannot
  resolve the minor-versioned `android-37.0` platform. The root
  `android/build.gradle.kts` clamps library modules to SDK 36 via AGP's
  `finalizeDsl`; the plugin only uses APIs up to 30, so this is safe.

### What's included

- **Splash → Landing** marketing page (hero, features, how-it-works, live score
  preview, testimonials, FAQ, footer) with working navigation.
- **Auth** — login & register with validation, plus "continue as guest".
- **Dashboard** — time-aware greeting, a health-overview card (animated
  average-score ring, stat pills, 7-day activity strip), quick-action tiles
  that jump straight into a scan, recent scans and a rotating daily insight.
- **Scanner** — camera-style viewfinder with an animated scan line; scan a
  barcode, "capture" a photo, or pick a sample product.
- **Report** — the centerpiece: animated health-score ring beside a big,
  language-free emoji verdict (😄 → 🤢) so the result reads at a glance in any
  language, plus AI summary, pros / watch-outs, nutrition bars, additives with
  concern badges, allergen alerts, ingredients and OCR manufacturing/expiry
  dates.
- **History** & **Profile** — past scans, dark-mode toggle, logout.

### Wiring up a real backend

Everything talks to the API through `lib/core/services/` (`ApiService`,
`AuthService`, `ScanService`). To switch from demo data to a live server, set
`useMockData = false` in `lib/core/constants/api_constants.dart` and provide the
base URL (edit `baseUrl` or pass `--dart-define=NUTRILENS_API_BASE=https://…`).
The models already include `fromJson` parsers to consume the backend responses.

### Architecture

`lib/core/` holds shared constants, theme, models, services, providers and
widgets; `lib/features/<feature>/` holds each screen with its own widgets and
providers. State is managed with `provider`; navigation goes through
`RouteGenerator` for consistent transitions.