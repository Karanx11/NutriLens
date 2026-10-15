# NutriLens 🥗📱

NutriLens turns a packaged-food product into a clear health verdict: ingredients, additives with concern levels, allergens, nutrition per 100 g, a plain-language analysis, a 0–100 health score — and a big, language-free emoji so the result reads at a glance in any language.

> **Project status — Flutter frontend; real barcode scanning, no backend yet.**
> Scanning a barcode with the camera (or from a photo) looks the product up in the public **Open Food Facts** database and builds a real report. There is still no backend, no label OCR and no AI analysis — see [What is real and what is simulated](#what-is-real-and-what-is-simulated).

## What the app does today

- **Landing page** — hero, features, how-it-works, a live report preview, testimonials and FAQ.
- **Sign in / register / guest** — demo authentication: any email and password signs you in; the session is kept in secure storage across launches.
- **Home** — time-aware greeting, a health-overview card (animated average-score ring, scan/healthy/watch pills, 7-day activity strip), quick-action tiles that open the scanner *and* start the action, recent scans, and a rotating daily insight.
- **Scanner** — live camera barcode scanning (EAN-13/8, UPC-A/E, Code 128) with torch and camera-flip; **Capture photo** / **From gallery** scan a photo for a barcode on-device; **Try a sample** opens the demo catalog. A scanned barcode is looked up in Open Food Facts; unknown products and network errors are reported honestly.
- **Analysis** — the centrepiece: product photo, score ring beside a large emoji verdict, rating, analysis summary, pros / watch-outs, nutrition bars (sugar, fat, saturated fat, sodium, fiber), additives with concern badges, allergen alerts, ingredient chips, freshness, and a data-source note.
- **History** — every analysed product with score badges, totals and average; clear-all.
- **Profile** — name/email, dark-mode toggle, notifications switch, about, log out.
- **Persistent bottom tabs** — Home / History / Profile live in one shell, so the bar never disappears when you switch tabs.
- **Light and dark themes**, phone-first layout that also caps width sensibly on tablets and the web.

## What is real and what is simulated

| Area | Today | Planned |
|---|---|---|
| Barcode scanning | **Real** — live camera via `mobile_scanner` (Google ML Kit on Android/iOS; works on the web too) | — |
| Photo capture / gallery | **Real** — `image_picker`; the photo is scanned for a barcode on-device (Android/iOS; not on the web) | Label OCR |
| Product data for scanned barcodes | **Real** — Open Food Facts (crowd-sourced; can be incomplete or stale) | Backend with additional sources |
| Health score, summary, pros/cons for scanned products | **Computed by NutriLens** from Nutri-Score, nutrients and additives — rule-based, not AI | AI-generated analysis |
| "Try a sample" products | 6 hand-written demo products | — |
| Manufacturing / expiry dates | Not available — barcode databases don't carry them; the report says so | OCR of the printed label |
| Authentication | Local demo — any credentials accepted, stored on device | Backend accounts |
| Backend (Node.js / Express / MongoDB) | **Does not exist yet** | The service layer already targets it behind one flag |
| Home-cooked meals (rice-dal, chole bhature, …) | Not supported — the design is for packaged products with a barcode | Dish recognition + Indian food nutrition data |
| Dark-mode preference | Applies immediately, resets on restart | Persisted |

## Health score and emoji verdict

The score is 0–100. The same bands drive the rating text, the traffic-light color and the emoji everywhere in the app:

| Score | Rating | Emoji | Color |
|---|---|---|---|
| 80–100 | Excellent | 😄 | green |
| 60–79 | Good | 🙂 | green |
| 40–59 | Fair | 😐 | amber |
| 20–39 | Poor | 😟 | orange |
| 0–19 | Avoid | 🤢 | red |

For scanned products the score starts from the product's **Nutri-Score** grade (A 90 · B 74 · C 56 · D 36 · E 16), then subtracts for additives of concern (−6 high, −3 moderate, capped) and for ultra-processed NOVA-4 foods (−5). When no Nutri-Score is available, a per-100 g nutrient formula is used instead. Pros, watch-outs and the summary are generated from the same numbers using common per-100 g traffic-light thresholds. Demo-catalog products carry hand-assigned scores. This is guidance, not medical advice.

## Getting started

Requirements:

- Flutter **3.47+** (Dart SDK ≥ 3.11.4, as pinned in `frontend/pubspec.yaml`)
- For Android: Android Studio / Android SDK and a **JDK 17 or 21** (see Android notes below)
- For web: Chrome or Edge

```bash
cd frontend
flutter pub get
flutter run            # pick a device, e.g. -d chrome or -d emulator-5554
```

Useful commands:

```bash
flutter analyze        # static analysis (clean)
flutter test           # 6 tests: score bands, demo catalog, ScoreRing widget, Open Food Facts mapping
flutter build web --release
flutter build apk
```

Demo sign-in: any email and any password (4+ characters), or **Continue as guest**.

**Testing the scanner.** The camera permission is requested at runtime. An emulator's virtual camera cannot show a real barcode, so on an emulator use **From gallery** with a barcode image (any EAN-13 picture works, e.g. 8901058000290 Maggi or 8901491101837 Lay's); on a real phone just point the camera at any packaged product.

### Android build notes

