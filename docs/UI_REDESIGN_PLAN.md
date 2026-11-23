# UI Redesign — Implementation Plan & Tracker

Last updated: 2026-11-22 22:40
Status: Phases 0–3 complete. Analyze clean, 21/21 tests pass, debug APK built
with SDK 37. On-device install and light/dark screenshots are blocked until an
Android device or AVD is available.
Source of truth for design intent: `docs/UI_REDESIGN.md`.
This file is the working tracker: update checkboxes and notes as work lands.

---

## Goal

Rebuild the YOU&ME UI into a soft-clay kawaii experience that feels professional,
cute, and easy for everyone. Fewer cards, shorter copy, one hero and one
illustration per screen, one accent, one shadow. Keep the existing palette and
functionality.

## Defaults / decisions

- Keep 3 tabs (Home, Connect, More); Plans is removed and its content lives in
  Home shortcuts and More rows.
- Home mood tap saves instantly; "Add a note" opens the full check-in.
- No new font dependency; rely on art, shape, spacing, and weight.
- Coupon ticket clipper is in scope; fall back to a rounded card + dashed divider
  if it causes layout problems.
- Build from `E:\Projects\you_and_me` only.
- Do not commit/push unless the user explicitly asks.

---

## Phase 0 — Design system foundation

- [x] `lib/core/theme/app_colors.dart`: add `lilac`, `peach`, `butter`, `mint`, `tile`
      (light + dark), wire into `copyWith` and `lerp`.
- [x] `lib/core/theme/app_spacing.dart`: add `AppDurations.press`, `pop`, `enter`.
- [x] `lib/core/theme/app_spacing.dart`: change `AppGradients.brand` to end at
      `tint` (`#FF7B83`) so white text passes contrast.
- [x] `lib/core/theme/app_theme.dart`: simplify type scale to 5 roles
      (display 30/w800, title 17/w700, body 14.5/w400, caption 12.5/w500,
      label 11/w700 tracking 0.4).
- [x] `lib/core/theme/app_theme.dart`: nav height 64, icon 22, selected label w700,
      softer inputs, flat card theme.
- [x] `lib/core/widgets/app_card.dart`: add `SectionCard`; make `AppCard` flat by
      default (`shadow: false`).
- [x] New `HeroCard`: brand/soft gradient, mascot overflow 8–12dp, max 220dp,
      only shadow on screen.
- [x] New `FeatureTile`: spot art + label + one caption.
- [x] New `ListRow`: no card, divider, 12dp vertical padding.
- [x] New `MoodChip`: 56dp circle, 28dp icon, label, selected `AnimatedScale` 1.08.
- [x] New `PressScale`: 0.97 tap-down feedback.
- [x] `EmptyState`: replace `IconData` with `AppArt` + 160dp scene + one sentence
      + one filled button; update 7 call sites.
- [x] `AppIllustration`: add `cacheWidth` bound (logical size x DPR); dark-mode
      opacity 0.92; keep decorative semantics default.
- [x] `SectionHeader`: optional leading `IllustrationTile`, action pill, sentence
      case, remove unnecessary subtitles.
- [x] `AppSheet`: optional 40dp art beside title for creation flows; one primary
      action.
- [x] Precache `AppArt.aboveTheFold` at startup.

---

## Phase 1 — Screen rebuilds

### Home
- [x] Blocks: hero, Live Distance card, Today, box-shaped feature grid, one nudge.
- [x] Hero: mascots overflow, "Day N" eyebrow, greeting, streak pill, slim invite.
- [x] Move DEMO badge to a thin banner under the app bar.
- [x] Today: `spot_checkin` + 5-mood row; tap saves instantly; "Add a note" link;
      partner mood inline.
- [x] Feature grid: Check-in, Bucket list, Capsules, Coupons, Goals, Album,
      Deep talk, Chores (2-up, stretch-matched rows).
- [x] Live Distance card opens the consent request flow and live map.
- [x] Nudge priority: overdue chore -> nearest capsule -> nearest goal.
- [x] Remove quick-actions grid, Next up, goals card, chore stat row, separate
      partner card, big PIN display.

### Splash
- [x] `splash_art` 240dp, 6s gentle float, wordmark 28, tagline `bodySmall`.
- [x] Faint pattern backdrop; no spinner unless boot > 600ms.

### Setup
- [x] `mascots` 140; shorter subtitle; flat `SectionCard`.
- [x] Demo row with `spot_checkin` 44 instead of bare text button.
- [x] Remove footer copy.
- [x] Keep "Create a space" / "Open the demo space" strings for tests.

### Shell
- [x] Nav height 64, icon 22, selected label w700.
- [x] Animated soft-pink selection indicator.
- [x] Keep 5 tabs.

### Plans
- [x] Removed. Date ideas live in Bucket (`Surprise date`); chores, goals, and
      deep talk are reached from the Home grid.

### Connect
- [x] Brand hero with avatars + "How are you two?".
- [x] Daily pulse as two compact cards.
- [x] Rituals use `spot_*` art.
- [x] Weekly mood strip in one flat card.
- [x] Remove duplicate bottom check-in card.

