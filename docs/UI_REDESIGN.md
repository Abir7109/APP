# UI Redesign Guide — *Soft & Cute*

> Companion to the new artwork in `assets/brand/` and `assets/illustrations/` (12 illustrations, complete).
> Preview every asset at once: [`docs/asset_sheet.png`](asset_sheet.png).
> This document is a working plan: audit → system → component upgrades → screen-by-screen map → rollout.

---

## 0. TL;DR

The app is functionally complete but visually generic: white card, thin border, soft shadow, Material icon in a tinted square — repeated ~40 times. There is no character, so nothing feels made *for two people*.

The fix is not "more gradients". It is **one mascot pair + one illustration per screen + fewer cards + one accent colour**, with the existing palette kept intact.

Three moves carry 80% of the improvement:

1. **Give the app a face.** The pink heart and the lilac bun (`mascots.png`) become recurring characters in splash, empty states, streaks, and celebrations.
2. **Replace decorative icon soup with spot illustrations** (`spot_*.png`) — one per feature, always inside a soft-pink tile, never more than one per card.
3. **Cut the noise.** One hero per screen, one accent per screen, three type sizes per screen, and remove the duplicated navigation (Home quick actions ↔ tabs ↔ More tiles all point at the same five places).

---

## 1. Honest audit of the current UI

| # | Symptom in the code today | Why it hurts | Fix in this guide |
|---|---|---|---|
| 1 | `AppCard` is used for **everything** (`lib/core/widgets/app_card.dart`) — home stacks ~12 of them | Uniform elevation erases hierarchy; the eye has nowhere to land | Tiered containers: hero → tinted section → bare list rows (§4.2) |
| 2 | Four competing hero gradients: `AppGradients.brand`, `lilac`, `sunset`, `sunrise` across Home/Plans/Connect/Capsules/Coupons/Goals/Chores | Brand dilutes; different screens look like different apps | One gradient (`brand`) for the single hero; everything else uses `AppGradients.soft` or flat tint (§2.2) |
| 3 | White text on `#FFB199` peach (gradient ends) | ~2.1:1 contrast — unreadable in daylight | Text only on plum or primary; gradients end at `tint` (§7) |
| 4 | `SoftIcon` (44dp tinted square + Material icon) repeated in every list row | Reads as "stock Material app", not a cute one | `IllustrationTile` + `spot_*` art (§4.1) |
| 5 | Home repeats navigation three times (`_QuickTile` grid, tab bar, `MoreScreen` `_MoreTile`s) | Users don't know where "the real" entry point is | One canonical entry per feature (§6, rule 8) |
| 6 | Everything is uppercase with wide tracking (`'YOUR SPACE'`, `'DAILY PULSE'`, `'KEEP TALKING'`, `'TO DO · 3'`) | Shouty, cramped, and doesn't fit a soft brand | Lowercase/Title Case labels, tracking ≤ 0.6 (§2.3) |
| 7 | Headlines embed manual line breaks (`'Make memories,\nnot just plans.'`) | Breaks on small/large text scales | Let the layout wrap (§6, rule 10) |
| 8 | `EmptyState` is a 76dp gradient circle with a Material icon | Generic; the emptiest screens are the least charming | `empty_state.png` scene + one sentence + one button (§4.3) |
| 9 | 5-tab bar, 70dp tall, plus 4-stat chore row, plus 2-up "Next up" cards | Noisy first screen; every element shouts equally | Home rebuilt around "Today" + 3 shortcuts (§5.1) |
| 10 | Mood picker is 5 full-width stacked cards in `checkin_screen.dart` | Needs a scroll to see all five; kills comparison | One row of 5 mood chips, thumb-reachable (§5.6) |
| 11 | Money hardcodes `$` while `Goal.currency` exists | Wrong for most users | Format through `goal.currency` (§5.9) |
| 12 | No press feedback, no celebration, no first-frame art | Feels static; "cute" is 50% motion | Press-scale + heart pop + precache (§2.6, §8) |

---

## 2. The new visual system

### 2.1 Art direction — six rules

The set is **soft-clay kawaii**: chunky rounded volumes, matte gradient shading, blush cheeks, dot eyes, no outlines, no text.

