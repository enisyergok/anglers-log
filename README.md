# Anglers' Log

Anglers' Log is a fishing journal app for tracking, analyzing, and sharing your
catches. This repository contains three related projects:

| Directory | What it is |
|---|---|
| [`mobile/`](mobile) | The Flutter app (Android/iOS) — the main product. |
| [`web/`](web) | The AngularJS + Bootstrap marketing/support site at [anglerslog.ca](http://anglerslog.ca). |
| [`polls/`](polls) | JSON data files used to drive in-app polls. |

This fork is maintained at [enisyergok/anglers-log](https://github.com/enisyergok/anglers-log)
and is based on the original project by [Cohen Adair](#credits--license).

## Contents

- [Architecture](#architecture)
- [Mobile app setup](#mobile-app-setup)
- [Running the app](#running-the-app)
- [Testing](#testing)
- [Localization](#localization)
- [Web site](#web-site)
- [CI/CD](#cicd)
- [Known setup caveats](#known-setup-caveats)
- [Credits & license](#credits--license)

## Architecture

The mobile app is organized around a few core patterns worth knowing before
you dig into the code:

- **Service locator** — `AppManager` is a singleton that wires up and exposes
  every manager/service in the app (database, preferences, location, etc.).
- **Entity managers** — Most data types (catches, trips, species, bait, ...)
  are managed by a subclass of `EntityManager<T extends GeneratedMessage>`,
  which provides CRUD operations and a `Stream`-based change-notification API
  over entities stored in SQLite.
- **Protocol Buffers** — Entities are defined as `.proto` messages and
  serialized with the `protobuf` package. Generated Dart code lives in
  `mobile/lib/model/gen/` and is **not** meant to be edited by hand — see
  [Regenerating protobuf code](#regenerating-protobuf-code).
  `mobile/lib/database/legacy_importer.dart` provides an import path for
  pre-2.0 JSON/zip backups.

## Mobile app setup

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) matching
  `environment.sdk: ^3.10.0` in `mobile/pubspec.yaml`.
- Android Studio and/or Xcode, depending on which platform(s) you're building
  for.

### 1. Clone `adair-flutter-lib` as a sibling directory

`mobile/pubspec.yaml` depends on a shared library via a relative path:

```yaml
adair_flutter_lib:
  path: ../../adair-flutter-lib
```

This resolves to a directory **two levels above `mobile/`** — i.e. a sibling
of this repository, not something inside it. Clone it next to this repo
before running `flutter pub get`:

```
some-parent-folder/
├── anglers-log/              <- this repo
└── adair-flutter-lib/        <- clone this here
```

```bash
git clone https://github.com/cohenadair/adair-flutter-lib.git
```

This mirrors what the project's own CI does (see
[`.github/workflows/build-apk.yml`](.github/workflows/build-apk.yml)).

### 2. Add API keys

The app calls out to several third-party services (VisualCrossing weather,
WorldTides, Firebase, SendGrid) using keys read from
`mobile/assets/sensitive.properties`. This file is gitignored and not included
in the repo — you'll need to create it yourself with your own keys before the
app will build with those features working:

```properties
# mobile/assets/sensitive.properties
visualCrossing.apiKey=...
worldTides.apiKey=...
firebase.secret=...
```

These dot-notation names come from `mobile/lib/properties_manager.dart`,
which wraps `adair_flutter_lib`'s `PropertiesManager` and is the single
source of truth for what key each fetcher reads (e.g.
`mobile/lib/atmosphere_fetcher.dart` for `visualCrossing.apiKey`,
`mobile/lib/tide_fetcher.dart` for `worldTides.apiKey`). The map no longer
requires an API key — it's rendered with `flutter_map` using free, keyless
tile sources (standard OpenStreetMap, CARTO Dark Matter, and Esri World
Imagery), with offline tile caching handled by `flutter_map_tile_caching`.

Firebase (Analytics/Crashlytics) also expects standard `google-services.json`
(Android) / `GoogleService-Info.plist` (iOS) config files, which aren't
included here either.

### 3. Install dependencies

```bash
cd mobile
flutter pub get
```

## Running the app

```bash
cd mobile
flutter run
```

## Testing

```bash
cd mobile
./run_tests.sh
```

> **Caveat:** `run_tests.sh` delegates to `../../run_tests.sh` — a script
> expected two directories above `mobile/`, outside this repository entirely.
> This script is not included here and isn't resolved by CI either. Until you
> have it, run tests directly instead:
> ```bash
> flutter test
> ```

### Regenerating mocks

If you change an interface that's mocked in tests:

```bash
cd mobile
./gen_mocks.sh
```

### Regenerating protobuf code

If you change a `.proto` file under `mobile/protobuf/`:

```bash
cd mobile/protobuf
./gen.sh
```

> **Caveat (macOS/Linux):** `gen.sh` uses `sed -i ''` (BSD/macOS syntax). On
> Linux (including most CI runners) this fails — use `sed -i` (no empty
> argument) on GNU sed instead.

### Static analysis

`mobile/analysis_options.yaml` includes `../../analysis_options.yaml`, an
external file not present in this repository. `flutter analyze` will fail to
find it unless you provide one at that path (two directories above `mobile/`)
or replace the `include:` with local rules.

## Localization

Strings are managed via ARB files and `flutter_localizations`, configured in
[`mobile/l10n.yaml`](mobile/l10n.yaml):

- Source strings: `mobile/lib/l10n/localizations_en.arb`
- Generated output: `mobile/lib/l10n/gen/` (class `AnglersLogLocalizations`)

Generation happens automatically as part of `flutter pub get` / `flutter run`
via Flutter's `gen-l10n` tool. To add a string, add it to
`localizations_en.arb` (and translated ARB files) and reference it through
`AnglersLogLocalizations.of(context)`.

## Web site

See [`web/README.md`](web/README.md) for setting up and deploying the
marketing/support site independently of the mobile app.

## CI/CD

[`.github/workflows/build-apk.yml`](.github/workflows/build-apk.yml) builds a
release APK on GitHub Actions. It:

1. Checks out this repo and clones `adair-flutter-lib` as a sibling directory.
2. Writes a dummy `sensitive.properties` (the release build doesn't need real
   third-party keys to compile).
3. Reconstructs the Android release-signing keystore from GitHub Secrets
   (`ANDROID_KEYSTORE_BASE64`, `ANDROID_STORE_PASSWORD`, `ANDROID_KEY_ALIAS`,
   `ANDROID_KEY_PASSWORD`).
4. Sets up Java 17 (Zulu) and the stable Flutter channel.
5. Runs `flutter pub get` and `flutter build apk --release`.
6. Uploads the resulting APK as a build artifact (`anglers-log-pro-apk`).

## Known setup caveats

A few things in this repo assume files or directories that live outside it —
worth knowing up front rather than discovering via a failed build:

- `mobile/pubspec.yaml` → `adair_flutter_lib` expects a sibling checkout at
  `../../adair-flutter-lib` ([step 1 above](#1-clone-adair-flutter-lib-as-a-sibling-directory)).
- `mobile/run_tests.sh` → delegates to `../../run_tests.sh`, not present in
  this repo or resolved by CI. Use `flutter test` directly instead.
- `mobile/analysis_options.yaml` → includes `../../analysis_options.yaml`,
  not present in this repo or resolved by CI.
- `mobile/assets/sensitive.properties` → gitignored; you must supply your own
  API keys to exercise weather/tides/maps features locally.

## Credits & license

Anglers' Log was created by [Cohen Adair](https://github.com/cohenadair)
([LinkedIn](https://www.linkedin.com/in/cohenadair/),
[Facebook](https://www.facebook.com/anglerslog)). This repository is a fork
of the original [cohenadair/anglers-log](https://github.com/cohenadair/anglers-log)
project, maintained here under the terms of its license.

If you build on this project, please don't redistribute it — or a
lightly-modified version of it — under a different name. It represents a
significant amount of original work; publishing a clone as your own isn't
fair to that effort. Contributions and forks for personal/learning use are
welcome and appreciated.

Licensed under the terms in [`LICENSE`](LICENSE) (GPL). See that file for
the full license text.