- Build with a **JDK 17 or 21**. Newer Android Studio builds bundle JDK 25, which this project's Gradle 8.14 cannot run on — the build fails with only a version string (e.g. `25.0.3`) as the error. Point Flutter at a supported JDK: `flutter config --jdk-dir <path-to-jdk-21>`.
- On Windows, `flutter pub get` may demand Developer Mode to create desktop plugin symlinks. If you don't target Windows/Linux desktop, disable those targets instead: `flutter config --no-enable-windows-desktop --no-enable-linux-desktop`.
- `flutter_secure_storage` 11 declares `compileSdk = 37`, but AGP 8.11 cannot resolve the minor-versioned `android-37.0` platform. `frontend/android/build.gradle.kts` clamps library modules to SDK 36 via AGP's `finalizeDsl`; the plugin only uses APIs up to 30, so this is safe.
- The manifest declares `android.permission.CAMERA` (camera marked optional) and a query for the image-capture intent; `ios/Runner/Info.plist` carries the camera and photo-library usage descriptions.

## Project structure

```
frontend/
├── lib/
│   ├── main.dart, app.dart          # entry point; MultiProvider + MaterialApp
│   ├── core/
│   │   ├── constants/               # API endpoints & mock flag, colors, sizes, strings
│   │   ├── data/additives_db.dart   # common E-number reference (name, purpose, concern)
│   │   ├── models/product.dart      # ProductAnalysis, NutritionFacts, Additive (+ fromJson)
│   │   ├── providers/               # ThemeProvider
│   │   ├── routes/                  # route names, RouteGenerator (shared transitions)
│   │   ├── services/                # ApiService (dio), AuthService, ScanService,
│   │   │                            # OpenFoodFactsService + mapper, StorageService
│   │   ├── theme/                   # light/dark ThemeData from one builder
│   │   ├── utils/                   # ScoreUtils (bands, colors, emoji), ProductScorer, dates
│   │   └── widgets/                 # buttons, text field, cards, loading, ScoreRing, ScanTile
│   └── features/
│       ├── splash/, landing/, auth/ # onboarding
│       ├── shell/                   # MainShell: persistent bottom tabs (IndexedStack)
│       ├── dashboard/               # Home tab
│       ├── scanner/                 # live scanner screen, ScanProvider, demo catalog, ScannerAction
│       ├── report/                  # Analysis screen
│       └── history/, profile/       # remaining tabs
├── test/                            # widget_test.dart, off_mapper_test.dart
└── android/, ios/, web/, macos/, linux/, windows/
```

State management is `provider` (`AuthProvider`, `ScanProvider`, `ThemeProvider`). Navigation uses named routes through `RouteGenerator`; `/dashboard`, `/history` and `/profile` all open the tab shell at the matching tab.

## Tech stack

**In use:** Flutter / Dart, Material 3, `provider`, `dio`, `flutter_secure_storage`, `mobile_scanner` (ML Kit barcode scanning), `image_picker`, `flutter_test`, `flutter_lints`. Product data from [Open Food Facts](https://world.openfoodfacts.org) (ODbL).

**Planned:** Node.js + Express + MongoDB backend, label OCR, AI-generated analysis.

## Connecting a real backend

Barcode lookups go straight to Open Food Facts (`lib/core/services/open_food_facts_service.dart`) and do not need a backend. Everything else goes through `lib/core/services/`; to switch the app's own API off demo mode:

1. In `lib/core/constants/api_constants.dart` set `useMockData = false`.
2. Set `baseUrl`, or pass it at build time: `--dart-define=NUTRILENS_API_BASE=https://your-api.example.com`.

The app expects these endpoints:

| Endpoint | Request | Response |
|---|---|---|
| `POST /auth/login` | `{ email, password }` | `200 { token, user: { id, name } }` |
| `POST /auth/register` | `{ name, email, password }` | `200/201 { token, user: { id } }` |
| `POST /scan/analyze` | image/label payload | a product analysis (below) |
| `POST /scan/barcode` | `{ barcode }` | a product analysis (below) |
| `GET /scan/history` | — | list of product analyses |

A product analysis is parsed by `ProductAnalysis.fromJson` with these fields: `id` (or `_id`), `name`, `brand`, `category`, `barcode`, `nutrition { servingSize, calories, protein, carbs, sugar, fat, saturatedFat, fiber, sodium }`, `ingredients[]`, `additives[] { code, name, purpose, concern: none|low|moderate|high }`, `allergens[]`, `dietaryFlags[]`, `manufacturedOn`, `expiresOn` (ISO-8601), `healthScore` (0–100 int), `summary`, `pros[]`, `cons[]`, and optionally `imageUrl`, `dataSource`, `nutriscoreGrade`, `novaGroup`. Missing fields fall back to safe defaults.

## Verification

- `flutter analyze` — no issues; `flutter test` — 5/5 passing (including the Open Food Facts mapper with prepared-only nutrients and salt→sodium fallbacks).
- On an Android emulator (Pixel 10 Pro AVD): live camera preview in the scanner with the camera-permission flow, the system photo picker, and the Open Food Facts API answering for real Indian products (Maggi, Lay's).

## Roadmap

- Backend: accounts, product lookup fallbacks, scan history sync.
- OCR for ingredients, nutrition tables and dates on the pack.
- AI-generated analysis.
- Meal-photo mode for home-cooked food (dish recognition, portion estimate, Indian food nutrition data).
- Emoji verdicts in list views; persisted theme preference; localisation.

## Contributing

Development happens on feature branches merged into `main` by pull request. Run `flutter analyze` and `flutter test` before opening a PR.