1. **Characters, not clip-art.** The heart (you) and the bun (them) are recurring. They should appear on at least one screen per session.
2. **Always grounded.** Every illustration sits on a soft-pink (`#FFF0FB`) or cream (`#FFF7FA`) tile. Never float art on pure white, never on a gradient.
3. **One per screen, one per card.** If a screen needs a second illustration, it needs a layout fix instead.
4. **Art never carries text or data.** Numbers and labels stay in the type system.
5. **Never stretch.** Always `BoxFit.contain`, sized by the longest edge.
6. **Art is decoration unless it means something.** Mark it `excludeFromSemantics` (the default in `AppIllustration`) and add `semanticLabel` only when the artwork is the message (e.g. "you checked in today").

### 2.2 Colour — keep the palette, ration it

Keep the existing tokens. Add four art-support colours to `AppColors` (`lib/core/theme/app_colors.dart`) so the illustrations and the UI share one vocabulary:

```dart
// add to AppColors (light values; mirror in dark)
lilac:   Color(0xFFC9A7FF),  // the bun's body — secondary accent
peach:   Color(0xFFFFB199),  // the cloud — warm accent
butter:  Color(0xFFFFF3D6),  // celebration / streak
mint:    Color(0xFFB8E6CF),  // "done" surfaces, softer than success
tile:    Color(0xFFFFF0FB),  // == softPink, named for illustration tiles
```

**Ration rule 60 / 30 / 10**

| Share | Role | Tokens |
|---|---|---|
| 60% | ground | `background`, `card`, `softPink` tiles |
| 30% | ink & structure | `text`, `bodyText`, `muted`, `border` |
| 10% | accent | **one** of `primary` **or** `lilac` per screen |

Status colours (`success`, `warning`, `danger`, `info`) are **only** for state: done, overdue, destructive, syncing. Never for decoration. Today `info` is used on the bucket tile, `warning` on capsules, `success` on photos, `primary` on coupons — four accents on one 2×2 grid. Reduce to: `primary` for every tile, and status colour only on the badge that deserves it.

### 2.3 Type — five roles, three sizes per screen

The current theme has 12 styles with weights w700–w900 almost everywhere, which flattens the hierarchy.

| Role | Style | Size / weight | Use |
|---|---|---|---|
| Display | `headlineMedium` | 30 / w800, tracking −0.5 | Screen hero only |
| Title | `titleMedium` | 17 / w700 | Card titles, section heads |
| Body | `bodyMedium` | 14.5 / w400, height 1.5 | Copy, notes |
| Caption | `bodySmall` | 12.5 / w500 | Meta, timestamps, captions |
| Label | `labelSmall` | 11 / w700, tracking **0.4** | Pills, counters, nav |

Rules: max 3 sizes on a screen; tracking never above 0.6; no `toUpperCase()` except 2-letter badges (`PIN`, `DEMO`); never manually `\n` a headline.

### 2.4 Shape, spacing, elevation

- **Spacing rhythm:** 4-point grid, but only use `8 / 12 / 16 / 24 / 32`. Keep `AppSpacing`, ban arbitrary `SizedBox(height: 7)`.
- **Radii:** art tiles `size * 0.34`, cards `20`, sheets `28` (top only), pills `999`, buttons `999`. One radius per component class.
- **Elevation:** at most **one** soft shadow per screen (on the hero). Lists use `border: colors.border` **or** a tinted fill — never both border and shadow. Concretely: in `AppCard`, add a `flat` mode (`shadow: false` already exists) and make flat the default for list rows.

### 2.5 Icons vs illustrations

| Use Material icons for | Use illustrations for |
|---|---|
| Utility actions: add, edit, delete, chevron, copy, share, close | Feature identity, empty states, headers, celebrations |
| Status: check, lock, clock, warning | Mood, streak, milestone |
| Navigation (tabs) | Onboarding, splash |

Rule of thumb: if the icon is a **verb**, use a Material icon at 20–24dp with `colors.muted` (or `primary` when selected). If it is a **noun the user came for**, use a spot illustration.

### 2.6 Motion — small, warm, fast

Add to `AppDurations`:

```dart
static const press = Duration(milliseconds: 90);
static const pop   = Duration(milliseconds: 260);
static const enter = Duration(milliseconds: 320);
```

