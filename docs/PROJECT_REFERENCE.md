# PROJECT_REFERENCE: Flutter Real Estate Assessment

> **Single source of truth for this project.** Agent rules live in `.cursor/rules/*.mdc` and point here.
> Last updated: 2026-10-13 · Status: **Planning complete. Implementation not started.**

---

## 0. How to use this reference

### 0.1 Kickoff prompt (paste into a new chat and fill in the two placeholders)

```text
You are a senior Flutter engineer working on this repository.

Read fully before doing anything:
- @docs/PROJECT_REFERENCE.md   (single source of truth)
- @.cursor/rules               (all project rules)

Figma design (my Drafts duplicate, NOT the Community original):
{{FIGMA_LINK}}

Screens required by the recruiter:
{{SCREENS — e.g. "Home, Search & Filter, Property Details" or "decide from Figma and ask me"}}

Task: execute PHASE 1 ONLY (reference §7, "Phase 1: Figma inspection & design inventory").
1. Call `whoami` and confirm the Figma MCP server is connected. If it fails, report the exact error and stop.
2. Respect the Figma call budget (~20 read calls/month): get_metadata (pages) → get_metadata (page)
   → get_variable_defs (page) → get_design_context ONLY for the required screens and shared components.
3. Fill reference §5: screen inventory (node IDs, purpose, components, entry/exit navigation,
   every tappable element + proposed action), design tokens (colors, typography, spacing, radii,
   shadows), design frame size (ScreenUtil designSize), fonts (Arabic coverage?), asset list.
4. Map each Figma data field to a DummyJSON product field (reference §4.6). Mark fields the API lacks.
5. Update §9 (open questions), §10 (progress log), §11 (AI usage log).
Constraints: write no Dart code, export no assets, don't commit. Stop and wait for my approval.
```

### 0.2 Per-phase prompt (for every later phase)

```text
Read @docs/PROJECT_REFERENCE.md and @.cursor/rules.
Execute ONLY Phase {{N}}: {{PHASE NAME}} exactly as defined in reference §7.
- Follow the UI ↔ backend wiring recipe in §4.4 for any feature work.
- Respect approved decisions in §4 and answered questions in §9; ask before deviating.
- Finish with: flutter analyze (0 issues), flutter test (all green), update §10 and §11,
  and propose Conventional Commit messages. Do not commit or push unless I say so.
```

---

## 1. Project summary

| Item | Value |
| --- | --- |
| Assessment | Practical hiring test: **Flutter Mobile Developer** |
| Goal | Figma design → working real-estate app · Arabic + English · RTL/LTR · API integration |
| Suggested effort | **12–14 working hours** |
| Figma (from the brief) | <https://www.figma.com/design/dXUFyRx7RgaaS0lGWPPFd3/Real-Estate-Mobile-App-Design--Community-?node-id=0-1> (page `0:1`) |
| API | DummyJSON: <https://dummyjson.com/>, <https://dummyjson.com/docs/products> |
| Local repo | `/Users/mohamadali/Desktop/flutter_real_estate_assessment`, branch `main` |
| `origin` | `https://github.com/AnasAlhamadd/flutter-real-estate-assessment.git` (public) |
| Evaluated on | Code quality, project structure, edge-case handling, and the candidate's understanding of their technical decisions, not only visuals |

---

## 2. Environment & tooling status (verified 2026-10-13)

| Item | Status |
| --- | --- |
| Flutter / Dart | 3.44.1 stable / 3.12.1 ✅ |
| Xcode / CocoaPods | 26.5 / 1.16.2 ✅ (iOS uses Swift Package Manager; no `Podfile`) |
| Android | SDK 36, JDK 21 ✅ · ⚠️ some Android licenses not accepted (`flutter doctor --android-licenses`) |
| Simulators | iPhone 16 / 16e / 16 Plus / 16 Pro / 16 Pro Max · Android `Medium_Phone_API_36.0` |
| Project | Default Flutter template (counter app). `flutter analyze` clean, `flutter test` passes |
| IDs | Default `com.example.*` (change only if required) |
| Figma MCP | ✅ Plugin installed and authenticated (`plugin-figma-figma`) · account `anasalhamadstd@gmail.com`, **Starter plan, Full seat → ~20 read calls/month** (`whoami` exempt; 2 calls already used) |
| Figma file access | ❌ Community original returns *"you don't have edit access to this file"*. **Use a Drafts duplicate** (Open in Figma / Duplicate → new fileKey) |
| GitHub | Two repos exist: `AnasAlhamadd/...` (origin, 1 commit) and `anasAlhamd/...` (empty). Delivery target: see Q2 |

