# M-PESA Sign-In — Mobile Developer Technical Exam

A Flutter recreation of the M-PESA sign-in flow: **Splash → PIN sign-in → Home dashboard**,
integrated with the provided mock login API and built on **Clean Architecture + BLoC**.

Brand primary colour: `#FE0000` · `rgb(254, 0, 0)` · Tailwind `red-600`.

---

## How to run

```bash
flutter pub get

# Run on a device / emulator / browser
flutter run                    # pick a target when prompted
flutter run -d chrome          # web
flutter run -d linux           # desktop

# Quality gates
flutter analyze                # static analysis — expected: "No issues found!"
flutter test                   # unit + bloc + widget tests — 23 tests, all green
```

**Requirements:** Flutter `3.35.x` (Dart `3.9.x`). No secrets or `.env` needed — the mock
API base URL is compiled in at `lib/core/constants/api_constants.dart`.

**Test credentials:** PIN `1111` → successful login. Any other 4-digit PIN → the API's
`404 / USER_NOT_FOUND` path, which the UI surfaces inline.

---

## Architecture used and why

**Clean Architecture (Uncle Bob), feature-first, three layers per feature.**

```
lib/
├── core/                       # cross-cutting, feature-agnostic
│   ├── constants/              # API endpoints, user-facing strings
│   ├── di/                     # get_it service locator (composition root)
│   ├── error/                  # Failure hierarchy + data-layer Exception taxonomy
│   ├── network/                # ApiClient (http wrapper), NetworkInfo
│   ├── theme/                  # brand colours + Material 3 theme
│   ├── usecases/               # UseCase<T, Params> contract
│   └── utils/                  # Validators, Formatters (pure, framework-free)
└── features/
    ├── auth/
    │   ├── domain/             # entities · repository interface · use cases   (no Flutter, no http)
    │   ├── data/               # models (JSON) · datasources · repository impl
    │   └── presentation/       # AuthBloc · SplashPage · SignInPage · PinInput
    └── home/
        ├── domain/  ·  data/  ·  presentation/   (HomeBloc, HomePage, widgets)
```

**Dependency rule:** source dependencies point inward only.
`presentation → domain ← data`. The domain layer imports nothing from Flutter, `http`,
or any package except `dartz`/`equatable`. Concrete implementations are bound to
interfaces exclusively in `core/di/injection_container.dart`.

**Why this architecture for this exam:**

- **Testability** — business rules (PIN validation, error mapping, state transitions)
  are tested with plain Dart unit tests and `bloc_test`, no widget pumping required.
  23 tests run in ~8s.
- **Swappability** — the API only exposes `login`. Interfaces (`AuthLocalDataSource`,
  `HomeRepository`, `NetworkInfo`) mean the in-memory session cache can become
  `flutter_secure_storage`, and the seeded activity feed can become a real endpoint,
  without touching the BLoC or a single widget.
- **Explicit error contract** — datasources throw `ServerException / NetworkException /
  ParsingException`; repositories catch these and return `Either<Failure, T>` (dartz).
  Presentation code never sees an exception — it pattern-matches on `Failure`.
- **Scales to a team** — feature-first folders keep a feature's domain/data/presentation
  together, so two people can work on `auth` and `home` with minimal merge surface.

**State management: `flutter_bloc` (BLoC + Cubit-style state).**

- Chosen over Riverpod/Provider/GetX because BLoC is the most widely adopted pattern in
  **enterprise Flutter**: explicit `Event → State` transitions, an auditable state
  machine, first-class testing via `bloc_test`, and strong tooling (`bloc` DevTools,
  observers). It pairs naturally with Clean Architecture — a BLoC depends on use cases,
  nothing else.
- `AuthBloc` owns the whole sign-in state machine: live PIN validation
  (`AuthPinChanged`), submission (`AuthLoginSubmitted` → `loading` → `authenticated` /
  `failure`), and `AuthLogoutRequested`. State is a single immutable `AuthState` with a
  `copyWith` that supports nullable overrides.
- `HomeBloc` loads the recent-activity feed (`HomeStarted` / `HomeRefreshed`) with
  `loading / success / failure` states and retry.

---

## Packages used and why

| Package | Layer | Why |
|---|---|---|
| **flutter_bloc** `^8.1.6` | presentation | Enterprise-standard state management; testable, explicit, well-tooled. |
| **equatable** `^2.0.5` | all | Value equality for entities, states and events → correct BLoC rebuild/dedupe and clean test assertions. |
| **dartz** `^0.10.1` | domain/data | `Either<Failure, T>` — makes the success/failure contract explicit in the type system; no throwing across layers. |
| **get_it** `^7.7.0` | core/di | Lightweight service locator for the composition root. Compile-time-safe enough, zero codegen, easy to reset in tests (`sl.reset()`). |
| **http** `^1.6.0` | core/network | Minimal, official HTTP client. A hand-rolled `ApiClient` wrapper centralises timeout, JSON decoding and the exception taxonomy — no need for a heavier client here. |
| **iconsax** `^0.0.8` | presentation | Required by the brief. Used for every icon (splash wallet mark, lock, eye toggle, arrows, bottom-nav, quick actions). |
| **cupertino_icons** | presentation | Flutter default; retained. |