- **Press:** scale to 0.97 on tap-down for cards and big buttons (`AnimatedScale`).
- **Enter:** first 5 list items fade+slide 8dp, staggered 40ms. Use `TweenAnimationBuilder`; no dependency needed.
- **Celebrate:** on check-in save and on a completed goal, animate a heart popping from the mascot (`ScaleTransition` 0.6→1.1→1.0).
- **Respect reduced motion:** wrap custom motion in `MediaQuery.of(context).disableAnimations` checks.
- **Splash:** animate `splash_art.png` with a 6s gentle float (`Transform.translate` + `sin`), not a spinner. Only show a spinner if bootstrap exceeds ~600ms.

---

## 3. The asset pack

### 3.1 Inventory

| File | Size | What it is | Where it goes |
|---|---|---|---|
| `design/app_icon.png` | 1024² | Two overlapping hearts on a pink→peach gradient | **Master, not bundled.** All launcher icons (Android/iOS/web) are already generated from it |
| `assets/brand/heart_icon.png` | 384 | Single glossy heart, transparent | `BrandMark` — now a floating mark, no square |
| `assets/brand/notification_icon.png` | 96² | White heart silhouette on alpha | Also copied to `android/app/src/main/res/drawable/ic_stat_heart.png` for FCM |
| `assets/illustrations/mascots.png` | 720 | The pair holding hands | Splash, Setup header, Home hero, About, "waiting for partner" |
| `assets/illustrations/splash_art.png` | 720 | Pair on a cloud (tall) | Splash screen, onboarding |
| `assets/illustrations/spot_bucket.png` | 420 | Suitcase + map + pin | Bucket list header, Plans section, Home shortcut |
| `assets/illustrations/spot_checkin.png` | 420 | Smiling sun + cloud | Check-in screen, Home "Today" card, Connect pulse |
| `assets/illustrations/spot_capsule.png` | 420 | Sealed envelope + clock | Capsules header, Plans section |
| `assets/illustrations/spot_coupons.png` | 420 | Two scalloped tickets | Coupons header, Connect ritual list |
| `assets/illustrations/spot_goals.png` | 420 | Savings jar with hearts | Goals header, Home goals card |
| `assets/illustrations/spot_photo.png` | 420 | Instant camera | Album header, Home "photo" shortcut |
| `assets/illustrations/spot_deeptalk.png` | 420 | Two speech bubbles | Deep talk header, Connect ritual list |
| `assets/illustrations/spot_chores.png` | 420 | Broom + sparkles | Chores header, Home chores card |
| `assets/illustrations/empty_state.png` | 420 | Pair peeking into an empty box | Every empty state |
| `assets/illustrations/pattern_hearts.png` | 512² | Seamless heart/sparkle scatter tile, transparent (6 KB) | Onboarding / splash background at 6–8% opacity, or an `ImageRepeat.repeat` backdrop |

> **Status: complete.** All 12 illustrations are installed in `assets/illustrations/`, including the shadow-free `mascots` and the outline-free `spot_checkin`. The one exception is `pattern_hearts`, which is drawn as a true seamless vector tile rather than generated.

### 3.2 Display sizes (3× screens)

| Context | Logical size | Notes |
|---|---|---|
| Tile inside a card / list row | 52–64 | `IllustrationTile(art, size: 56)` |
| Feature shortcut tile | 56–72 | art inside, label below |
| Section header | 88–112 | aligned left, caption to the right |
| Empty state | 150–180 | centred, `empty_state.png` |
| Splash / onboarding | 220–280 | `splash_art.png`, floats |
| Hero mascots | 120–200 | `mascots.png`, overflows the hero card by 8–12dp |

Because art ships at 420–720px, `Image.asset` with `cacheWidth: (size * dpr).round()` keeps memory small (§8).

### 3.3 Using the registry

New file: `lib/core/widgets/app_illustration.dart`

```dart
import '../../core/widgets/app_illustration.dart';

// spot inside a tinted tile
IllustrationTile(AppArt.capsules, size: 56)

// empty state scene
AppIllustration(AppArt.empty, size: 160)

// hero mascots, decorative
AppIllustration(AppArt.mascots, size: 150)

// seamless backdrop on setup / splash (keep it faint)
Image.asset(
  AppArt.pattern.asset,
  repeat: ImageRepeat.repeat,
  opacity: const AlwaysStoppedAnimation(0.08),
)
```

`AppIllustration` already handles: transparent PNG, `BoxFit.contain`, decorative semantics, an icon fallback if a file is missing, and opacity for dark mode.

