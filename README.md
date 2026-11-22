# YOU&ME

A private space for two. YOU&ME is an original Flutter couple app for sharing the small things that keep you close: plans, moods, letters, goals, photos, conversations, and the everyday split of chores.

- **Package / bundle:** `com.youandme.app`
- **Stack:** Flutter (stable) · Dart 3 · Material 3 · Riverpod · GoRouter
- **Backend:** Firebase-ready (anonymous auth + Firestore + Storage + Messaging), with an offline **Demo Mode** that runs before Firebase is configured
- **Platforms:** Android, iOS, Web

## Features

1. **Shared bucket list + date ideas** — categories, completion, and a “surprise date” picker.
2. **Daily check-in + mood pulse** — one-tap mood, note, partner mood, streak, and a 14-day history strip.
3. **Time capsule letters** — write now, lock until a date, countdown, open together.
4. **Kindness coupons** — seeded and custom coupons, redeem with confirmation, history.
5. **Shared goals + savings** — target amount, contributions, progress, deadlines.
6. **Photo challenges** — weekly prompts, custom prompts, camera/gallery, shared album.
7. **Deep-talk prompt cards** — shuffle a prompt, save an answer, revisit your conversations.
8. **Chores + errands** — assign to you, your partner, or both; due dates and fairness stats.

Plus first-run setup with **no login**: create a space, share a **6-digit PIN**, and pair. Settings include profile name, theme, PIN sharing, and leaving a space.

## Run it

```bash
flutter pub get
flutter run -d chrome      # web
flutter run                # connected Android/iOS device or emulator
```

The app starts in **Demo Mode** when Firebase is not configured. Demo Mode stores everything locally with `shared_preferences`, seeds a populated space, and simulates a partner so every feature can be explored immediately.

## Firebase

See [`docs/FIREBASE_SETUP.md`](docs/FIREBASE_SETUP.md). Once `flutterfire configure` generates `lib/firebase_options.dart` with real values, the app automatically switches to Firebase.

- Data model: [`docs/FIRESTORE_SCHEMA.md`](docs/FIRESTORE_SCHEMA.md)
- Rules: [`docs/SECURITY_RULES.md`](docs/SECURITY_RULES.md), [`firestore.rules`](firestore.rules), [`storage.rules`](storage.rules)

## Verify

```bash
flutter analyze
flutter test
flutter build web
```

> **Android builds and the `&` path:** Gradle builds fail when the project path contains `&` (the Flutter tool splits `E:\U&ME` when invoking Gradle). For Android, copy or move the project to a path such as `C:\dev\you_and_me` and run `flutter build apk --debug` there. Web, tests, and analysis are unaffected.

## Project layout

```
lib/
  core/        theme, router, shared widgets, utils
  data/        models, seed content, backend interface + demo/Firebase implementations
  features/    home, plans, connect, album, more, and each feature screen
  state/       session, data providers, theme mode
test/          model, demo backend, and widget smoke tests
docs/          Firebase setup, schema, rules, feature guide
```

## Design system & art

- **Redesign guide:** [`docs/UI_REDESIGN.md`](UI_REDESIGN.md) — audit, new visual system, component upgrades, screen-by-screen map, and a 12-rule simplicity checklist.
- **Asset pack:** [`docs/asset_sheet.png`](asset_sheet.png) previews every illustration. Art lives in `assets/brand/` (icon, mark, notification silhouette) and `assets/illustrations/` (mascots, splash scene, feature spot art, empty state).
- **In code:** `lib/core/widgets/app_illustration.dart` exposes `AppArt`, `AppIllustration`, and `IllustrationTile` so screens never hardcode asset paths.

The art direction is *soft-clay kawaii*: a pink heart and a lilac bun as the mascot pair, chunky rounded volumes, and the existing pink/coral/peach palette.

## Design & IP

YOU&ME is an original app. It is inspired by the *design language* recovered from a reference app, but contains no reference-app code, assets, copy, or backend. Brand artwork lives in `assets/brand/` and can be replaced with your own.