### Album
- [x] `spot_photo` 72 in "This week" header.
- [x] Empty state uses `empty_state`.
- [x] Compact challenge card; past prompts as flat rows.
- [x] Custom prompt action in app bar.

### More
- [x] Mascots profile hero with Day count and PIN / paired pills.
- [x] Grouped flat rows: Settings, Invite code, Live distance, Anniversary.
- [x] Privacy notes + demo incoming-request preview; footer mode line.

### Check-in
- [x] One row of 5 `MoodChip`s.
- [x] Tinted confirm card, no border.
- [x] Note field; streak card with mascot 56 + 14-day strip.
- [x] Partner card; heart pop on save.

### Capsules
- [x] Soft hero + `spot_capsule` 96.
- [x] Sentence-case groups; `IllustrationTile(capsules, 48)`.
- [x] Warning only when locked.
- [x] Envelope scale/fade before opening.

### Coupons
- [x] Soft hero + `spot_coupons`.
- [x] Real ticket card: two side notches + dashed divider.
- [x] Redeem becomes a filled pill; flat cards.

### Goals
- [x] Flat hero with `spot_goals` 96 and one big percentage.
- [x] Per-goal flat card with art tile + one progress bar.
- [x] Fix currency everywhere (`goal.currency`, dynamic symbol in sheets).

### Chores
- [x] Brand hero + `spot_chores` 88.
- [x] Fairness bar (You / Partner / Shared).
- [x] Heart-shaped completion; 44dp tap target.
- [x] Keep overdue `danger` pill.

### Deep talk
- [x] Soft-pink prompt card + `spot_deeptalk` 64 + plum text.
- [x] Saved reflections become `ListRow`s.
- [x] Shorter hint; no sunset gradient.

### Settings
- [x] Grouped sections: Profile / Space / Appearance / About / Leave.
- [x] Mascots 64 in profile; icon-only theme segmented control.
- [x] Keep leave-space destructive and prominent.

---

## Phase 2 — Motion, accessibility, dark mode

- [x] Press-scale on cards and big buttons.
- [x] Staggered fade+slide for first 5 list items.
- [x] Heart pop on check-in save and goal completion.
- [x] Respect `MediaQuery.disableAnimations`.
- [x] 44dp minimum tap targets (bucket/chore circles are 30dp today).
- [x] Dark mode: art on dark `softPink` tiles, no shadows, `cardAlt` flat cards.
- [x] 200% text scale: mood row and shortcut grid switch to `Wrap` when
      `textScale > 1.3`.
- [x] Verify 320dp width, light and dark (widget test covers 320dp, dark mode,
      200% text across all three tabs).

---

## Phase 3 — Tests, build, install

- [x] Update `test/widget_test.dart` (currently expects removed "Quick actions"
      and "Next up").
- [x] Keep all existing tests green (21 total, including live-session and
      responsive tests).
- [x] Run `C:\flutter\bin\flutter.bat analyze`.
- [x] Run `C:\flutter\bin\flutter.bat test`.
- [x] Install `platforms;android-37.0`; `compileSdk = 37`.
- [x] Build `flutter build apk --debug` -> 202.8 MB at 22:34.
- [ ] Install `adb install -r`, launch, screenshot light + dark.
      **Blocked:** no Android device or AVD attached (`adb devices` empty,
      `flutter emulators` finds none). APK ready at
      `build\app\outputs\flutter-apk\app-debug.apk`.
- [ ] Verify no overflow errors in logcat. **Blocked** with the same device gap;
      the 320dp/200% text widget test is the current overflow guard.

---

## Execution order

1. Foundation + Home + Splash + Setup + Shell -> analyze/test.
2. Connect + Album + More -> analyze/test.
3. Check-in + Capsules + Coupons + Goals + Chores + Deep talk + Settings ->
   analyze/test.
4. Live Distance + motion + accessibility + tests + APK build/install.

---

## Progress log

| Date | Change | Status |
|---|---|---|
| 2026-11-22 | Plan written; design guide and all screens reviewed | planned |
| 2026-11-22 | Phases 0–2 implemented: all 15 screens/widgets rebuilt, motion + a11y + dark mode, bucket/chore 44dp targets, removed unused `splash_logo.png` | done |
| 2026-11-22 | Phase 3: analyze clean, 16/16 tests pass, debug APK built; install/screenshots pending an Android device | partial |
| 2026-11-22 | Live Distance built (card, consent popup, notification actions, map, demo preview); Plans removed; shell reduced to 3 tabs; 21/21 tests pass | done |
| 2026-11-22 22:35 | SDK 37 installed; debug APK rebuilt (202.8 MB); install still blocked (no device/AVD) | done |

## Notes / risks

- Large change surface: run `flutter analyze` after each phase.
- `material_ui` package, not `flutter/material`; use existing extensions.
- Add `cacheWidth` for illustration tiles to avoid decoding 420–720px PNGs.
- Ticket clipper is the riskiest visual change; keep a fallback.
- Widget tests will need new expectations after Home is restructured.
