# M-PESA Sign-In — Mobile Developer Technical Exam

A Flutter recreation of the M-PESA sign-in flow — **Splash → 4-digit PIN sign-in →
Home dashboard** — integrated with the provided mock login API and built on
**Clean Architecture + BLoC**.

Brand primary colour: `#FE0000` · `rgb(254, 0, 0)` · Tailwind `red-600`.

---

## How to run

```bash
flutter pub get

# Run on a device / emulator (developed and tested on a physical Android phone)
flutter run

# Quality gates
flutter analyze     # static analysis — "No issues found!"
flutter test        # unit + bloc + widget tests — 24 tests, all green
```

**Requirements:** Flutter `3.35.x` (Dart `3.9.x`). No `.env` or secrets — the mock API
base URL is compiled in at [`lib/core/constants/api_constants.dart`](lib/core/constants/api_constants.dart).

**Test credentials:** PIN `1111` → successful login. Any other 4-digit PIN → the API's
`404 / USER_NOT_FOUND` response, surfaced inline on the PIN screen.

**Assets:** `assets/images/logo.png` (white M-PESA wordmark) and
`assets/images/pattern.png` (decorative header background) are bundled via `pubspec.yaml`.

---

## Architecture used and why

**Clean Architecture (Uncle Bob), feature-first, three layers per feature.**

```
lib/
├── core/                       # cross-cutting, feature-agnostic
│   ├── constants/              # API endpoints, strings, asset paths
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
    │   └── presentation/       # AuthBloc · SplashPage · SignInPage · widgets
    └── home/
        ├── domain/  ·  data/  ·  presentation/   (HomeBloc, HomePage, widgets)
```

**Dependency rule** — source dependencies point inward only:
`presentation → domain ← data`. The `domain` layer imports nothing from Flutter, `http`,
or any package except `dartz` / `equatable`. Concrete classes are bound to their
interfaces in exactly one place — [`core/di/injection_container.dart`](lib/core/di/injection_container.dart).

### Why this architecture, for this exam

| Reason | How it shows up here |
|---|---|
| **Testability** | Business rules — PIN validation, `Exception → Failure` mapping, BLoC state transitions — are covered by plain-Dart unit tests and `bloc_test`, no widget pumping. 24 tests run in ~8 s. |
| **Swappability** | The API only exposes `login`. Interfaces (`AuthLocalDataSource`, `HomeRepository`, `NetworkInfo`) mean the in-memory session cache can become `flutter_secure_storage`, and the seeded transactions feed can become a real endpoint, without touching a BLoC or a widget. |
| **Explicit error contract** | Datasources throw `ServerException` / `NetworkException` / `ParsingException`; repositories catch these and return `Either<Failure, T>`. Presentation code never sees an exception — it pattern-matches on `Failure`. |
| **Team scale** | Feature-first folders keep a feature's `domain` / `data` / `presentation` together, so `auth` and `home` can be worked on with minimal merge surface. |

---

## State management used and why

**`flutter_bloc` — BLoC + immutable state.**

Chosen over Riverpod / Provider / GetX because BLoC is the most widely adopted pattern
in **enterprise Flutter**: an explicit `Event → State` machine that is auditable, first
class to test (`bloc_test`), and has strong tooling (`bloc` observers / DevTools). It
layers cleanly onto Clean Architecture — a BLoC depends on use cases and nothing else.

- **`AuthBloc`** owns the entire sign-in state machine:
  - `AuthPinChanged` — live validation as digits are tapped; `isPinValid` drives the
    Continue button; inline errors stay quiet until the field is full.
  - `AuthLoginSubmitted` — `loading → authenticated` / `failure`; on `failure` the PIN
    is cleared for re-entry and the message is surfaced.
  - `AuthLogoutRequested` — resets to the initial state.
  - State is a single immutable `AuthState` with a `copyWith` that supports **explicit
    nulling** of `pinError` / `errorMessage` (via `String? Function()?` setters) — a
    common BLoC pitfall handled deliberately.
- **`HomeBloc`** loads the transactions feed (`HomeStarted` / `HomeRefreshed`) with
  `loading / success / failure` states, retry, and pull-to-refresh.

---

## Packages used and why

### Runtime

| Package | Version | Why this one |
|---|---|---|
| **flutter_bloc** | `^8.1.6` | Enterprise-standard state management. Explicit events/states, an auditable state machine, excellent test story, mature tooling. Depends only on use cases, so it fits the Clean-Architecture boundary exactly. |
| **equatable** | `^2.0.5` | Value equality for entities, BLoC events and states. Without it every `AuthState` is a new identity and `BlocBuilder` / `bloc_test` can't tell "changed" from "same"; with it, rebuilds are minimal and test assertions are clean. |
| **dartz** | `^0.10.1` | Provides `Either<Failure, T>`. Makes the success/failure outcome part of the **type signature** of every repository and use case, so error handling can't be silently forgotten and no exception is thrown across a layer boundary. |
| **get_it** | `^7.7.0` | Lightweight service locator for the composition root. Wires the dependency graph (`ApiClient → datasource → repository → use case → BLoC`) in one file, needs no code generation, and `sl.reset()` makes it trivial to re-wire with mocks in tests. |
| **http** | `^1.6.0` | The minimal, official HTTP client. A single mock endpoint doesn't justify a heavier client; a thin `ApiClient` wrapper centralises timeout, JSON decoding and the exception taxonomy. `package:http/testing.dart`'s `MockClient` lets widget tests exercise the real BLoC → repository → datasource chain with no network. |
| **iconsax** | `^0.0.8` | Required by the brief. Used for every icon in the app — lock, eye toggle, keypad backspace, notification bell, add-money `+`, scan FAB, service tiles, footer links. |
| **cupertino_icons** | `^1.0.8` | Flutter template default; retained for iOS-style glyph availability. |

