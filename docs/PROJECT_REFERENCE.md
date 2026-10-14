# PROJECT_REFERENCE: Flutter Real Estate Assessment

> **Single source of truth for this project.** Agent rules live in `.cursor/rules/*.mdc` and point here.
> Last updated: 2026-10-14 · Status: **All approved screens are built (Splash, Auth, Home, Explore, Filter sheet, Property Details, Profile). Phase 9 docs written 2026-10-14: `README.md`, `AI_USAGE.md`, §3 ticked. Screenshots added (G7). Before delivery: merge into `main` and push (G1).** Earlier status: **Home screen (Figma `1:4426`) implemented on `feature/home` (from `feature/auth` `34700e4`), with its own domain + data layers (`HomeRepository`, remote + local data sources). Flow: Splash → Auth → Home (guest). Property Details (Figma `1:4236`) implemented on `feature/property-details` (from `origin/main` `d0646e1`). Explore (Figma `1:4120`, Search-v1) implemented on `feature/search`, uncommitted (paged search, §4.5.1 update). Filter sheet (Figma `1:3867`) implemented on `feat/add_filter`, uncommitted, opened from Explore's filter icon (`1:4146`); backend interaction in §4.5.1 "Filter sheet". Profile is still a placeholder; the rest of Phase 5 waits for your go-ahead.**

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
| Figma MCP | ✅ Plugin installed and authenticated (`plugin-figma-figma`) · account `anasalhamadstd@gmail.com` (handle "Anas alhamad"), **Starter plan, Full seat → ~20 read calls/month** (`whoami` exempt). **≈16–18 read calls used** as of 2026-10-13: 2 in Phase 0, 1 access check, 7 in Phase 1, 5–6 in Phase 4 (`create_session`, `download_assets` ×3 for Home/Explore/Profile, `get_metadata(1:3786)`, `download_assets(1:3865)`), 1–2 for Splash (`create_session`, `get_design_context(1:4551)`; the logo came from that response's asset URL, so no `download_assets`), 1–2 for Auth (`create_session`, `get_design_context(1:4499)`; the Google logo came from the response's asset URL and the collage from your manual SVG export, so no `download_assets`). **≈18–20 used**: ask before any further call. Whether `create_session` counts is unverified. **Property Details (2026-10-13, approved going over budget):** `create_session` + `get_design_context(1:4236)`, so **≈20–22 used**; the monthly limit is likely reached. **Details extras (2026-10-13, your request to add the missing parts of `1:4273`):** `create_session` + `get_design_context(1:4273)`; every icon, the map art, the pin and the two sample photos came from that response's asset URLs (no `download_assets`), so **≈22–24 used**. **Explore (2026-10-13):** the Search task's design read of `1:4120` was lost, and the next `get_design_context` returned "You've reached the Figma MCP tool call limit on the Starter plan": **limit reached**, no further Figma reads this month |
| Figma file access | ❌ Community original returns *"you don't have edit access to this file"*. ✅ **Drafts duplicate** `idJrPCgmZTzih809HNpgnr` is readable (verified 2026-10-13) |
| GitHub | Two repos exist: `AnasAlhamadd/...` (origin, 1 commit) and `anasAlhamd/...` (empty). Delivery target: see Q2 |

---

## 3. Requirements checklist (from the assessment brief)

Each phase in §7 references these IDs. Tick them in Phase 9.
⚠️ The repo is **public**: don't commit the assessment PDF without permission (`*.pdf` is in `.gitignore` since 2026-10-14).

**Audit 2026-10-14** (all features done, branch `docs/final-audit`): ticked items were checked against the code and tests. Still open: **G1** (merge `docs/final-audit` into `main` through a PR), **F6**. G7 done: 12 simulator screenshots (1320×2868) in `docs/screenshots/{en,ar}/` (`home`, `explore`, `filter`, `property_details`, `profile`, `auth`), all linked from README §2 (yours: be ready to explain the code). Partial, documented in README §14: A1/A2 for Explore (category chip row `1:4149` not shown, pixel values not re-checked against Figma), Home's filter icon hidden and "See All" without category/sort.

### A. Implement the Figma design
- [x] **A1** Implement the **screens specified by the recruiter** from the Figma design.
- [x] **A2** Match the design as closely as possible: colors, spacing, sizes, fonts, icons, borders, shadows, images, and image cropping.
- [x] **A3** Reusable widgets for repeated elements (property cards, buttons, section headers).
- [x] **A4** Support different phone sizes with **no clipped content and no overflow errors**.
- [x] **A5** Don't replace design elements with generic ones that visibly change the look.

### B. Arabic/English and RTL/LTR
- [x] **B1** Both languages, **switchable in-app without restarting**.
- [x] **B2** Arabic → RTL layout; English → LTR.
- [x] **B3** Translate **all** static text: buttons, titles, error messages, loading states, navigation.
- [x] **B4** Correct direction for lists, arrows, back buttons, fields, alignment, content cards.
- [x] **B5** Long text handled without overlapping or overflowing its container.
- [x] **B6** Readable mixed content: numbers, prices, phone numbers, Latin text inside the Arabic UI.
- [x] **B7** **Persist the language choice** and restore it on next launch.

### C. API integration
- [x] **C0** Dynamic data comes from the API and is never hard-coded in UI. DummyJSON products may be used as card data.
- [x] **C1** JSON → clear **models**.
- [x] **C2** Network calls **separated from widgets**.
- [x] **C3** Loading, success, empty, and error states.
- [x] **C4** **Retry** on failure where appropriate.
- [x] **C5** Handle **no internet, timeouts, server errors, unexpected responses**.
- [x] **C6** Unavailable images must not crash the screen.
- [x] **C7** **Avoid repeated or unnecessary requests**.
- [x] **C8** **Search and filtering**.
- [x] **C9** DummyJSON simulates POST/PATCH/DELETE but **does not persist them**. State this in README and never claim data survives restarts.

### D. UX & navigation
- [x] **D1** Clear navigation between required screens.
- [x] **D2** Selected language preserved while navigating.
- [x] **D3** User-friendly messages, never raw technical errors.
- [x] **D4** **No buttons that look active but do nothing.**

### E. Code quality & tests
- [x] **E1** Organized files; UI separated from data logic and app state.
- [x] **E2** A suitable state management approach applied consistently.
- [x] **E3** Clear names, minimal duplication, no giant hard-to-maintain widgets.
- [x] **E4** Basic tests for important logic (e.g., JSON parsing, search logic).
- [x] **E5** Document important external packages and why they're used.

### F. AI usage policy (documented in `AI_USAGE.md`)
- [x] **F1** AI tools used and the purpose of each.
- [x] **F2** Parts AI helped create or review (planning, components, tests, debugging, API).
- [x] **F3** Short examples or summaries of the most important prompts.
- [x] **F4** How outputs were verified (tests, reviews, experiments).
- [x] **F5** **At least one** AI output that was modified or rejected, and why.
- [ ] **F6** Be able to explain and modify all delivered code. Full responsibility for correctness, security, and quality.