---

## 4. Component upgrades (do these once, use everywhere)

### 4.1 `IllustrationTile` — replaces `SoftIcon` for feature nouns

Already added in `app_illustration.dart`:

```dart
IllustrationTile(AppArt.goals, size: 56)              // in list rows / feature tiles
IllustrationTile(AppArt.coupons, size: 52, onTap: …)  // tappable
```

Keep `SoftIcon` only for compact utility rows (settings, info rows).

### 4.2 Three container tiers

Stop using `AppCard` for everything. Introduce three explicit levels:

| Tier | Look | Used for |
|---|---|---|
| `HeroCard` | gradient (`brand` only) or `softPink`, 24 radius, optional mascot overflow | one per screen, top |
| `SectionCard` | flat `colors.card`, 1px `border`, no shadow, 20 radius | grouped content |
| `ListRow` | no card, `Divider` between, 12 vertical padding | items in lists |

Implementation sketch (add to `lib/core/widgets/app_card.dart`):

```dart
/// Flat, border-only card. Default for content groups.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.child, this.onTap, this.padding});
  // Container(decoration: BoxDecoration(
  //   color: colors.card,
  //   borderRadius: BorderRadius.circular(AppRadii.lg),
  //   border: Border.all(color: colors.border)))
}
```

Then delete the shadow from every list card on Home/Bucket/Chores/Coupons/Capsules. The only shadow left should be on the hero.

### 4.3 `EmptyState` — art, one sentence, one button

Current signature takes an `IconData`. Replace with `AppArt` and a 160dp scene:

```dart
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.art = AppArt.empty,          // replaces `icon`
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });
  // Column(
  //   AppIllustration(art, size: 160),
  //   SizedBox(height: AppSpacing.lg),
  //   Text(title, style: texts.titleMedium, textAlign: center),
  //   SizedBox(height: AppSpacing.xs),
  //   Text(message, style: texts.bodySmall.copyWith(color: muted), textAlign: center),
  //   if (actionLabel != null) FilledButton(...)
  // )
}
```

Call sites to update (seven): bucket, capsules, coupons, goals, chores, album, deep talk.

| Screen | Current copy | Suggested copy (warmer, shorter) |
|---|---|---|
| Bucket | "Your list is wide open" | "Nothing on the list yet — add the first little plan." |
| Capsules | "No capsules yet" | "Write a letter now, open it on a date that matters." |
| Coupons | "No coupons yet" | "Offer one small thing they can cash in." |
| Goals | "Dream something up" | "Pick something to save for, together." |
| Chores | "Nothing on the board" | "Split the little things. Start with one." |
| Album | "Your album is empty" | "One photo a week. The first prompt is waiting." |
| Deep talk | "No deep talks yet" | "Answer the question above. Keep what matters." |

### 4.4 `FeatureTile` — the cute replacement for `_QuickTile` / `_MoreTile`

```dart
class FeatureTile extends StatelessWidget {
  const FeatureTile({
    super.key,
    required this.art,
    required this.label,
    required this.caption,
    this.onTap,
  });

  final AppArt art;
  final String label;
  final String caption;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IllustrationTile(art, size: 54),
          const Spacer(),
          Text(label, style: context.texts.titleSmall),
          const SizedBox(height: 2),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.texts.bodySmall?.copyWith(color: colors.muted),
          ),
        ],
      ),
    );
  }
}
```

Use it in: Home shortcuts, `MoreScreen` grid, Plans sections, Connect rituals.

### 4.5 `HeroCard` — one per screen

```dart
HeroCard(
  art: AppArt.mascots,        // optional, overflows bottom-right
  eyebrow: 'Day 412',
  title: 'Good evening, Alex',
  subtitle: 'Sam checked in 2h ago',
  trailing: HeartBadge(streak: 12),
)
```

Rules: max 220dp tall, `brand` gradient **or** `softPink` (never `sunset`/`lilac`/`sunrise`), white text only if the gradient's lightest stop is ≤ `#FF7B83`. Mascots may overflow the card edge by 8–12dp — that single detail is what makes it feel designed rather than generated.

### 4.6 `MoodPicker` — one row, five faces