### Dev / test

| Package | Version | Why this one |
|---|---|---|
| **bloc_test** | `^9.1.7` | Declarative `blocTest(...)` — seed a state, dispatch an event, assert the exact emitted sequence. Turns each `AuthBloc` transition into a one-block, readable test. |
| **mocktail** | `^1.0.4` | Null-safe mocking with **no code generation**. Mocks repositories, datasources, use cases and `NetworkInfo` directly; `registerFallbackValue` handles non-primitive matchers. |
| **flutter_lints** | `^5.0.0` | The recommended lint set. The project passes `flutter analyze` with zero issues. |

---

## Important technical decisions and why

1. **The "OTP" screen is a PIN screen.** The API authenticates with `{ "pin": "1111" }`
   and returns the user + token directly — there is no SMS/OTP step. The screen is a
   4-digit PIN entry that auto-submits on the 4th digit.

2. **Custom on-screen numeric keypad.** The PIN boxes are display-only; a bespoke
   `NumberKeypad` (`1 2 3 / 4 5 6 / 7 8 9 / 0 ⌫`, white background) replaces the OS
   keyboard, matching the design and keeping the layout stable.

3. **Validation lives in the domain.** `Validators.pin()` is a pure function reused by
   the widget layer, `AuthBloc`, and `LoginUseCase`. `LoginUseCase` returns
   `ValidationFailure` **without calling the repository** for a malformed PIN — the rule
   is enforced regardless of caller and is unit-tested.

4. **Three-state loading/error handling, everywhere.**
   - *Sign-in:* Continue is disabled until the PIN is valid → inline spinner during the
     request → on failure the PIN clears and the message renders inline with an
     `Iconsax.info_circle` → on success a fade transition to `HomePage`.
   - *Home feed:* `loading` spinner → `success` list / empty state → `failure` with a
     Retry button. Pull-to-refresh wired to `HomeRefreshed`.

5. **`Exception → Failure` mapping at the repository boundary.** `ApiClient` throws
   `ServerException` (carrying the API's `error.code`), `NetworkException` (timeout /
   `ClientException`), or `ParsingException` (bad JSON). `AuthRepositoryImpl` maps each
   to the matching `Failure` with a user-safe message. A pre-flight `NetworkInfo` check
   short-circuits to `NetworkFailure` when offline (assumed online on platforms where
   `InternetAddress.lookup` is unsupported — the HTTP call then surfaces the real error).

6. **Session as an interface-backed in-memory cache.** `AuthLocalDataSource` holds the
   `AuthSession` for the process lifetime; `HomePage` reads the signed-in `User` from
   `AuthRepository.currentSession`. Swapping in persistent secure storage is a
   one-class change.

7. **`copyWith` with nullable-setter closures.** `AuthState.copyWith` takes
   `String? Function()?` for nullable fields so a caller can *explicitly clear*
   `pinError` / `errorMessage` (`() => null`) versus *leave unchanged* (omit).

8. **Centralised brand theming.** `AppColors` defines `#FE0000` once; `AppTheme.light`
   seeds a Material 3 `ColorScheme` from it and styles buttons, inputs (incl. error
   borders), progress indicators, text selection and the app bar. No hard-coded colours
   in feature widgets.

9. **`main()` is async.** `WidgetsFlutterBinding.ensureInitialized()` →
   `di.initDependencies()` → `runApp`, so the object graph is fully wired before the
   first frame.

10. **Home screen has no bottom navigation bar** (per the design) — a single scrolling
    surface with a scan FAB. Header greeting + first name with a bell; a primary-red
    wallet card (Main Balance hidden by default, `+ Add Money`, Reward / Erif balance,
    bottom-right eye toggle); a 3×2 services card; and a transactions card with channel
    badges (CBE, M-PESA, Telebirr).

---

## AI tools used and how

- **Claude (Claude Code / Sonnet)** — used as a pair-programmer throughout:
  - Scaffolded the Clean Architecture folders and layer boundaries (entities /
    repository interfaces / use cases / datasources / models / blocs).
  - Generated boilerplate-heavy pieces: the `Failure` / `Exception` hierarchies, the
    `UseCase` contract, `copyWith` implementations, `get_it` registrations, JSON
    `fromJson` / `toJson`, and the BLoC `event` / `state` `part` files.
  - Wrote the first draft of the test suite (validator unit tests, `LoginUseCase` tests,
    `AuthRepositoryImpl` exception-mapping tests, `bloc_test` cases, and the
    `MockClient`-backed widget tests), then iterated against real `flutter test` runs
    until green.
  - Built and iterated the UI (splash, custom keypad, PIN dots, sign-in header/footer,
    home wallet / services / transactions cards) to match the M-PESA design, using
    `iconsax` for every icon.
  - Every AI-produced change was verified locally with `flutter analyze` (zero issues)
    and `flutter test` (24 passing) before committing.

---

## Test coverage summary

```
test/core/utils/validators_test.dart ........................  PIN validation rules
test/features/auth/domain/usecases/login_usecase_test.dart ..  validation short-circuit, delegation, failure passthrough
test/features/auth/data/repositories/
        auth_repository_impl_test.dart .....................  offline guard, caching, Exception→Failure mapping
test/features/auth/presentation/bloc/auth_bloc_test.dart ....  PIN-changed, submit success/failure, invalid-PIN guard, logout
test/features/auth/presentation/pages/sign_in_page_test.dart   keypad + header render, Continue gating, backspace, loader,
                                                              navigation, API error + PIN reset, network error
```

Run: `flutter test` → **+24  All tests passed!**

---

## Git

Public repository: **https://github.com/Hailemariyam/Hailemariyam-Kebede**
(branch `main`).
