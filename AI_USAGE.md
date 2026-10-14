# AI Usage

This file explains how AI tools were used to build this assessment, how their output was checked, and where it was changed or rejected. I take full responsibility for the correctness, security and quality of the delivered code, and I can explain and modify any part of it.

The day-by-day record (date, tool, purpose, output, verification, changes) is in [`docs/PROJECT_REFERENCE.md` §11](docs/PROJECT_REFERENCE.md#11-ai-usage-log-raw-material-for-ai_usagemd).

---

## 1. Tools and what each was used for

| Tool | Purpose |
| --- | --- |
| **Cursor (agent mode)** | Main assistant: planning, architecture, writing and refactoring Dart code, writing tests, debugging failing tests, running `flutter analyze` / `flutter test`, and documentation |
| **Figma MCP server** (inside Cursor) | Reading the Figma file: frame list, design tokens (colors, text styles), exact sizes and spacing per screen, and exporting icons and images |
| **Cursor project rules** (`.cursor/rules/*.mdc`) | Written at the start to keep every AI session on the same stack, architecture, naming, localization and testing rules |
| **GitHub CLI** (driven by the agent) | Creating the Splash and Auth task issues ([#1](https://github.com/AnasAlhamadd/flutter-real-estate-assessment/issues/1), [#6](https://github.com/AnasAlhamadd/flutter-real-estate-assessment/issues/6)) after I approved them |
| `curl`, small Python/Dart scripts, headless Chrome (run by the agent) | Checking the live DummyJSON API, parsing the font file, normalizing exported SVGs, rendering temporary screenshots to compare with Figma |

## 2. What AI helped create or review

| Area | AI contribution | My role |
| --- | --- | --- |
| **Planning** | Turned the brief into a numbered requirements checklist (A1–G9), phases, and a single project reference (`docs/PROJECT_REFERENCE.md`) | Approved the screen list, color set, cache scope, and every open question (Q1–Q19) before code was written |
| **Design inspection** | Read the Figma frames and filled the design inventory (screens, node ids, tokens, every tappable element with a proposed action) | Decided which elements to implement, hide or show a "not available" message for |
| **API layer** | Endpoints, defensive JSON models, Dio client, error mapping, repositories with caching and offline fallback | Chose the cache policy (what is saved, for how long), the search/filter strategy and the fallback rules |
| **UI components** | Design tokens, shared widgets, property cards, all screens, skeletons, animations | Reviewed against Figma; requested changes (for example the back-to-top button, hero scroll effects, the collage as one image) |
| **Localization / RTL** | Translation keys, Arabic translations, directional layout, plural rules | Chose `easy_localization`, Rubik for both languages, Western digits |
| **Tests** | Unit, Cubit and widget tests (1,050+), fixtures, fakes, layout matrix | Required tests for every layer and both languages; checked that failing tests were fixed in the code, not loosened |
| **Debugging** | Found and fixed bugs, mostly surfaced by tests (see section 5) | Reported visual bugs found while running the app |
| **Documentation** | README, this file, progress log | Reviewed for accuracy |

## 3. Main prompts (summarized)

**Kickoff (Phase 1):**

> You are a senior Flutter engineer working on this repository. Read `docs/PROJECT_REFERENCE.md` (single source of truth) and `.cursor/rules` fully before doing anything. Execute PHASE 1 ONLY: confirm the Figma MCP connection, respect the Figma call budget, fill the screen inventory (node ids, components, navigation, every tappable element with a proposed action), design tokens, frame size and fonts, and map each Figma field to a DummyJSON field, marking fields the API lacks. Write no Dart code, don't commit, stop and wait for my approval.

**Every later phase:**

> Read `docs/PROJECT_REFERENCE.md` and `.cursor/rules`. Execute ONLY Phase N exactly as defined in §7. Follow the UI ↔ backend wiring recipe in §4.4. Respect approved decisions and ask before deviating. Finish with `flutter analyze` (0 issues), `flutter test` (all green), update the progress and AI usage logs, and propose commit messages. Don't commit or push unless I say so.

**Feature prompts (examples):**

- "Implement the Home screen from Figma `1:4426` with its own domain and data layers; use saved data when the request fails or there's no internet."
- "Search: paged results, 300 ms debounce, at least 2 characters, cache per query, cancel stale requests."
- "Build the Filter sheet and open it from the filter icon in Explore. Decide the backend interaction and record it in the reference."
- "Apply the Profile design with the recorded decisions; the Language row must switch the language instantly."
- "After the features are done, audit every file against the assessment requirements, fix what's missing, and write the README in English."

The quotes above are short summaries of longer briefs, not verbatim prompts.

**Who decided what (search cache, pagination, connectivity):** the full records, with code paths and tests, are in [`docs/PROJECT_REFERENCE.md` §4.9](docs/PROJECT_REFERENCE.md#49-decision-records-search-pagination-connectivity).

- **My requirements:**
  - Search: a 2-character minimum, a configurable debounce of about 300 ms, normalized queries, a late "ca" response never replacing "car", and a session cache per query that keeps loaded pages, caches empty results and never caches errors.
  - Paged, lazy-loaded Home listings.
  - Saved data when a request fails or there's no internet, limited to the first "All" page and the categories.
  - `connectivity_plus`, with real request failures handled separately because a connection doesn't prove internet access.
- **Agent choices:** the cache limits (20 queries, 10 minutes, least recently used evicted), lower-casing queries, the request generation counter, refreshing all loaded pages in one request, the 5-set / 10-minute memory for filtered results, and a single refresh when the device comes back online.

**Who decided what (UI/UX additions not in Figma):** see [§4.10](docs/PROJECT_REFERENCE.md#410-decision-records-uiux-additions-not-in-figma).

- **My requests:** the Details hero zoom, blur and gradient tied to the drag; a back-to-top button on Home; a clear (×) button in the search field; an appear animation for product cards with pagination; tabs that keep their scroll position and data when switching, so the product requests aren't sent again (`StatefulShellRoute.indexedStack` instead of rebuilding the screen for each tab); a search bar pinned on Explore, with pull to refresh moving only the results; a fresh shimmer while pull to refresh reloads Home and Explore, driven by the Cubit status (`loading` with the old data kept) rather than a flag in the view; a `DataSource` enum for saved (offline) data instead of a bool.
- **Agent choices:** the values (timings, sizes, thresholds), blurring the hero as it scrolls away rather than while pulling, so the zoomed photo stays sharp, and keeping background refreshes (stale cache, reconnect) free of skeletons.

## 4. How the output was verified

- **Static analysis:** `flutter analyze` had to report 0 issues at the end of every task.
- **Automated tests:** every task ended with the full suite green. Data-layer tests run through the real `DioClient` over a fake HTTP adapter; widgets are tested in English and Arabic, on 320–768 px wide screens, at text scale 1.0 and 1.3, and fail on any overflow.
- **Live API checks:** DummyJSON behavior was verified with `curl` before designing around it (for example: search ignores `category`, there are no price parameters, `limit=0` returns everything, 47 % of products have no `brand`). Test fixtures were captured from real responses.
- **Design checks:** values were traced to Figma MCP output; temporary real-font renders of screens in both languages were compared with Figma screenshots, then deleted.
- **Source reading:** when behavior was unclear, the agent read the package source in the pub cache (easy_localization plural handling, go_router initial location, flutter_svg cache keys, `SliverAppBar` stretch).
- **Running the app:** on the iOS simulator, including timed screenshots to investigate the splash logo bug.
- **Architecture checks:** code searches confirmed that the domain layer has no Flutter/Dio/storage imports and that each storage key has one owner.

## 5. AI output that was modified or rejected

| What the AI produced or proposed | What I did and why |
| --- | --- |
| Project rules copied from another project (Laravel backend paths, Firebase, 5 locales with a Dutch fallback, a 360×800 design size) | **Rejected.** They didn't match this assessment; the rules were rewritten for this stack and the Figma frame size (430×932) |
| The Figma "colors" spec frame as the color source (every swatch labeled "Voog blue #443DF6") | **Rejected.** It contradicts the `#0061FF` actually used on the screens; colors were taken from the screens and named variables |
| A generated button shadow `rgba(112,79,56,.25)` from the Figma code export | **Rejected** in favor of the named Figma variable `Button/Shadow 1` (`#246BFD` 25 %) |
| The claim (in an early draft of the reference) that Rubik has no Arabic glyphs | **Rejected** after parsing the font file: Rubik has full Arabic coverage, so one font is used for both languages |
| Showing product `stock` / `weight` as bedrooms or area | **Rejected.** That would present unrelated data as real-estate facts; the stats row uses clearly marked mock values instead |
| An Auth collage rebuilt from 12 tiles and crop factors in code | **Rejected by me** as over-engineered for static artwork. The agent then **rejected my SVG export** (7.6 MB of base64 JPEGs, no real vectors) and we kept one 128 KB WebP image |
| An Arabic-character regex to decide when to drop letter spacing | **Modified by me** to a simpler check of the current locale |
| Translations with `'key'.tr()` | **Modified** to `context.tr(key)` after a test showed titles on kept-alive tabs didn't update when the language changed |
| easy_localization's default plural handling | **Fixed** (`ignorePluralRules: false`) after tests showed Arabic counts used the wrong grammatical form |
| Passing Dio's `CancelToken` through the domain layer | **Rejected.** A pure-Dart `CancellationSignal` keeps the domain free of Dio |
| A linear price scale for the filter histogram | **Rejected.** DummyJSON prices are heavily skewed, so a log scale is used |
| `Future.delayed` for the card entrance stagger | **Rejected.** Pending timers can't be cancelled; the delay is part of the animation curve instead |
| Node ids the agent wrote into comments without checking them | **Rejected** and replaced with verified ids |

**Bugs found during AI-assisted review and testing, fixed in the code** (never by weakening a test): the filter sheet opening under the bottom navigation bar, an off-center sheet header, a button that grew to full height and would have hidden the Details body, and a heart button invisible to screen readers (all found by tests); `NaN`/`Infinity` values crashing JSON parsing (found by code review); and the splash logo appearing late in debug builds (found by timed simulator screenshots).

## 6. Responsibility

I reviewed the delivered code and am responsible for it. I can walk through any file, explain why each decision was made (the reasoning is recorded in `docs/PROJECT_REFERENCE.md`), and change it during a technical discussion.