---

## 3. Requirements checklist (from the assessment brief)

Each phase in §7 references these IDs. Tick them in Phase 9.
⚠️ The repo is **public**: don't commit the assessment PDF without permission.

### A. Implement the Figma design
- [ ] **A1** Implement the **screens specified by the recruiter** from the Figma design.
- [ ] **A2** Match the design as closely as possible: colors, spacing, sizes, fonts, icons, borders, shadows, images, and image cropping.
- [ ] **A3** Reusable widgets for repeated elements (property cards, buttons, section headers).
- [ ] **A4** Support different phone sizes with **no clipped content and no overflow errors**.
- [ ] **A5** Don't replace design elements with generic ones that visibly change the look.

### B. Arabic/English and RTL/LTR
- [ ] **B1** Both languages, **switchable in-app without restarting**.
- [ ] **B2** Arabic → RTL layout; English → LTR.
- [ ] **B3** Translate **all** static text: buttons, titles, error messages, loading states, navigation.
- [ ] **B4** Correct direction for lists, arrows, back buttons, fields, alignment, content cards.
- [ ] **B5** Long text handled without overlapping or overflowing its container.
- [ ] **B6** Readable mixed content: numbers, prices, phone numbers, Latin text inside the Arabic UI.
- [ ] **B7** **Persist the language choice** and restore it on next launch.

### C. API integration
- [ ] **C0** Dynamic data comes from the API and is never hard-coded in UI. DummyJSON products may be used as card data.
- [ ] **C1** JSON → clear **models**.
- [ ] **C2** Network calls **separated from widgets**.
- [ ] **C3** Loading, success, empty, and error states.
- [ ] **C4** **Retry** on failure where appropriate.
- [ ] **C5** Handle **no internet, timeouts, server errors, unexpected responses**.
- [ ] **C6** Unavailable images must not crash the screen.
- [ ] **C7** **Avoid repeated or unnecessary requests**.
- [ ] **C8** **Search and filtering**.
- [ ] **C9** DummyJSON simulates POST/PATCH/DELETE but **does not persist them**. State this in README and never claim data survives restarts.

### D. UX & navigation
- [ ] **D1** Clear navigation between required screens.
- [ ] **D2** Selected language preserved while navigating.
- [ ] **D3** User-friendly messages, never raw technical errors.
- [ ] **D4** **No buttons that look active but do nothing.**

### E. Code quality & tests
- [ ] **E1** Organized files; UI separated from data logic and app state.
- [ ] **E2** A suitable state management approach applied consistently.
- [ ] **E3** Clear names, minimal duplication, no giant hard-to-maintain widgets.
- [ ] **E4** Basic tests for important logic (e.g., JSON parsing, search logic).
- [ ] **E5** Document important external packages and why they're used.

### F. AI usage policy (documented in `AI_USAGE.md`)
- [ ] **F1** AI tools used and the purpose of each.
- [ ] **F2** Parts AI helped create or review (planning, components, tests, debugging, API).
- [ ] **F3** Short examples or summaries of the most important prompts.
- [ ] **F4** How outputs were verified (tests, reviews, experiments).
- [ ] **F5** **At least one** AI output that was modified or rejected, and why.
- [ ] **F6** Be able to explain and modify all delivered code. Full responsibility for correctness, security, and quality.