Replace the five stacked `_MoodOption` cards in `checkin_screen.dart` with:

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    for (final mood in moodScale)
      _MoodChip(mood: mood, selected: _mood == mood.value, onTap: …),
  ],
)
```

`_MoodChip`: 56dp circle tinted with `mood.color` at 14%, icon 28dp, label below, `AnimatedScale` 1.08 when selected. Keep the confirm card under it (shows the chosen label and a one-line note field). The 14-day strip stays — it's one of the best things in the app; just retitle "Last 14 days" (sentence case) and let the mascot sit beside the streak number.

### 4.7 Composable stat strip (chores, goals)

The four `_ChoreStat` columns on Home read as a spreadsheet. Replace with:

```
[IllustrationTile(chores, 48)]  Chores          2 open · 1 done
                                [----------progress----------]
```

One line + one bar. Move "Yours / Partner / Shared / Done" into the Chores screen where it belongs, as a fairness bar:

```
You  ██████░░  3     Sam ████░░░░  2     Shared ██ 1
```

### 4.8 Sheets

`AppSheet` is solid. Two refinements:

1. Grab handle + 28dp top radius (already themed) and a **single** primary action (`GradientButton`), secondary as a text button. Never two filled buttons.
2. Add a small illustration to the sheet header when the sheet is a *creation* flow (bucket → `spot_bucket` 40dp beside the title). Cheap charm, no layout cost.

---

## 5. Screen-by-screen map

Legend: ✅ keep · 🔁 change · ➕ add · ➖ remove.

### 5.1 Home — `lib/features/home/home_screen.dart` (the big one)

Current sections: Hero → Invite → Check-in → Partner mood → Quick actions (2×2) → Next up (2 cards) → Shared goals → Chores stats. Eleven cards.

Target structure (four blocks, ~420dp before scroll):

| Order | Block | Detail |
|---|---|---|
| 1 | 🔁 **Hero** | `mascots.png` overflowing right, "Day N" as eyebrow, greeting as title, streak pill. No `DEMO` badge inside the hero — move it to a thin banner under the app bar. |
| 2 | 🔁 **Today** | One card: `spot_checkin` 56 + "How are you today?" + 5-mood row (reuse `_MoodChip`) → tap directly saves, no navigation. If already checked in: "You feel good today" + partner mood in the same card. Merges the old `_CheckInCard` + `_PartnerMoodCard`. |
| 3 | ➕ **Three shortcuts** | Bucket · Photo · Capsules as `FeatureTile`s with `spot_*` art. Exactly three — the rest live in the tab bar. |
| 4 | ➕ **One nudge** | A single, rotating "next up" line: nearest capsule **or** nearest goal **or** overdue chore — whichever is most urgent, with a chevron. Replaces the 2-up "Next up" row, the goals card, and the chore stats. |

➖ Remove: `_QuickTile` grid, `_PartnerMoodCard` as a separate card, the goals progress card, the 4-stat chore row, the `_InviteCard`'s big PIN display (keep a slim invite row: "Invite Sam · PIN 428 913" with a copy icon).

That takes Home from 11 cards to 4 + app bar. Nothing is lost: every destination is still one tap away.

### 5.2 Splash — `lib/features/splash/splash_screen.dart`

✅ Keep structure. 🔁 Replace `BrandMark(size: 108)` with `splash_art.png` (240dp, gentle float), keep the `YOU&ME` wordmark smaller (28) and send the tagline to `bodySmall`. ➕ Precache in `main()` so the first frame is art, not a spinner. ➖ Remove the `CircularProgressIndicator` unless boot > 600ms.

### 5.3 Setup — `lib/features/setup/setup_screen.dart`

🔁 `BrandMark(76)` → `mascots.png` (140). 🔁 Segmented "Create / Join" stays (good). 🔁 Card becomes a flat `SectionCard`. ➕ Demo mode gets a small illustrated "Open the demo space" row with `spot_checkin`, not a bare `TextButton`. ➖ Drop the "No passwords. Just your PIN." footer row (the lock icon + PIN field already say it) or shrink it to a single caption line.

### 5.4 Shell — `lib/features/shell/app_shell.dart` + `app_theme.dart`

🔁 Navigation height 70 → 64, icon 24 → 22, selected label weight w700 (not w800). ➕ Animate the selection indicator (theme already uses `softPink` indicator). ➖ Consider 4 tabs (Home, Plans, Connect, Album) and move "More" to a profile avatar in the top-right of Home — the current 5th tab is a second navigation layer. If you keep 5, make `MoreScreen` a spot-illustration grid so it doesn't read as a settings dump.

### 5.5 Plans — `plans_screen.dart`

🔁 Replace the `AppGradients.lilac` hero with `softPink` + `spot_bucket` 96 on the right; title "Plans" in `headlineMedium` (no `\n`). ✅ Keep the three sections. 🔁 Each section header gains a 40dp `IllustrationTile` on the left instead of a Material icon. ➕ "Surprise me" becomes a pill button with a small heart, aligned right in the Date ideas header.

### 5.6 Check-in — `checkin_screen.dart`

🔁 Stacked mood rows → one row of five `_MoodChip`s (§4.6). 🔁 The selected-mood confirm card keeps the mood colour but drops the border (use a 12% tint fill). 🔁 Streak card: mascot 56 + "12 days in a row" + 14-day strip in one flat card. ➕ Celebrate on save: heart pop + snackbar "Saved. That's 12 days." ✅ Partner card stays.

### 5.7 Capsules — `capsules_screen.dart`

🔁 `sunset` hero → `soft` gradient + `spot_capsule` 96. 🔁 `_CapsuleCard` uses `IllustrationTile(capsules, 48)`; status pill keeps `warning` only when locked. ➕ Opening animation: envelope scale+fade (200ms) before the letter dialog. ✅ Ready/Locked/Opened grouping is good — retitle to sentence case.

### 5.8 Coupons — `coupons_screen.dart`

🔁 Hero → `softPink` + `spot_coupons`. ➕ Make `_CouponCard` an actual **ticket**: `CustomClipper` with two semicircular notches on the sides and a dashed divider. This is the single highest-charm-per-line change in the app. 🔁 "Redeem" becomes a filled pill on the card, not a `TextButton` at the end of a row. ✅ Redemption history stays.

### 5.9 Goals — `goals_screen.dart`

🔁 `sunrise` hero → flat `SectionCard` with `spot_goals` 96, overall percentage as the only big number. 🔁 Per-goal card: `IllustrationTile(goals, 44)` + title + amount line + 8dp progress. ➕ Optional jar fill: overlay a clipped, tinted rectangle inside `spot_goals` in the header, height = overall progress (a 60px-wide illustration detail, done with `ClipRect` + `Align`). 🔁 Fix currency: format with `goal.currency` in `_GoalCard`, `_ContributionSheet`, and the `$` prefix in both sheets → `NumberFormat.simpleCurrency(name: goal?.currency ?? 'USD').currencySymbol`.

### 5.10 Chores — `chores_screen.dart`

🔁 Hero `brand` gradient (keep white text on `#FF4576`→`#FF7B83` only) + `spot_chores` 88. ➕ Fairness bar (§4.7) at the top instead of a plain `done/total` fraction. 🔁 `_ChoreCard`: checkbox → heart-shaped check (`Icons.favorite` when done) for a softer completion. ✅ Overdue `danger` pill stays — status colour used correctly.