### G. Deliverables
- [ ] **G1** Git repository link with the complete code.
- [x] **G2** README: requirements, install & run steps, **API base URL setup**.
- [x] **G3** Short explanation of architecture, state management, key packages.
- [x] **G4** `AI_USAGE.md`.
- [x] **G5** How language switching works and how RTL/LTR is implemented.
- [x] **G6** AI usage summary per section F.
- [x] **G7** Screenshots of required screens **in both languages**, or a short video showing navigation + language switch.
- [x] **G8** Assumptions and known limitations, especially the demo API's behavior.
- [x] **G9** Clear, meaningful commit messages reflecting a natural work history (commit count isn't a quality metric).

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
│   │   ├── app_text_keys.dart        # every translation key (en/ar parity checked by a test)
│   │   ├── api_constants.dart        # baseUrl (--dart-define) + endpoints
│   │   └── storage_keys.dart         # SharedPreferences keys (approved: first page + categories + favorites)
│   ├── storage/versioned_preferences_store.dart # {schemaVersion, cachedAt, data} envelope, size cap, corrupt → removed
│   ├── network/
│   │   ├── dio_client.dart           # timeouts, ApiLogInterceptor (debug only)
│   │   ├── api_log_interceptor.dart  # dart:developer log (name `API`): request / request_status (+ ms) / uri per finished request
│   │   └── network_info.dart
│   ├── error/
│   │   ├── exceptions.dart           # Server/Network/RequestTimeout/Parsing/Cache/Cancelled/Unknown
│   │   ├── failures.dart             # Failure + subtypes
│   │   ├── exception_failure_mapper.dart # AppException → Failure (used by repositories)
│   │   └── failure_message.dart      # Failure → translation key
│   ├── localization/app_localization.dart # locales, EasyLocalization wrapper
│   ├── usecase/usecase.dart          # UseCase<T, Params>, NoParams
│   ├── enums/request_status.dart
│   ├── services/phone_dialer.dart    # PhoneDialer (tel: through url_launcher); faked in tests
│   ├── utils/{formatters, cancellation_signal, relative_time}.dart  # debounce lives in SearchCubit (Timer); Latin/number runs use TextDirection.ltr (no bidi_text helper)
│   └── widget/                       # CustomText (translated key / .plain), AppButton, SectionHeader, AppNetworkImage, LoadingView,
│                                     # ErrorView, EmptyView, AppSearchField, AppBackButton (+ .plain), AppSvgIcon,
│                                     # CircleIconButton, CategoryChip, RatingBadge, AppBottomNavBar, AppDivider,
│                                     # FavoriteButton, AppShimmer + SkeletonBox + SkeletonTextLine, LoadMoreScrollListener, LoadMoreErrorView,
│                                     # GuestAvatar (Home + Profile, Q11), app_shell.dart (Figma nav since Phase 4)
│                                     # placeholder_screen.dart: only the not-found page (language_switcher.dart removed 2026-10-14)
└── feature/
    ├── splash/presentation/pages/splash_screen.dart # UI + timed go(auth) only, no domain/data (#1, #6)
    ├── auth/presentation/                # UI only, no domain/data until backend auth exists (#6)
    │   ├── pages/auth_screen.dart
    │   └── widget/{auth_collage, auth_intro, google_auth_button}.dart
    ├── profile/presentation/             # UI only (Q17): the locale lives in easy_localization, no domain/data
    │   ├── pages/profile_screen.dart
    │   └── widget/{profile_user_info, profile_menu_row, language_sheet}.dart
    ├── favorites/                    # Q8: local only, no screen; FavoritesCubit provided above the router
    │   ├── domain/{repositories/favorites_repository, usecases/{get,save,toggle}_favorite(s)_usecase}.dart
    │   ├── data/{datasource/favorites_local_data_source, repositories/favorites_repository_impl}.dart
    │   └── presentation/{cubit/favorites_{cubit,state}, widget/{property_favorite_button, favorites_failure_listener}}.dart
    ├── home/                         # Home screen with its own domain + data (2026-10-13, your call)
    │   ├── domain/
    │   │   ├── repositories/home_repository.dart   # featured, categories, recommendations (All | category, paged)
    │   │   └── usecases/{get_featured_properties, get_categories, get_recommendations}_usecase.dart
    │   ├── data/
    │   │   ├── datasource/home_remote_data_source.dart  # DummyJSON: featured, categories, /products, /products/category/{slug}
    │   │   ├── datasource/home_local_data_source.dart   # SharedPreferences: "All" first page + categories (§4.5.2)
    │   │   └── repositories/home_repository_impl.dart   # remote first; saved copy on any failure except cancel
    │   └── presentation/
    │       ├── cubit/home_{cubit,state}.dart
    │       ├── pages/home_screen.dart
    │       └── widget/{home_header, home_category_chips, featured_property_list, section_status_view}.dart
    ├── property_details/             # Details screen over properties' GetPropertyDetailsUseCase + mock extras
    │   ├── domain/{entities/property_extras_entity, repositories/property_extras_repository,
    │   │           usecases/get_property_extras_usecase}.dart
    │   ├── data/{datasource/property_extras_mock_data_source,   # this mock: Figma sample values (§4.6)
    │   │         repositories/property_extras_repository_impl}.dart
    │   └── presentation/
    │       ├── cubit/property_details_{cubit,state}.dart
    │       ├── pages/property_details_screen.dart
    │       └── widget/{details_top_bar, details_hero, details_page_dots, details_header, property_tag,
    │                   details_rating_text, details_stats, details_agent, details_overview,
    │                   details_facilities, details_gallery, details_location, details_map,
    │                   details_reviews, review_tile, details_price_bar, details_skeleton}.dart
    ├── search/                       # Explore + Filter sheet (paged search, filtered full sets, §4.5.1)
    │   ├── domain/entities/{search_query, search_results_entity, property_filter, price_histogram}.dart
    │   ├── domain/{repositories/search_repository, usecases/*}.dart         # paged search + its memory cache
    │   ├── data/{datasource/search_results_local_data_source, repositories/search_repository_impl}.dart
    │   └── presentation/
    │       ├── cubit/{search,filter}_{cubit,state}.dart
    │       ├── pages/search_screen.dart
    │       └── widget/{search_header, search_results_section, search_results_count, filter_sheet,
    │                   filter_sheet_header, filter_section, filter_price_section, filter_category_section,
    │                   price_range_chart, price_histogram_bars}.dart
    └── properties/                   # shared entities/models, search + details, property widgets
        ├── domain/
        │   ├── entities/{property_entity, properties_page_entity, category_entity,
        │   │             review_entity, price_range}.dart
        │   ├── repositories/properties_repository.dart   # full sets (search, catalog; memory, 5 × 10 min), details
        │   └── usecases/{search_properties, get_property_details, filter_properties}_usecase.dart
        ├── data/
        │   ├── model/{property_model, properties_response_model, category_model,
        │   │          review_model, json_readers}.dart
        │   ├── datasource/properties_remote_data_source.dart
        │   └── repositories/properties_repository_impl.dart
        └── presentation/widget/{featured_property_card, property_grid_card, property_list_card,
                                 property_location_label, sliver_property_grid,
                                 property_card_skeletons}.dart
assets/
├── images/  ├── svg/  ├── fonts/
└── translations/{en.json, ar.json}
test/                                 # see §4.7
integration_test/app_test.dart        # optional
```

**Screen features (2026-10-13, your call):** Home moved from `properties/presentation` to `feature/home/` because it is a screen that composes several sources, not part of the property data module. **Updated 2026-10-13 (your call):** Home now owns its domain and data layers: `HomeRepository`, three use cases, `HomeRemoteDataSource` (DummyJSON) and `HomeLocalDataSource` (the persisted "All" first page + categories, moved from `properties`). `properties` keeps the shared entities/models, search, full catalog and details. One `GetRecommendationsUseCase` takes an optional category slug, so `HomeCubit` no longer chooses the endpoint. Dependencies point one way: `home → properties` (entities/models), `home → favorites → properties`; `properties` never imports a screen feature. Explore's paged mode (§4.5.1: "All" and category pages when there's no search text) will need the paged listing again; whether it reuses Home's use cases or gets its own is TODO(question) until Explore is built. **Details (approved 2026-10-13):** `feature/property_details/` holds presentation only (Cubit, screen, widgets) over the existing `GetPropertyDetailsUseCase` in `properties`, which already has the details endpoint and its in-memory cache. Dependencies: `property_details → properties`, `property_details → favorites`. **Updated 2026-10-13 (your request):** `property_details` now also has a small domain + data layer for the Figma fields DummyJSON lacks (`PropertyExtrasEntity`, `PropertyExtrasRepository`, `GetPropertyExtrasUseCase`, `PropertyExtrasMockDataSource`). The cubit loads them in parallel with the details; a failure only hides their sections. A real source can replace the mock data source without touching the presentation. Explore is proposed to follow the same pattern (`feature/explore/`); TODO(question) until it's built.

Favorites (Q8, approved 2026-10-13) live in `feature/favorites/`: local-only data source, one app-wide `FavoritesCubit`. They reuse `PropertyEntity` and `PropertyModel` from `properties` (listing fields only).

### 4.3 Request lifecycle (one user action end-to-end)

```text
User types "villa"   (implemented 2026-10-13, feature/search; paged, §4.5.1)
 → SearchView: AppSearchField.onChanged
 → SearchCubit.onQueryChanged(q)       debounce 300 ms, normalize, < 2 chars → browse mode, ignore unchanged query,
                                        bump the request generation, cancel previous CancellationSignal
 → GetCachedSearchResultsUseCase        cached pages for "villa"? → emit them at once (no loading state); older than 10 min → refresh in the background
 → emit(status: loading)                otherwise
 → SearchFirstPageUseCase(SearchPageParams(q))
 → SearchRepository.searchFirstPage     (domain contract)
 → SearchRepositoryImpl                 memory cache → NetworkInfo.isConnected? no → Left(NetworkFailure)
 → PropertiesRemoteDataSource.searchProductsPage   GET /products/search?q=villa&limit=20&skip=0&select=<listing fields>
      DioException → typed exception    200 → PropertiesResponseModel.fromJson → cache entry (deduped by id)
 → Right(SearchResultsEntity)
 → Cubit: older generation → dropped  |  items.isEmpty ? empty : success  |  Left(f) → failure(f)  |  CancelledFailure → ignored
 → BlocBuilder renders SliverPropertyList / EmptyView / ErrorView(onRetry: cubit.retry)
```

```text
User taps the filter icon, picks "Furniture", taps "Set Filter"   (feat/add_filter, §4.5.1 "Filter sheet")
 → SearchView._openFilter              showFilterSheet(query: cubit.requestedQuery, applied: state.filter)
 → FilterCubit.load                    categories (GetCategoriesUseCase, cached) ‖ full set (SearchPropertiesUseCase)
 → PropertiesRepositoryImpl._fullSet   fresh memory copy? → served | else GET /products?limit=0 (or /products/search?q=…&limit=0)
 → PriceHistogram.of(prices)           20 log-scale buckets → bars + RangeSlider positions
 → toggleCategory / setPriceRange      draft only, no request;  back → closes, nothing applied
 → "Set Filter" pops PropertyFilter    → SearchCubit.applyFilter(filter)   unchanged → nothing
 → SearchCubit._loadFiltered(query)    same full set, now from memory (no request) → FilterPropertiesUseCase
 → emit(mode: filtered, items, total = items.length, hasReachedMax: true)   empty → "Clear filters"
```

### 4.4 UI ↔ backend wiring recipe (follow this order for every feature)

| Step | Layer | File | Done when |
| --- | --- | --- | --- |
| 1 | domain | `entities/*_entity.dart` | Immutable, Equatable, only fields the UI needs |
| 2 | domain | `repositories/*_repository.dart` | Abstract methods return `Future<Either<Failure, T>>` |
| 3 | domain | `usecases/*_usecase.dart` | One `call(Params)`, Params is Equatable |
| 4 | test | `test/fixtures/*.json` | Real API response saved + broken variants |
| 5 | data | `model/*_model.dart` | Defensive `fromJson`, `toJson` (for cache), `toEntity()`, **tests pass** |
| 6 | data | `datasource/*_remote_data_source.dart` | Abstract + Dio impl, throws typed exceptions, **tests through the real `DioClient` over a fake HTTP adapter** (`test/helpers/stub_http_adapter.dart`) |
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

✅ Approved 2026-10-13 (cache option B, search/filter strategy, Featured sort). `<listing fields>` = `select=title,price,rating,category,brand,thumbnail` (§4.6).

| Operation | Remote | Local | Strategy |
| --- | --- | --- | --- |
| Listing "All", page 0 (default order, no search, no price filter) | `GET /products?limit=20&skip=0&select=<listing fields>` | **persisted** (§4.5.2) | Online: always remote → save → fresh. Remote fails (§4.5.2 fallback rule): cached page with `isFromCache: true` (UI shows an "offline: saved data" banner). No usable cache: the original `Failure` |
| Listing pages > 0 | `skip = page * 20` | — | Remote only. Failure keeps existing items and shows a retry footer |
| By category (paged mode) | `GET /products/category/{slug}?limit=20&skip=…&select=<listing fields>` | — | Remote only, paginated |
| Filter sheet / filtered Explore (full-set mode) | `GET /products/search?q=…&limit=0&select=<listing fields>` with search text, else `GET /products?limit=0&select=…` | **in-memory only** (`PropertiesRepositoryImpl`: last 5 full sets, fresh for 10 min, successes only) | Fetch the full matching set once; categories (several) + price range are filtered on the device. The sheet's histogram and the filtered results share the same memory copy; pull to refresh skips it (`forceRefresh`) (§4.5.1) |
| Featured (Home) | `GET /products?sortBy=rating&order=desc&limit=5&select=<listing fields>` | — | Remote only (not in the approved persisted scope) |
| Categories | `GET /products/categories` | **persisted** (§4.5.2) + in-memory | Memory → persisted if < 24 h old → remote → save. Remote fails: persisted copy of any age |
| Details | `GET /products/{id}` (full object) | **in-memory only** (session, last 20) | Show the list item as initial data → remote → keep in memory. Failure: in-memory item, else `Failure`. Never persisted |
| Sort | `sortBy`, `order` query params | — | Server-side (verified to work on `/products`, `/search`, `/category/{slug}` together with `select`) |
| Price range | not supported by API (`minPrice`/`price_gte` are ignored, verified) | — | Local pure function `FilterPropertiesUseCase` (unit-tested), full-set mode only |
| Favorites | — | **persisted** (§4.5.2, `StorageKeys.favorites`) | ✅ Q8 approved 2026-10-13. Device only, no API. Toggle updates the UI at once, then saves; saves run one at a time and always write the latest list; a failed save reverts to the saved list and shows a snackbar |
| Language | — | `easy_localization` (`saveLocale`, key `locale`) | Automatic |

#### 4.5.1 Listing modes (search, category, price)

DummyJSON can't combine them server-side (verified 2026-10-13): `/products/search` ignores `category`, `/products/category/{slug}` ignores `q`, and no price parameters exist.

| Mode | When | Request | Local work |
| --- | --- | --- | --- |
| **Paged** | Search text empty (after trim) **and** no price filter | "All" → `/products?limit=20&skip=…`; a category → `/products/category/{slug}?limit=20&skip=…` | None. `hasReachedMax` when the response's `skip + limit >= total` (DummyJSON echoes the returned count in `limit`) |
| **Full set** | A Filter-sheet filter is active (categories and/or price; **updated 2026-10-13**, Explore's plain search is paged, next rules) | Text → `/products/search?q=<text>&limit=0&select=…`; no text → `/products?limit=0&select=…` | `FilterPropertiesUseCase`: categories (slug in the selected set) + price range (inclusive, open ends allowed) on the full set |

Rules:
- **Fetched once:** in full-set mode, changing the category or price range only re-filters the in-memory set (no request). A new request happens only when the search text changes, or when entering full-set mode.
- **Query changes:** 300 ms debounce (`SearchCubit.defaultDebounce`, the same timer in search and filtered mode; the original plan said 400 ms, corrected 2026-10-14 to match the code), normalized, unchanged text ignored; the previous request is cancelled through its `CancellationSignal` (pure Dart, `core/utils/cancellation_signal.dart`; one signal per request) and its `CancelledFailure` is ignored. The remote data source converts the signal into a Dio `CancelToken`: an already cancelled signal sends no request, and cancelling in flight aborts it. A response that arrives just before cancellation can still succeed, so the Cubit must also check that the result belongs to the latest request before updating the state.
- **Mode switches** reset pagination. Clearing the text with no price filter returns to paged mode (page 0, with the persisted fallback for "All").
- **Changed 2026-10-13 (your Search brief, `feature/search`):** Explore searches **page by page** instead of fetching the full set: `GET /products/search?q=<normalized>&limit=20&skip=…`, debounce **300 ms** (`SearchCubit.defaultDebounce`, configurable), at least **2 characters** after trimming (`SearchQuery.minLength`; shorter text shows browse mode, the "All" pages through `GetRecommendationsUseCase`, and sends no search). The query is normalized (trimmed, inner spaces collapsed, lower case). Results live in a session memory cache per normalized query (`SearchResultsMemoryDataSource`: last 20 queries, fresh for 10 minutes, only successful pages, deduped by id), so going back to a query restores its loaded pages without a request. Stale responses are dropped by a request generation plus `CancellationSignal`. The count uses the API `total`. The full-set rules above apply to the Filter sheet (next bullet).
- **Filter sheet: backend interaction (decided 2026-10-13 by the agent at your request, `feat/add_filter`):**
  - **Rule:** any active filter (at least one category or a price range) switches Explore to **full-set mode** (`SearchMode.filtered`). With no filter, Explore stays exactly as above (paged browse/search). Filters apply to the current query: the whole catalog when the field has fewer than 2 characters, otherwise that query's full set.
  - **Why full set:** DummyJSON can't combine search + category, accepts one category per request and has no price parameters (verified, see the top of §4.5.1). Filtering only the loaded pages would give wrong results and a wrong "Found {n}". The worst case is the whole catalog, 194 items / ≈40 KB with `<listing fields>`, so one `limit=0` request is cheaper than several paged ones.
  - **Requests:** one per query, not per filter change. `PropertiesRepositoryImpl` keeps the last **5** full sets in memory for **10 minutes** (keys `all` and `search:<query>`, least recently used evicted, only successful responses kept, never persisted). The sheet's `FilterCubit` loads the full set to draw the price histogram; "Set Filter" then reads the same copy, so applying usually sends **no** request. Changing filters, reopening the sheet, or typing back a recent query within 10 minutes is also free. Pull to refresh in filtered mode passes `forceRefresh: true`.
  - **Cancellation:** closing the sheet cancels its in-flight load (`CancellationSignal`). `SearchCubit` cancels the previous full-set request when the query or filter changes, and drops late responses by its request generation.
  - **Local work:** `FilterPropertiesUseCase` keeps items whose category is **in** the selected set (empty set = every category) and whose price is inside the range (inclusive). Order is the API's. The count is the filtered list length; everything is shown at once (no pagination).
  - **Price scale:** the histogram has 20 buckets on a **logarithmic** scale (`ln(price + 1)`) between the floor of the lowest and the ceil of the highest price, because DummyJSON prices run from $0.79 to $36,999.99 with most under $100 (a linear scale puts almost everything in the first bar). Thumb prices are rounded to whole dollars. A thumb at its end of the track leaves that side **open** (`min` 0 or `max` ∞), so a later query with wider prices isn't cut off; both thumbs at the ends means no price filter. With fewer than two different prices the slider is disabled.
  - **Draft vs applied:** the sheet edits a draft (`FilterState`); back closes without applying, Reset clears the draft, "Set Filter" applies it. Reopening starts from the applied filter. Clearing every filter returns to the paged listing (the "All" listing is restored without a request).
  - **States:** the sheet shows a price skeleton while loading and a retry row if the full set fails (categories and "Set Filter" still work; the applied price range is kept). Explore shows the usual loading/error states, and "Nothing matches these filters." with a "Clear filters" button when the filtered list is empty.
  - **Rejected:** a paged category endpoint (one category only, can't combine with search); filtering only loaded pages (wrong results and count); deduplicating in-flight requests between the sheet and Explore (one caller's cancellation would cancel the other's request); persisting full sets (outside the approved storage scope, §4.5.2).
- **Result count** ("Found {n}"): paged mode uses the API `total`; full-set mode uses the filtered list length.
- **States:** loading while the full set is fetched; failure → `ErrorView` with retry of the same request; empty when nothing matches.
- **Verified `limit=0` behavior:** returns every match and echoes `limit = total`. Worst case is the whole catalog: 194 items, **39.6 KB** with `<listing fields>`. Empty `q` and `q=a` both return all 194. Search is case-insensitive. Arabic text returns 0 results (the API is English-only, so the empty state applies). An unknown category slug returns HTTP 200 with `total: 0` (not 404).

#### 4.5.2 Persisted cache boundaries (`shared_preferences`)

Approved scope: **three keys only**. API cache: `StorageKeys.productsFirstPage` (`cache.products.first_page`) and `StorageKeys.categories` (`cache.categories`); nothing else from the API is written to disk. User data: `StorageKeys.favorites` (`favorites`, Q8). All three use `VersionedPreferencesStore` (`core/storage/`).

| Rule | Value |
| --- | --- |
| Envelope | `{ "schemaVersion": <int>, "cachedAt": <ISO-8601 UTC>, "data": <JSON> }` |
| Schema versioning | A version mismatch, missing field, or unparseable value counts as "no cache": the key is removed and the local data source throws `CacheException` |
| Bounds | First page: exactly the "All" page 0, ≤ 20 items, `<listing fields>` only (measured **4.2 KB**). Categories: the `/products/categories` list (24 entries, measured **2.5 KB**). Writes larger than **32 KB** are skipped |
| First-page fallback rule | **Changed 2026-10-13 (your call):** used when the remote call fails for any reason except cancellation: no connection, timeout, any non-2xx status (4xx included), unreadable data, or an unknown error; and the entry is < 24 h old. Previously 4xx never fell back (a 4xx usually means a request bug, which the saved copy now hides). Never used for pages > 0, category pages, Featured, search, or price filtering. Implemented in `HomeRepositoryImpl` |
| Categories freshness | < 24 h old: served without a request. Older: refreshed from remote; if that fails, the stale copy is still used |
| Write failures | Never fail the user's request (cache is best-effort; the README states writes aren't guaranteed to reach disk) |
| Favorites | Newest first, unique ids, **≤ 100** (`ToggleFavoriteUseCase.maxFavorites`; adding beyond shows `favorites.limit_reached`). Each entry is a snapshot of the listing fields only (`PropertyModel.listingFromEntity`). Writes over **64 KB** fail with `CacheException` (100 long entries fit). Never expires. Unreadable or older-schema data is removed and favorites start empty; invalid or repeated entries are skipped |
| Not persisted | Details, Featured, pages > 0, category pages, search/full-set results (full sets live in memory only, §4.5.1 "Filter sheet") |
| API | The existing `SharedPreferences` instance (same store as easy_localization's `locale` key), behind `HomeLocalDataSource` (`feature/home/data`), so a later move to `SharedPreferencesAsync`/`WithCache` is a one-file change |

**Error mapping**

| Source | Exception (data) | Failure (domain) | Translation key |
| --- | --- | --- | --- |
| `NetworkInfo` false / `connectionError` / `badCertificate` / `SocketException` | `NetworkException` | `NetworkFailure` | `errors.no_internet` |
| connect/send/receive/transform timeout | `RequestTimeoutException` | `TimeoutFailure` | `errors.timeout` |
| HTTP 5xx | `ServerException(code)` | `ServerFailure` | `errors.server` |
| HTTP 4xx (404 details) | `ServerException(code)` | `NotFoundFailure` / `RequestFailure` | `errors.not_found` / `errors.request` |
| JSON shape/type errors | `ParsingException` | `UnexpectedResponseFailure` | `errors.unexpected_response` |
| Cache empty/corrupt | `CacheException` | `CacheFailure` | `errors.no_cached_data` |
| `CancellationSignal` cancelled (superseded search; Dio `cancel`) | `RequestCancelledException` | `CancelledFailure` (cubits ignore it, never shown) | `errors.request_cancelled` |
| Anything else | `UnknownException` | `UnknownFailure` | `errors.unknown` |

`NetworkInfo` (`connectivity_plus`) only reports whether a network interface is up. It is **not** proof the API is reachable, so real reachability problems still surface as timeouts or connection errors.

### 4.6 Data mapping (DummyJSON product → `PropertyEntity`)

**API schema verified 2026-10-13** with `GET /products/1`. Product keys: `id, title, description, category, price, discountPercentage, rating, stock, tags, brand, sku, weight, dimensions{width,height,depth}, warrantyInformation, shippingInformation, availabilityStatus, reviews[{rating, comment, date, reviewerName, reviewerEmail}], returnPolicy, minimumOrderQuantity, meta, images, thumbnail`. A list response has `{products, total, skip, limit}` (`total` = 194). `GET /products/categories` returns 24 entries shaped `{slug, name, url}`, e.g. `beauty, fragrances, furniture, groceries, home-decoration, kitchen-accessories, laptops, …, vehicle, womens-watches`. `brand` is missing on some products, so treat it as nullable.

**Coverage across all 194 products (verified 2026-10-13):** `brand` missing on **92** (47%) · `images` 1–6 per product · `reviews` exactly 3 on every product · `tags` 1–3 (English) · `availabilityStatus` ∈ {In Stock, Low Stock, Out of Stock} · `weight` is an integer **with no unit** · `price` 0.79–36,999.99 (always decimal) · titles ≤ 41 characters.

**Requests and fields (✅ Q4 approved 2026-10-13)**
- **Listing requests** (paged, full-set, Featured) send `select=title,price,rating,category,brand,thumbnail`; `id` is always included. `select` omits keys the product lacks (e.g. `brand`) and silently ignores unknown names, so the model must treat every listing field as optional. Listing items carry **only** these fields.
- **Details** uses the full `GET /products/{id}` object and is the only source for the detail-only fields below.
- **Entity superset (approved):** `id`, `title`, `description`, `price`, `discountPercentage`, `rating`, `category`, `brand?`, `stock`, `availabilityStatus`, `tags`, `thumbnailUrl`, `imageUrls`, `reviews`. Detail-only fields must be nullable or default-empty, because listing items don't have them. `weight`, `dimensions`, `sku`, `meta` and the shipping/warranty/return fields are **not** mapped.

**Entity fields (the API provides them)**

| Entity field | API field | Figma usage | Notes |
| --- | --- | --- | --- |
| `id` | `id` | route param `/property/:id` | |
| `title` | `title` | Card titles, Details title | English only (documented) |
| `description` | `description` | Details "Overview" | |
| `price` | `price` (double, e.g. `9.99`) | Card price, Details bottom-bar price, Filter price range | Format via `formatters.dart`. Figma shows whole dollars (`$12219`), but the API has decimals |
| `rating` | `rating` (e.g. `2.56`) | Rating badges, Details "4.8 (1,275 reviews)" | Show 1 decimal |
| `category` | `category` (slug) | Details tag "APARTMENT", category chips | Slug → localized label where possible, else `name` from `/products/categories` |
| `thumbnailUrl` | `thumbnail` | Card images | Nullable-safe |
| `imageUrls` | `images` (list; product 1 has 1 image) | Details hero carousel + dots, Gallery (3 tiles + "N+") | Defaults to `[]`. Fall back to `thumbnail` when empty |
| `reviews` | `reviews[]` → `reviewerName`, `comment`, `date`, `rating` | Details reviews block (name, text, "6 days ago") | Review count = `reviews.length` (Figma's "1,275" is sample data). Relative date computed locally |
| `total` (page entity) | `total` | "Found 182 Apartments" | Localized "Found {n} results" |
| `brand` | `brand` (nullable, missing on 47%) | Card "location" line | See the location rule below |
| `discountPercentage`, `stock`, `availabilityStatus`, `tags` | same (details only) | **not in design** | Kept in the entity. Must **not** be presented as bedrooms, bathrooms, or area |

**Figma fields DummyJSON does not provide (decision Q4, never hard-coded, C0)**

| Figma field | Screen(s) | Handling |
| --- | --- | --- |
| Location text ("New York, US", "Beijing, China") | Featured card, grid card, list card | ✅ **Approved:** `brand` when non-empty, else the category display name (`name` from `/products/categories` by slug; localized label per Q12 when available; raw slug as a last resort). The line is always filled, so card heights stay consistent |
| Beds / baths / sqft | Details stats row | ✅ **Changed 2026-10-13 (your request): mock data** (8 beds, 3 baths, 2000 sqft from Figma) from `PropertyExtrasMockDataSource`. `stock`, `weight`, and `availabilityStatus` are still never shown as bedrooms, bathrooms, or area |
| Agent (name, role, avatar, chat, call) | Details "Agent" | ✅ **Changed 2026-10-13: mock data** ("Natasya Wilodra", Owner, Figma photo, fictional `+1 555 0100`). Chat → "not available yet" message; call → phone dialer (`url_launcher`), message if it can't open |
| Facilities (8 icons + labels) | Details "Facilities" | ✅ **Changed 2026-10-13: mock data**, the 8 Figma facilities for every property (not mapped from `tags`) |
| Address + map | Details "Location" | ✅ **Changed 2026-10-13: mock address** + **static** Figma map art (map, street names, pin, sample photo); not mirrored in Arabic; no map package |
| Reviewer avatar, review like count ("938") | Details reviews | ✅ **Approved 2026-10-13:** initials of the reviewer name on a Greyscale/400 circle instead of the photo (Profile icon when the name is empty). **Changed 2026-10-13:** like counts are mock data (938, 254, 61 by review position), display only |
| Property type (Apartments, Townhomes, Homes, Condos, Duplexes, Studios) | Filter sheet | Replace with API categories (Q12) |
| Bedrooms / Bathrooms steppers, Building Size slider | Filter sheet | Hide (no matching field) |
| User identity (avatar, "Adrian Hajdin") | Home header, Profile | No auth in scope. Q11 |
| Booking ("Booking Now") | Details bottom bar | ✅ **Changed 2026-10-13 (your request):** the button is shown; there's still no booking endpoint, so it shows "This isn't available yet" |

**Mock data rule (your decision, 2026-10-13):** every mock value lives in `PropertyExtrasMockDataSource` (plus the two sample photos and the map art) with a `/// this mock:` comment giving the reason. This overrides "never invent fields the API lacks" (`data-layer.mdc`, `00-project-core.mdc`) for these Details fields only; the rule still holds everywhere else, and the card location line and filters are unchanged.

### 4.7 Test folder

```text
test/
├── fixtures/
│   ├── fixture_reader.dart
│   ├── products_page.json  product.json  categories.json  search_empty.json
│   └── product_missing_fields.json  product_wrong_types.json
├── helpers/
│   ├── mocks.dart          # mocktail: MockNetworkInfo, MockRemote/LocalDataSource, MockRepository, MockSharedPreferences (+ use-case mocks with the Cubits)
│   ├── stub_http_adapter.dart # fake Dio HTTP adapter: records requests, returns a set status/body, or hangs (cancellation)
│   ├── fake_properties_repository.dart # details by id + full sets (sample matches), gates, request logs
│   ├── fake_search_repository.dart     # paged search fake; searchCubitFor / filterCubitFor
│   └── pump_app.dart       # pumpApp(widget, {locale, textScale, size}) with EasyLocalization + ScreenUtil
├── core/
│   ├── error/failure_message_test.dart
│   ├── network/dio_exception_mapping_test.dart
│   └── utils/{formatters, cancellation_signal, relative_time}_test.dart
├── feature/property_details/presentation/
│   ├── cubit/property_details_cubit_test.dart
│   ├── widget/<one file per widget>_test.dart
│   └── pages/property_details_screen_test.dart  # states, hidden sections, gallery → hero, routing, layout matrix
├── feature/home/
│   ├── data/datasource/{home_remote, home_local}_data_source_test.dart
│   ├── data/repositories/home_repository_impl_test.dart   # fallback by failure type (4xx included), cancel, age
│   ├── domain/usecases/home_usecases_test.dart
│   ├── presentation/cubit/home_cubit_test.dart, home_cubit_pagination_test.dart
│   ├── presentation/widget/{home_header, home_category_chips, section_status_view}_test.dart
│   └── presentation/pages/home_screen_test.dart, home_screen_interactions_test.dart  # finders in helpers/home_screen_finders.dart
├── feature/favorites/            # one test file per lib file, e.g. domain/usecases/toggle_favorite_usecase_test.dart
├── feature/search/
│   ├── domain/entities/{price_histogram, search_query}_test.dart  # log buckets, open ends; normalization, 2-char minimum
│   ├── data/datasource/search_results_local_data_source_test.dart # LRU 20, freshness window
│   ├── data/repositories/search_repository_impl_test.dart         # offline, cache hit, failures not cached, next page, dedupe, refresh
│   ├── presentation/cubit/{filter_cubit, search_cubit_filter}_test.dart
│   ├── presentation/widget/filter_sheet_test.dart    # Figma geometry at 430, en/ar mirror, price states, layout matrix
│   └── presentation/pages/search_screen_test.dart    # incl. filter icon, apply, back, reset, typing, clear
└── feature/properties/
    ├── data/model/property_model_test.dart
    ├── data/datasource/properties_remote_data_source_test.dart
    ├── data/repositories/properties_repository_impl_test.dart  # incl. full-set memory (fresh, forceRefresh, stale, LRU 5)
    ├── domain/usecases/filter_properties_usecase_test.dart
    └── presentation/widget/{property_cards, sliver_property_grid, property_card_skeletons}_test.dart
integration_test/app_test.dart                     # optional: browse → details → switch to AR → RTL
```

### 4.8 Key technical decisions

| # | Decision | Covers |
| --- | --- | --- |
| T1 | One Equatable state per Cubit with a `RequestStatus` enum (+ `isLoadingMore`, `hasReachedMax`) | C3, E2 |
| T2 | Defensive parsing; all shape/type errors → `UnexpectedResponseFailure` | C1, C5 |
| T3 | Repository remote-first; persisted fallback limited to the "All" first page + categories, details in memory (§4.5.2) | C5, C7 |
| T4 | Shared `ErrorView` with retry, plus a retry footer for pagination failures | C4 |
| T5 | Request dedupe: debounce, `CancellationSignal` (converted to a Dio `CancelToken` in the data layer), unchanged-query guard, no fetch in `build()`, pagination guard, category cache, `select=` | C7 |
| T6 | Two listing modes (§4.5.1): paged server-side listing and search; full-set fetch (`limit=0`, kept in memory 5 × 10 min) with local multi-category + price filtering while a Filter-sheet filter is active. Sort is server-side | C8, E4 |
| T7 | `AppNetworkImage` with placeholder + error widget, null-safe | C6 |
| T8 | `easy_localization` (persisted, instant), directional APIs only | B1–B4, B7, D2 |
| T9 | Bidi isolation for prices/phones/Latin text; `intl` formatting | B6 |
| T10 | ScreenUtil with the Figma frame size; `Flexible`/ellipsis; tested at 1.3 text scale on 320-wide surface | A4, B5 |
| T11 | Every tappable element works or is removed (decision per button in §5) | D4 |
| T12 | `API_BASE_URL` via `--dart-define`, default `https://dummyjson.com` | G2 |
| T13 | Light theme only unless Figma includes dark | Scope |

### 4.9 Decision records: search, pagination, connectivity

Audited 2026-10-14 against the code on `docs/final-audit`. Each record traces a decision to the code and tests that implement it. **Decided by** separates your recorded requirements from choices the agent made while implementing them (see `AI_USAGE.md` §3). **Verification** lists existing tests; on 2026-10-14 the test folders `test/feature/search`, `test/feature/home/presentation/cubit`, `test/feature/home/data`, `test/core/network` and `test/feature/properties/data/{repositories,datasource}` were run: 288 passed. Behavior with no test is marked *inspection only*. Figma was not consulted and the app was not run for this audit.

#### D1. Debounced search with a per-query session cache

- **Decision:** Explore searches 300 ms after the last keystroke, needs at least 2 characters, and keeps every successful page of each normalized query in memory for the app session. Going back to a query shows its results again without a request.
- **Decided by:** you (Search brief, 2026-10-13): a minimum of 2 characters, a configurable debounce of about 300 ms, normalized queries, a late response never overwriting a newer query ("ca" vs "car"), and an in-memory cache keyed by query that keeps pagination state, removes duplicate ids, caches empty results, never caches errors, has bounded memory and shows cached results while refreshing. Agent: the bounds (20 queries, 10 minutes), least-recently-used eviction, lower-casing, and refreshing all loaded pages in one request.
- **Context:** Without a debounce every keystroke sends a request, and responses can arrive out of order. People also edit a query back and forth ("ca" → "cap" → "ca"), so the same request would be sent again.
- **Reasoning:** The debounce waits for typing to pause. The minimum skips one-letter queries, which match almost the whole catalog (`q=a` returns all 194, §4.5.1). Normalizing (trim, collapse spaces, lower case) gives "Ca " and "ca" one cache entry; this is safe because DummyJSON search is case-insensitive (§4.5.1). The cache makes going back instant and saves data.
- **Implementation:**
  - `SearchCubit.onQueryChanged` normalizes the text with `SearchQuery.normalize` and `isSearchable` (`minLength = 2`, counted in characters, not UTF-16 units). Text that normalizes to the last query does nothing. A shorter query shows the browse listing at once: it is restored from a snapshot without a request, or the filtered catalog when a filter is active. Otherwise a `Timer(debounce, …)` starts. `defaultDebounce` is 300 ms and can be changed through the constructor. `submitQuery` (the keyboard search action) skips the wait.
  - Each new query calls `_invalidate()`: it cancels the timer, cancels the in-flight request's `CancellationSignal` (a Dio `CancelToken` in `PropertiesRemoteDataSource`) and bumps `_generation`. Responses from an older generation are dropped, and `CancelledFailure` is never shown.
  - `_search` checks `GetCachedSearchResultsUseCase` first. It reads memory only, with no connectivity check, so cached queries also work offline. A hit is shown at once with no loading state and no request.
  - `SearchResultsMemoryDataSource` is a lazy singleton (`injection_container.dart`), so the cache outlives the screen. The key is the normalized query. It holds at most 20 queries, evicts the least recently used one, and a read counts as use. An entry is stale after 10 minutes. `SearchRepositoryImpl` stores only successful pages; an empty result is stored as finished (`hasReachedMax`).
  - A stale entry is still shown at once. `_refreshShown` then requests every loaded page in one call (`refreshResults`, `limit = max(loaded, 20)`). If that fails, the results stay and the snackbar `searchRefreshFailed` appears.
- **Walk-through ("ca"):**
  1. "c" is too short: the browse listing stays and no search is sent.
  2. "ca": after 300 ms, `GET /products/search?q=ca&limit=20&skip=0&select=…`. The page is stored under `ca`.
  3. "cap": a new 300 ms wait, then a request for `cap`. If the `ca` request is still running it is cancelled, and a late `ca` response is dropped.
  4. Back to "ca": after 300 ms the `ca` entry is shown from memory, with no request, no loading state, every loaded page, and the next offset for pagination.
  - **Exceptions:** an entry older than 10 minutes is shown and then refreshed with one request. An entry evicted by 20 newer queries, or lost on app restart, needs a normal request. If the `ca` request was cancelled before it finished (fast typing), nothing was stored. With a filter active, queries use the full-set memory instead (D4).
- **Alternatives and trade-offs:**
  - A request per keystroke: rejected. Cancellation alone still sends every request.
  - Full-set search with `limit=0` (the earlier plan in §4.5.1): replaced by paged search in your brief.
  - Persisting search results: outside the approved storage scope (§4.5.2).
  - An unbounded cache: memory would grow for the whole session.
  - Trade-off: the debounce also applies to cached queries, so cached results appear 300 ms after the last keystroke, even though no request is sent.
- **Verification:**
  - `search_query_test.dart`: normalization, the minimum, and characters vs UTF-16 units.
  - `search_results_local_data_source_test.dart`: "evicts the least recently written query beyond the bound", "reading a query keeps it from being evicted next", and the `isStale` group.
  - `search_repository_impl_test.dart`: "serves a cached query again without a request", "caches an empty result as a finished answer", "maps a server error and caches nothing", "flags a cached query as stale after the freshness window", "passes the cancellation signal to the request", "fetches the loaded range in one request and replaces it", "a failed refresh leaves the cached pages as they were".
  - `search_screen_test.dart`: "one character sends no request"; "two characters search after the debounce…" (no request at 299 ms, one at 300 ms; the test types `mirror`); "a result opens its details, and Back keeps the query and…" (no second request).
  - `properties_remote_data_source_test.dart`: an already cancelled signal sends no request, and cancelling in flight aborts the request.
  - *Inspection only*, with no Cubit or screen test: the full "ca" → "cap" → "ca" sequence through `SearchCubit` (the screen test "a stale cached query refreshes in the background without skeletons", added 2026-10-14 for U8, covers the stale-entry background refresh); a late response from an older query being dropped by `SearchCubit`; text that normalizes to the same query being ignored.
- **Limitations:**
  - Memory only: the cache is empty after a restart.
  - At most 20 queries are kept.
  - A request cancelled before it finishes stores nothing.
  - A stale entry costs one refresh request.
  - Scroll position is not part of the cache (only the loaded pages and the next offset are).

#### D2. Paginated browsing (Home and Explore)

- **Decision:** Home's recommendations and Explore's browse and search listings load 20 items per page as the user nears the end of the list. Filtered Explore shows the whole filtered set at once.
- **Decided by:** you: "pagination products, lazy loading home" (Home data brief), and paged search (Search brief). Page size 20 is part of the approved strategy (§4.5). Agent: the trigger distance, the guards, removing duplicate ids, and the rule for stale pages.
- **Context:** DummyJSON pages with `limit`/`skip` and returns `total` (194 products). A listing shows a grid or list that can grow.
- **Reasoning:** A small first page appears faster. Loading near the end avoids a "load more" tap. The full set is used only where the API can't filter (§4.5.1).
- **Implementation:**
  - `LoadMoreScrollListener` (`core/widget/`) calls `onLoadMore` when the outer vertical scroll view is less than one screen from its end (`extentAfter < viewportDimension`). It fires on every qualifying scroll event, so the Cubits guard each call with `canLoadMore`. That requires a success state, more pages, no page loading, no failed page, no refresh running and no saved copy on screen (`DataSource.saved`). The guard is in `HomeState` and `SearchState`.
  - End of list: `hasReachedMax` is `skip + limit >= total`, because DummyJSON echoes the returned count in `limit` (`PropertiesResponseModel`). An empty page also ends the list.
  - Home: `HomeRepositoryImpl` sends `skip = page × 20` to `/products` ("All") or `/products/category/{slug}`. `HomeCubit` skips ids already in the grid. One request counter (`_recommendationsRequest`) drops pages that arrive after a category change or a refresh.
  - Explore browse uses the same `GetRecommendationsUseCase`, guarded by `SearchCubit`'s `_generation`.
  - Explore search: `SearchRepositoryImpl.loadNextPage` continues from the cache entry's `nextSkip`. It sends nothing once `hasReachedMax` is set, removes duplicate ids, and appends only if `nextSkip` hasn't changed meanwhile, so two overlapping loads can't append twice. A cancelled next page clears the loading flag without showing an error.
  - Failure: the loaded items stay, and a footer with Retry appears (`retryLoadMore`). Automatic loading pauses until Retry or a reconnect (D3).
  - Filtered mode: no pagination (`hasReachedMax: true`); see the reasons in §4.5.1.
- **Alternatives and trade-offs:** loading the full set (`limit=0`) for every listing was kept only for filtered mode. Nothing else is recorded.
- **Verification:**
  - `home_cubit_pagination_test.dart`:
    - groups `canLoadMore`, `loadMore` (append, "skips items whose id is already in the grid", "stops requesting after the last page", "an empty page ends the list…", "ignores calls while a page is loading", "does nothing on saved results") and "load more failure";
    - "drops a next page that arrives after the change" and "drops a next page that arrives after the refresh".
  - `home_cubit_test.dart`: "a slow response for an older selection is dropped".
  - `home_repository_impl_test.dart`: "later pages use skip and are never cached" and "use skip and never touch the cache".
  - `search_repository_impl_test.dart`: the `loadNextPage` group, including "drops ids a later page repeats", "sends nothing once the last page is loaded" and "a failed page keeps the loaded pages".
  - `search_screen_test.dart`: "shows a skeleton card while the next page loads" and "a failed next page keeps the results and offers a retry".
  - *Inspection only*: `LoadMoreScrollListener` has no test of its own.
- **Limitations:**
  - Home and Explore-browse page requests are not cancelled. A late page is ignored, but its request still completes.
  - Quick category taps each send a request; older ones are dropped, not debounced.
  - Paging stops while a saved copy is shown.
  - A saved copy covers only the first "All" page (§4.5.2).

#### D3. Connectivity awareness and offline handling (`connectivity_plus`)

- **Decision:** `connectivity_plus` (`^6.0.3` in `pubspec.yaml`, 6.1.5 resolved) sits behind `NetworkInfo`. Repositories fail fast when no interface is up. Real request failures are mapped separately. Home and Explore act once when the connection comes back.
- **Decided by:** you: the package and its version, with the note "connectivity status does not guarantee internet access. Handle actual API request failures separately". Also yours: saved data when the request fails or there's no internet (Home data brief), cache option B (§4.5.2), and the fallback on any failure except cancellation (§4.5.2, changed 2026-10-13). Agent: one action on an offline → online change, filtering repeated events (`.distinct()`), and what each Cubit does on reconnect.
- **Context:** `connectivity_plus` reports network interfaces, not internet access; its README warns about Wi-Fi without internet such as captive portals. Users still need data offline and a way to recover.
- **Implementation:**
  - `NetworkInfoImpl`: `isConnected` is true when any reported interface isn't `none`. `onStatusChange` maps changes to a `bool` and drops repeats.
  - `HomeRepositoryImpl`, `SearchRepositoryImpl` and `PropertiesRepositoryImpl` check `isConnected` first and return `NetworkFailure` without a request.
  - Real failures: `DioClient` (connect 10 s, send 10 s, receive 15 s) maps every error type to its own `Failure` (§4.5.2 "Error mapping"). An HTML page from a captive portal is not a JSON object, so it becomes "unexpected response". Every failure shows a localized message with Retry.
  - Saved data offline:
    - Home and Explore browse: the "All" first page (saved copy under 24 h old; the entity's `isFromCache` becomes `DataSource.saved` in the Cubit state, U8; an offline notice on both screens).
    - Categories: served without a request when under 24 h old; any age when the API fails.
    - Details: the remembered copy from this session.
    - Search: cached queries (D1).
    - Featured, later pages and category pages have no saved copy; they show their error with Retry.
  - Reconnect: `injection_container.dart` passes `sl<NetworkInfo>().onStatusChange` to `HomeCubit` and `SearchCubit`. They act only on a change from offline to online. The first event only records the state, and `connectivity_plus` sends the current state first on Android and iOS (plugin source), so starting offline and then connecting counts.
    - `HomeCubit`: refresh if Featured or recommendations failed or a saved copy is shown; otherwise retry a failed next page.
    - `SearchCubit`: retry a failed first load, otherwise refresh a saved copy, otherwise retry a failed next page.
    - These refreshes keep the section status, so they show no skeletons (U8).
    - Both cancel the subscription when closed.
- **Alternatives and trade-offs:**
  - Trusting connectivity as proof of internet: rejected by your note.
  - An extra reachability package or pinging the API: not used. The stack allows no alternatives without approval, and real request errors already cover it.
  - Refreshing on every connectivity event: avoided by acting only on the offline → online change.
- **Verification:**
  - `network_info_test.dart`: "is connected when any interface is up", "is disconnected when only \"none\" is reported", "status stream emits only real changes".
  - `home_repository_impl_test.dart`: "offline page 0 serves a fresh cache without calling the API", "falls back to the cache on …" (one case per failure type), "a cancelled request never falls back to the cache", "ignores a cache that is 24 hours old", "ignores a cache timestamped in the future", "offline fails fast with NetworkFailure" (Featured), "uses stale categories when the refresh fails".
  - `search_repository_impl_test.dart`: "returns NetworkFailure without a request when offline".
  - `home_cubit_pagination_test.dart`, connectivity group: "coming back online refreshes a failed section once", "…replaces saved results", "the reconnect refresh keeps the saved results visible", "…retries a failed next page", "does nothing when the first event is online", "does nothing when every section is fine", "stops listening when closed".
  - `dio_exception_mapping_test.dart` and `dio_client_test.dart`: error mapping.
  - *Inspection only*: `SearchCubit`'s reconnect handling (no test; the shared `showLoading: false` path is covered by the stale-cache test in `search_cubit_refresh_test.dart`); the plugin sending the current state first was read from the plugin source, not tested on a device.
- **Limitations:**
  - On Wi-Fi without internet, `isConnected` is true, so the request runs and fails only after its timeout.
  - A categories-only failure doesn't trigger the reconnect refresh.
  - Featured has no offline copy.
  - Saved copies are best-effort (writes may not reach disk).

#### D4. Other decisions found in the code

| Decision | Decided by | Where | Verified by |
| --- | --- | --- | --- |
| Session memory vs disk: only the "All" first page, categories and favorites go to disk; search pages, full sets and details stay in memory | You (cache option B, Q8) | §4.5.2; `HomeLocalDataSource`, `SearchResultsMemoryDataSource`, `PropertiesRepositoryImpl` | `home_repository_impl_test`, `properties_repository_impl_test`, `search_results_local_data_source_test` |
| Filtered Explore loads the full matching set once and filters on the device (last 5 sets, 10 minutes; unlike D1, a stale set is fetched again, not shown) | Agent, at your request | §4.5.1 "Filter sheet"; `PropertiesRepositoryImpl`, `FilterPropertiesUseCase` | `properties_repository_impl_test`, `search_cubit_filter_test` ("applying the same filter again sends nothing", "a query while filtered loads its full set, not search pages") |
| Home sections load in parallel and fail and retry separately | Agent (Home phase, §10) | `HomeCubit.load`, `retryFeatured`, `retryRecommendations` | `home_cubit_test` ("a Featured failure leaves the other sections loaded", retry group) |
| A failed pull to refresh keeps the loaded data in the state, which is shown again with a snackbar (during the pull the status is `loading` and the screen shows skeletons, U8); a saved copy counts as a failed refresh | Agent (Home phase, §10) | `HomeCubit._refresh`, `SearchCubit._refreshShown` | `home_cubit_pagination_test` ("a failed request brings the shown content back and reports it", "does not replace live results with the saved copy"); `search_cubit_refresh_test` ("a failed pull to refresh brings the results back"); `home_screen_interactions_test` ("a failure keeps what is shown and says so"); `search_screen_test` ("a failed pull to refresh brings the results back and says so") |
| No request starts from `build()`; Cubits are created in `BlocProvider.create` with `..load()`, and the tabs stay mounted (`StatefulShellRoute.indexedStack`) | Rules (`data-layer.mdc`: never call the network from `build()`) | `HomeScreen`, `SearchScreen`, `app_router.dart` | *Inspection only*; "a result opens its details, and Back keeps the query and…" checks that coming back from Details sends nothing |

**Discrepancies found by this audit:** §4.5.1 "Query changes" said 400 ms; the code has a single 300 ms debounce, now corrected there. `.cursor/rules/presentation-layer.mdc` still says "~400 ms", and `.cursor/rules/testing.mdc` lists a `utils/debouncer` that doesn't exist (the debounce is a `Timer` in `SearchCubit`). The rules files were left unchanged; this task was documentation-only.

### 4.10 Decision records: UI/UX additions not in Figma

Audited 2026-10-14 like §4.9. None of these behaviors is specified in the Figma file. Each record says who decided it; values chosen by the agent live in `AppSizes` / `ColorsApp` / widget constants, not in Figma. On 2026-10-14 the tests listed below were run: 51 passed for U1–U5, and the two app test files for U6 passed 71/71. Figma was not consulted and the app was not run for this audit.

#### U1. Details hero: zoom on pull, blur on scroll, bottom gradient

- **Decision:** On Property Details, pulling the page down past the top zooms the photo. Scrolling the hero away blurs it. A dark gradient sits at the bottom of the photo.
- **Decided by:** you (2026-10-13): a custom flexible space instead of `FlexibleSpaceBar`'s defaults, zoom with `Transform.scale` while pulling down, blur with `ImageFiltered`, a dark gradient at the bottom, and both effects tied to the real drag rather than a timer. Agent: the values (blur up to σ 10, gradient 120 high), bouncing physics on every platform, and one change to your request: the blur follows scrolling away, not the pull.
- **Context:** The Figma hero is a static 460-high photo. A large photo with no feedback on overscroll feels flat, and the white page dots can disappear on light photos.
- **Reasoning:** Zoom on pull is the usual "stretchy header" feedback. Blurring while the hero scrolls away fades the photo out behind the content. Blurring during the pull was not used because it would blur the very photo the user is pulling to see. The gradient is at the bottom only: it keeps the white dots readable, while the top-bar icons are dark, so a dark top gradient would hide them.
- **Implementation:** `DetailsHero` (`feature/property_details/presentation/widget/details_hero.dart`) is a `SliverAppBar` (`expandedHeight` = `AppSizes.detailsHeroHeight` 460, `stretch: true`). `_HeroSpace` reads the real header height from its constraints and the full height from `FlexibleSpaceBarSettings.maxExtent`:
  - `pulled` = extra height when stretched → `Transform.scale(1 + pulled / expanded)` anchored at the top edge.
  - `scrolledAway` = lost height → `ImageFiltered` blur σ = `detailsHeroMaxBlur` (10) × `scrolledAway / expanded`, switched off at rest (`enabled: blur > 0`).
  - `_BottomGradient`: `heroGradientStart` → `ColorsApp.overlay`, `detailsHeroGradientHeight` 120, under the dots, and it ignores taps.
  - `PropertyDetailsScreen` uses `BouncingScrollPhysics` on every platform, so the stretch also works on Android.
- **Alternatives and trade-offs:** blur on pull was changed to blur on scroll-away (reason above). `BackdropFilter` (your second option) was not used; `ImageFiltered` blurs only the photo. A top gradient was not added. Trade-off: Android also gets iOS-style bounce on this screen.
- **Verification:** `details_hero_test.dart`: "at rest: no zoom, no blur", "pulling down zooms with the drag, release settles back", "scrolling away blurs in step with the offset", "a dark gradient sits at the bottom, under the dots".
- **Limitations:** the effects follow the finger, so they are not turned off when the system reduces motion (they are direct manipulation, not animations). Blur costs GPU time while the hero is partly visible.

#### U2. Back-to-top button on Home

- **Decision:** After the Home page has scrolled more than one screen, a round button appears. Tapping it scrolls back to the top.
- **Decided by:** you (2026-10-13): a back-to-top button once the user has scrolled far down. Agent: the threshold (one screen), its place, the look, and the timing.
- **Context:** Home grows with pagination (D2), so the way back to the header, the search bar and the category chips gets long.
- **Implementation:**
  - `ScrollToTopButton` (`core/widget/scroll_to_top_button.dart`) listens to Home's `ScrollController`. It is visible when `pixels > viewportDimension` and appears with an `AnimatedScale` (200 ms).
  - Tap: `animateTo(0)` over 500 ms with `easeOutCubic`, or `jumpTo(0)` when the system disables animations.
  - While hidden it ignores taps and is excluded from semantics.
  - It is placed in `HomeScreen`'s `floatingActionButton` slot: end side (right in English, left in Arabic), above the bottom navigation bar.
  - It is built only from existing parts: `CircleIconButton` (`core/widget/circle_icon_button.dart`, the shared 44 px round button with a semantics label, also used by `AppBackButton`) in `ColorsApp.primary`, `AppSizes.buttonShadow`, and the Figma chevron `ImagePath.arrowRight` turned up with `RotatedBox`. No new asset. Its semantics label is `common.back_to_top` (en/ar).
- **Alternatives and trade-offs:** a Material `FloatingActionButton` (default look, not the design tokens) and a new up-arrow asset (the rotated Figma chevron is enough) were rejected (§11). The one-screen threshold is a judgment call; Figma has no value for it.
- **Verification:**
  - `scroll_to_top_button_test.dart`: "is hidden and not focusable at the top", "stays hidden within the first screen", "appears past one screen and scrolls back to the top" (en, ar), "jumps without animating when animations are off".
  - `home_screen_interactions_test.dart`: "appears at the end side above the nav bar and returns to the top" (en, ar).
  - `CircleIconButton` has no test of its own; it is covered through these tests.
- **Limitations:** Home only. Explore's long list has no back-to-top button.

#### U3. Clear (×) button in the search field

- **Decision:** While the Explore search field has text, an × appears at its end. Tapping it empties the field, and Explore returns to the listing without a query.
- **Decided by:** you (2026-10-14): an × to delete the typed search text. Agent: where it sits (between the text and the filter icon), when it shows, the icon, and reporting the clear as a normal edit.
- **Context:** Without it, clearing a query means deleting it character by character.
- **Implementation:**
  - `_ClearButton` in `AppSearchField` (`core/widget/app_search_field.dart`) rebuilds from the `TextEditingController` (`ValueListenableBuilder`). It is shown only while there is text, never on the read-only Home bar, and never when no controller is given.
  - Tap: `controller.clear()`, then `onChanged('')`, so `SearchCubit.onQueryChanged('')` runs as for any edit. The browse listing comes back at once from its snapshot, without a request (or the filtered catalog when a filter is active; see D1).
  - The icon is `AppSvgIcon(ImagePath.close)` (`core/widget/app_svg_icon.dart`, the shared SVG icon widget, tinted with `colorFilter`), 20 px in `ColorsApp.black03`, like the search and filter icons. `assets/svg/close.svg` is a new 24×24 stroke icon in the Iconly style, because Figma has no close icon and the project uses SVG icons only.
  - Its semantics label is `common.clear_search` (en/ar).
- **Alternatives and trade-offs:** Material `Icons.close` was rejected (SVG icons only, §11).
- **Verification:** `app_search_field_test.dart`: "hides the clear button while the field is empty", "hides the clear button on the read-only Home bar", "clears the text and reports an empty query" (en, ar). `search_screen_test.dart` "clearing the query returns to the \"All\" listing" covers the same path by editing the text, not by tapping ×.
- **Limitations:** the tap area is 44 px tall but only as wide as the 16 px gap plus the 20 px icon (about 36 px at the design width); no test checks its size. The §10 entry called it a "44 px tap target", which is accurate for the height only.

#### U4. Grid cards: appear animation with pagination

- **Decision:** Recommendation cards on Home fade in, slide up and grow slightly when they first appear, column after column. Each new page animates the same way.
- **Decided by:** you (2026-10-13): an animation for the product cards that goes with pagination. Agent: the motion values, the stagger, and the no-replay rule.
- **Implementation:**
  - `AppearAnimation` (`core/widget/appear_animation.dart`): 450 ms `easeOutCubic`, opacity 0 → 1, slide from 12 % of the card height, scale 0.94 → 1. The delay is the start of an `Interval` on one controller (no timers). The card is at rest immediately when `animate` is false or the system disables animations.
  - `SliverPropertyGrid` wraps each `PropertyGridCard` with a 70 ms stagger per column in reading order, so it mirrors in Arabic.
  - Ids already shown are remembered, so cards rebuilt after scrolling back don't replay.
  - A replaced list (new category, refresh) clears that memory and bumps a key generation, so it animates again even when the same id stays in the same place.
- **Alternatives and trade-offs:** `Future.delayed` for the stagger was rejected: a pending timer can't be cancelled and fails widget tests (§11). No animation package was added.
- **Verification:**
  - `appear_animation_test.dart`: "starts hidden, lower and smaller, then comes to rest", "waits for the delay before moving", "is at rest at once when animate is false", "is at rest at once when the system disables animations".
  - `sliver_property_grid_test.dart`: "a new page animates in while loaded cards stay put", "the second column starts after the first", "scrolling back does not replay it", "a replaced list (new category) animates again".
- **Limitations:** grid cards only (Home). Explore's list cards and the Featured cards don't animate.

#### U5. 44 px tap targets without moving the Figma layout

- **Decision:** Small Figma icons keep their drawn size and position, but each gets a tap area of at least 44 px (`AppSizes.minTapTarget`, unscaled so small screens don't shrink it).
- **Decided by:** agent, within the 44 px minimum recorded in §5.2. The overlay placement on cards is the agent's choice (§11, Home favorites entry).
- **Implementation:**
  - `FavoriteButton` centers the 20 px Figma heart in a 44 px square.
  - `PropertyGridCard` doesn't put it in the price row (that would push the row taller than Figma). The card reserves the heart's 20 px in the row and draws the 44 px button as an overlay centered on that spot (`PositionedDirectional`, mirrored in Arabic).
  - `CircleIconButton` is a 44 px circle.
  - The search field's filter and clear icons get a 44 px-tall `InkResponse`.
- **Verification:** `favorite_button_test.dart`: "has a 44 px tap target around the Figma-sized heart".
- **Limitations:** Android's guideline is 48 px; the project uses 44 (§11). The heart's 44 px square lies over part of the card, so a tap there toggles the favorite instead of opening the card.

#### U6. Tabs keep their state: no jump back to the first product, no new request

- **Decision:** Switching between Home, Explore and Profile keeps each tab as it was left: scroll position, loaded pages, the typed query and filter. Returning to a tab sends no API request.
- **Decided by:** you; recorded as a UX decision on 2026-10-14. The tab shell has used `StatefulShellRoute` since Phase 2 (§5.2 "Switch tabs").
- **Context:** The common pattern of a bottom bar that swaps the `Scaffold` body by index (or go_router's plain `ShellRoute`) disposes the screen that is left. Here each screen creates its Cubit in `BlocProvider(create: (_) => sl<XCubit>()..load())` and the Cubits are factories. A disposed screen would therefore come back with a new Cubit: scroll back at the first product, paged items lost, and the first-load requests sent again.
- **Reasoning:** Users switch tabs to check something and come back. Losing their place in a long paginated list, and paying for the same requests again, is worse than keeping one more screen in memory.
- **Implementation:**
  - `AppRouter.create` (`core/constant/app_router.dart`) uses `StatefulShellRoute.indexedStack` with one `StatefulShellBranch` per tab. Each branch has its own `Navigator`, and go_router 18 puts the built branches in an `IndexedStack`. A hidden tab stays mounted with its `ScrollController`, its Cubit and its state.
  - A branch is built on its first visit only (`StatefulShellBranch.preload` defaults to `false`, read in the go_router 18.0.2 source). Explore therefore sends its first requests when it is first opened, not at launch.
  - `AppShell` (`core/widget/app_shell.dart`) switches with `navigationShell.goBranch(index, initialLocation: index == currentIndex)`. Another tab is restored as it was; tapping the current tab resets that branch to its first route, without resetting the scroll.
  - The bar is the custom `AppBottomNavBar` drawn from Figma `1:4489`; tab state comes from the router, not from the bar widget.
- **Alternatives and trade-offs:** swapping the body by index or using a plain `ShellRoute` (loses the state, as above). Saving the scroll offset with `PageStorageKey` would keep only the position: the Cubit, its pages and its requests would still be recreated. Trade-off: every visited tab stays in memory (three tabs at most), and the data on a hidden tab isn't refreshed by itself: pull to refresh, or a reconnect (D3).
- **Verification:**
  - `app_shell_responsive_test.dart` "bottom navigation switches tabs" checks the switch only.
  - `language_switch_test.dart` "language switch keeps the current tab" checks the current tab after a language change.
  - *Inspection only*: no test checks that the scroll position, the loaded pages or the request count survive a Home → Explore → Home round trip.
- **Limitations:**
  - Tapping the active tab doesn't scroll to the top (Home has the back-to-top button, U2).
  - Property Details is outside the shell, so it is rebuilt on each open (it starts from the tapped item, §4.5).

#### U7. Explore: pinned search bar, refresh limited to the results

- **Decision (UX):** keep the search field reachable at all times, so after scrolling down through products the user can search for another product, or open the filter, right away, without scrolling back to the top. On Explore, the header (back button and title) and the search field stay pinned at the top, and the results scroll under them. Pull to refresh moves only the results: its spinner appears under the search field and the header and field don't move. During the pull the results show skeletons (U8).
- **Decided by:** you (2026-10-14): pin the search area and let the products pass under it. You also reported that refresh pulled and redrew the whole screen; you chose to pin the header and field together and to limit refresh to the results. Agent: the layout (a fixed top area above the list instead of a pinned sliver).
- **Context:** Before, the header, the field and the results were one `CustomScrollView` inside one `RefreshIndicator`. Scrolling hid the search field, and pull to refresh dragged the whole screen, the field included.
- **Reasoning:** Explore exists to find a product. With pagination the list grows as the user scrolls (D2), so a field that scrolls away gets further out of reach the more results are browsed; changing the query would mean scrolling back up first. Pinning it makes a new search, a correction, the clear × (U3) or the filter one tap away from any scroll position. Refreshing is about the results, so only the results move.
- **Implementation:**
  - `SearchView` (`feature/search/presentation/pages/search_screen.dart`) is a `Column`: `_SearchTopBar` (`SearchHeader`, a `sectionGap` gap, then `AppSearchField`, with the same paddings as before), then an `Expanded` `RefreshIndicator` → `LoadMoreScrollListener` → `_ResultsScrollView` (a `CustomScrollView` with only `SearchResultsSection`).
  - The results viewport starts at the field's bottom edge and clips there, so cards slide under the field. The 24 px gap above "Found {n}" is inside the list, so the layout at rest is unchanged (the Figma layout test still passes).
  - **Superseded the same day by U8:** at first the shown results stayed during a refresh (`SearchResultsSection`'s `buildWhen` ignores `isRefreshing`). Now the user's pull sets `SearchState.status` to `loading`, so the results show skeletons, and they come back after it ends (D4).
  - Pinned with a plain `Column` rather than a `SliverPersistentHeader`: the header's height grows with the text scale, and a persistent header needs fixed extents.
- **Alternatives and trade-offs:** a pinned `SliverPersistentHeader` (fixed extents, see above). Pinning the field only, with the header scrolling away, was offered and not chosen. Trade-off: the pinned area always takes about 136 px at the design size (16 + 44 + 24 + 52), so on small screens with the keyboard open fewer results are visible. No divider or shadow under the field: Figma has none, and inventing one was avoided.
- **Verification** (`search_screen_test.dart`, pinned header and search field group):
  - "results scroll under the header and the search field": the list scrolls, the header and field don't move, and the list starts at the field's bottom edge.
  - "pull to refresh moves only the results, shows skeletons until the new results arrive, and refreshes once": the spinner is below the field, the header and field don't move, and exactly one `refresh:` request is sent (the skeleton part belongs to U8).
  - Existing layout, responsive (4 viewports × en/ar × text scale 1.0/1.3) and pagination tests pass unchanged.
- **Limitations:** Home is unchanged: its search bar is a read-only shortcut to Explore and still scrolls away.

#### U8. Pull to refresh shows a fresh shimmer (Home and Explore)

- **Decision (UX):** when the user pulls to refresh, the content is replaced by skeletons (shimmer) until the new data arrives, so the screen visibly reloads. On Home this covers Featured and the recommendation grid; on Explore, "Found {n}" and the results. If the refresh fails, the previous content comes back with the refresh-failed snackbar.
- **Decided by:** you (2026-10-14): refresh the page and show a new shimmer loading on pull to refresh, on Home and Explore. Then, the same day, you asked for the loading to live in the Cubit (status `loading` → `success`/`failure`, the builder shows the skeleton) instead of a view-level flag, and for the offline state to be an enum (`DataSource`). Agent: showing skeletons only for the user's pull (not background refreshes), keeping the old data in the state so a failure restores it, and leaving the chips and the Explore header/field in place.
- **Context:** Before, a refresh kept the old content on screen and swapped it silently when the answer came. Apart from the spinner, nothing showed that the content was being replaced.
- **Reasoning:**
  - Skeletons make the reload visible and match the first load. The section status is the single source of what the screen shows, so the existing `BlocBuilder`s render `loading` with the same skeletons as the first load; the views hold no extra state.
  - Only the user's pull changes the status. Refreshes the user didn't ask for (a stale cached search entry, D1, and the reconnect refresh, D3) keep it, because covering those with skeletons would hide results that should appear instantly. `isRefreshing` stays set for every refresh; it guards paging and drives the snackbar.
- **Implementation:**
  - `HomeCubit.refresh()` (the pull) runs `_refresh(showLoading: true)`; the reconnect runs `_refresh(showLoading: false)`. With `showLoading`, Featured and the recommendations go to `RequestStatus.loading` if they were `success`, with their items kept in the state. A failed request (or a saved copy) sets that section back to `success`, and `refreshFailed` is set.
  - `SearchCubit.refresh()` runs `_refreshShown(showLoading: true)`: the status goes to `loading` with `items` kept; a failure or a cancelled refresh restores the previous status (`success` or `empty`). The stale-cache and reconnect refreshes pass `showLoading: false`.
  - Views: `RefreshIndicator.onRefresh` is `cubit.refresh` again. `_FeaturedSection`, `_RecommendationsSection` and `SearchResultsSection` build from the status as for the first load (`FeaturedPropertyListSkeleton`, `SliverPropertyGridSkeleton`, `_LoadingResults`). The category chips and the Explore header/field stay (U7).
  - Offline: `HomeState.recommendationsSource` and `SearchState.source` are a `DataSource` enum (`remote`, `saved`, `core/enums/data_source.dart`) instead of the `isFromCache` bool. The offline notice and `canLoadMore` check `DataSource.saved`. The domain `PropertiesPageEntity.isFromCache` is unchanged and mapped by the Cubits. `RequestStatus` keeps its five values.
  - After the skeletons the grid is built anew, so its cards play the appear animation (U4). The `RefreshIndicator` spinner shows during the pull, together with the skeletons.
- **Alternatives and trade-offs:**
  - First implementation (same day, replaced): a `ValueNotifier<bool>` in each view, set around `await cubit.refresh()`. It worked, but the UI state was split between the view and the Cubit, and the Cubit tests couldn't see the loading.
  - Driving the skeletons from `isRefreshing` was rejected: background refreshes set it too (see Reasoning).
  - Clearing the data in the Cubit was rejected: a failed refresh would leave nothing to show, against D4.
  - An `offline` value in `RequestStatus` was rejected: saved data is still a success with content, and the source is per listing, not per request.
  - Trade-off: the old content disappears during every pull, even when the new data turns out the same. The spinner and the skeletons both show at once. A section's `loading` no longer always means "nothing loaded yet"; widgets that need that check the items.
- **Verification:**
  - `home_cubit_pagination_test.dart`: "shows loading on every section while keeping its data" (exact states), "a failed request brings the shown content back and reports it", "does not replace live results with the saved copy", and "the reconnect refresh keeps the saved results visible" (no `loading` status emitted).
  - `search_cubit_refresh_test.dart` (new): loading with the results kept then success; failure restores the results; a saved copy counts as a failed refresh; saved browse results block paging until a refresh succeeds; a stale cached query refreshes without a `loading` status.
  - `home_screen_interactions_test.dart`: "shows skeletons until the new data arrives", plus "a failure keeps what is shown and says so" (en, ar) and "shows the new results".
  - `search_screen_test.dart`: "pull to refresh moves only the results, shows skeletons until the new results arrive, and refreshes once", "a failed pull to refresh brings the results back and says so", and "a stale cached query refreshes in the background without skeletons".
- **Limitations:**
  - If a background refresh is already running, the user's pull returns at once and shows no skeletons.
  - The pull usually starts at the top of the page, but if the list is longer than the skeletons, the scroll position can change when the content returns.

---

## 5. Design inventory (filled in Phase 1)

**Evidence key.** **[V]** means verified from Figma MCP output (`get_metadata`, `get_variable_defs`, or `get_design_context` code/screenshot). **[S]** means read only from a screenshot (approximate). **[U]** means unverified or an assumption.

| Field | Value |
| --- | --- |
| Figma Drafts duplicate URL | <https://www.figma.com/design/idJrPCgmZTzih809HNpgnr/Real-Estate-Mobile-App-Design--Community---Copy-> |
| fileKey / page | `idJrPCgmZTzih809HNpgnr` / `0:1` "Page 1" (the only page) [V] |
| File layout | Three color sets of the same 8 frames (Splash, Auth, Home, Search-v1, Search-v2, Details, Filters, Profile): a **top-level set (blue, primary `#0061FF`)**, section `1:2188` "New Orange", and section `1:2987` "New Purple". Plus a spec frame `1:4584` "colors" [V]. The Orange/Purple sets were checked by metadata only (same frame names and sizes); their colors were not inspected [U]. **Proposed: implement the top-level blue set (Q10).** |
| "colors" spec frame `1:4584` | Every swatch and the typography sample are labeled "Voog blue / #443DF6" [V, layer names]. These are placeholders that don't match the colors actually used. **Not used as a token source.** |
| Frame size (ScreenUtil `designSize`) | All screen frames are **430 wide** [V]. Non-scrolling frames (Splash, Auth) are **430 × 932** [V]. The other frames are taller because they show scroll content (Home 1459, Details 2060). Status bar 44, home indicator 34 [V]. **Proposed `designSize: Size(430, 932)`** (iPhone 14/15 Pro Max viewport). Details content and hero use 428 instead of 430 [V], treated as a design inconsistency |
| Fonts (Latin) | **Rubik** Regular 400 / Medium 500 / SemiBold 600 / Bold 700 for all UI text [V]. **Inter** Bold/SemiBold 12, only for the Filter stepper values and Building Size labels [V]. **Urbanist** Regular 10, only for the street labels inside the map art [V]. SF Pro Text belongs to the iOS status-bar mock only and won't be implemented |
| Arabic glyph coverage | **Rubik covers Arabic** (corrected 2026-10-13; the earlier "no Arabic" note was outdated). Google Fonts metadata for `ofl/rubik` lists the subsets `arabic, cyrillic, cyrillic-ext, hebrew, latin, latin-ext` (OFL). The font file `Rubik[wght].ttf` was parsed directly: 36/36 Arabic letters, 8/8 harakat, 10/10 Arabic-Indic digits, Arabic punctuation (، ؛ ؟ ٫ ٬), all 37 non-ASCII characters in `ar.json`, an `arab` script with `init`/`medi`/`fina`/`rlig` substitutions and `mark`/`mkmk` positioning. Variable `wght` axis 300–900 covers 400/500/600/700; Flutter's `FontWeight` drives the `wght` axis of the bundled file (verified in Phase 4 by `test/core/theme/rubik_font_test.dart`: w700 is wider than w400 for Latin and Arabic, identical widths with or without `fontVariations`). The Figma file has no Arabic text [V]. **Phase 4 rendering check:** shared widgets and cards rendered with the real Rubik file in EN and AR (temporary golden renders, not committed): Arabic letters join correctly (also asserted by the shaping test), no tofu, no clipped diacritics. No simulator screenshot was taken (the iOS build was skipped at your request). No rendering issue found, so IBM Plex Sans Arabic isn't needed. ✅ Q6: Rubik for both locales |
| Designed states | **Only populated (success) states exist.** There are no loading, empty, error, or offline frames [V, metadata]. Those states will be built from tokens (C3) |

### 5.1 Screens

★ = approved screens (Q1, 2026-10-13).

| Screen | Node ID | Purpose | Components | Entry → Exit | Data (endpoint) | States designed? |
| --- | --- | --- | --- | --- | --- | --- |
| ★ **Home** | `1:4426` (430×1459) | Browse: featured carousel + recommendations grid | Header (avatar, greeting, name, bell), search bar (search + filter icons), section headers ×2 ("Featured", "Our Recommendation" + "See All"), featured cards ×2 (250×340, horizontal scroll), category chips (All, House, Villa, Apartments, Others), grid cards ×4 (2 columns), bottom nav (Home active) | App start / nav "Home" → Explore (search bar, See All, nav), Filter sheet (filter icon), Details (card), Profile (nav) | Featured: `GET /products?sortBy=rating&order=desc&limit=5` (✅ approved 2026-10-13; count 5 per Q18). Grid: first page of `GET /products?limit&skip` ("All") or `GET /products/category/{slug}`. Chips: `GET /products/categories` | Success only. **✅ Implemented** (`HomeScreen`, route `/`, Home tab of the shell). Loading, error + retry, empty and offline ("saved results") states are built per section from tokens. Header per Q11, bell and filter icon hidden. **Updated 2026-10-13:** card-shaped shimmer skeletons for first loads, infinite scroll (next page when less than one screen is left, skeleton row while loading, retry footer on failure, dedupe by id, stops at the last page, paused on saved results), pull to refresh (keeps shown content on failure + snackbar), automatic refresh once when the device comes back online, working hearts (Q8) Back-to-top button (not in Figma, your request 2026-10-13): appears after one screen of scrolling, end side above the nav bar, primary circle 44 + `Button/Shadow 1` + the Figma chevron turned up |
| ★ **Explore (Search results)**: Figma "Search-v1" | `1:4120` (430×1041) | Search by text, filter by category, see result count | Header (back button, title "Search for Your Ideal Home", bell), search field (typed state "Beijing China \|" with primary-color caret), category chips, "Found 182 Apartments" heading, list cards ×4 (390×128), bottom nav (Explore active) | Nav "Explore" / Home search bar / See All → Details (card), Filter sheet (filter icon), Home (back, nav), Profile (nav) | `GET /products/search?q=` (debounced), `GET /products/category/{slug}`, `total` for the count | Success only. ✅ **Built 2026-10-13** (`feature/search`, `SearchScreen` at `/explore`): header (back → Home, centered title, bell hidden), search field (filter icon opens the Filter sheet since `feat/add_filter`, tinted Primary while a filter is applied), "Found {n} results" (plural, ar six forms), list cards with hearts, skeletons, empty/error/offline states, infinite scroll, pull to refresh. Category chips **not shown yet** (search ignores the category, §4.5.1). Title style `searchHeaderTitle` is [U]: the Figma read for this task hit the plan limit |
| ★ **Filter** (bottom sheet over Explore) | `1:3867` (430×955) | Narrow results | Dim overlay (black 30%), sheet with 24 top radius, title row (back, "Filter", "Reset"), Price Range (histogram + range slider + labels), Property Type chips (multi-select, wrap), Home Details (Bedrooms/Bathrooms steppers), Building Size (range slider), primary button "Set Filter" (390×54) | Filter icon on Home or Explore → back to the caller (back / Set Filter) | ~~Local price filter on loaded items. Category via API.~~ **Decided 2026-10-13:** full matching set of the Explore query (`limit=0`, memory 5 × 10 min) + local multi-category and price filter (§4.5.1 "Filter sheet"). Categories: `GET /products/categories`. Beds/baths/size have no data | Success only. ✅ **Built 2026-10-13** (`feat/add_filter`, `showFilterSheet` over Explore, root navigator so the overlay covers the nav bar): header (back, centered "Filter", Reset), Price Range (log-scale histogram of the full set, range slider, price labels; skeleton + retry), Property Type (API categories, multi-select wrap), "Set Filter". Bedrooms/Bathrooms/Building Size hidden (Q4/Q14), so the sheet is as tall as its content (max 758/932 of the screen, scrolls inside). Opened from Explore only; Home's filter icon is still hidden |
| ★ **Property Details** | `1:4236` (430×2060) | Full property info + call to action | Hero image 428×460 with pagination dots, overlay app bar (back, heart, share), title, category tag, rating + review count, stats row (beds/bath/sqft), divider, Agent block (avatar, name, role, chat, call), Overview, Facilities grid (2×4), Gallery (3 tiles, "20+"), Location (address + map), Reviews (summary, "See All", one review), sticky bottom bar ("PRICE", price, "Booking Now") | Any card → back | `GET /products/{id}` (list item as initial data) | Success only. **✅ Implemented 2026-10-13** on `feature/property-details` (`PropertyDetailsScreen`, route `/property/:id`, pushed over the shell). Shown: hero carousel + dots (dots only with 2+ photos; `thumbnail` when `images` is empty), top bar (back, heart), title, category tag (slug with spaces, uppercase), rating + review count (count only after the details load), divider, Overview (if a description exists), Gallery (only with 2+ photos; "N+" over the last tile), Reviews (one review, "See All" expands inline and then disappears), price bar. **Added 2026-10-13 (mock data, §4.6):** stats row, Agent (chat → message, call → dialer), Facilities, Location (address + static map), review likes, "Booking Now" (→ message). Still hidden: share (Q8). States: skeleton without list data; list data shown at once with an Overview skeleton; full-screen error + retry without data; header + price kept with an inline error + retry when the details fail. Invalid ids show the not-found page |
| ★ **Profile** (reduced) | `1:3786` (430×975) | **Host the in-app language switch** through the design's own "Language" row (B1), and give the nav "Profile" tab a destination (D4) | Title "Profile", bell, avatar 140 + edit badge, name, divider, menu rows (My Booking, Payments, Profile, Notification, Security, **Language**, Help Center, Invite Friends, Logout in red), bottom nav (Profile active) | Nav "Profile" → language picker (Language row) | None (locale via `easy_localization`) | Success only. ✅ **Built 2026-10-14** on `feature/profile` (`ProfileScreen` at `/profile`, replaces the placeholder and the temporary `LanguageSwitcher`). Geometry from the saved Phase 1 `get_metadata` of `1:3786` (no new Figma call): title row 16 below the status bar and 44 high, content 16 below it, `GuestAvatar` 140 centered, name 14 below (Rubik 600 24/1.2), divider 24 below, Language row 24 below the divider (icon 28, gap 12, Rubik 500 18/1.4, chevron 20). Shown: title, guest avatar, "Guest" (Q11), divider, Language row with the current language before the chevron (not in Figma, approved). Hidden: bell (Q13), edit badge, the other eight rows (Q17). Language row → `showLanguageSheet` (not in Figma, approved: built like the Filter sheet: root navigator, white, top radius 24, overlay; title + one option per language written in that language, Primary label + check on the current one) → `context.setLocale` at once, persisted; picking the current language or dismissing changes nothing |
| ★ **Splash** ([#1](https://github.com/AnasAlhamadd/flutter-real-estate-assessment/issues/1), added 2026-10-13) | `1:4551` (430×932) | Logo + "Real Scout" + tagline | Logo group `1:4553` (SVG 133.885×112.445, exported as-is), title `1:4561` (Outfit Black 20, uppercase, tracking 2, primary) and tagline `1:4562` (Outfit Medium 12, uppercase, tracking 1.2, Black/02), gaps 12 / 10, centered on white [V] | Launch → **Auth** after 1.5 s via `context.go` (replaces Splash; changed by [#6](https://github.com/AnasAlhamadd/flutter-real-estate-assessment/issues/6)). Deep links skip it | None | Success only. **Font decision:** Outfit has no Arabic glyphs, so the text uses Rubik at the same weights (900 / 500), size and tracking (Q6); tracking is dropped for the Arabic tagline because it breaks letter joins. No native OS splash |
| ★ **Auth** ([#6](https://github.com/AnasAlhamadd/flutter-real-estate-assessment/issues/6), added 2026-10-13) | `1:4499` (430×932) | Google sign-in landing, **UI only** | Photo collage `1:4521` + fade `1:4541` (399×552, top 83), eyebrow "WELCOME TO REAL SCOUT" (Rubik 400 16/1.8, tracking 1.6, Black/02), headline Rubik 600 32/1.3 with "Your Ideal Home" in primary, subtitle Rubik 400 18/1.8 Black/02, gaps 12 / 20, Google button `1:4547` (white, radius 30, border primary 4%, shadow 0 4 60 black 20%, padding 18, logo 22 + gap 10, label Rubik 500 18/1.3) [V]. **No credential fields in the design** | Splash → Auth. "Continue as guest" (not in Figma, approved) → Home via `context.go`. Real sign-in → `AppRouter.signedInDestination` (= Home) once it exists (Q19) | None (no backend; DummyJSON has no Google auth) | Success only. Layout: collage pinned to the top, text panel to the bottom with a 34 px white fade; short screens slide the panel over the faded collage end; it scrolls only when the panel alone is taller than the screen (320×568 at 1.3 in English) |
| Search-v2 | `1:4055` (430×1051) | Same results as Search-v1 in a 2-column grid | Same as Search-v1, but uses grid cards and vuesax icons | — | — | Not recommended: duplicates Search-v1. Alternative layout (Q15) |

### 5.2 Tappable elements (D4)

Decision key: **implement** = real behavior. **local** = device-only state. **hide** = removed from the UI (no backend or feature). Every hide decision is tied to Q4, Q8, Q9, Q11, Q13, Q14, or Q17.

| Screen | Element (node) | Proposed action | Decision |
| --- | --- | --- | --- |
| Home | Avatar + "Good Morning" + name (`1:4449`) | Not tappable. Greeting localized | ✅ Q11: neutral avatar (Profile icon on Greyscale/400), greeting by hour (5–11 morning, 12–16 afternoon, else evening), "Welcome, Guest" instead of the name |
| Home / Explore / Profile | Bell + dot (`1:4454`, `1:4165`, `1:3810`) | No notifications feature | **hide** (Q13) |
| Home | Search bar (`1:4458`) | Open Explore with the field focused | implement. ✅ Home: read-only field, `go(explore)`; focusing the field waits for the Explore screen |
| Home / Explore | Filter icon (`1:4462`, `1:4146`) | Open Filter sheet | implement. ✅ Explore (`feat/add_filter`): opens the sheet for the current query; 44 px tall tap target around the 20 px Figma icon; tinted Primary while a filter is applied (not in Figma, so filtered results are never mistaken for the full list). Home: still **hidden** (`AppSearchField` without `onFilterTap`); TODO(question): open the sheet on Home too, or go to Explore first |
| Home | "See All" Featured (`1:4465`) | Explore, sorted by rating | implement. ✅ Home: `go(explore)`; sorting waits for Explore |
| Home | "See All" Recommendation (`1:4468`) | Explore with the selected category | implement. ✅ Home: `go(explore)`; passing the category waits for Explore |
| Home / Explore | Category chips (`1:4478`, `1:4149`) | Select category → reload list | implement (Q12) |
| Home / Explore | Card tap (featured `1:4470`, grid `1:4473`, list `1:4170`) | Push `/property/:id` | implement |
| Home / Explore / Details | Heart (cards, Details `1:4270`) | Toggle favorite, persisted locally (no favorites list screen in Figma) | **local** (Q8, ✅ approved). ✅ Home Featured + grid cards: 44 px tap target centered on the Figma heart; filled heart when saved (white on Featured, Primary on grid); same state on every card with the same id. The list card (Explore) still uses its in-row slot until Explore is built. ✅ Explore list cards: 22 px heart on top of the end column (`FavoriteButton` variant `listCard`), price at the bottom |
| Explore | Back button (`1:4161`) | Return to Home tab (pop when pushed from Home) | implement (Q16). ✅ `go(home)` (Explore is a tab, nothing to pop) |
| Explore | Search field (`1:4142`) | Debounced server search, clear on empty | implement. ✅ 300 ms debounce, 2-character minimum, submit searches at once, clearing returns to browse mode. Not autofocused when opened from Home's search bar yet |
| Filter | Back arrow (`1:3973`) | Close sheet without applying | ✅ implement: `AppBackButton.compact` (32 px Primary 10% circle, 20 px arrow, 44 px tap target), mirrored in Arabic |
| Filter | "Reset" (`1:3977`) | Reset to defaults | ✅ implement: clears the draft (every category, full price range); applied only on "Set Filter" |
| Filter | Price range slider (`1:4004`) + histogram (`1:3982`) | Local min/max price filter on the full matching set (§4.5.1) | ✅ implement (Q14): histogram = price distribution of the full set (20 log-scale bars), thumbs at the ends = open range |
| Filter | Property Type chips (`1:4014`) | Category selection | ✅ implement (Q12/Q14): API categories, multi-select, none selected = all |
| Filter | Bedrooms / Bathrooms steppers (`1:4030`, `1:4037`) | No API field | **hide** (Q4) ✅ hidden |
| Filter | Building Size slider (`1:4045`) | No API field | **hide** (Q4) ✅ hidden |
| Filter | "Set Filter" button (`1:4053`) | Apply + close | ✅ implement: applies the draft; Explore re-filters, usually without a request |
| Details | Back (`1:4267`) | Pop | ✅ implement: `AppBackButton.plain` (28 px arrow, mirrored in Arabic, 44 px tap target) |
| Details | Share/Send (`1:4271`) | Needs `share_plus` (not in the approved stack) | **hide** (Q8) |
| Details | Hero image swipe + dots (`1:4237`) | Page through `images` | ✅ implement (each page announced as "Image N of M") |
| Details | Heart (`1:4270`) | Toggle favorite | ✅ **local** (Q8): `FavoriteButton` variant `detailsTopBar` (28 px, Black/01 → Primary), shared with Home through `FavoritesCubit` |
| Details | Agent chat / call (`I1:4310;929:29137/38`) | Mock agent (§4.6) | ✅ **Changed 2026-10-13:** chat → "not available yet" message; call → phone dialer with the mock number (`PhoneDialer`, `url_launcher`), "Couldn't open the phone app" if it fails. 44 px tap targets with the icons where Figma draws them |
| Details | Gallery tiles + "N+" (`1:4369`) | Jump the hero carousel to that image | ✅ implement (approved 2026-10-13): animates the hero to the photo and scrolls to the top; jumps without animation under reduced motion |
| Details | Reviews "See All" (`1:4405`) | Expand to all `reviews` (DummyJSON usually returns 3) | ✅ implement (approved 2026-10-13): expands inline, then the link disappears; hidden with ≤ 1 review |
| Details | Review like heart (`1:4416`) | Mock counts | ✅ display only (not tappable) |
| Details | "Booking Now" (`1:4425`) | No booking endpoint | ✅ **Changed 2026-10-13:** shown; tap → "not available yet" message |
| Profile | Avatar edit badge (`1:3817`) | No feature | **hide** ✅ hidden (2026-10-14) |
| Profile | "Language" row (`1:3842`) | Open the English/Arabic picker → `context.setLocale` (instant, persisted) | **implement** (B1, B7). ✅ 2026-10-14: `ProfileMenuRow` (44 px tap target around the 28 px row, announced as one button with label + current language) opens `showLanguageSheet`; options are a single-choice group (selected state announced), 44 px targets |
| Profile | My Booking, Payments, Profile, Notification, Security, Help Center, Invite Friends, Logout (`1:3821` … `1:3854`) | No features | **hide** (Q17) ✅ hidden (2026-10-14, you confirmed Q17 over showing them with a notice or keeping Logout → Auth) |
| All | Bottom nav Home / Explore / Profile (`1:4489`) | Switch tabs (`StatefulShellRoute`) | implement |
| Auth | "Sign Up with Google" (`1:4547`) | No backend sign-in: shows a localized "Sign-in isn't available yet" snackbar, never navigates or claims success | **notice** (approved, Q19) |
| Auth | "Continue as guest" (not in Figma) | `context.go(home)`, replacing Auth; nothing persisted, so every launch shows Splash → Auth | implement (approved) |

### 5.3 Design tokens

Named Figma variables come from `get_variable_defs(1:4426)` plus the style lists returned with each design context. Raw values are those used directly in the design-context code (not bound to variables) [V].

| Group | Values |
| --- | --- |
| Colors: variables | `Black/01 #191D31` (primary text) · `Black/02 #666876` (secondary text, inactive nav) · `Black / 03 #8C8E98` (placeholder, muted) · `White/01 #FFFFFF` · `Greyscale / 400 #BDBDBD` (image placeholder background) · `Alerts & Status / Error #F75555` (Logout) · `Gradients/Gradident Orange` (**returned with an empty value** [V]; not used visibly in the blue set) |
| Colors: raw | **Primary `#0061FF`** (buttons, links, active chip, prices, active nav, active dot) · rating text `#246BFD` · search-field background `#FBFBFD` · primary 4% `rgba(0,97,255,0.04)` (inactive chip fill, icon-circle fill, search border, stepper fill, tag fill) · primary 10% `rgba(0,97,255,0.10)` (chip border, nav top border, back-button fill, bottom-bar border) · overlay `rgba(0,0,0,0.30)` · badge fill `rgba(255,255,255,0.90)` · featured-card gradient over the bottom 46.5%: transparent → `rgba(32,32,32,0.70)` (8 stops) · inactive dot `#FFFFFF`. Notification dot, slider thumbs, and histogram bar colors live inside SVG assets: light-blue bars and white thumbs with primary outline [S] |
| Typography: variables | `Paragraph/Regular/P12 - LH 180%` Rubik 400 12/1.8 · `Paragraph/Regular/P14 - LH 180%` Rubik 400 14/1.8 · `Paragraph/Medium/P12 - LH 130%` Rubik 500 12/1.3 · `Paragraph/Medium/P16 - LH 130%` Rubik 500 16/1.3 · `Body/Small/Bold` Inter 700 12/16px · `Body/Small/Semi Bold` Inter 600 12/16px · `body / xsmall / regular` Urbanist 400 10, letter-spacing 0.2 |
| Typography: raw (Rubik) | Details title Bold 24/1.2 · profile name, Details price SemiBold 24/1.2 · featured title Bold 20/1.1 (ellipsis), featured price Bold 20/1.2 · section headings SemiBold 20/1.2 (Profile title 20/1.3) · list title SemiBold 18/1.4, list price SemiBold 18/1.2, agent name SemiBold 18/1.2 · profile menu Medium 18/1.4 · "See All", button label, reviewer SemiBold 16/1.4 · grid title, grid price SemiBold 16/1.2 · Filter section titles SemiBold 16/24px · featured location Regular 16/1.4 (+0.2 letter-spacing) · Overview, review body Regular 16/1.7 · chip active SemiBold 14/1.8, inactive Regular 14/1.8 · search placeholder Regular 14/1.3, typed SemiBold 14/1.3 · list location, facility label Regular 14/1.4 · stats, agent role, Details rating Medium 14/1.4 · "Reset" Medium 14/1.8 · Filter row labels Medium 14/20px · Details review time Regular 14 · price-range labels SemiBold 12/16px · grid location Regular 12 · featured badge SemiBold 12/1.4 · "PRICE" Medium 12, letter-spacing 2, uppercase · tag SemiBold 10 uppercase · grid badge SemiBold 10/1.4 · list badge SemiBold 8/1.4 |
| Spacing | Screen horizontal padding **20** · header top **60** (below the 44 status bar) · vertical rhythm between header, search, chips, and sections **24** · featured card gap **20** · grid gap **16** horizontal / **20** vertical · chip gap **12** (Filter chips **10**, wrap) · chip padding **20×8** (Filter **20×4**) · grid card padding top 16 / sides 14 / bottom 20, inner gap 12 / 10 · list card padding left 14, right 18, vertical 14, image-text gap 14, list gap **16** · search field inset 13.5, icon-text gap 16 · Details body padding 20×24, section gap **30**, inner gaps 16 / 12 / 20 · Filter sheet: section gap 30, title → content 16, popup title → sections 32 · Details bottom bar: top 24, bottom 36, sides 24, price-button gap 60 · nav bar: side padding 30, tab padding 20, icon-label gap 6 · Profile rows: gap 24, icon-label gap 12 |
| Sizes | Icon button 44 (Filter back 32) · icons 20 / 22 / 24 / 28 · avatar 44 (Home), 140 (Profile), 60 (agent), 40 (reviewer) · featured card 250×340 · grid image 159×154 (2 columns of 187) · list image 100×100, list card height 128 · search field 390×52 · primary button height 54 · stepper buttons 24 · slider thumbs 24 · hero 428×460 · gallery tiles 118 · facility circle 60 (icon 28) · nav bar height 86 · dots: active 32×8, inactive 8×8, gap 6 |
| Radii | 6 search field · 10 card images, gallery · 12 grid card · 20 featured card, tag · 24 Filter sheet top corners, steppers · 28 list card · 30 chips, 44 icon buttons · 36 Details bottom-bar top corners · 100 pill button, badges, icon circles, dots |
| Shadows | `Card/Shadow 2` = `#04060F` 5%, offset (0,4), blur 60 [V variable]. The generated CSS uses `drop-shadow(0 4 30 rgba(4,6,15,.05))` for the grid and list cards · badge shadow (0,20) blur 100 `rgba(4,6,15,.12)` · `Button/Shadow 1` = `#246BFD` 25%, offset (4,8), blur 24 [V variable]. ⚠ The generated button code shows `rgba(112,79,56,.25)` (4,8,12) instead, a design inconsistency, so use the named variable · Flutter blur equivalents to be tuned visually in Phase 4 [U] |

### 5.4 Shared components & assets

**Exported in Phase 4 (approved "minimal" set):** 11 SVGs in `assets/svg/` (`ImagePath`): `search` (light; also the inactive Explore tab), `search_bold`, `filter`, `star`, `arrow_left`, `arrow_right` (Arrow-Right 2 chevron), `language` (Curved/More Circle), `home_bold`, `home_light`, `profile_bold`, `profile_light`. No heart, bell, share, or location icons (Q8, Q13). `download_assets` returns bare vector shapes without their icon frames, so each file was normalized by script: masks removed, shape scaled into a `0 0 24 24` viewBox by `24 / frame size` and centered (frames: nav 24, search/filter 20, star 14, arrow-left 24, chevron 20, Language 28). The arrows are exported as rotated down-arrows and were rotated back. The light search icon is composed from the ring and handle shapes. `star` keeps its orange gradient (`#FB9400 → #FFAB38`); all other icons are black and tinted by `AppSvgIcon`. Shapes were compared visually with the Figma frame exports. The Profile bold icon came from a separate `download_assets(1:3865)` call because each frame call is capped at 20 SVGs.

**Card values measured from the 1x frame exports [S]** (not in §5.3, marked `[S]` in `AppSizes`): rating-badge insets 24 / 12 / 6 (featured / grid / list), badge padding 10×4 / 6×4 / 5×1.5 with icon-text gaps 4 / 2 / 2, featured content inset 16 (sides) / 20 (bottom), gaps title→location→price 8 / 10 (featured), 8 / 10 (grid), 10 (list). Sampled text colors: grid location Black/03, list location Black/02, search/filter icons Black/03, inactive nav Black/02. Prices are shown as `$12219` (no grouping); prices with cents keep two decimals.

**Built in Phase 4:** `AppSvgIcon`, `CircleIconButton`, `AppBackButton`, `AppButton`, `SectionHeader`, `CategoryChip`, `AppSearchField`, `RatingBadge` (3 sizes), `AppNetworkImage`, `LoadingView`, `ErrorView`, `EmptyView`, `AppBottomNavBar` (wired into `AppShell`), and `FeaturedPropertyCard`, `PropertyGridCard`, `PropertyListCard`. Cards take an optional `favoriteButton` widget and show nothing when it's `null` (no heart asset until Q8 is decided). **Deferred to Phase 5** with their screens because their measurements aren't in §5.3: `PropertyTag`, `Divider`, `ProfileMenuRow`, range slider. **Range slider built 2026-10-13** (`feat/add_filter`): `PriceRangeChart` = `PriceHistogramBars` + a Material `RangeSlider` themed in code (no new assets; values from the saved Phase 1 `1:3867` design context: bars Primary 10% 58 tall with 4 px gaps and a 3 px minimum, track 4 px Primary 10% / Primary, white 24 px thumbs with a 3 px Primary border, SemiBold 12/16 labels 8 px below).

**Built with Home (`1:4426`):** `HomeHeader` (avatar + greeting + welcome line; `greetingKeyFor(DateTime)`), `FeaturedPropertyList` (horizontal list of `FeaturedPropertyCard`), `HomeCategoryChips` ("All" + API categories, horizontal scroll), `SliverPropertyGrid` (rows of `PropertyGridCard`, column count from the width), `SectionStatusView` (`.failure` / `.empty` wrappers around `ErrorView` / `EmptyView` with a minimum height, so a section keeps its place; its `.loading` variant was replaced by skeletons on 2026-10-13). Header values verified in `get_design_context(1:4426)`: header top 60 (16 below the status bar), avatar 44 (radius 30), avatar-text gap 10, greeting `Paragraph/Regular/P12 - LH 180%` Black/03 (`AppTextStyles.homeGreeting`), name line `Paragraph/Medium/P16 - LH 130%` Black/01; section title → content 20, Featured cards → "Our Recommendation" 32 (`AppSizes` Home block).

**Built with Home favorites, loading and pagination (2026-10-13):**
- Heart icons: `assets/svg/heart.svg` (`ImagePath.heart`) is the Figma Iconly Light-Outline Heart from the saved `get_design_context(1:4426)` asset URL, normalized to `0 0 24 24` with its mask removed. `heart_bold.svg` (`ImagePath.heartBold`, selected state) is not in Figma: it fills the outline's outer contour and keeps the highlight arc as a cut-out (approved). Both are tinted by `AppSvgIcon`.
- `FavoriteButton` (`core/widget`): heart in a 44 px tap target. Variants `onImage` (22, white; Featured) and `onSurface` (20, Black/03 → Primary when selected; grid). Announced as a toggle button: "Add to favorites" / "Remove from favorites" in both languages. `PropertyFavoriteButton` binds it to `FavoritesCubit` by id. Cards draw the button as an overlay centered on the Figma heart (price-row end, bottom-aligned with the price), and reserve the heart's width in the price row, so the bigger tap area doesn't move the Figma layout.
- `AppShimmer` + `SkeletonBox` (`core/widget`, no package): a highlight sweeping in the reading direction; static when the platform asks for reduced motion. Not in Figma: tints `ColorsApp.skeletonBase/Highlight`. `FeaturedPropertyCardSkeleton` (250×340 `.r`) and `PropertyGridCardSkeleton` (grid card surface, image ratio, paddings, line heights measured with the current font and text scale) match the real cards' sizes (tested), so the page doesn't jump. `FeaturedPropertyListSkeleton` and `SliverPropertyGridSkeleton(rows)` are announced once as "Loading".
- `LoadMoreScrollListener` (next page when less than one viewport is left, vertical depth-0 scrolls only) and `LoadMoreErrorView` (compact message + retry under loaded items): reusable by Explore.
- Visual check: one `get_screenshot(1:4426)` compared with temporary real-font renders of the app at 430×932 and 430×1459 in EN and AR (deleted afterwards). Section positions match within ≈5 px (status-bar mock 44 vs. a 47 px test inset); heart position and colors match. Differences that are decisions, not defects: no photos in the test data, sample text, bell and filter icon hidden (Q13), greeting per Q11. ⚠ The rating badge's Figma shadow (0,20 blur 100) renders as a solid grey pill under the badge in the test renderer; not checked on a device yet.

**Built with Property Details (`1:4236`, 2026-10-13):**
- Values from `get_design_context(1:4236)` in `AppSizes` (Details block) and `AppTextStyles` (`details*`, `review*`): hero 460, top bar 16 below the status bar with 24 side padding and 28 px icons, dots 32×8 / 8 with gap 6 at 16 from the bottom, body 20×24, section gap 30, title → tag row 16, tag padding 10×6 radius 20, rating star 20 + gap 6, Overview title → text 12, Gallery title → tiles 20 with 17 between tiles, reviews star 24 + gap 12, avatar 40 + gap 10, review gaps 12 / 24, price bar 24 / 24 / 36 with top radius 36. No new assets: `arrow_left`, `heart`/`heart_bold` and `star` were reused.
- Shared widgets added or extended: `AppDivider` (1 px Primary 10%), `AppBackButton.plain` (no circle; Details top bar), `FavoriteButton` variant `detailsTopBar`, `SectionHeader.leading` (the reviews star), and `SkeletonTextLine` (moved out of the card skeletons so Details reuses it). `RelativeTimes` (`core/utils/relative_time.dart`) picks the unit for "6 days ago"; the text comes from plural keys (`time.*`).
- Adaptations, not in Figma: "N+" sits on the `overlay` token (black 30%) because API photos are mostly on white; reviewer initials on Greyscale/400; selected heart in Primary; price-bar bottom padding is `max(36, bottom safe inset)`. The top bar scrolls with the hero, as in the frame.
- Known limitation: inactive dots are white as in Figma, so they can be hard to see on white product photos.
- **Plural rules:** `AppLocalization.wrap` now sets `ignorePluralRules: false`. easy_localization's default (`true`) only picks zero/one/two/other, so Arabic "few"/"many" forms (3–10, 11–99) never showed; found by the Details tests.

**`CustomText` API** (`core/widget/custom_text.dart`), the only text widget for UI copy:

| Constructor | Use for |
| --- | --- |
| `CustomText(AppTextKeys.x, …)` | Translation keys. Uses `context.tr`, so it rebuilds on a locale change |
| `CustomText.plain(text, …)` | Text that must not be translated: API data (titles, categories), formatted prices, already-translated strings |

Shared parameters: `style`, `textAlign`, `maxLines`, `overflow`, `softWrap`, `textDirection` (e.g. keep Latin-only content LTR in the Arabic UI), `semanticsLabel`, `upperCase`. It drops `letterSpacing` in the Arabic locale (tracking breaks letter joins) and never overrides the text scaler, so the user's accessibility text size always applies. `SectionHeader`, `CategoryChip` and the property cards use it.

**Responsive conventions (Home is the reference):**
- Every screen scrolls (`CustomScrollView` / slivers) inside a `SafeArea`; the shell's bottom nav takes the bottom inset, so tab screens use `SafeArea(bottom: false)`.
- Spacing uses `.w` / `.h` from `AppSizes`; fixed-ratio boxes (the 250×340 featured card) use `.r` on both sides, so they keep their ratio in landscape and on tablets.
- Grids pick their column count from the available width: `floor((width + gap) / (187 + gap))`, clamped to 2–4 (`SliverPropertyGrid.columnsFor`). Rows use `Expanded` cells, so card height follows the content and the text scale instead of a fixed `childAspectRatio`.
- Horizontal rows of variable-width items (chips) scroll horizontally instead of wrapping or shrinking.
- Text that can be long gets `maxLines` + ellipsis. The only fixed heights around text are fixed-ratio cards, whose lines are all clamped.
- Tests cover 320×568, 360×800, 430×932, 768×1024 and 932×430 (landscape) × en/ar × text scale 1.0/1.3.

| Component / asset | Node ID (example instance) | Type | Used on | Export |
| --- | --- | --- | --- | --- |
| `FeaturedPropertyCard` (image, gradient, title, location, price, heart, rating badge) | `1:4470` | Figma component instance "card" | Home | Build in code. Image from API |
| `PropertyGridCard` (image, badge, title, location, price, heart) | `1:4473` | Instance "card" | Home (also Search-v2) | Build in code |
| `PropertyListCard` (image, badge, title, location, price, heart) | `1:4170` | Frame "card-item" | Explore, Filter background | Build in code |
| `RatingBadge` (3 sizes: 14/12, 10/10, 8/8 icon/text) | `I1:4470;85001:13416` | Frame | All cards | Code + star SVG |
| `SectionHeader` (title + "See All") | `1:4463` | Frame "head" | Home, Details reviews | Code |
| `CategoryChip` (active/inactive) | `1:4479` / `1:4481` | Frame "Tab" | Home, Explore, Filter | Code |
| `AppSearchField` (search icon, hint, filter icon) | `1:4458` | Frame "search-bar" | Home, Explore | Code + 2 SVG |
| `CircleIconButton` 44 (white or primary-10% fill) | `1:4454`, `1:4161` | Frame "Icon" | Headers | Code |
| `AppBottomNavBar` (3 tabs, bold/light icon pairs) | `1:4489` | Frame "Navbar" | Home, Explore, Profile | Code + 6 SVG |
| `AppButton` primary pill | `1:4053`, `1:4425` | Component "Button / Primary / Rounded" | Filter, Details | Code |
| `PropertyTag` | `1:4277` | Component "Tag / Inverted / Info" | Details | ✅ Code (`feature/property_details/presentation/widget/property_tag.dart`) |
| `StatChip` (icon circle + label) | `1:4282` | Frame | Details stats | ✅ Code (`DetailsStats`) + 3 SVG (`stat_bed`, `stat_bath`, `stat_area`) |
| `RangeSlider` + histogram | `1:4004`, `1:3982` | Frames/vectors | Filter | Code (custom `SliderTheme`). ✅ Built (`PriceRangeChart`) |
| `ProfileMenuRow` (icon, label, chevron) | `1:3842` | Frame | Profile | ✅ Code (`feature/profile/presentation/widget/profile_menu_row.dart`) + the 2 Phase 4 SVGs (`language`, `arrow_right`); optional `value` before the chevron (not in Figma) |
| `GuestAvatar` (Q11) | `1:4449` (Home), `1:3817` (Profile) | Code | Home, Profile | ✅ Code (`core/widget/guest_avatar.dart`, 2026-10-14): extracted from Home's private avatar; icon keeps Home's 24/44 ratio at any size |
| Language sheet check | — (not in Figma) | SVG | Profile language sheet | ✅ `assets/svg/check.svg` (`ImagePath.check`), 24×24 stroke check drawn like `close.svg` |
| `Divider` (Theme=Light) | `1:4307` | Instance | Details, Profile | ✅ Code (`AppDivider`, `core/widget/app_divider.dart`) |
| Iconly icons (SVG) | — | Vector instances | — | Home/Search/Filter/Heart/Star/Notification/Profile (Light-Outline + Bold), Home (Bold + Light), Search (Bold), Arrow-Left, Arrow-Right 2, Send, Bold/Location, Curved/More Circle (Language row) — **export the ones used by approved elements only** |
| Facility icons ×8, Agent chat/call | `1:4320`…, `I1:4310;929:29137` | SVG | Details | ✅ `assets/svg/facility_*.svg`, `chat.svg`, `call.svg`, `location_bold.svg`, normalized to 24×24 (2026-10-13) |
| Profile menu icons except Language | — | SVG | Profile | **Skip** (Q17) |
| Details map art, pin, sample photos | `1:4387`, `1:4400`, `I1:4310`… | SVG / PNG | Details Location, Agent | ✅ **this mock** (2026-10-13): `details_map.svg` (437×926, mask removed, colors kept), `map_pin.svg`, `assets/images/{agent_avatar, map_pin_photo}.png` at 2× |
| vuesax `setting-4`, `search-normal` | `1:3890`, `1:3892` | SVG | Filter background, Search-v2 | **Skip**. Iconly equivalents are used on Search-v1 |
| Sample photos, avatars, map art | `1:4450`, `1:4239`, `1:4387`, … | PNG / vector | All | **Skip**: replaced by API images, or the section is hidden. Avatar handling is Q11 |
| Splash logo | `1:4553` | Vector group | Splash | ✅ `assets/svg/splash_logo.svg` (`ImagePath.splashLogo`), unedited Figma export with its gradients, not tinted |
| Google logo | `1:4549` | Vector | Auth button | ✅ `assets/svg/google.svg` (`ImagePath.google`), unedited 22×22 export from the design-context asset URL |
| Auth collage + fade | `1:4521`, `1:4541` | 12 photo tiles (9 sample JPEGs) + gradient | Auth | ✅ `assets/images/auth_collage.webp` (`ImagePath.authCollage`): one static image. Your Figma SVG export (7.6 MB: the 9 full-resolution JPEGs base64-embedded, not vectors) rendered by headless Chrome at 3× (1197×1656) on white, WebP q80 = **128 KB**. Replaced a first version that rebuilt the 12 tiles and crops in code from 9 resized JPEGs (940 KB). ⚠ The photos are Freepik previews (a faint "freepik" watermark is visible on a faded tile); their license is unknown, so they're design placeholders |
| iOS status bar / home indicator | `1:4428`, `1:4427` | Device chrome | All | **Skip** (system UI) |

---

## 6. Packages (and why they're used: E5)

Install in Phase 2 with `flutter pub add`, and only the packages confirmed by Phase 1.

| Package | Purpose | Why |
| --- | --- | --- |
| `flutter_bloc` | Cubit state management | Predictable, testable, consistent (E2). Pinned to 8.x (`^8.1.3`, per your constraint), so dev `bloc_test` must be 9.x |
| `equatable` | Value equality for states/entities | Avoids redundant rebuilds |
| `get_it` | Dependency injection | Decouples layers; easy mocking |
| `go_router` | Declarative routing | Typed paths, deep-link ready (D1) |
| `dio` | HTTP | Timeouts, interceptors, CancelToken (C5, C7) |
| `dartz` | `Either<Failure, T>` | Explicit error flow (`fpdart` is a maintained alternative; note in README) |
| `shared_preferences` | Local cache + favorites | Lightweight; already a dependency of easy_localization |
| `connectivity_plus` | `NetworkInfo` (`isConnected`, `onStatusChange`) | Fail fast offline (C5). Connectivity awareness only, not API reachability. Chosen by you in Phase 2 instead of `internet_connection_checker_plus` |
| `easy_localization` + `flutter_localizations` (SDK) | Translations, instant switch, persisted locale, RTL delegates | B1–B4, B7 |
| `intl` | Number/price formatting | B6. `^0.20.2` (Phase 4) |
| `flutter_screenutil` | Responsive sizing | A4 |
| `cached_network_image` | Image caching + error widget | C6, C7. `^4.0.3` (Phase 4; pulls in `sqflite` and `path_provider`, hence the regenerated macOS/Linux/Windows plugin registrants) |
| `flutter_svg` | SVG icons from Figma | A2: Figma icons are SVG. `^2.3.0` (Phase 4) |
| `url_launcher` | Agent "call" opens the phone dialer (`tel:`) | `^6.3.3`, added 2026-10-13 with your approval (dialer option). Behind `PhoneDialer`; Android `<queries>` DIAL/tel and iOS `LSApplicationQueriesSchemes` tel added |
| `device_preview` | Preview the app on simulated devices, locales and text scales | `^1.3.1`, added 2026-10-14 at your request. Debug/profile only (`enabled: !kReleaseMode` in `main.dart`); the locale still comes from easy_localization, not from the preview's language tool |
| dev: `bloc_test`, `mocktail` | Cubit tests, mocks | E4 |

Fonts are bundled in `assets/fonts/` (no runtime `google_fonts`). Only Rubik (`Rubik[wght].ttf`, OFL) is needed, for both English and Arabic (Q6). Inter and Urbanist appear only in elements hidden under Q4 (filter steppers, Building Size) and in the Details map's street names, which use Rubik instead (2026-10-13), so they aren't bundled.

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
2. Entities (approved superset, §4.6), repository contract, use cases (incl. `FilterPropertiesUseCase` for category + price on the full set, §4.5.1).
3. Models + tests (listing items with only `<listing fields>`, missing `brand`, wrong types).
4. Remote data source + tests through the real `DioClient` over a fake HTTP adapter: paged, `limit=0` full set, search, category, Featured (`sortBy=rating&order=desc`), details, categories, cancellation.
5. Local data source (SharedPreferences, two keys only, schema-versioned envelope, size bound, §4.5.2) + tests (round-trip, version mismatch, corrupt value, oversize write skipped).
6. Repository impl with the §4.5 strategy + tests for every branch (online, first-page fallback by failure type and age, no cache, 4xx not falling back, categories freshness, details in-memory reuse, timeout, 5xx, parsing).
7. DI registration.
- **Dev dependency:** `mocktail` (approved stack). `bloc_test` waits for Phase 5 and must be 9.x (because of `flutter_bloc` 8.x).
- **Done when:** all data/domain tests pass without network.
- **Commits:** `feat(properties): add domain entities, contracts and use cases` · `feat(properties): add models and remote data source` · `feat(properties): add local cache data source` · `feat(properties): add repository with cache fallback` · `test(properties): cover parsing, data sources and repository`

### Phase 4: Design system & shared widgets (~2 h) · A2, A3, A5, B4, T7, T10
1. `colors_app.dart`, `app_text_styles.dart`, `app_sizes.dart`, `app_theme.dart` from §5.3 only.
2. Rubik variable font (both locales, Q6) + approved assets (`download_assets`) → `assets/` + `image_path.dart`. **Verify rendered Arabic** (screenshots in EN and AR); consider IBM Plex Sans Arabic only if a real rendering issue is found.
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
- [ ] Fast typing → one request after pause (check the `ApiLogInterceptor` output; superseded requests log `request_status: cancel`).
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
- Phase branches are created from the previous phase's committed branch until you approve merging into `main` (2026-10-13: `feature/properties-data` from `feature/foundation`, `feature/design-system` from `feature/properties-data`).
- Conventional Commits: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `build`.
- **No commit or push without explicit approval.**
- Never commit: the assessment PDF, secrets, build outputs.

---

## 9. Open questions & decisions

| # | Question / decision | Blocks | Proposed default |
| --- | --- | --- | --- |
| **Q1** | Which **screens did the recruiter specify**? (The brief doesn't name them) | — | ✅ **Approved 2026-10-13:** Home `1:4426`, Explore/Search-v1 `1:4120`, Filter sheet `1:3867`, Property Details `1:4236`, Profile (reduced to the Language row) `1:3786`. Excluded: Auth, Search-v2, and the Orange/Purple sets (§5.1). **Updated 2026-10-13:** Splash `1:4551` added by [#1](https://github.com/AnasAlhamadd/flutter-real-estate-assessment/issues/1). **Updated again 2026-10-13:** Auth `1:4499` added as UI only by [#6](https://github.com/AnasAlhamadd/flutter-real-estate-assessment/issues/6); approved flow Splash → Auth → Home (guest) |
| **Q2** | Delivery repo: `AnasAlhamadd/...` (origin) or `anasAlhamd/...` (empty)? | Phase 9 | `AnasAlhamadd/...` |
| **Q3** | Figma **Drafts duplicate** link | — | ✅ Answered: `idJrPCgmZTzih809HNpgnr` (§5) |
| **Q4** | Figma fields missing from DummyJSON (location, beds/baths/sqft, agent, facilities, address/map, review avatar/likes, filter steppers/size): hide or replace with available fields? | — | ✅ **Approved 2026-10-13 (partly):** product superset entity fields; card "location" line → `brand`, else category; Details stats row → **hidden** (stock/weight/availability must not pose as beds/baths/area). **Approved 2026-10-13 with Details:** Agent, Facilities, Location/map and review likes → hide; reviewer avatar → initials. **Still proposed:** Bedrooms/Bathrooms/Building Size (Filter) → hide. Full table in §4.6 **Changed 2026-10-13 (your request): Details stats, Agent, Facilities, Location/map and review likes now use mock data** (`PropertyExtrasMockDataSource`, `/// this mock:` comments, §4.6). This overrides "never invent fields" for those fields only |
| **Q5** | Default language on first launch | — | ✅ Implemented as proposed: saved choice → device language if `ar`/`en` → `en` (easy_localization `saveLocale: true`, `useOnlyLangCode: true`) |
| **Q6** | Arabic font | — | ✅ **Approved 2026-10-13: Rubik for both English and Arabic.** The earlier "no Arabic glyphs" assumption was outdated; coverage verified from the font file (§5). Verify rendered Arabic in Phase 4; consider IBM Plex Sans Arabic only if a real rendering issue is found |
| **Q7** | Digits in Arabic UI: Western (123) or Eastern Arabic (١٢٣)? | Phase 6 | Western for prices/phones |
| **Q8** | Non-required buttons: hearts (cards + Details), share (Details) | Phase 5 | ✅ **Hearts approved 2026-10-13:** local favorites, persisted under `StorageKeys.favorites` as bounded listing snapshots (§4.5.2); no favorites screen; selected heart = filled shape derived from the Figma outline. Share → **hide** (would need `share_plus`, which isn't in the approved stack) |
| **Q9** | Use DummyJSON POST/PATCH/DELETE? Specifically "Booking Now" on Details | Phase 5 | ✅ **Approved 2026-10-13: option A**, hide the button and keep the price bar (implemented on Details). Option B (simulated `POST /carts/add` + snackbar + C9 disclaimer) was not chosen **Changed 2026-10-13 (your request):** "Booking Now" is shown and taps show "This isn't available yet" (no endpoint, nothing sent) |
| **Q10** | Which color set to implement: top-level blue (`#0061FF`), "New Orange" (`1:2188`), or "New Purple" (`1:2987`)? | — | ✅ **Approved 2026-10-13: top-level blue set** |
| **Q11** | Home header and Profile show a user avatar and name ("Adrian Hajdin"), but there is no auth in scope | Phase 5 | Keep the localized time-based greeting. Replace the name with a localized welcome line and show a neutral avatar placeholder, so no fake user data is hard-coded (C0). ✅ **Approved and applied on Home 2026-10-13. Applied on Profile 2026-10-14:** shared `GuestAvatar` (140) and the localized name "Guest" (`profile.guest_name`) |
| **Q12** | Category chips: the design shows real-estate types (House, Villa, Apartments, Others / Townhomes, Condos…), but the API has 24 product categories | Phase 3 | Chips are **data-driven** from `GET /products/categories` ("All" + API names, localized where possible). Don't fake real-estate labels |
| **Q13** | Notification bell (Home, Explore, Profile): no notifications feature | Phase 5 | **Hide** (D4). ✅ Applied on Home 2026-10-13, Explore 2026-10-13, Profile 2026-10-14 |

| **Q14** | Filter sheet scope | Phase 5 | Keep: Price Range (local filter on the full matching set, §4.5.1; the histogram's data source is decided in Phase 5), category chips (Q12), Reset, Set Filter. Hide: Bedrooms, Bathrooms, Building Size. Optional: add sort (rating/price) via server `sortBy`/`order`, which isn't in Figma, so only with your approval. ✅ **Applied 2026-10-13** (`feat/add_filter`; you left the backend interaction to the agent): kept and hidden as proposed; the histogram shows the price distribution of the query's full set (log scale); chips are multi-select. No sort added |
| **Q15** | Explore results layout: Search-v1 list (`1:4120`) or Search-v2 grid (`1:4055`)? | Phase 5 | **Search-v1 list**. The Filter sheet is designed over it, and it adds a distinct reusable list card |
| **Q16** | Explore's back arrow when Explore is a bottom-nav tab | Phase 5 | Back → Home tab (or pop when opened from the Home search bar / See All) |
| **Q17** | Profile screen scope | Phase 5 | Keep title, Language row, and bottom nav. Hide every row without a feature (My Booking … Logout) and the edit badge. Avatar/name per Q11. ✅ **Approved and applied 2026-10-14** (`feature/profile`). Also approved: the picker is a bottom sheet built like the Filter sheet, and the row shows the current language before the chevron (neither is in Figma). Rejected: all rows with a "not available yet" notice, and Logout → Auth |
| **Q18** | Featured item count (`limit` for `sortBy=rating&order=desc`). Figma shows 2 cards in a horizontal scroll; the total isn't specified | — | ✅ **Answered 2026-10-13: 5** (`HomeCubit.featuredLimit`) |
| **Q19** | Real authentication: provider (Google Sign-In, Firebase, custom backend), endpoints, session/token storage, and whether guest mode stays once sign-in exists | Future auth work | TODO(question). **Not approved, nothing implemented.** Current Auth is UI only (§5.1). Integration point: an `AuthCubit` calling a sign-in use case over an `AuthRepository` contract (domain) replaces `AuthScreen._showSignInUnavailable` and navigates to `AppRouter.signedInDestination` on success. No contract, use case, data source, or DI registration exists yet, on purpose (no requirements to shape them) |
| **P1** | `.cursorrules` replaced by `.cursor/rules/*.mdc` | — | ✅ Done 2026-10-13 |
| **P2** | Branch per phase vs. direct commits on `main` | — | Branch per phase (default applied: `feature/foundation` created from `main`) |

---

## 10. Progress log

| Date | Phase | Status | Notes |
| --- | --- | --- | --- |
| 2026-10-13 | 0: Setup & planning | ✅ | Env verified; Figma MCP authenticated; Community file access denied (needs duplicate); brief analyzed; rules rewritten in `.cursor/rules/` |
| 2026-10-13 | 1: Figma | ✅ Screen list (Q1) and color set (Q10) approved | Drafts duplicate verified. Page `0:1` mapped: 3 color sets × 8 frames + spec frame. Inspected Home, Search-v1, Filters, Details, Profile (blue set). §5 (inventory, tappables, tokens, components/assets) and §4.6 (API mapping, verified against live DummyJSON) filled. Q3 answered. Q1/Q4/Q6/Q8/Q9 updated. Q10–Q17 added. No code, assets, packages, or commits. Figma calls in Phase 1: 7 (≈10 total this month) |
| 2026-10-13 | 2: Foundation | ✅ Committed on `feature/foundation` (not merged into `main`) | Branch `feature/foundation`. Counter template removed. Deps via `flutter pub add` (resolved: flutter_screenutil 5.9.3, equatable 2.1.0, flutter_bloc 8.1.6, shared_preferences 2.5.6, connectivity_plus 6.1.5, easy_localization 3.0.8, get_it, go_router, dio, dartz, flutter_localizations). Core error model + mappers, `DioClient`, `NetworkInfo`, `UseCase`, `RequestStatus`, `ApiConstants`, `StorageKeys`, GetIt DI, en/ar translations, `CFBundleLocalizations`, `ScreenUtilInit(430×932)`, go_router shell with **placeholder** tabs (Home/Explore/Profile) + `/property/:id`, temporary `LanguageSwitcher`. `flutter analyze` 0 issues. `flutter test` 116/116, including a 64-case responsive matrix (4 tab/detail routes × 4 viewports × en/ar × text scale 1.0/1.3) **on placeholder screens only**. Fixed a real bug the tests found: `'key'.tr()` didn't rebuild kept-alive routes on locale change → `context.tr(key)` |
| 2026-10-13 | Pre-Phase 3 decisions | ✅ Approved | Q6 → Rubik for both locales (Arabic coverage verified from the font file; rendering checked in Phase 4). Q4 → superset entity, location = `brand` else category, stats row hidden. Cache option B: `shared_preferences` for the "All" first page + categories only, schema-versioned, bounded; details in memory (§4.5.2). Listing modes: paged category endpoint vs. full set via `limit=0` with local category + price filters (§4.5.1, verified live). Featured `sortBy=rating&order=desc` (count = Q18). Removed unused `StorageKeys.productDetails`/`favoriteIds`. Rules updated (`00-project-core`, `data-layer`, `testing`, `clean-architecture`, `localization-rtl`) |
| 2026-10-13 | 3: Properties data | 🟡 Implemented, uncommitted, awaiting review | Branch `feature/properties-data`. Domain: entities (approved superset + `ReviewEntity`, `PriceRange`), repository contract, 7 use cases (incl. Featured and a pure synchronous `FilterPropertiesUseCase`). Data: defensive models (only `id` required; wrong types → null/defaults; broken list entries skipped; top-level shape errors → `ParsingException`), remote data source (paged, `limit=0` full set, search, category, Featured rating sort, details, categories, cancellation via pure-Dart `CancellationSignal`), local data source (two keys, schema-versioned envelope, ≤ 20 items, 32 KB cap, corrupt entries removed), repository (§4.5 strategy, first-page fallback by failure type and age, categories memory → 24 h persisted → remote → stale, details in memory, last 20). Core: `DioClient.getJsonList`, URL-encoded category slugs, `ApiConstants.listingFields`. DI registered. Dev dep `mocktail ^1.0.5`. 12 fixtures (8 captured live; fake reviewer emails replaced with `@example.com`). Review fixes: non-finite numbers (`NaN`, `Infinity`, `1e400`) parse to `null` (`readInt(Infinity)` used to throw `UnsupportedError`), and an unencodable cache write becomes `CacheException`, so it can't fail a successful request. Docs/rules aligned (`CancellationSignal`, fake HTTP adapter, `skip + limit >= total`). `flutter analyze` 0; `flutter test` 226/226 (110 new). No UI, Cubits, favorites, or database |
| 2026-10-13 | 4: Design system & shared widgets | ✅ Implemented on `feature/design-system` | Tokens from §5.3 (`ColorsApp`, `AppTextStyles`, `AppSizes`, `AppTheme`; card values not in §5.3 measured from the frame exports and marked [S]). Rubik variable font bundled (OFL) for both locales; weight axis and Arabic shaping covered by tests; Arabic rendering checked on real-font renders in EN and AR (no simulator screenshot, iOS build skipped at your request). 11 normalized Figma SVGs + `ImagePath`. Shared widgets in `core/widget/` + `Formatters` (price, rating). `AppBottomNavBar` replaces the temporary Material `NavigationBar` in `AppShell`. Property cards (featured, grid, list) with the location rule (brand → category name → slug) and an optional favorite slot. Packages: `flutter_svg`, `cached_network_image`, `intl`. New keys `common.see_all/search_hint/filter/empty` in both languages. Tests: LTR/RTL, long text, 320×640 at 1.3, null/empty/bad image URL, assets, formatters, font. `flutter analyze` 0; `flutter test` 329/329 (103 new). Screens stay placeholders until Phase 5 |
| 2026-10-13 | Splash ([#1](https://github.com/AnasAlhamadd/flutter-real-estate-assessment/issues/1)) | ✅ Implemented on `feature/splash` (from `feature/design-system`) | GitHub task created and approved first (no issue existed). `/splash` is the default `initialLocation`; it shows the Figma logo, "REAL SCOUT" and the localized tagline, then `context.go(home)` after 1.5 s (no back stack; timer cancelled on dispose). Deep links bypass it. Rubik replaces Figma's Outfit (no Arabic glyphs). New key `splash.tagline`. Tests: en/ar × 320x568/430x932 × text scale 1.0/1.3, timing, back stack, early dispose, deep link, logo asset. `flutter analyze` 0; `flutter test` 342/342 |
| 2026-10-13 | Text keys, `CustomText`, splash timing fix | ✅ Implemented on `feature/splash`, uncommitted | `AppTextKeys` (`core/constant/app_text_keys.dart`) declares every translation key; all string-literal keys in `lib/` replaced (router, app title, failure messages, shared widgets, splash). `CustomText` (`core/widget/custom_text.dart`) translates a key, can upper-case, and drops letter spacing in the Arabic locale (replaces the splash-only RTL check; you chose a `context.locale` check over detecting Arabic characters, so Latin text such as "REAL SCOUT" also loses its tracking in Arabic). **Splash bug:** the logo was parsed in an isolate only after the splash mounted, so in debug builds the title showed alone and the logo was visible for ≈0.6 s of the 1.5 s timer (measured from simulator screenshots every ≈0.3 s). Fix: `SplashScreen.precacheLogo()` fills `svg.cache` in `main()` alongside `di.init()`; the widget reads the same cache key. After the fix the logo and text appear together and stay ≈1.4 s. Note: hot reload keeps the router's current route, so the splash only reappears after a hot restart or cold launch. Tests: key parity with both JSON files (read from source), `CustomText` (translation, props, upper case, letter spacing per locale, locale switch), precache + cache key. `flutter analyze` 0; `flutter test` 357/357 |
| 2026-10-13 | Auth UI ([#6](https://github.com/AnasAlhamadd/flutter-real-estate-assessment/issues/6)) | ✅ Implemented on `feature/auth` (from `feature/splash` `ebfc910`) | No Auth issue existed: decisions asked first (Google button → notice, guest action, collage export, Figma budget, base branch), issue drafted and approved. Flow: Splash → `/auth` (replaces Splash) → "Continue as guest" → Home (replaces Auth). `AppRouter.signedInDestination` (= Home) reserved for real sign-in (Q19). Deep links unchanged. Screen from Figma `1:4499`: single-image collage, `AuthIntro` (eyebrow, rich headline, subtitle), `GoogleAuthButton` (`OutlinedButton`, Figma shadow), guest `TextButton` (44 px minimum tap target). No Cubit/use case/repository: the screen has no state or data yet. New tokens (`AppSizes`/`AppTextStyles`/`ColorsApp` auth entries, `minTapTarget`), 7 keys in both languages, `assets/images/` registered. Tests: Auth matrix (en/ar × 320×568/430×932 × 1.0/1.3), no scroll at design size, scroll at 2.0, notice without navigation, single snackbar, guest → Home without back stack, semantics (buttons, header); Splash → Auth timing/back stack/deep link; router flow; asset checks. `flutter analyze` 0; `flutter test` 385/385 |
| 2026-10-13 | 5: Home screen | ✅ Implemented on `feature/home` (from `feature/auth` `34700e4`), local commits only | No GitHub issue (you chose to start without one). Decisions asked first: `HomeCubit` over the existing use cases (no data-layer changes), one `get_design_context(1:4426)` call, header per Q11, filter icon and bell hidden, Featured count 5 (Q18). `HomeCubit` loads Featured, categories and the first "All" page in parallel, with separate status, failure and retry per section; selecting a chip reloads page 0 for that category and drops stale responses; `isFromCache` shows a localized offline notice. `HomeScreen` replaces the Home placeholder at `/`: header, read-only search field → Explore, Featured list, "See All" ×2 → Explore, chips, responsive grid, cards → `/property/:id`. `CustomText.plain` added (API data and prices now go through `CustomText`); featured card sized with `.r`. 8 keys added, `home.title` removed. Dev dep `bloc_test ^9.0.0`. Tests: `HomeCubit` (bloc_test), Home widgets, `CustomText.plain` (props, ellipsis, text scale, RTL), Home screen (5 viewports incl. tablet and landscape × en/ar × 1.0/1.3, Figma geometry at 430, long Arabic text at 320 × 1.3, navigation, states, clock), shell/router/language-switch/DI updates. `flutter analyze` 0; `flutter test` 477/477 (92 new). Explore still a placeholder, so "See All" and search don't pass a query, sort or category yet |
| 2026-10-13 | Home: favorites, skeletons, pagination, refresh | 🟡 Implemented on `feature/home`, uncommitted (you asked for no commits) | Decisions asked first: favorites as bounded snapshots under a new key, no favorites screen, filled heart derived from the outline, no static fallback data, own shimmer (no package), remote-first cache policy kept, one Figma screenshot. **Favorites:** `feature/favorites` (domain, data, presentation), app-wide `FavoritesCubit` above the router, serialized saves with revert on failure, 100-item limit, snackbars for limit/save failures. **Storage:** `VersionedPreferencesStore` extracted from the properties local data source (API unchanged) and reused for favorites. **Home:** skeletons replace the spinners; infinite scroll with dedupe, `hasReachedMax`, retry footer, stale-response protection (one request counter for category changes, refresh and pages), paging paused on saved results; pull to refresh keeps content on failure and shows `home.refresh_failed` (a saved copy counts as a failure); one refresh when connectivity goes offline → online (never on every event). **Bug found by tests:** `Semantics(excludeSemantics: true)` hid the heart's tap action from screen readers; fixed with `onTap` on the semantics node. Removed `SectionStatusView.loading`. Keys: `home.refresh_failed`, `favorites.{add,remove,limit_reached,save_failed}`. Tests: store, favorites data/domain/cubit (incl. restart with real prefs, rapid taps, failure revert), `HomeCubit` pagination/refresh/connectivity, heart button (states, semantics en/ar, 44 px), heart placement on cards (en/ar × 430/320 × 1.0/1.3), shimmer + reduced motion, skeleton sizes, Home favorites sync, pagination footer, refresh. `flutter analyze` 0; `flutter test` 605/605 (128 new). **Then, at your request:** Home moved to `feature/home/presentation/` (cubit, page, Home-only widgets); shared property widgets stay in `properties`; tests moved to mirror `lib/` one file per source file (`favorites_usecases_test` → `{toggle_favorite, get_favorites, save_favorites}_usecase_test`, `home_widgets_test` → per-widget files, `card_favorite_button_test` → `property_favorite_button_test`, Home finders → `test/helpers/`). `flutter analyze` 0; `flutter test` 608/608 |
| 2026-10-13 | Debug request log | ✅ Implemented, uncommitted | Replaced Dio's verbose `LogInterceptor` with `ApiLogInterceptor` (`core/network/api_log_interceptor.dart`), still added in debug builds only. One block per finished request: `request: GET`, `request_status: 200 (142 ms)` (or the `DioExceptionType` name such as `cancel` / `connectionTimeout` when there is no response), `uri: <full uri with query>`. Tests: success, HTTP 404, in-flight cancel. `flutter analyze` 0; `flutter test` 611/611 |
| 2026-10-13 | Home data layer | ✅ Implemented on `feature/home`, uncommitted | Decisions asked first (3 questions): Home gets its own domain + data; saved data on any non-200 or no internet; cache scope unchanged ("All" first page + categories). **Domain:** `HomeRepository` (`getFeaturedProperties`, `getCategories`, `getRecommendations({categorySlug, page})`) + `GetFeaturedPropertiesUseCase`, `GetCategoriesUseCase`, `GetRecommendationsUseCase` (one use case for "All" and category pages, so `HomeCubit` no longer picks the endpoint). **Data:** `HomeRemoteDataSource` (DummyJSON), `HomeLocalDataSource` (moved from `PropertiesLocalDataSource`, same keys and envelope), `HomeRepositoryImpl` (remote first; the "All" first page falls back to its < 24 h copy on any failure except cancellation, 4xx included). **Properties** now holds search, full catalog, details and the shared entities/models; its four Home use cases and local data source were removed. Pagination and lazy loading were already in place and are unchanged (20 per page, `hasReachedMax`, retry footer). Tests moved/added: Home remote/local data sources, repository (every failure type, cancel, cache age, category pages), use cases, DI; test helpers split into `sample_properties.dart` + `fake_home_repository.dart`. `flutter analyze` 0; `flutter test` 621/621 |
| 2026-10-13 | Home: back to top | ✅ Implemented on `feature/home`, uncommitted | Your request. `ScrollToTopButton` (`core/widget/scroll_to_top_button.dart`) listens to Home's `ScrollController` (`HomeView` is now stateful and owns it) and shows once the page is scrolled more than one viewport. It sits in the Scaffold's floating slot: end side (right in English, left in Arabic), above the bottom nav bar. Tap scrolls to the top in 500 ms (`easeOutCubic`), or jumps when the system disables animations. While hidden it ignores taps and is excluded from semantics. Not in Figma, so built from existing tokens only: `CircleIconButton` (44) in `ColorsApp.primary`, `AppSizes.buttonShadow`, `ImagePath.arrowRight` rotated to point up; no new asset. New key `common.back_to_top` (en/ar). Tests: widget (hidden at top, hidden within one screen, appears + returns to top in en/ar, no animation) and Home (end side per locale, above the nav bar, back to 0). `flutter analyze` 0; `flutter test` 628/628 |
| 2026-10-13 | Grid cards: appear animation | ✅ Implemented on `feature/home`, uncommitted | Your request. `AppearAnimation` (`core/widget/appear_animation.dart`): fade 0→1, slide up from 12 % of the card height, scale 0.94→1, 450 ms `easeOutCubic`, optional delay folded into the controller (`Interval`, no timers). `SliverPropertyGrid` (now stateful) wraps every card: first page and each new pagination page animate, column after column (70 ms stagger, reading order, so it mirrors in Arabic). Cards rebuilt after scrolling back don't replay it (ids already shown are remembered); a replaced list (category change, refresh) clears that memory and bumps a generation in the card keys so even the same id in the same place replays. Off when the system disables animations. Not in Figma (motion isn't designed); no new package. Tests: animation (start/rest values, delay, `animate: false`, reduced motion) and grid (new page animates while loaded cards stay, stagger, no replay on scroll back, replaced list replays). `flutter analyze` 0; `flutter test` 636/636 |
| 2026-10-13 | 5: Property Details | ✅ Implemented on `feature/property-details` (from `origin/main` `d0646e1`, PR #8 merge, same tree as `feature/home`), local commits only | Git checked first: clean tree, target branch absent, `origin/main` contains the design system, properties data layer, Home and Favorites; local `main` (behind origin) untouched. Decisions asked first: one Figma read, hide "Booking Now" (Q9 A), hide Agent/Facilities/Location/likes with reviewer initials (Q4), gallery tile → hero, "See All" expands inline, presentation-only feature. `PropertyDetailsCubit` (list item as initial data when the id matches; failure keeps it; retry; drops late responses). Screen, 12 widgets, `AppDivider`, `AppBackButton.plain`, `FavoriteButton.detailsTopBar`, `SectionHeader.leading`, shared `SkeletonTextLine`, `RelativeTimes`. Router: `/property/:id` builds Details, non-numeric ids → not-found, `extra` only used when its id matches; Home passes the tapped item. Keys: `details.{overview, gallery, price, rating_reviews, image_position, show_image}`, `time.*` plurals (en one/other, ar all six forms); `details.title` removed. **Bug fixed:** plural rules were ignored (easy_localization default), so Arabic counts used the wrong form. Tests: cubit, every widget, screen (loading with/without list data, success, hidden sections, failure with/without data + retry, unknown id, gallery → hero + scroll to top, heart shared with Home, routing, layout matrix 4 viewports × en/ar × 1.0/1.3), relative time, plural-group key parity, Home/shell/splash updates. `flutter analyze` 0; `flutter test` 760/760 |
| 2026-10-13 | 5: Property Details extras (`1:4273`) | ✅ Implemented on `feature/property-details`, **uncommitted** (you asked for no commits); your pushed `42856d8` untouched | Reviewed `1:4273` and added what was missing, with mock data where DummyJSON has nothing (your choices: static map, call → dialer, chat/booking → message, Booking Now shown, Share hidden, Figma agent photo + reviewer initials). New: `PropertyExtrasEntity`/repository/use case/mock data source (all mock values commented `/// this mock:` with the reason), `PhoneDialer` (`url_launcher`), widgets `DetailsStats`, `DetailsAgent`, `DetailsFacilities`, `DetailsLocation`, `DetailsMap`; review likes in `ReviewTile`; "Booking Now" in `DetailsPriceBar`. Cubit loads extras in parallel; an extras failure only hides their sections. 17 SVGs + 2 PNGs from the design-context asset URLs. Keys `details.{beds, baths, review_likes}` (plurals, ar six forms), `area`, `agent*`, `chat_agent`, `call_agent`, `facilities`, `facility.*`, `location`, `map`, `booking_now`, `not_available`, `call_failed`. **Bugs fixed:** `AppButton` grew to full height under loose constraints (its `Center` lacked `heightFactor`), which would have hidden the Details body once the button sat in the price bar; agent action gaps went negative below ~360 px. Tests: data source/repository/use case, cubit (extras, extras failure), every new widget (en/ar, narrow + 1.3 text), screen (section order, extras failure, booking/chat message, call → dialer, dialer failure), assets. **Follow-up (your report):** "Booking Now" stopped in the middle of the bar because the price `Flexible` and the button `Expanded` split the free space in half; the price now keeps its own width (capped at half, ellipsized) and the button fills the rest to the end edge (tested in en/ar). `flutter analyze` 0; `flutter test` 831/831 |
| 2026-10-13 | 5: Details hero scroll effects | ✅ Implemented, **uncommitted** | Your request: custom flexible space instead of `FlexibleSpaceBar`'s defaults. `DetailsHero` is now a `SliverAppBar` (`primary: false`, `toolbarHeight: 0`, `expandedHeight` 460, `stretch: true`) whose `flexibleSpace` reads the real header height from its constraints: pulling down → `Transform.scale` from the top edge (`1 + pulled / 460`); scrolling away → `ImageFiltered` blur up to σ 10 (`detailsHeroMaxBlur`), disabled at rest; a bottom gradient (transparent → `ColorsApp.overlay`, 120 high) keeps the white dots readable. Both effects follow the scroll position, no timers. The Details scroll view uses bouncing physics on every platform so the stretch works on Android too. The gradient is at the bottom only: the top-bar icons are dark, so a dark top gradient would make them harder to see. Not in Figma (values in `AppSizes`/`ColorsApp` marked as your request). Tests: rest state, zoom grows with the drag and settles back, blur grows with the offset, top bar scrolls with the content, gradient under the dots. `flutter analyze` 0; `flutter test` 835/835 |
| 2026-10-13 | 5: Explore / Search (`1:4120`) | 🟡 Implemented on `feature/search`, **uncommitted** (domain, data and cubit staged by an earlier chat; screen, widgets, routing and tests unstaged) | Your Search brief, then "apply the design on Explore" (Explore still showed the placeholder). **Domain/data/cubit** (earlier chat, kept): `SearchQuery` (2-character minimum, normalization), `SearchRepository` + 4 use cases, `SearchResultsMemoryDataSource` (20 queries, 10 min), `SearchRepositoryImpl` (cache first, paged, dedupe, stale pages dropped), `SearchCubit` (300 ms configurable debounce, browse mode under 2 characters, request generation + cancellation, cached query restores its pages, load more + retry, pull to refresh, refresh once when back online), `searchProductsPage` on the remote data source, DI. **This chat:** `SearchScreen` replaces the Explore placeholder at `/explore` (`SearchHeader`, `AppSearchField` without filter icon, `SearchResultsSection` with skeletons, error/empty/offline states, "Found {n} results" via `SearchResultsCount`, `SliverPropertyList` + skeleton in `properties`, load-more footer, refresh-failure snackbar, card → Details, hearts); keys `search.{found, no_results, refresh_failed}` (ar six plural forms); `searchHeaderTitle` style [U]; `searchSkeletonCount`. Chips and bell hidden; filter icon waits for the Filter sheet. **Figma:** the design read was lost and the next call hit the plan limit, so geometry follows §5.3 values (20 padding, 24 rhythm, 16 list gap, 390×52 field, 44 back button) and is tested at 430×932, but pixel fidelity is **not verified** against `1:4120`. Tests: `FakeSearchRepository`, screen (geometry at 430, header centering and RTL side, 4 viewports × en/ar × 1.0/1.3, browse, 1 character sends nothing, debounce timing, loading, empty vs error, retry, clearing, pagination skeleton + retry, Details and back keep query/results with no new request, back → Home, hearts), widgets; 21 existing tests updated from the placeholder to `SearchScreen`. `dart format` changed whitespace only in 4 staged files. `flutter analyze` 0; `flutter test` 897/897. **Gaps:** no unit tests yet for the search domain, data layer and `SearchCubit`; Home's search bar doesn't focus the Explore field; "See All" doesn't pass sort/category |
| 2026-10-13 | 5: Filter sheet (`1:3867`) + Explore filter icon (`1:4146`) | 🟡 Implemented on `feat/add_filter` (from `a4a0236`), **uncommitted** | Your request: build the sheet, open it from the icon in Explore's search field, decide the backend interaction and record it. **Backend decision (§4.5.1 "Filter sheet"):** any active filter → full matching set of the current query (`limit=0`), filtered on the device (several categories + open-ended price range); no filter → Explore unchanged (paged). Full sets kept in `PropertiesRepositoryImpl` memory (last 5, 10 min, successes only, `forceRefresh` for pull to refresh), so the sheet's histogram load and "Set Filter" share one request. **Domain:** `PropertyFilter`, `PriceHistogram` (20 log-scale buckets, whole-dollar bounds, open ends, disabled with < 2 different prices); `FilterParams.categorySlugs` (set) replaces `categorySlug`; `forceRefresh` on the full-set repository calls. **Presentation:** `FilterCubit` (draft, categories ‖ prices in parallel, retry, Reset, cancels on close), `SearchCubit` filtered mode (`applyFilter`, typing while filtered re-filters the new query's full set, clearing restores the paged listing, retry/refresh per mode), `showFilterSheet` on the root navigator (overlay covers the nav bar), `FilterSheetHeader`, `FilterPriceSection` (skeleton / retry / chart), `PriceRangeChart` (bars + themed `RangeSlider` + labels that merge when the thumbs are close), `FilterCategorySection`, `AppBackButton.compact`, `CategoryChip.verticalPadding`, `AppSearchField.filterActive` (Primary tint, not in Figma), filtered empty state with "Clear filters". Bedrooms/Bathrooms/Building Size hidden (Q4/Q14). Tokens from the saved Phase 1 `1:3867` design context (no Figma call this chat). 8 keys `filter.*` (en/ar). **Bugs found by tests and fixed:** the sheet opened in Explore's branch navigator and stopped above the nav bar (fixed with `useRootNavigator`); the loose title `Flexible` packed the header to the start, so "Filter" wasn't centered and Reset didn't reach the edge; Reset's 48 px Material tap target made the header 2 px too tall; a single $9.99 price produced a selectable $9–$10 range. Tests: histogram, full-set memory (fresh, `forceRefresh`, stale, failure not kept, LRU 5), `FilterCubit`, `SearchCubit` filter flows, sheet (Figma geometry at 430×932, Arabic mirror, chips, skeleton, retry, single price, 4 viewports × en/ar × 1.0/1.3), Explore (icon position and tint, apply, slider drag, back, reopen + Reset, typing while filtered, clear filters), DI (shared repository, new `FilterCubit` per sheet). Temporary real-font renders in en/ar checked, then deleted. `flutter analyze` 0; `flutter test` 958/958. **Gaps:** Home's filter icon stays hidden (TODO(question) in §5.2); Explore's category chip row (`1:4149`) isn't added; `core/utils/bidi_text.dart` listed in §4.2 doesn't exist, so prices are kept LTR with `TextDirection.ltr` instead |
| 2026-10-14 | Search field: clear button | 🟡 Implemented on `feat/add_filter`, uncommitted | Your request: an × to delete the typed search text. `AppSearchField` shows `_ClearButton` (between the input and the filter icon) while its controller has text; hidden on the read-only Home bar and when no controller is given. Tap clears the controller and reports `''` through `onChanged`, so Explore returns to the browse listing (or the filtered catalog) at once. Not in Figma: built from existing tokens (`smallIconSize`, `black03`, `searchFieldIconGap`, 44 px tap target) with a new 24×24 stroke icon `assets/svg/close.svg` (`ImagePath.close`). New key `common.clear_search` (en/ar) as its semantics label. Tests: `app_search_field_test.dart` (hidden when empty, hidden when read-only, clears and reports an empty query in en/ar). `flutter analyze` 0; `flutter test` 963/963 |
| 2026-10-14 | 5: Profile (`1:3786`) | 🟡 Implemented on `feature/profile` (from `feat/add_filter` `c2ddd38`), **uncommitted**, no GitHub issue (your choice) | Your request: apply the Profile design with the recorded decisions. Decisions asked first (4): Q17 as recorded (only the Language row), picker = bottom sheet like the Filter sheet, current language shown on the row, new branch without an issue. **Figma:** no MCP call (budget used up); geometry from the saved Phase 1 `get_metadata` of `1:3786` and typography from §5.3. **Feature `profile` (presentation only):** `ProfileScreen` replaces the placeholder at `/profile`; widgets `ProfileUserInfo` (`GuestAvatar` 140 + "Guest"), `ProfileMenuRow` (icon 28, label, optional value, mirrored chevron, 44 px target reaching 8 px past the 28 px row), `showLanguageSheet` / `LanguageSheet` (completes with the picked `Locale` or `null`; the screen calls `context.setLocale` only when it differs). Bell, edit badge and the eight other rows hidden (Q13, Q17). **Core:** `GuestAvatar` extracted from Home's private avatar and reused by Home; temporary `LanguageSwitcher` deleted; tokens `AppSizes.profile*`, `AppTextStyles.profile{Title,Name,MenuLabel}`; key `profile.guest_name` (en/ar); `assets/svg/check.svg` (`ImagePath.check`, not in Figma). **Tests:** Profile screen (Figma geometry at 430×932 in en/ar within 1.5 px, only one row, exactly 3 SVGs so no bell/badge, header semantics, 4 viewports × en/ar × 1.0/1.3 with the sheet open, current value, sheet over the nav bar, pick Arabic → RTL + persisted, pick current → no change, dismiss → no change), `LanguageSheet` (both options in each locale, check + Primary on the current one, single-choice semantics, result on tap, `null` on dismiss, 44 px targets), `ProfileMenuRow` (sides per direction, Figma sizes, 44 px target, value, tap, merged button semantics, ellipsis at 280 px × 2.0), `ProfileUserInfo`, `GuestAvatar`; `language_switch_test` and `app_shell_responsive_test` moved from the placeholder to the real flow; helpers `profile_finders.dart`, `svg_finders.dart`. Temporary real-font renders of the screen and sheet in en/ar checked, then deleted. `flutter analyze` 0; `flutter test` 1020/1020 |
| 2026-10-14 | Audit + 9: Documentation | 🟡 Implemented on `docs/final-audit` (from `origin/main` `24ea3ce`, the squash merge of PR #13, same tree as `feature/profile`), **uncommitted** | Your request: audit every file against the brief, fix what's missing, write the README in English. **Audit:** greps for hard-coded `Text('…')`, physical `left/right` paddings/alignments, empty tap handlers, `print`/TODO, secrets/PDF in git; all clean (the one `EdgeInsets.fromLTRB` in `DetailsTopBar` applies physical safe-area insets on purpose). **Fixed:** missing unit tests for search logic (E4): `search_query_test` (normalization, 2-character minimum in runes), `search_results_local_data_source_test` (LRU, freshness), `search_repository_impl_test` (offline, cache hit, cancellation pass-through, failures not cached, empty cached, timeout/cancel mapping, stale flag, next page offset + dedupe, stop at max, failed page keeps items, refresh range + failure keeps cache); `pubspec.yaml` template description; `*.pdf` in `.gitignore`; §4.2/§4.7 listed files that don't exist (`debouncer`, `bidi_text`, `core/function`). **Docs:** `README.md` (screens, setup, `API_BASE_URL`, architecture, state management, API/errors/caching, search & filter, language switch + RTL, responsive, packages, tests, assumptions and limitations incl. C9), `AI_USAGE.md` (F1–F6 from §11), §3 ticked with the open items noted. **Open:** G7 screenshots (README links `docs/screenshots/{en,ar}/*.png`, not captured yet), G1 merge + push. `flutter analyze` 0; `flutter test` 1051/1051 (31 new) |

| 2026-10-14 | Decision log audit | 🟡 Documentation only on `docs/final-audit`, uncommitted | Your request: audit and complete the decision log for search caching, pagination and connectivity. §11 is the AI usage log, so the records went to the new §4.9 next to §4.8. Traced `SearchCubit`, `SearchRepositoryImpl`, `SearchResultsMemoryDataSource`, `HomeCubit`, `HomeRepositoryImpl`, `PropertiesRepositoryImpl`, `NetworkInfoImpl`, `DioClient`, `LoadMoreScrollListener`, the DI setup and the `connectivity_plus` 6.1.5 plugin source. Corrected §4.5.1 (400 → 300 ms); clarified README §8 (offline copies, cache freshness) and §7 (`SearchCubit` reconnect); `AI_USAGE.md` §3 now separates your requirements from the agent's choices. No Dart, test, dependency or config changes. Targeted tests run: 288 passed (folders listed in §4.9). Gaps listed in §4.9 as *inspection only*. **Follow-up (your request):** UI/UX decisions not in Figma recorded as §4.10 (Details hero zoom/blur/gradient, Home back-to-top, search clear ×, grid appear animation, 44 px tap targets, tabs keeping their state with `StatefulShellRoute.indexedStack`); their widget tests run: 51 passed, plus 71/71 in the two app shell test files |
| 2026-10-14 | Explore: pinned search bar | 🟡 Implemented on `docs/final-audit`, uncommitted | Your request: pin the search area and let the products pass under it; refresh was pulling and redrawing the whole screen. Decisions asked first (2): pin the header and field together; limit refresh to the results. `SearchView` is now a pinned `_SearchTopBar` above an `Expanded` `RefreshIndicator` + `_ResultsScrollView`; same paddings, so the Figma layout is unchanged at rest. Recorded as §4.10 U7. Tests: 2 new in `search_screen_test.dart` (results scroll under the pinned bar; pull to refresh moves only the results, keeps them shown, one request). `flutter analyze` 0; `flutter test` 1053/1053 |
| 2026-10-14 | Pull to refresh: fresh shimmer | 🟡 Implemented on `docs/final-audit`, uncommitted | Your request: on pull to refresh, Home and Explore reload with a new shimmer. The views track the user's pull (`_pullRefreshing`) and show the first-load skeletons in place of Featured + the grid (Home) and the results (Explore). Background refreshes (stale cached search, reconnect) show none. Cubits unchanged: a failed refresh brings the old content back with the snackbar. Replaces the earlier "content stays during refresh" behavior (U7, D4 updated). Recorded as §4.10 U8; README §8 updated. Tests: 1 new on Home, 2 new on Explore, 1 Explore test changed to expect skeletons. `flutter analyze` 0; `flutter test` 1056/1056 |
| 2026-10-14 | Refresh loading in the Cubits + `DataSource` | 🟡 Implemented on `docs/final-audit`, uncommitted | Your request: drive the pull-to-refresh skeletons from the Cubit status (loading → success/failure, the builder shows the skeleton) instead of a view flag, and make the offline state an enum. You chose: the user's pull sets the section status to `loading` with the old data kept; a failure goes back to `success` + `refreshFailed`; background refreshes keep the status; a separate `DataSource { remote, saved }` replaces the `isFromCache` bool in `HomeState`/`SearchState` (`RequestStatus` unchanged). `HomeCubit._refresh(showLoading:)`, `SearchCubit._refreshShown(showLoading:)`; the views' `ValueNotifier`s and `showSkeleton` parameters removed. U8, D3, D4 updated. Tests: Home refresh expectations updated to the loading states, 1 new reconnect test, new `search_cubit_refresh_test.dart` (5). `flutter analyze` 0; `flutter test` 1062/1062 |
| 2026-10-14 | Device Preview | 🟡 Implemented on `docs/final-audit`, uncommitted | Your request. `device_preview ^1.3.1` via `flutter pub add` (3.0.0 not resolvable with the current constraints). `main.dart` wraps `AppLocalization.wrap(const App())` in `DevicePreview(enabled: !kReleaseMode)`; `MaterialApp.router` gets `builder: DevicePreview.appBuilder`. Locale stays on easy_localization. `flutter analyze` 0; `flutter test` 1062/1062 |

---

## 11. AI usage log (raw material for `AI_USAGE.md`)

| Date | Tool | Purpose | Output | Verification | Modified / rejected & why |
| --- | --- | --- | --- | --- | --- |
| 2026-10-13 | Cursor Agent | Environment audit (git, flutter doctor, analyze, test) | Environment section (§2) | Re-ran commands manually | — |
| 2026-10-13 | Cursor Agent + Figma MCP | Connect Figma MCP, verify access | §2 Figma status | `whoami`; `get_metadata` returned a documented permission error | — |
| 2026-10-13 | Cursor Agent | Analyze brief, plan phases, architecture | This reference + `.cursor/rules/` | Each requirement mapped to an ID (§3) and a phase (§7) | **Rejected** reusing rules copied from another project (Laravel backend path, Firebase, 5 locales with `nl` fallback, fixed 360×800 design size) because they didn't match this assessment |
| 2026-10-13 | Cursor Agent + Figma MCP | Verify access to the Drafts duplicate | §2 Figma rows | `create_session` + `get_metadata` (no node) returned page `0:1` "Page 1" | — |
| 2026-10-13 | Cursor Agent + Figma MCP | Phase 1 design inventory: `get_metadata(0:1)`, `get_variable_defs(1:4426)`, `get_design_context` for `1:4426`, `1:4120`, `1:3867`, `1:4236`, `1:3786` | §5, §4.6, §9 Q10–Q17 | Each value traced to MCP output (evidence key [V]/[S]/[U] in §5). Product schema re-checked with `curl https://dummyjson.com/products/1` and `/products/categories` | **Rejected** the "colors" spec frame (all swatches labeled "Voog blue #443DF6", contradicting the `#0061FF` used on screens). **Rejected** the generated button shadow `rgba(112,79,56,.25)` in favor of the named variable `Button/Shadow 1`. Did not claim Rubik Arabic coverage (marked unverified) |
| 2026-10-13 | Cursor Agent | Phase 2 foundation: core error/network/DI, l10n, router, responsive setup, shared test helpers + responsive matrix | `lib/core/**`, `lib/app.dart`, `lib/main.dart`, `lib/injection_container.dart`, `assets/translations/*`, `test/**` | `flutter analyze` 0; `flutter test` 116/116; `plutil -lint` on `Info.plist`; pubspec YAML parsed and asset paths checked; easy_localization/dio/connectivity_plus sources read in pub cache to confirm APIs | Added `DioExceptionType.transformTimeout` (new in dio 5.11, flagged by the analyzer). Replaced string `.tr()` with `context.tr()` after the language-switch test showed stale titles on kept-alive routes. Scoped nav-label finders to `NavigationBar` instead of loosening assertions. No overflow was hidden to make tests pass |
| 2026-10-13 | Cursor Agent | Pre-Phase 3 decision review (font, field mapping, cache, filtering) | §4.3, §4.5 (+4.5.1, 4.5.2), §4.6, §4.8, §5, §6, §7, §9, rules | Google Fonts `METADATA.pb` + direct parsing of `Rubik[wght].ttf` (cmap/GSUB/GPOS) with plain Python; live `curl` checks of DummyJSON (`limit=0`, `select`, search/category combinations, price params, field coverage across 194 products); `shared_preferences` README; `dart:ui` `FontWeight` docs | **Rejected** the reference's own earlier claim that Rubik has no Arabic (the metadata and the font file show full Arabic support). **Rejected** using `weight` in the UI (no unit in the API). The user **narrowed** the proposed stats-row substitution to "hide" |
| 2026-10-13 | Cursor Agent | Phase 3 data layer + tests | `lib/feature/properties/{domain,data}/**`, core additions, `test/feature/**`, `test/fixtures/**` | Fixtures captured from live DummyJSON with `curl`; remote data source tested through the real `DioClient` with a recording HTTP adapter (paths, query params, slug encoding, cancellation); repository branches tested with `mocktail`; `flutter analyze` 0; `flutter test` 216/216; boundary greps (no Flutter/Dio/prefs imports in domain; only the two approved keys written) | Fixed a test that compared lists wrapped in dartz `Right` (identity equality) by unwrapping. Chose a pure-Dart `CancellationSignal` instead of passing Dio's `CancelToken` through the domain. Kept `FilterPropertiesUseCase` synchronous instead of forcing it into `Future<Either>` |
| 2026-10-13 | Cursor Agent | Phase 3 review fixes | `json_readers.dart`, `properties_local_data_source.dart`, model/local/repository tests, `product.json`, reference §4.3–§4.8 + §7, `data-layer.mdc`, `testing.mdc` | Confirmed with a Dart script that `double.tryParse("NaN")` returns NaN, that `jsonEncode(NaN)` throws `JsonUnsupportedObjectError` (an `Error`), and that `jsonDecode("1e400")` gives `Infinity`, whose `toInt()` throws `UnsupportedError`. Regression tests cover string and numeric non-finite values, overflowing literals, the local write, and the repository end-to-end with the real local data source; 226/226 | The AI review found the NaN path; the `readInt(Infinity)` crash was found while fixing it |
| 2026-10-13 | Cursor Agent + Figma MCP | Phase 4 design system: asset export and normalization, tokens, shared widgets, property cards, widget tests | `assets/svg/*`, `assets/fonts/rubik/*`, `lib/core/{app_theme.dart,constant/*,utils/formatters.dart,widget/*}`, `lib/feature/properties/presentation/widget/*`, `test/core/**`, `test/feature/properties/presentation/**`, reference §2/§5/§6/§10 | Exported shapes measured against the Figma PNG renders; composed icons rendered side by side with the frame exports; card insets and text colors measured/sampled from the 1x exports with PIL; a probe test showed `FontWeight` alone moves Rubik's `wght` axis (kept as a permanent test); temporary golden renders with the real font in EN/AR (deleted afterwards); `flutter analyze` 0; `flutter test` 329/329 | Asked you before exporting (asset list, hearts, packages, extra calls for the bold Profile icon). Fixed a list-card layout bug found in the renders (price drifted to mid-row). Changed the heart from a bare callback to an optional widget slot because no heart asset was approved. Rewrote a badge-position test that compared against the wrong element, and an invalid `LoadingView` test that could never settle. Deferred `PropertyTag`, `Divider`, `ProfileMenuRow` instead of inventing their sizes |
| 2026-10-13 | Cursor Agent + Figma MCP + GitHub CLI | Splash feature ([#1](https://github.com/AnasAlhamadd/flutter-real-estate-assessment/issues/1)) | Issue #1, `lib/feature/splash/**`, router/app defaults, tokens, `assets/svg/splash_logo.svg`, tests, reference §2/§4.2/§5.1/§5.4/Q1 | Searched both repos for an existing task (none) and stopped for approval; `get_design_context(1:4551)` with screenshot; logo fetched from the response's asset URL and parsed in a test (size + gradients); temporary real-font renders in EN/AR compared with the Figma screenshot (deleted afterwards); `flutter analyze` 0; `flutter test` 342/342 | **Rejected** Outfit (Figma font) because it has no Arabic and would add a second font for one screen; kept Rubik at the same weights. Dropped letter spacing for the Arabic tagline. Fixed a timing test that assumed the harness used no time before the check |
| 2026-10-13 | Cursor Agent | Translation key constants, `CustomText`, splash "doesn't appear" investigation | `lib/core/constant/app_text_keys.dart`, `lib/core/widget/custom_text.dart`, key replacements in `lib/`, `SplashScreen.precacheLogo()` in `main.dart`, tests, `localization-rtl.mdc`, reference §4.2/§10 | Ran the app on the iPhone 16 Pro simulator (debug) before and after, with screenshots every ≈0.3 s; read `go_router` 18.0.2 `_effectiveInitialLocation` (platform route only wins for deep links) and `flutter_svg` 2.3.0 loader/cache code to confirm the cache key; `flutter analyze` 0; `flutter test` 357/357 | **Rejected** go_router's platform default route as the cause (`/` falls back to `initialLocation`). **Rejected** starting the timer only after the SVG loads inside the splash (a failed or hanging load would block navigation, and the isolate doesn't complete inside fake-async widget tests). Dropped a `namedArgs` parameter from `CustomText` until a key needs placeholders (Phase 5). The first version detected Arabic characters with a regex; **you replaced it** with a `context.locale` check for simplicity, accepting that Latin text loses letter spacing in the Arabic UI |
| 2026-10-13 | Cursor Agent + Figma MCP + GitHub CLI + headless Chrome | Auth UI ([#6](https://github.com/AnasAlhamadd/flutter-real-estate-assessment/issues/6)) and Splash → Auth flow | Issue #6, `lib/feature/auth/**`, router/Splash change, tokens, keys, assets, tests, reference §2/§4.2/§5.1/§5.2/§5.4/Q1/Q19 | Stopped before coding: no Auth issue, and the brief asked for credential fields that the Figma frame doesn't have (confirmed with `get_design_context(1:4499)`); decisions taken through questions. Temporary real-font renders (EN/AR, 430×932 and 320×568, shadows on) compared with the Figma screenshot, then deleted; measured the panel parts when a test failed; `flutter analyze` 0; `flutter test` 385/385 | **You rejected** the first collage (12 tiles rebuilt in code with crop factors from 9 JPEGs) as over-engineered for static artwork and proposed your SVG export. **The agent rejected the SVG format**: it only wraps the 9 full-resolution JPEGs in base64 (7.6 MB, ~55 MB decoded per 4096 px photo), so it adds no precision. Kept your single-image idea as a 3× WebP (128 KB). Rejected macOS Quick Look rendering (it cropped the image to a square). A matrix test wrongly assumed no scrolling at 320×568 × 1.3: `splitScreenMode` scales text by 0.744 there, so the English headline takes 4 lines and the panel scrolls by design; the test now scrolls each action into view. Replaced deprecated `containsSemantics` with `isSemantics` |
| 2026-10-13 | Cursor Agent + Figma MCP | Home screen (`1:4426`), `HomeCubit`, `CustomText.plain`, responsive grid | `lib/feature/properties/presentation/{cubit,pages,widget}/**`, `custom_text.dart`, tokens, keys, router, DI, tests, reference §4.2/§4.5/§5.1/§5.2/§5.4/§9 | Decisions asked before coding (data source, Figma budget, header, filter, Featured count, branch). Figma: `create_session` (first attempt timed out, retried once) + one `get_design_context(1:4426)`; header and spacing values taken from it. `flutter analyze` 0; `flutter test` 477/477 | Chose rows with `Expanded` cells over a `SliverGrid`, which needs a fixed cell height or ratio and can't grow with the text scale. Replaced the featured card's width-based `AspectRatio` with `.r` on both sides so the card keeps 250×340 proportions without growing past the viewport in landscape. Fixed test bugs found while running: column count read after the first row was recycled, ambiguous chip finders (card location shows the same category text), a "See All" test that pumped the app twice in one test, a `.at(1)` finder that broke after scrolling, and a loading test that hung after passing because `addTearDown(cubit.close)` waited outside the fake-async zone on a cubit `BlocProvider(create:)` already owns |
| 2026-10-13 | Cursor Agent + Figma MCP | Home favorites, offline/refresh behavior, skeletons, pagination | `lib/core/{storage,widget}/**`, `lib/feature/favorites/**`, Home cubit/state/screen/widgets, DI, keys, heart SVGs, tests, reference §4.2/§4.5/§4.5.2/§5.1/§5.2/§5.4/Q8, rules (`00-project-core`, `data-layer`, `clean-architecture`) | Decisions asked before coding (7 questions). Heart outline from the asset URL saved from the earlier `get_design_context(1:4426)` (no new design-context call); filled variant checked in a headless-Chrome render. Figma: `create_session` + one `get_screenshot(1:4426)`, compared with temporary real-font renders (deleted). `flutter analyze` 0; `flutter test` 605/605 | Chose a card-level overlay for the 44 px heart instead of growing the price row (that would move the Figma layout). Registered `FavoritesCubit` as a factory owned by one root `BlocProvider` instead of the rule's lazySingleton (a provider would close a singleton); rule updated. Fixes from failing tests: missing semantics tap action on the heart, skeleton lines using a fixed 1.2 line height (now measured with `TextPainter`; a first fix collapsed bar widths and was caught by a measurement), test expectations that ignored bloc's equal-state dedupe, a finder for a formatted price, a locale switch inside one test, and the Android 48 px guideline applied to the approved 44 px target |
| 2026-10-13 | Cursor Agent | Concise debug log for API requests | `lib/core/network/api_log_interceptor.dart`, `dio_client.dart`, `test/core/network/api_log_interceptor_test.dart`, reference §4/§7/§10 | `flutter analyze` 0; `flutter test` 611/611 | **Rejected** testing a pre-cancelled `CancelToken`: Dio rejects it before the error interceptors run, and the app never sends one (the remote data source throws `RequestCancelledException` first); tested an in-flight cancel instead |
| 2026-10-13 | Cursor Agent | Home domain + data layers, fallback on any failure | `lib/feature/home/{domain,data}/**`, trimmed `lib/feature/properties/{domain,data}`, `HomeCubit`, DI, tests, helpers, reference §4.2/§4.5.2/§4.7/§10, rules (`data-layer`, `testing`) | Asked 3 questions before coding because the request conflicted with the recorded Home decision and the 4xx rule; boundary greps (no Flutter/Dio/prefs/data imports in domain, `properties` never imports `home`, each storage key has one owner); `flutter analyze` 0; `flutter test` 621/621 | **Rejected** keeping two recommendations use cases ("All" and category) because that left the endpoint choice in the cubit. **Rejected** keeping the paged listing in `properties` as well, which would have duplicated endpoints and cache keys; Explore's paged mode is a TODO(question). A batch of parallel edits to one test file was suspected of overwriting itself; a re-check showed every edit had applied |
| 2026-10-13 | Cursor Agent | Home back-to-top button | `lib/core/widget/scroll_to_top_button.dart`, `home_screen.dart`, `app_text_keys.dart`, `{en,ar}.json`, tests, reference §5.1/§10 | `flutter analyze` 0; `flutter test` 628/628; position checked per locale and against the nav bar in widget tests | **Rejected** a Material `FloatingActionButton` (default look, not from the design tokens) and a new up-arrow asset (the Figma chevron rotated is enough). Threshold set to one viewport height, a judgment call with no design value to follow |
| 2026-10-13 | Cursor Agent | Appear animation for grid cards with pagination | `lib/core/widget/appear_animation.dart`, `sliver_property_grid.dart`, tests, reference §10 | `flutter analyze` 0; `flutter test` 636/636 | **Rejected** a `Future.delayed` for the stagger (a pending timer can't be cancelled and fails widget tests); the delay is the start of the curve's `Interval`. A test found that a replaced list kept old card states when the same id stayed in the same place (equal keys), so the animation didn't replay; fixed with a list generation in the key. Two timing assertions were moved off exact frame boundaries. Parallel edits to one file duplicated an import, caught by `flutter analyze` |
| 2026-10-13 | Cursor Agent + Figma MCP | Property Details screen (`1:4236`) on a new branch | `lib/feature/property_details/**`, shared widgets/tokens/keys, router, DI, Home navigation, `AppLocalization.wrap`, tests, reference §2/§4.2/§4.6/§4.7/§5.1/§5.2/§5.4/§9/§10 | Git state and base branch verified before branching (no uncommitted work, `origin/main` tree equal to `feature/home`). Figma: `create_session` + one `get_design_context(1:4236)` (over budget, approved); every size and style traced to that response. easy_localization 3.0.8 source read in the pub cache to confirm `plural` and `ignorePluralRules`. `flutter analyze` 0; `flutter test` 760/760 | **Rejected** a new domain/data layer for Details (the details use case and its memory cache already exist in `properties`). Kept the Figma white inactive dots instead of inventing a darker color (limitation noted). Tests found the ignored Arabic plural rules (app bug, fixed in `AppLocalization.wrap`) and two test-side mistakes: a fixed-height harness for a 30-sentence review, and "See All" tapped before the lazy list had built it |
| 2026-10-13 | Cursor Agent + Figma MCP | Details extras from `1:4273` with mock data | `lib/feature/property_details/{domain,data}/**`, 5 new widgets, `review_tile`, `details_price_bar`, `details_header`, screen, `core/services/phone_dialer.dart`, `app_button.dart`, tokens/keys/translations, 19 assets, Android/iOS tel config, tests, reference §2/§4.2/§4.6/§5/§6/§9/§10 | `get_design_context(1:4273)` values traced into `AppSizes`/`AppTextStyles`; SVGs normalized to 24×24 by script and checked by the asset test (viewBox, no mask, parse size) and by rendering the screen to PNG; `plutil -lint`; `flutter analyze` 0; `flutter test` 828/828 | **Modified:** the call button's position (44 px targets shifted so the icons keep Figma's 20 px gap and end on the content edge), map street names in Rubik (Urbanist isn't bundled), name-to-chat gap is 16 px instead of 12 because of the tap targets. **Rejected:** a real map package (you chose static art) |
| 2026-10-13 | Cursor Agent | Details hero: stretch zoom, scroll blur, bottom gradient | `details_hero.dart`, screen physics, `AppSizes`/`ColorsApp` tokens, `details_hero_test.dart`, reference §10 | Read `SliverAppBar`'s delegate source to confirm the flexible space gets the stretched height and `maxExtent` through `FlexibleSpaceBarSettings`; widget tests for each effect; rendered rest/pulled/scrolled states to PNG | **Modified:** blur tied to scrolling away rather than to the pull, so the zoomed photo stays sharp; gradient only at the bottom (dark icons on top) |
| 2026-10-13 | Cursor Agent (two chats) + Figma MCP | Explore / Search screen (`1:4120`) on `feature/search` | Search domain/data/cubit (earlier chat), `SearchScreen` + widgets, `SliverPropertyList`, router, keys/translations, tokens, test helpers and tests, reference §2/§4.3/§4.5.1/§5.1/§5.2/§10 | Stopped while another chat was writing to the same tree and asked you how to proceed; took over its staged work only after it ended, without modifying it beyond `dart format`. `get_design_context(1:4120)` returned the plan-limit error, so no design values were read in this chat and pixel fidelity is not claimed. Geometry asserted in widget tests at 430×932; `flutter analyze` 0; `flutter test` 897/897 | **Modified:** search is paged with a 300 ms debounce and 2-character minimum (your brief) instead of the reference's full-set 400 ms plan; recorded in §4.5.1. **Rejected** node ids the agent had written in comments without verifying them (replaced with known ids). Tests found: Arabic "Found 5" uses the "few" form (helper made CLDR-aware), a second locale pumped in the same test didn't apply (split per locale), and a gap assertion that assumed height-only scaling (exact value now checked at the design size only) |
| 2026-10-13 | Cursor Agent | Filter sheet (`1:3867`), Explore filter icon, filter backend decision | `lib/feature/search/{domain/entities,presentation}/**` (filter files), `SearchCubit`/`SearchState`, `PropertiesRepositoryImpl` memory, `FilterPropertiesUseCase`, `SearchPropertiesUseCase`, shared widgets (`AppBackButton`, `CategoryChip`, `AppSearchField`), tokens/keys/translations, DI, test helpers and tests, reference §4.2/§4.3/§4.5/§4.5.1/§4.5.2/§4.7/§4.8/§5.1/§5.2/§5.4/Q14/§10, `data-layer.mdc` | Figma budget exhausted, so **no MCP call**: values read from the saved Phase 1 `get_design_context(1:3867)` output in an earlier transcript, and its asset SVGs fetched with `curl` for reference (no new assets added; the back arrow and filter icon already exist in `assets/svg/`). API limits taken from the verified §4.5.1 notes. Geometry asserted in widget tests at 430×932 (en/ar); temporary real-font renders in en/ar, deleted afterwards; `flutter analyze` 0; `flutter test` 958/958 | **Rejected** (backend): paged category requests (one category only, can't combine with search), filtering only the loaded pages (wrong results and count), sharing in-flight requests between the sheet and Explore (a cancel from one would cancel the other), persisting full sets (outside §4.5.2). **Rejected** a linear price scale (DummyJSON prices are heavily skewed). **Modified** a planned bidi helper: `core/utils/bidi_text.dart` doesn't exist despite §4.2, so prices are forced LTR instead. Tests caught the nested-navigator sheet, the off-center header, the 48 px Reset target and the single-price slider; all four fixed in code, not by loosening tests. One test expectation was wrong (field border not counted in the icon inset) and was corrected |
| 2026-10-14 | Cursor Agent | Clear (×) button in the search field | `app_search_field.dart`, `assets/svg/close.svg`, `ImagePath.close`, `common.clear_search` (en/ar), `app_search_field_test.dart`, reference §10 | `flutter analyze` 0; `flutter test` 963/963 (the SVG inventory test caught the missing `ImagePath.icons` entry) | No Figma close icon exists, so a simple stroke × in the Iconly style was drawn instead of using a Material icon (project uses SVG icons only) |
| 2026-10-14 | Cursor Agent | Profile screen (`1:3786`) with the recorded decisions, on a new branch | `lib/feature/profile/**`, `core/widget/guest_avatar.dart`, Home header, router, tokens/keys/translations, `check.svg`, tests + helpers, reference §4.2/§5.1/§5.2/§5.4/Q11/Q13/Q17/§10 | Figma budget used up, so **no MCP call**: frame geometry read from the Phase 1 `get_metadata` output saved in the agent tools folder (the `get_design_context(1:3786)` response wasn't saved), typography from §5.3. Geometry asserted in widget tests at 430×932 (en/ar); temporary real-font renders of the screen and sheet in en/ar, deleted afterwards; `flutter analyze` 0; `flutter test` 1020/1020 | Asked 4 questions before coding because the picker and the row value aren't in Figma. **Rejected** a Cubit/use case for the locale (easy_localization already holds and persists it, so the screen stays UI only like Auth). **Rejected** Material `Icons.check` (project uses SVG icons only); drew a stroke check like `close.svg`. Tests found that `ProfileUserInfo` shrank to the avatar's width under loose constraints (name off-center); fixed in the widget. Title finders were scoped to the screen because the title and the nav label share the same text in both languages. A `dart format` whitespace change in an unrelated test file was reverted to keep the diff scoped |
| 2026-10-14 | Cursor Agent | Requirements audit, search unit tests, README, AI_USAGE.md | `test/feature/search/{domain/entities/search_query, data/datasource/search_results_local_data_source, data/repositories/search_repository_impl}_test.dart`, `README.md`, `AI_USAGE.md`, `pubspec.yaml`, `.gitignore`, reference header/§3/§4.2/§4.7/§10 | Code greps per requirement (strings, directional APIs, dead handlers, secrets); every README claim checked against the code (endpoints, timeouts, cache sizes, debounce, plural setting, `matchTextDirection`, `TextDirection.ltr` uses); `flutter analyze` 0; `flutter test` 1051/1051 | **Modified** two README claims the agent couldn't verify: "tested on iPhone 16/16e/16 Pro Max and an Android emulator" (only the iOS simulator run is recorded) and a link to a demo video that doesn't exist. Kept the screenshot table but flagged that the images must be captured before delivery, instead of generating test renders without network photos |
| 2026-10-14 | Cursor Agent | Decision log audit: search cache, pagination, connectivity (documentation only) | Reference §4.9 (new), §4.5.1 debounce line, §10; `README.md` §7/§8; `AI_USAGE.md` §3 | Every claim traced to the source files named in §4.9; `connectivity_plus` 6.1.5 plugin source read in the pub cache (README warning, Android/iOS emit the current status on listen); your original Search, Home-data and connectivity briefs re-read from the chat transcripts to attribute decisions; targeted `flutter test` run: 288/288. Figma not used, app not run | **Corrected** the reference's 400 ms debounce (the code has 300 ms). **Not documented as tested:** `SearchCubit` behaviors with no Cubit or screen test (listed in §4.9 D1/D3/D4 as inspection only). The rules files' "~400 ms" and `utils/debouncer` were reported, not edited (documentation-only scope). **Follow-up §4.10 (UI/UX):** your original requests for the hero, back-to-top, clear × and card animation re-read from the chat transcripts; code and tests traced; 51/51 widget tests run. **Corrected** the clear button's "44 px tap target" (§10): 44 px tall only, about 36 px wide. U6 (tab state): `StatefulShellBranch.preload` default read in the go_router 18.0.2 source; no test covers scroll or request count across a tab round trip, marked *inspection only* |
| 2026-10-14 | Cursor Agent | Explore: pinned header and search field, refresh limited to the results | `search_screen.dart`, `search_screen_test.dart`, reference §4.10 U7/§10 | Asked 2 questions first (what to pin; what "refresh stretches and rebuilds" meant). `flutter analyze` 0; `flutter test` 1053/1053, including the unchanged Figma layout test and the responsive matrix. Figma not used, app not run | **Rejected** a pinned `SliverPersistentHeader`: it needs fixed extents, but the header grows with the text scale. Did not add a divider or shadow under the field (not in Figma) |
| 2026-10-14 | Cursor Agent | Pull to refresh shows a fresh shimmer on Home and Explore | `home_screen.dart`, `search_screen.dart`, `search_results_section.dart`, `home_state.dart` (doc comment), tests, reference §4.10 U7/U8/D1/D4/§10, `README.md`, `AI_USAGE.md` | `flutter analyze` 0; `flutter test` 1056/1056. Figma not used, app not run | **Rejected** driving the skeletons from the Cubits' `isRefreshing`: a stale cached search and the reconnect refresh also set it, so cached results would be hidden behind skeletons (a new test covers the stale case). **Rejected** clearing the data in the Cubit: a failed refresh would leave nothing to show. An existing Explore test that expected the cards to stay during refresh was changed to expect skeletons, because the requested behavior changed, not to make it pass |
| 2026-10-14 | Cursor Agent | Pull-to-refresh loading moved into the Cubits; `DataSource` enum for saved data | `core/enums/data_source.dart` (new), `home_state.dart`, `home_cubit.dart`, `search_state.dart`, `search_cubit.dart`, `home_screen.dart`, `search_screen.dart`, `search_results_section.dart`, `home_cubit_pagination_test.dart`, `home_cubit_test.dart`, `search_cubit_refresh_test.dart` (new), reference §4.10 U7/U8, D3, D4, §4.6, §10 | `flutter analyze` 0; `flutter test` 1062/1062. Figma not used, app not run | You rejected the agent's view-level `ValueNotifier` (previous row) in favor of the Cubit status. The agent's earlier argument against `isRefreshing` still holds, so the user-vs-background split is a `showLoading` parameter inside the Cubits. **Rejected** an `offline` value in `RequestStatus` (saved data is still a success). The Home refresh test "never shows a loading state over content" was replaced, because the requested behavior changed: a pull now shows `loading` by design |
| 2026-10-14 | Cursor Agent | Device Preview setup | `pubspec.yaml`, `main.dart`, `app.dart`, reference §6/§10 | Read `device_preview` 1.3.1 source in the pub cache (`appBuilder`, `locale`, the `useInheritedMediaQuery` assert falls back to true for non-app widgets); `flutter analyze` 0; `flutter test` 1062/1062 | **Rejected** `DevicePreview.locale(context)` for `MaterialApp.locale`: it would override the in-app language switch. Disabled in release builds |