### G. Deliverables
- [ ] **G1** Git repository link with the complete code.
- [ ] **G2** README: requirements, install & run steps, **API base URL setup**.
- [ ] **G3** Short explanation of architecture, state management, key packages.
- [ ] **G4** `AI_USAGE.md`.
- [ ] **G5** How language switching works and how RTL/LTR is implemented.
- [ ] **G6** AI usage summary per section F.
- [ ] **G7** Screenshots of required screens **in both languages**, or a short video showing navigation + language switch.
- [ ] **G8** Assumptions and known limitations, especially the demo API's behavior.
- [ ] **G9** Clear, meaningful commit messages reflecting a natural work history (commit count isn't a quality metric).

---

## 4. Architecture: Clean Architecture (Uncle Bob)

### 4.1 Layers and the dependency rule

```text
┌──────────────────────── presentation ────────────────────────┐
│  Screens / Widgets ──► Cubit ──► State (status, data, failure) │
└───────────────────────────────┬───────────────────────────────┘
                                │ depends on
┌──────────────────────────── domain ───────────────────────────┐
│  Entities · Repository contracts · Use cases   (pure Dart)     │
└───────────────────────────────▲───────────────────────────────┘
                                │ implements
┌───────────────────────────── data ────────────────────────────┐
│  RepositoryImpl ──► RemoteDataSource (Dio → DummyJSON)          │
│                 └─► LocalDataSource  (SharedPreferences cache)  │
│  Models (fromJson/toJson/toEntity) · Exceptions → Failures      │
└────────────────────────────────────────────────────────────────┘
Wiring of concrete classes happens only in lib/injection_container.dart (GetIt).
```

- **domain** knows nothing about Flutter, Dio, JSON, or storage.
- **presentation** talks to **use cases** only, never to models or data sources.
- **data** implements domain contracts; exceptions never leave it (they become `Left(Failure)`).

### 4.2 Folder structure

```text
lib/
├── main.dart                         # ensureInitialized → EasyLocalization → DI → ScreenUtilInit → App
├── app.dart                          # MaterialApp.router (theme, locale, delegates, router)
├── injection_container.dart          # GetIt: external → core → datasources → repos → usecases → cubits
├── core/
│   ├── app_theme.dart
│   ├── constant/
│   │   ├── app_router.dart           # GoRouter + static const paths
│   │   ├── colors_app.dart           # Figma colors
│   │   ├── app_text_styles.dart      # Figma typography
│   │   ├── app_sizes.dart            # spacing, radii, shadows
│   │   ├── image_path.dart           # asset paths
│   │   ├── api_constants.dart        # baseUrl (--dart-define) + endpoints
│   │   └── storage_keys.dart         # SharedPreferences keys
│   ├── network/
│   │   ├── dio_client.dart           # timeouts, LogInterceptor (debug only)
│   │   └── network_info.dart
│   ├── error/
│   │   ├── exceptions.dart           # Server/Network/RequestTimeout/Parsing/Cache exceptions
│   │   ├── failures.dart             # Failure + subtypes
│   │   └── failure_message.dart      # Failure → translation key
│   ├── usecase/usecase.dart          # UseCase<T, Params>, NoParams
│   ├── enums/request_status.dart
│   ├── function/show_snack_bar.dart
│   ├── utils/{debouncer, formatters, bidi_text}.dart
│   └── widget/                       # AppButton, SectionHeader, AppNetworkImage, LoadingView,
│                                     # ErrorView, EmptyView, AppSearchField, AppBackButton, LanguageSwitcher
└── feature/
    └── properties/                   # final screen names come from Phase 1
        ├── domain/
        │   ├── entities/{property_entity, properties_page_entity, category_entity}.dart
        │   ├── repositories/properties_repository.dart
        │   └── usecases/{get_properties, search_properties, get_categories,
        │                 get_properties_by_category, get_property_details, filter_properties}_usecase.dart
        ├── data/
        │   ├── model/{property_model, properties_response_model, category_model}.dart
        │   ├── datasource/{properties_remote_data_source, properties_local_data_source}.dart
        │   └── repositories/properties_repository_impl.dart
        └── presentation/
            ├── cubit/{home, search, property_details}_cubit.dart (+ _state.dart)
            ├── pages/{home, search, property_details}_screen.dart
            └── widget/{property_card, category_chips, filter_sheet, ...}.dart
assets/
├── images/  ├── svg/  ├── fonts/
└── translations/{en.json, ar.json}
test/                                 # see §4.7
integration_test/app_test.dart        # optional
```

If Figma has favorites, add `feature/favorites/` (local-only data source, app-wide Cubit).

### 4.3 Request lifecycle (one user action end-to-end)

```text
User types "villa"
 → SearchScreen: AppSearchField.onChanged
 → SearchCubit.onQueryChanged(q)       debounce 400 ms, ignore unchanged query, cancel previous CancelToken
 → emit(status: loading)
 → SearchPropertiesUseCase(SearchParams(q, skip: 0))
 → PropertiesRepository.search(...)     (domain contract)
 → PropertiesRepositoryImpl             NetworkInfo.isConnected? no → Left(NetworkFailure)
 → PropertiesRemoteDataSource.search    GET /products/search?q=villa&limit=20&skip=0
      DioException → typed exception    200 → PropertiesResponseModel.fromJson
 → model.toEntity() → Right(PropertiesPageEntity)
 → Cubit: items.isEmpty ? empty : success  |  Left(f) → failure(f)
 → BlocBuilder renders PropertyList / EmptyView / ErrorView(onRetry: cubit.retry)
```

### 4.4 UI ↔ backend wiring recipe (follow this order for every feature)

| Step | Layer | File | Done when |
| --- | --- | --- | --- |
| 1 | domain | `entities/*_entity.dart` | Immutable, Equatable, only fields the UI needs |
| 2 | domain | `repositories/*_repository.dart` | Abstract methods return `Future<Either<Failure, T>>` |
| 3 | domain | `usecases/*_usecase.dart` | One `call(Params)`, Params is Equatable |
| 4 | test | `test/fixtures/*.json` | Real API response saved + broken variants |
| 5 | data | `model/*_model.dart` | Defensive `fromJson`, `toJson` (for cache), `toEntity()`, **tests pass** |
| 6 | data | `datasource/*_remote_data_source.dart` | Abstract + Dio impl, throws typed exceptions, **tests with MockDio** |
| 7 | data | `datasource/*_local_data_source.dart` | Abstract + SharedPreferences impl, TTL, `CacheException`, **tests** |
| 8 | data | `repositories/*_repository_impl.dart` | Strategy from §4.5, exception → Failure, **tests for every branch** |
| 9 | DI | `injection_container.dart` | Data sources, repo, use cases (lazySingleton), cubit (factory) |
| 10 | presentation | `cubit/*_state.dart` + `*_cubit.dart` | `RequestStatus` flow, retry, pagination guard, **bloc_test** |
| 11 | presentation | `widget/*.dart` | Small widgets, tokens only, RTL-safe |
| 12 | presentation | `pages/*_screen.dart` | `BlocProvider(create: (_) => sl<XCubit>()..load())`, renders all statuses |
| 13 | routing | `core/constant/app_router.dart` | Route + typed params (`/property/:id`) |
| 14 | l10n | `assets/translations/{en,ar}.json` | Every new key in both files |
| 15 | test | `presentation/...` widget tests | LTR + RTL, long text, narrow width, each status |

### 4.5 Remote + local strategy

| Operation | Remote | Local | Strategy |
| --- | --- | --- | --- |
| Listing, page 0 (default sort/category) | `GET /products?limit=20&skip=0&select=…` | cache JSON + `cachedAt` (TTL 10 min) | Online: remote → save → fresh. Offline/timeout: cache with `isFromCache: true` (UI shows an "offline: saved data" banner). No cache: `NetworkFailure` |
| Listing, page > 0 | `skip = page * limit` | — | Remote only. Failure keeps existing items and shows a retry footer |
| Search | `GET /products/search?q=` | — | Remote only, debounced, cancellable |
| Categories | `GET /products/categories` | cache (TTL 24 h) + in-memory | Memory → valid cache → remote → save |
| By category | `GET /products/category/{slug}` | — | Remote only |
| Details | `GET /products/{id}` | last opened items | Remote → save. Failure: cached item, else `Failure` |
| Sort | `sortBy`, `order` query params | — | Server-side |
| Price range / other filters | not supported by API | — | Local pure function `FilterPropertiesUseCase` (unit-tested) |
| Favorites (only if in Figma) | — | ids list | Local only, app-wide `FavoritesCubit` |
| Language | — | `easy_localization` (`saveLocale`) | Automatic |

**Error mapping**

| Source | Exception (data) | Failure (domain) | Translation key |
| --- | --- | --- | --- |
| `NetworkInfo` false / `connectionError` | `NetworkException` | `NetworkFailure` | `errors.no_internet` |
| connect/send/receive timeout | `RequestTimeoutException` | `TimeoutFailure` | `errors.timeout` |
| HTTP 5xx | `ServerException(code)` | `ServerFailure` | `errors.server` |
| HTTP 4xx (404 details) | `ServerException(code)` | `NotFoundFailure` / `RequestFailure` | `errors.not_found` / `errors.request` |
| JSON shape/type errors | `ParsingException` | `UnexpectedResponseFailure` | `errors.unexpected_response` |
| Cache empty/corrupt | `CacheException` | `CacheFailure` | `errors.no_cached_data` |
| Anything else | — | `UnknownFailure` | `errors.unknown` |

### 4.6 Data mapping (DummyJSON product → `PropertyEntity`)

| Entity field | API field | Notes |
| --- | --- | --- |
| `id` | `id` | |
| `title` | `title` | English only (documented) |
| `description` | `description` | |
| `price` | `price` | Formatted via `formatters.dart` |
| `discountPercentage` | `discountPercentage` | Only if the design shows a discount |
| `rating` | `rating` | |
| `category` | `category` | Slug → label |
| `thumbnailUrl` | `thumbnail` | Nullable-safe |
| `imageUrls` | `images` | Defaults to `[]` |
| `brand`, `stock`, `availabilityStatus` | same | Candidates to replace real-estate-only fields |
| _Figma-only fields (location, beds, baths, area, agent…)_ | **none** | **Decision Q4.** Never hard-code in UI (C0) |

To be completed in Phase 1 once Figma fields are known.

### 4.7 Test folder

```text
test/
├── fixtures/
│   ├── fixture_reader.dart
│   ├── products_page.json  product.json  categories.json  search_empty.json
│   └── product_missing_fields.json  product_wrong_types.json
├── helpers/
│   ├── mocks.dart          # MockDio, MockNetworkInfo, MockRemote/LocalDataSource, MockRepository, MockUseCases
│   └── pump_app.dart       # pumpApp(widget, {locale, textScale, size}) with EasyLocalization + ScreenUtil
├── core/
│   ├── error/failure_message_test.dart
│   ├── network/dio_exception_mapping_test.dart
│   └── utils/{formatters, debouncer, bidi_text}_test.dart
└── feature/properties/
    ├── data/model/property_model_test.dart
    ├── data/datasource/{remote, local}_data_source_test.dart
    ├── data/repositories/properties_repository_impl_test.dart
    ├── domain/usecases/filter_properties_usecase_test.dart
    └── presentation/
        ├── cubit/{home, search, property_details}_cubit_test.dart
        ├── widget/property_card_test.dart         # LTR/RTL, long title, 320×640 @ 1.3 text scale
        └── pages/home_screen_test.dart            # each RequestStatus renders the right view
integration_test/app_test.dart                     # optional: browse → details → switch to AR → RTL
```

### 4.8 Key technical decisions

| # | Decision | Covers |
| --- | --- | --- |
| T1 | One Equatable state per Cubit with a `RequestStatus` enum (+ `isLoadingMore`, `hasReachedMax`) | C3, E2 |
| T2 | Defensive parsing; all shape/type errors → `UnexpectedResponseFailure` | C1, C5 |
| T3 | Repository remote-first with local cache fallback (§4.5) | C5, C7 |
| T4 | Shared `ErrorView` with retry, plus a retry footer for pagination failures | C4 |
| T5 | Request dedupe: debounce, CancelToken, unchanged-query guard, no fetch in `build()`, pagination guard, category cache, `select=` | C7 |
| T6 | Server-side search/category/sort; local price filter | C8, E4 |
| T7 | `AppNetworkImage` with placeholder + error widget, null-safe | C6 |
| T8 | `easy_localization` (persisted, instant), directional APIs only | B1–B4, B7, D2 |
| T9 | Bidi isolation for prices/phones/Latin text; `intl` formatting | B6 |
| T10 | ScreenUtil with the Figma frame size; `Flexible`/ellipsis; tested at 1.3 text scale on 320-wide surface | A4, B5 |
| T11 | Every tappable element works or is removed (decision per button in §5) | D4 |
| T12 | `API_BASE_URL` via `--dart-define`, default `https://dummyjson.com` | G2 |
| T13 | Light theme only unless Figma includes dark | Scope |

---

## 5. Design inventory (filled in Phase 1)

| Field | Value |
| --- | --- |
| Figma Drafts duplicate URL | _pending (Q3)_ |
| fileKey / page | _pending_ |
| Frame size (ScreenUtil `designSize`) | _pending_ |
| Fonts (Latin / Arabic coverage) | _pending_ |

### 5.1 Screens

| Screen | Node ID | Purpose | Components | Entry → Exit | Data (endpoint) | States designed? |
| --- | --- | --- | --- | --- | --- | --- |
| _pending_ | | | | | | |

### 5.2 Tappable elements (D4)

| Screen | Element | Action | Decision (implement / local / hide) |
| --- | --- | --- | --- |
| _pending_ | | | |

### 5.3 Design tokens

| Group | Values (from `get_variable_defs` / design context) |
| --- | --- |
| Colors | _pending_ |
| Typography | _pending_ |
| Spacing | _pending_ |
| Radii | _pending_ |
| Shadows | _pending_ |

### 5.4 Shared components & assets

| Component / asset | Node ID | Type | Used on | Export |
| --- | --- | --- | --- | --- |
| _pending_ | | | | |

---

## 6. Packages (and why they're used: E5)

Install in Phase 2 with `flutter pub add`, and only the packages confirmed by Phase 1.

| Package | Purpose | Why |
| --- | --- | --- |
| `flutter_bloc` | Cubit state management | Predictable, testable, consistent (E2) |
| `equatable` | Value equality for states/entities | Avoids redundant rebuilds |
| `get_it` | Dependency injection | Decouples layers; easy mocking |
| `go_router` | Declarative routing | Typed paths, deep-link ready (D1) |
| `dio` | HTTP | Timeouts, interceptors, CancelToken (C5, C7) |
| `dartz` | `Either<Failure, T>` | Explicit error flow (`fpdart` is a maintained alternative; note in README) |
| `shared_preferences` | Local cache + favorites | Lightweight; already a dependency of easy_localization |
| `internet_connection_checker_plus` (or equivalent) | `NetworkInfo` | Fail fast offline (C5). Check maintenance on pub.dev at install time |
| `easy_localization` + `flutter_localizations` (SDK) | Translations, instant switch, persisted locale, RTL delegates | B1–B4, B7 |
| `intl` | Number/price formatting | B6 |
| `flutter_screenutil` | Responsive sizing | A4 |
| `cached_network_image` | Image caching + error widget | C6, C7 |
| `flutter_svg` | SVG icons from Figma | Only if icons are SVG (A2) |
| dev: `bloc_test`, `mocktail` | Cubit tests, mocks | E4 |

Fonts are bundled in `assets/fonts/` (no runtime `google_fonts`). Add an Arabic font if the Figma font lacks Arabic glyphs (Q6).

---

## 7. Phases (≈ 13 h total)

Each phase ends with a running app, `flutter analyze` = 0, green tests, updated §10/§11, and proposed commits.

### Phase 0: Setup & planning ✅
Environment audit, Figma MCP connected, brief analyzed, rules + this reference written.

### Phase 1: Figma inspection & design inventory (~1 h) · A1, A2
- **Prerequisites (you):** Drafts duplicate link (Q3) and required screens (Q1).
- **Actions:** the kickoff prompt in §0.1.
- **Deliverable:** §5 completed, §4.6 mapping completed, questions updated.
- **Done when:** every required screen has a node ID, components, a button decision, and tokens. No "pending" left for required screens.
- **Risk:** Figma call budget. Fallback is manual inspection in Figma Dev Mode.
- **Commit:** `docs: add verified Figma inventory and design tokens`

### Phase 2: Foundation (~2 h) · E1, E2, E5, B1, B7, T12
1. Remove counter template (`lib/main.dart`, `test/widget_test.dart`).
2. `flutter pub add` for approved packages; register `assets/` in `pubspec.yaml`.
3. Create folder structure (§4.2) and core: `usecase.dart`, `request_status.dart`, `exceptions.dart`, `failures.dart`, `failure_message.dart`, `dio_client.dart`, `network_info.dart`, `api_constants.dart`, `storage_keys.dart`.
4. `injection_container.dart` (external + core).
5. `easy_localization` + `en.json`/`ar.json` (common + errors keys), `CFBundleLocalizations` in iOS `Info.plist`.
6. `app_router.dart` with placeholder routes; `ScreenUtilInit` with the Figma size; temporary `LanguageSwitcher`.
7. Tests: failure mapping, dio exception mapping.
- **Done when:** the app runs, language switches instantly and flips direction, and the choice survives a restart.
- **Commits:** `chore: remove counter template` · `build: add core dependencies` · `feat(core): add DI, network client and error model` · `feat(l10n): add Arabic/English with persisted locale` · `feat(core): add router and responsive setup`

### Phase 3: Data layer, remote + local (~2 h) · C0, C1, C2, C5, C7, C8, E4
Recipe steps 1–9 (§4.4) for `properties`:
1. Fixtures from real responses + broken variants.
2. Entities, repository contract, use cases (incl. `FilterPropertiesUseCase`).
3. Models + tests.
4. Remote data source + MockDio tests.
5. Local data source (SharedPreferences, TTL) + tests.
6. Repository impl with the §4.5 strategy + tests for every branch (online, offline with cache, offline without cache, timeout, 5xx, parsing).
7. DI registration.
- **Done when:** all data/domain tests pass without network.
- **Commits:** `feat(properties): add domain entities, contracts and use cases` · `feat(properties): add models and remote data source` · `feat(properties): add local cache data source` · `feat(properties): add repository with cache fallback` · `test(properties): cover parsing, data sources and repository`

### Phase 4: Design system & shared widgets (~2 h) · A2, A3, A5, B4, T7, T10
1. `colors_app.dart`, `app_text_styles.dart`, `app_sizes.dart`, `app_theme.dart` from §5.3 only.
2. Fonts + approved assets (`download_assets`) → `assets/` + `image_path.dart`.
3. `core/widget/*` and `PropertyCard`.
4. Widget tests: LTR/RTL, long text, 320×640 at 1.3 scale.
- **Commits:** `feat(theme): add design tokens from Figma` · `feat(ui): add shared widgets` · `feat(properties): add property card` · `test(ui): add RTL/LTR widget tests`

### Phase 5: Screens & states (~3–3.5 h) · A1, A4, C3, C4, C6, C8, D1, D4
Recipe steps 10–15 (§4.4) per screen, in navigation order:
1. Cubit + state + bloc_test.
2. Screen built from small widgets; all `RequestStatus` views; offline banner when `isFromCache`.
3. Search (debounce/cancel), filters (chips/sheet per Figma), sort, pagination with retry footer.
4. Details via `/property/:id` (list item as optional initial data, avoiding a duplicate fetch).
5. Apply every button decision from §5.2.
- **Done when:** each required screen works on live data, every state is reachable (airplane mode, wrong base URL), and there are no dead buttons.
- **Commits (per screen):** `feat(home): …` · `feat(search): add debounced search and filters` · `feat(details): …` · `test(search): add cubit tests`

### Phase 6: Arabic/RTL polish (~1–1.5 h) · B2–B6, D2, D3
- Audit for hard-coded strings; directional icons/alignment; horizontal lists; mixed content (prices, phones, Latin titles); long Arabic strings.
- Widget test: switching locale flips `Directionality` without restart.
- **Done when:** the same flow is clean in EN and AR on iPhone 16e, 16 Pro Max, and Android, at 1.3 text scale.
- **Commits:** `fix(l10n): translate remaining strings` · `fix(rtl): correct directional icons and alignment` · `feat(l10n): isolate mixed-direction content`

### Phase 7: Robustness (~1 h) · C4–C7, D3
Manual checklist:
- [ ] Launch in airplane mode → cached data or friendly error → reconnect → retry works.
- [ ] Timeout (temporarily lower timeouts).
- [ ] 404/500 (temporary wrong endpoint/base URL).
- [ ] Broken/empty image URLs → no crash.
- [ ] Fast typing → one request after pause (check LogInterceptor).
- [ ] Fast scroll to end → no parallel page requests.
- [ ] Navigate back and forth → no unnecessary refetch.
- **Commit:** `fix(network): harden error handling and request deduplication`

### Phase 8: Tests & quality (~1 h) · E3, E4
- Fill gaps against §4.7 minimum: parsing, repository strategy, filter/search logic, search cubit, property card RTL/LTR, language switch.
- `flutter analyze` = 0 · `dart format .` · split large widgets · remove dead code.
- **Commits:** `test: complete core coverage` · `refactor: split large widgets and tidy naming`

### Phase 9: Documentation & delivery (~1–1.5 h) · G1–G9, C9, E5, F1–F6
1. `README.md`: overview, requirements (Flutter 3.44.1 / Dart 3.12.1), install/run, **`API_BASE_URL` setup**, architecture (§4), state management, packages and why (§6), **language switching + RTL/LTR** (T8, T9), assumptions and limitations (**DummyJSON doesn't persist writes**, English-only API data, product→property mapping, local price filter, cache TTLs), how to run tests, screenshots.
2. `AI_USAGE.md` built from §11, covering F1–F6.
3. Screenshots in `docs/screenshots/{en,ar}/` and/or a short video.
4. Tick §3 item by item.
5. Push to the confirmed repo (Q2) after your approval.
- **Commits:** `docs: write README` · `docs: add AI_USAGE.md` · `docs: add screenshots`

---

## 8. Git workflow

- One branch per phase (`feature/foundation`, `feature/properties-data`, `feature/design-system`, `feature/screens`, …) merged into `main`. Alternative: direct commits on `main` (P2).
- Conventional Commits: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `build`.
- **No commit or push without explicit approval.**
- Never commit: the assessment PDF, secrets, build outputs.

---

## 9. Open questions & decisions

| # | Question / decision | Blocks | Proposed default |
| --- | --- | --- | --- |
| **Q1** | Which **screens did the recruiter specify**? (The brief doesn't name them) | Phase 1 | Home/Listing + Search & Filter + Property Details (+ language switcher), confirmed against Figma |
| **Q2** | Delivery repo: `AnasAlhamadd/...` (origin) or `anasAlhamd/...` (empty)? | Phase 9 | `AnasAlhamadd/...` |
| **Q3** | Figma **Drafts duplicate** link | Phase 1 | — |
| **Q4** | Figma fields missing from DummyJSON (location, beds, area…): hide or replace with available fields? | Phase 3 | Replace with available fields (brand, rating, stock) or hide; document. Never hard-code |
| **Q5** | Default language on first launch | Phase 2 | Device language if `ar`/`en`, else `en` |
| **Q6** | Arabic font if the Figma font lacks Arabic glyphs | Phase 4 | Decide after Phase 1 |
| **Q7** | Digits in Arabic UI: Western (123) or Eastern Arabic (١٢٣)? | Phase 6 | Western for prices/phones |
| **Q8** | Non-required buttons (favorite, share, call…): implement locally or hide? | Phase 5 | Favorites local if prominent; otherwise hide (D4) |
| **Q9** | Use DummyJSON POST/PATCH/DELETE? | Phase 5 | Only if a Figma screen needs it, with the C9 disclaimer |
| **P1** | `.cursorrules` replaced by `.cursor/rules/*.mdc` | — | ✅ Done 2026-10-13 |
| **P2** | Branch per phase vs. direct commits on `main` | Phase 2 | Branch per phase |

---

## 10. Progress log

| Date | Phase | Status | Notes |
| --- | --- | --- | --- |
| 2026-10-13 | 0: Setup & planning | ✅ | Env verified; Figma MCP authenticated; Community file access denied (needs duplicate); brief analyzed; rules rewritten in `.cursor/rules/` |
| | 1: Figma | ⏳ | Waiting on Q1, Q3 |

---

## 11. AI usage log (raw material for `AI_USAGE.md`)

| Date | Tool | Purpose | Output | Verification | Modified / rejected & why |
| --- | --- | --- | --- | --- | --- |
| 2026-10-13 | Cursor Agent | Environment audit (git, flutter doctor, analyze, test) | Environment section (§2) | Re-ran commands manually | — |
| 2026-10-13 | Cursor Agent + Figma MCP | Connect Figma MCP, verify access | §2 Figma status | `whoami`; `get_metadata` returned a documented permission error | — |
| 2026-10-13 | Cursor Agent | Analyze brief, plan phases, architecture | This reference + `.cursor/rules/` | Each requirement mapped to an ID (§3) and a phase (§7) | **Rejected** reusing rules copied from another project (Laravel backend path, Firebase, 5 locales with `nl` fallback, fixed 360×800 design size) because they didn't match this assessment |