### 5.11 Album — `album_screen.dart`

🔁 Empty state → `empty_state.png` + "One photo a week. The first prompt is waiting." ➕ Add `spot_photo` 72 to the "THIS WEEK" header block. 🔁 Current challenge card: photo (4:3) → prompt (title) → one compact action row; drop the author line when it's you. ✅ Past grid stays; ➕ a 3-column `GridView` for completed weeks would look more like an album than a list — recommend it once there are >6 photos.

### 5.12 Deep talk — `deep_talk_screen.dart`

🔁 Prompt card: drop the `sunset` gradient for `softPink` with plum text and `spot_deeptalk` 64 in the corner — white-on-peach fails contrast anyway. ➕ "Swipe for another" becomes a small animated hint with a heart divider. ✅ Saved reflections list is good; use `ListRow` (no card per entry) to reduce weight.

### 5.13 More — `more_screen.dart`

🔁 Profile hero: `mascots` 96 + names + "Day N" + PIN pill. ➕ Feature list becomes a 2-column `FeatureTile` grid with all six `spot_*` arts. ➖ Remove duplicate "Settings" tile shadow; keep one flat row. ✅ Demo/Firebase note stays but as a single muted line with a lock icon.

### 5.14 Settings — `settings_screen.dart`

🔁 Replace the five stacked `AppCard`s with **grouped list sections** (label + flat container + `Divider`s): Profile · Space · Appearance · About · Leave. ➕ Profile header uses `mascots` 64. 🔁 Theme chips: keep three, but use icon-only segmented buttons to save a row. ✅ Leave-space card stays prominent and destructive-coloured.