**Dev / test**

| Package | Why |
|---|---|
| **bloc_test** `^9.1.7` | Declarative `blocTest(...)` for `AuthBloc` / state-transition assertions. |
| **mocktail** `^1.0.4` | Null-safe mocking with no codegen — mocks repositories, datasources, use cases, `NetworkInfo`. |
| **flutter_lints** `^5.0.0` | Recommended lint set; project passes `flutter analyze` with zero issues. |
| `package:http/testing.dart` `MockClient` | Stubs HTTP at the boundary so widget tests exercise the real BLoC → use case → repository → datasource chain without a network. |

---

## Important technical decisions and why

1. **The "OTP" screen is a PIN screen.** The provided API authenticates with `{ "pin": "1111" }`
   and returns the user + token directly — there is no OTP/SMS step. The screen is a
   4-digit PIN entry (`PinInput`) that auto-submits on the 4th digit.

2. **Validation lives in the domain, not only the widget.** `Validators.pin()` is a pure
   function reused by the widget layer, `AuthBloc`, and `LoginUseCase`. `LoginUseCase`
   returns `ValidationFailure` **without hitting the repository** for a malformed PIN —
   the business rule is enforced regardless of caller and is unit-tested.

3. **Three-state loading/error handling, everywhere.**
   - *Sign-in:* button is disabled until the PIN is valid; shows an inline spinner during
     the request; on failure the PIN field clears and the message renders inline with an
     `Iconsax.info_circle`. On success, a fade transition to `HomePage`.
   - *Home feed:* `loading` spinner → `success` list / empty state → `failure` with a
     Retry button. Pull-to-refresh wired to `HomeRefreshed`.

4. **Exception → Failure mapping at the repository boundary.** `ApiClient` throws
   `ServerException` (carrying the API's `error.code`), `NetworkException` (timeout /
   `ClientException`), or `ParsingException` (bad JSON). `AuthRepositoryImpl` maps each
   to the corresponding `Failure` with a user-safe message. A pre-flight `NetworkInfo`
   check short-circuits to `NetworkFailure` when offline (assumed online on web, where
   `InternetAddress.lookup` is unsupported — the HTTP call then surfaces the real error).

5. **Session is an interface-backed in-memory cache.** `AuthLocalDataSource` holds the
   `AuthSession` for the process lifetime; `HomePage` reads the signed-in `User` from
   `AuthRepository.currentSession`. Swapping in `flutter_secure_storage` for persistence
   is a one-class change.

6. **`copyWith` with nullable-setter closures.** `AuthState.copyWith` takes
   `String? Function()?` for nullable fields so callers can *explicitly clear*
   `pinError` / `errorMessage` (pass `() => null`) versus *leave unchanged* (omit) —
   a common BLoC pitfall handled deliberately.

7. **Inline PIN error is suppressed mid-entry.** `AuthBloc` only surfaces
   `pinError` once the field reaches full length, so the user isn't shown
   "PIN must be exactly 4 digits" while they're still on digit 2.

8. **Brand theming is centralised.** `AppColors` defines `#FE0000` once;
   `AppTheme.light` seeds a Material 3 `ColorScheme` from it and styles buttons, inputs
   (incl. error borders), progress indicators, text selection and the app bar. No
   hard-coded colours in feature widgets.

9. **`main()` is async.** `WidgetsFlutterBinding.ensureInitialized()` →
   `di.initDependencies()` → `runApp`, so the object graph is fully wired before the
   first frame.

---

## AI tools used and how

- **Claude (Claude Code / Sonnet)** — used as a pair-programmer throughout:
  - Scaffolded the Clean Architecture folder structure and the layer boundaries
    (entities / repository interfaces / use cases / datasources / models / blocs).
  - Generated the boilerplate-heavy pieces: `Failure`/`Exception` hierarchies,
    `UseCase` contract, `copyWith` implementations, `get_it` registrations, JSON
    `fromJson`/`toJson`, and the BLoC `event`/`state` `part` files.
  - Wrote the first draft of the test suite (validator unit tests, `LoginUseCase` tests,
    `AuthRepositoryImpl` exception-mapping tests, `bloc_test` cases, and the
    `MockClient`-backed widget tests), which were then iterated on against real
    `flutter test` runs until green.
  - Built the UI widgets (splash, `PinInput`, sign-in page, home header / balance card /
    quick actions / transaction tile) to match the M-PESA design, then swapped all icons
    to `iconsax`.
  - Every AI-produced change was verified locally with `flutter analyze` (zero issues)
    and `flutter test` (23 passing) before committing.

---

## Test coverage summary

```
test/core/utils/validators_test.dart .......................  PIN validation rules
test/features/auth/domain/usecases/login_usecase_test.dart ..  validation short-circuit, delegation, failure passthrough
test/features/auth/data/repositories/
        auth_repository_impl_test.dart .....................  offline guard, caching, Exception→Failure mapping
test/features/auth/presentation/bloc/auth_bloc_test.dart ....  PIN-changed, submit success/failure, invalid-PIN guard, logout
test/features/auth/presentation/pages/sign_in_page_test.dart   button-enabled gating, loader, navigation, API error, network error, PinInput.clear
```

Run: `flutter test` → **+23  All tests passed!**