---

## 6. Twelve rules that make it feel simple and proper

1. **One hero per screen**, ≤ 220dp, top of the scroll.
2. **One accent per screen** — pick `primary` **or** `lilac`, not both.
3. **One shadow per screen** — heroes only; lists use borders or tints.
4. **One illustration per screen** — feature headers and empty states compete only when they're on different screens.
5. **Three type sizes per screen**, no exceptions in cards.
6. **No all-caps** longer than 3 characters; tracking ≤ 0.6.
7. **One filled button per view** (sheet, dialog, empty state). Secondary is always a text button.
8. **No duplicate doors**: each destination appears once in the tab bar, once in Home shortcuts (max 3), and once in More — no more.
9. **Empty = art + one sentence + one action.** Never art + two sentences + two buttons.
10. **Let text wrap.** Remove `\n` from all headline strings; cap at 2 lines with ellipsis where needed.
11. **Progress = one number + one bar** (or the jar). Never three stats in a row on a dashboard.
12. **Space, not separators.** Increase the gap between groups to 28–32 and remove half the `Divider`s.

---

## 7. Dark mode & accessibility

**Dark mode.** The art is bright and low-contrast against `#0F0214`. Rules:

- Put every illustration on a `softPink` **dark** tile (`#3E2436`) — the transparent PNG then reads as lit from within.
- Cap art opacity at 0.92 in dark (`AppIllustration(opacity: 0.92)`).
- Swap `color: colors.card` for `colors.cardAlt` on flat cards so they don't glow.
- Disable shadows (`AppShadows.soft` → transparent) — on dark they read as smudges.
- The white notification icon and `app_icon` need no changes.

**Accessibility.**

- Gradients must end at `#FF7B83` or darker when white text sits on them (peach `#FFB199` fails WCAG AA).
- Body text `bodyText` on `background` currently passes; keep `muted` for ≥12.5px only.
- Minimum tap target 44×44 — the current 30dp completion circle in bucket/chores is too small; use a 44dp `InkWell` around a 26dp visual.
- Decorative art: `excludeFromSemantics: true` (default). Meaningful art: give a short `semanticLabel`.
- Honour `MediaQuery.disableAnimations` for float/pop/confetti.
- Test at 200% text scale: the 2-column shortcut grid and the mood row are the two places that will break — switch them to `Wrap` when `textScale > 1.3`.

---

## 8. Performance & asset hygiene

- **Total bundled art weight:** ~2.4 MB (PNG, transparent; the 1024px launcher master lives in `design/` so it is not shipped). Fine for a store build; for web, keep the splash and mascots on a `precacheImage` list and lazy-load the rest, and consider re-encoding the illustrations to WebP once you confirm your platform matrix.
- **Precache** `AppArt.aboveTheFold` in `main()` or the splash `initState` (`precacheAppArt(context)`).
- **Bound decode size** for tiles: `cacheWidth: (logicalSize * devicePixelRatio).round()` (or `ResizeImage`) — a 720px PNG in a 56dp tile otherwise decodes at full size.
- **Never** put a 420px illustration inside a scrolling list row without `cacheWidth`.
- Keep PNG (alpha matters); only convert to WebP once you verify the platform matrix you ship.
- Do not animate `splash_art.png` with a blur/`ImageFilter` — use translation/scale only.
- Name new art `spot_<feature>.png`; keep everything flat in `assets/illustrations/` (already declared in `pubspec.yaml`).

---

## 9. Rollout plan

**P0 — foundation (this change set)**

- [x] Asset pack generated, keyed to transparency, installed
- [x] `assets/illustrations/` added to `pubspec.yaml`
- [x] `lib/core/widgets/app_illustration.dart` (`AppArt`, `AppIllustration`, `IllustrationTile`, `FloatingHeart`)
- [x] Launcher icons (Android/iOS/web) + notification icon + favicon regenerated
- [x] `design/app_icon.png` kept out of the bundle; `ic_stat_heart` drawable added for FCM
- [x] `docs/asset_sheet.png`
- [x] Batch 2 art: `spot_photo`, `spot_deeptalk`, `spot_chores`, `empty_state`, `pattern_hearts` (vector), plus shadow-free `mascots` and outline-free `spot_checkin`
- [ ] Delete the now-unused `assets/brand/splash_logo.png` (115 KB still bundled)

**P1 — visible upgrade (1–2 days)**

- [ ] `EmptyState` gains `art` (7 call sites)
- [ ] Splash uses `splash_art` + precache + float
- [ ] `Setup` header uses `mascots`
- [ ] `SectionCard` / `FeatureTile` / `IllustrationTile` replace `SoftIcon` on Home, More, Plans, Connect
- [ ] Home restructured to 4 blocks (§5.1)
- [x] `BrandMark` switched to `BoxFit.contain` with no container shadow (the mark is transparent now)

**P2 — feature polish (2–3 days)**

- [ ] Check-in mood row + celebration
- [ ] Coupon ticket clipper
- [ ] Capsule open animation
- [ ] Goals currency fix + jar fill
- [ ] Chores fairness bar
- [ ] Settings grouped list

**P3 — delight (optional)**

- [ ] Heart confetti on milestones (`CustomPainter`, no dependency)
- [ ] Mood-face illustration set (5 files) to replace Material mood icons
- [ ] `pattern_hearts` as a 6% opacity background on Setup/Splash
- [ ] Mascot reactions (waiting for partner, streak broken, first goal reached)
- [ ] Theme-honouring illustration shadows (dark mode = no shadow)

**Definition of done for any screen:** one hero, one accent, ≤3 type sizes, one illustration, max one shadow, no duplicate navigation, empty state has art + one action, works at 200% text, checked in light **and** dark.

---

## 10. Do / Don't

| ✅ Do | ❌ Don't |
|---|---|
| Put art on a tinted tile | Float art on white, or crop it into a circle |
| Use `brand` for the hero and `softPink` for everything else | Stack `sunset`, `lilac`, `sunrise`, `brand` on adjacent screens |
| Let mascots overflow the hero edge by 8–12dp | Centre them inside a box with equal padding |
| Keep status colours for status | Colour four tiles with four different accents |
| One big number per card | Three stats in a row on the dashboard |
| Shrink a headline's wording | Insert `\n` into a headline |
| 44dp tap targets | 30dp visual circles with no hit padding |
| Animate 90–260ms | 600ms page transitions |
| Verify in dark mode | Assume the palette handles it |

---

## 11. Regenerating or extending the art

The set was produced from a single style recipe, so new pieces will match. Paste this suffix on every prompt:

```
Kawaii sticker illustration in a soft 3D clay / matte felt style: chunky rounded
shapes, gentle gradients, subtle inner glow, no hard outlines. Palette strictly
blush pink #FF4576, coral #FF7B83, peach #FFB199, lilac #C9A7FF, cream #FFF7FA,
deep plum accents #3E0554. Single centered subject with generous empty margin,
nothing touches the edges. Perfectly flat uniform solid background of exactly
#FFF0FB, no gradient, no vignette, no cast shadow on the background, no texture
in the background. No text, no letters, no numbers, no logo, no watermark, no frame.
```

Post-processing used for this pack (repeatable):

1. Flood-fill the flat `#FFF0FB` background from the borders (tolerance ~10 RGB) → alpha 0; a 0.7px blur on the alpha keeps edges soft.
2. Trim to content with 4% padding.
3. Resize the longest edge: 420 for spots, 720 for scenes.
4. Export PNG RGBA, `optimize=True`.
5. White-only icons (notification): threshold to a 96×96 white silhouette on transparency.

**Housekeeping:** keep this prompt in the repo when you add art; it is the style contract. Do not prompt for, or ship, characters that resemble another app's IP — these mascots are original to YOU&ME (a heart and a bun, nothing borrowed).

---

## 12. Quick self-review checklist

- [ ] Does the screen have exactly one hero?
- [ ] Is there exactly one accent colour beyond the neutrals?
- [ ] Are there more than three text sizes?
- [ ] Does any card have both a border and a shadow?
- [ ] Is there an illustration where an icon would do — or an icon where the feature deserves art?
- [ ] Can any section be removed without losing a function? (If yes, remove it.)
- [ ] Do empty / loading / error states all have art or voice?
- [ ] Does it survive dark mode, 200% text, and a 320dp-wide screen?
- [ ] Do two different doors lead to the same place?
