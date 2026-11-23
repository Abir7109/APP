# YOU&ME — Product Research & Redesign Report

**Date:** 2026-11-23 · **Scope:** what to change, what to add, how it should work, why
**Based on:** the actual codebase at `lib/` (read file-by-file) + category research (sources at the bottom)
**Thesis in one line:** YOU&ME is a well-built *collection of couple features*. The market leaders are *one daily ritual that two people do together*, wrapped in something that feels handmade. Fix the ritual first, then the warmth, then the breadth.

---

## 0. Why it "feels AI-made" — the honest diagnosis

You said it doesn't feel romantic or handy. The research is blunt about why products feel algorithmically assembled: [smoothness and perfect symmetry read as machine](https://www.marcfriedmanportfolio.com/blog/ai-imperfect-aesthetics/); AI "copies patterns instead of making real choices… it doesn't feel anything about what it makes" and is missing **visual hierarchy, restraint, emotional depth, and human detail** — texture, asymmetry, hand-drawn elements, real words [1,2]. [Intentional imperfection](https://cda.academy/ai-generated-design-soulless/) is the antidote: grain, paper, uneven radii, handwriting, off-grid placement, pet names, inside jokes.

This app currently has **all six AI tells** and it's not close:

| AI tell | Where it lives in this repo |
|---|---|
| Perfect symmetry everywhere, one rounded-card pattern repeated | `app_card.dart`, every screen — same padding, same radius, same border+softPink tile grid |
| 4 gradients + tinted-square icons ("icon soup") | `AppGradients.brand/sunrise/lilac/sunset/ocean/meadow`, `SoftIcon` used in every list row |
| All-caps labels, wide tracking, eyebrow stacks | `LIVE DISTANCE` (live_distance_card.dart), `DAY $days`, `YOUR` section eyebrows, `caption` caps in `_SectionHeading` |
| Copy that sounds like a prompt output | "A private space for two.", "A little something to look forward to.", "Teamwork makes the shared life lighter." — same 3-beat sentence everywhere, never a pet name, never a specific memory, no humor |
| No texture/grain/paper — flat #FFFFFF + flat fills | `AppColors.background: #FFFFFF`, zero noise/SVG texture assets (assets/ has only flat PNGs) |
| Personalization = names only, everything else static | `session_provider` carries `myName/partnerName`; no pet names, couple photo, relationship title, anniversary-of-met, or love language anywhere in the schema |

The fix is not "more gradients". It is **fewer features, deeper ritual, human hand**.

---

## 1. What the market actually rewards (research digest)

### 1.1 The category is four jobs, not "couple apps"

| Job-to-be-done | Leaders | What wins | Price signal |
|---|---|---|---|
| **Daily question / growth** | **Paired** ([4.7★, ~208K ratings](https://apps.apple.com/us/app/paired-couples-relationship/id1469609343)), Agapé (4.8★, free), Gottman decks (free), Lasting, Relish | One question/day, **both answer blind, reveals together**; 5 minutes; therapist-designed | Paired ~$15/mo, ~$70/yr; one subscription covers both |
| **Private shared space & memory** | **Between** (4.5–4.8★) | Milk & Merry characters, memory timeline, anniversary countdown, private sticker chat, no outside noise | Free; Plus ~$1.99/mo or $13.99/yr |
| **Presence / "thinking of you"** | **Tap, obimy, NUJJ, Locket widget** | One tap → haptic buzz + notification, zero typing; home-screen widget with partner's last photo/status | Free to $2/mo |
| **Coordination** | **Cupla** (4.7★, 500K+ couples, [university-backed claims](https://cupla.app/blog/best-shared-calendar-apps-for-couples-in-2026/): 75% less friction, 65% more quality time), Cozi, Honeydue | Shared calendar, date-night frequency goal, wishlists, reminders | Cupla from $4.99/mo or $34.99/yr |

Useful summary tables: [Match.com's 9 best couples apps](https://www.match.com/p/dating-advice/best-couples-apps/), [our best-of 2026](https://www.unite.ai/best-ai-apps-for-couples/), [free vs paid compare](https://tryamora.app/blog/best-apps-for-couples-2026).

### 1.2 Why couple apps die (the recurring graveyard)

Across Reddit and review mining, the pattern repeats ([r/Marriage](https://www.reddit.com/r/Marriage/comments/1qt8f1l/are_couple_apps_worth_the_money/), [r/apps](https://www.reddit.com/r/apps/comments/1qao3tr/any_good_couples_apps_youd_recommend/), [Privé Game analysis](https://privegame.com/en/blog/best-apps-for-couples), [Paired long-term review](https://feelclose.app/blog/paired-couples-app-review)):

1. **Homework feel.** "Answer this / reflect on that" after work kills it by week two. Prompts must produce *a moment*, not maintenance. The test: *does opening the app give you two something to do together tonight, or another dashboard to maintain?*
2. **One-partner dependency.** If one partner stops, the app is a dead icon. Features must work asymmetrically — value even when the other is passive.
3. **Dead onboarding.** No space/partner → empty dashboard → churn in 48h. Demo/simulation or immediate value is mandatory (YOU&ME does this well — credit where due).
4. **Subscription hostility.** Locking the basic loop behind paywalls, or charging both partners separately, reads corporate ("a corporate chore instead of a helpful tool" — r/Marriage). Paired gets away with it; smaller apps don't.
5. **Notification failure.** Paired's #1 review complaint (after price): glitchy prompts, reminders after completion. The daily ping must be reliable and **forgiving** — never guilt-y.

### 1.3 What makes the survivors *feel* handmade

- **Between:** memory timeline ("scrolling back two years hits different"), sticker characters with names, milestone countdowns — [real users cite the timeline as the reason they stay for years](https://habi.app/insights/best-couple-apps/).
- **Tap/obimy:** a haptic nudge carries more feeling than a typed sentence; ~zero effort, ambient closeness. [Tap](https://play.google.com/store/apps/details?id=com.tapapp.tap): 8 tap types, reply-from-notification, a weekly "how often you thought about each other" recap.
- **Paired:** answer-first reveal — you can't see theirs until you answer yours. This single mechanic produces honesty and a shared reveal moment. [Read the UI-why](https://www.lemon8-app.com/experience/best-features-of-paired-couples-app-interface).
- **Love Nudge:** quiz → partner's love language → suggested micro-actions + a "love tank" that rises/depletes — abstract care made visible. [4.4★](https://apps.apple.com/au/app/love-nudge/id495326842), entirely free.
- **Cupla:** a **weekly date-night goal** with reminders — coordination reframed as romance, with the strongest research claim in the category.

---

## 2. YOU&ME today vs. what wins — gap scorecard

| Pillar | YOU&ME today | Verdict | Market benchmark |
|---|---|---|---|
| Pairing & privacy | PIN + anonymous auth, no accounts, data scoped to couple | **Strong** — better than most | Between/Paired use account links; YOU&ME's 6-digit PIN is friendlier |
| Demo/first run | Seeded couple "Alex & Sam", simulated partner | **Strong** — keep and lean in | Most competitors have empty states at install |
| **Daily ritual** | Check-in = solo mood log, charts to nowhere. Deep talk = *you* write, immediately visible, 16 prompts | **Weak** | Paired: both answer blind → joint reveal. This is the retention engine YOU&ME lacks |
| **Presence / ambient** | Nothing. Only a live-distance consent map | **Missing** | Tap/obimy: one haptic "thinking of you" — cheapest, highest-ROI feature in the category |
| Anticipation | Day counter ("Day 412"), capsule unlock countdowns | **Okay** | Also missing: special dates (met/first/proposal) countdowns, date-night frequency goal (Cupla) |
| Memory | Photo-challenge grid, opened capsules | **Okay** | Missing: chronological **memory timeline**, "this day in us", weekly/yearly recap |
| Logistics | Bucket list, goals/savings, chores + fairness bar, coupons | **Good scope** but spreadsheet-y tone | Cupla: same jobs, framed as "life together", with wishlists and calendar. Honeydue owns money — don't expand there |
| Personalization | Names + anniversary | **Weak** | Pet names, couple photo, relationship title, love language — none exist in schema |
| Craft / warmth | 12 cohesive but uniform AI-clay illustrations; perfect grids; corporate copy | **Weak** | Between characters + handwriting + paper + mixed media feels *made for you two* |
| Notifications | Live-distance ping only | **Weak** | A daily gentle ritual ping + partner-joined/recap digests are the category's retention loop |
| Widgets | None | **Missing** | Locket/Tap/Cupla widgets: days together, partner mood, streak, quick-tap |
| Growth content | 16 static prompts, 8 photo prompts, 8 coupon ideas | **Thin** | Paired: hundreds of expert questions across stages/topics. YOU&ME needs a real content pack + packs |

**Net:** YOU&ME over-indexes on solo ledgers (mood log, savings, fairness stats) and under-indexes on the three loops that drive category retention: **daily mutual question → presence tap → memory/recap**. Everything else is decoration until those work.

---

## 3. What to CHANGE (existing features, deepest first)

Ordered by ratio of (feeling fixed) / (code touched).

### 3.1 Deep talk → **"Today's Question" — the mutual blind-reveal ritual** *(the single most important change)*
**Today** (`lib/features/deep_talk/deep_talk_screen.dart`): shuffle a prompt, write an answer, it's immediately in both feeds. One-sided, no ritual, runs out of content.
**Change to:** One curated question per day, same for both. `Write → both answers hidden until both submit → reveal together → streak + a small stamp/scribble animation → "keep this one?" bookmark.`
- Data: new `answers/{questionDay}` doc per couple (`questionId`, `uid`, `text`, `createdAt`, `revealed` derived when both answered). Works exactly like the existing `live/current` doc pattern (`couples/{coupleId}/question/current`), so rules/`AppBackend` extend cleanly.
- Content: ship 90+ day-one prompts as a bundled asset (`assets/content/questions.json`) across 6 packs (fun, everyday, us, deep, money, future). Client-side pick by `dateKeyOf(today) % pool`. No backend needed for v1.
- UI: answer sheet replaces the inline field on Connect; Home "Today's question" card replaces the mood-only card as the ritual anchor; reveal is a flip/expand animation with `HeartPop`.
- Streak: reuse `calculateStreak` from `core/utils/dates.dart` on question-days answered jointly.
- Notification: one opt-in daily ping at a user-chosen time ("Sam hasn't answered yet — yours is waiting").
- Demo mode: simulated partner answers ~randomly after 5–20s so the reveal actually happens — same machinery as `_demoAllow()` in `demo_backend.dart`.

### 3.2 Check-in → **"How are we both, today?"**
**Today** (`_TodayCard` in `home_screen.dart`): you log your mood alone; partner's mood is a passive line of text.
**Change to:** mutual pulse — both faces in one card, a small "we both said Good" celebration when both match, and a gentle nudge ("Sam hasn't pulsed yet — poke ♡") instead of silence. Rename "Daily check-in" → **"Pulse"** or **"How are we?"** to kill the clinical word. The five `MoodChip`s stay (they're good) — add 1-tap note via a single text field labelled with a pet name.

### 3.3 Time capsules → **actual letters, not JSON blobs**
**Today:** plain dialog with `body` text. **Change to:** paper-texture card (`#FFF7FA` + 3% noise PNG), handwritten font (bundle **Caveat** or **Gochi Hand**, ~12 KB subset, add `family:` to pubspec), wax-seal icon (`Icons` custom painted or a tiny SVG), envelope-open scale/rotate animation before the letter (the file already sets `transitionDuration: AppDurations.fast` — extend it), "sealed by Sam · opens in 43 days" metadata line, optional voice note later (P2). This one screen converts the app's best metaphor into its best craft moment.

### 3.4 Coupons → **hand-illustrated tickets with peel**
**Today:** ticket clipper already exists (`_TicketCutPainter` in `coupons_screen.dart`) — good bones. **Change:** notch scallops on all four corners, dashed rule with pair of scissors icon, "FROM Sam ♡" stamp, peel-to-redeem gesture (AnimatedSwitcher → rotate/fade the stub), confetti burst on redeem, hand-lettered title. Keep seeded coupons; add "suggest one they'll love" based on love language (see 4.6).

### 3.5 Home → **"Us", not a dashboard**
**Today:** greeting → demo banner → hero → live card → "Today" → 8-tile grid → nudge card. It's competent. **Change:**
1. Replace corporate subtitle with pet-name greeting: "Good morning, Alex ♡ Sam".
2. One card: **Today's question** (see 3.1) with both-answer state — the emotional anchor.
3. A slim **"us line"**: day count + both streak faces + a one-tap **♡ Thinking of you** button (see 4.2).
4. Keep the 8-tile grid but move it below — it's a menu, not a morning.
5. The "one nudge" card stays; rewrite its three captions to speak ("Sam's capsule opens in 12 days — say something good", not "Unlocks in 12 days").
6. DEMO banner: keep, but as a playful stitched tag ("DEMO — everything here is make-believe").

### 3.6 Copy rewrite — kill generator-speak (before → after, real changes)

| Before (current) | After |
|---|---|
| A private space for two. | Just us, in here. (or: "You & me — no noise.") |
| A tiny pulse check for the two of you. | One tap to tell {partner} how you are. |
| Little acts of love, ready to redeem. | Coupons! Trade me. |
| Write it now. Open it later. | Sealed today. Read together later. |
| A little something to look forward to. | Someday soon, you two. |
| Teamwork makes the shared life lighter. | Split it, no scorekeeping. |
| Nothing on the list yet — add the first little plan. | Blank slate. Add the first someday-dream. |
| Your album is empty. | Sunday's photo prompt is waiting. |
| No deep talks yet. | One question, one honest answer. |
| Saved. That's 12 days. | 12 days of us, in a row. |

Rule: always a pet name or "us" where possible; never "the two of you" (third-person); never three-beat corporate rhythm; contractions; one emoji/stamp per screen max. Write a `docs/VOICE.md` (sample lines for every screen + do/don't) so future copy doesn't drift back to AI.

### 3.7 Chores → **"Our home" — demote the spreadsheet**
Keep functionality; reframe. Rename tab label in-app to "Home stuff", fairness bar becomes "This week: you 4 · Sam 3 · us 2 — even-ish ✓", hearts instead of checkmarks stay. Move it **below** the fold or to More; it's logistics, not romance. Same for goals → keep, but label **"Dream jar"** with the jar-fill from the redesign doc actually implemented instead of a plain progress bar.

### 3.8 Shell & density
- 3 tabs are right. Rename **More → Us** (holds couple photo, pet names, anniversary, coupons/letters/joint settings) and **Connect → Together**? Careful: don't churn names users know; only rename Connect if Home is doing the ritual. Recommend: keep Home / Connect / More; rename only the *screen titles* inside (Home → "Us", More → "Us & settings") — actually simplest: **Home titled "Us"**, Connect unchanged, More → "Us".
- Reduce one type-size per screen; purge uppercase; cap max width 520 on tablets (already done in setup).

### 3.9 Re-audit & cut
Run [UI_REDESIGN.md §6 twelve rules](UI_REDESIGN.md) after the redesign above. Specifically **remove**: `_ChoreStat`-era copy remnants, the literal all-caps `LIVE DISTANCE` / `LIVE` badges in the live-distance card & screen, `DAY $days` eyebrow styling in Home, and `AppGradients.sunrise/lilac/sunset/ocean/meadow` usages in feature screens (keep `brand` + `soft` only). Note the all-caps strings are literals, not `toUpperCase()` calls (the only `toUpperCase()` in the codebase is initials in `avatar.dart`, which is fine) — so this is a copy sweep, not a refactor.

---

## 4. What to ADD (new features, by ROI)

### P0 — the retention triangle (4–6 weeks)

**4.1 Today's Question** — as §3.1. *Market proof:* Paired's whole company is one blind mutual question a day; Agapé 4.8★ is the same loop. This converts YOU&ME from a shelf of tools into a daily habit.

**4.2 "Thinking of you" one-taps** *(ship in week 1, it's tiny)*
- 8 tap types (heart, hug, kiss, good morning, good night, made me laugh, proud of you, miss you) — reuses the `AppArt` pipeline for artwork, plus haptics (`HapticFeedback.lightImpact`) on send/receive.
- Delivery: write to `couples/{id}/moments/{autoId}`; partner's device shows a high-priority `firebase_messaging` push ("Sam is thinking of you ♡") with inline reply actions ("Love you too") — reuse the **exact notification-action machinery already built for Live Distance** (`notification_service.dart` showLiveRequest/cancelLiveRequest, action callbacks in `LiveSessionHost`). This is the strongest argument for doing taps in this codebase: the hard part is done.
- Taps are stored, surfaced as a **timeline strip** on Connect ("This week: 6 taps — mostly good nights ♡") and in the recap (4.4).
- Failure mode to avoid: no notification spam — max one aggregated tap per hour, batch the rest.
- *Market proof:* Tap, obimy, NUJJ — one-tap presence is a category of its own; [Tap](https://play.google.com/store/apps/details?id=com.tapapp.tap) even replies from the notification shade.

**4.3 Personalization: pet names, couple photo, relationship title**
- Schema: `users/{uid}` gains `petNameForMe` (what *I* want to be called) — actually store once per couple: `couples/{id}` gains `myPetName`, `yourPetName` (symmetric), `title` ("The Happy Eggs", "Mr & Mrs", free text, 28 chars), `photoUrl`, `metOn` (date), `loveLanguage` (enum, 5). Nullable → no migration; `fromMap` defaults preserve old docs.
- Shown: home greeting, hero eyebrow ("Since {metOn} ♡"), app bar title ("{title}"), settings header, recap, share cards.
- Cost: one new section in Settings + 3 fields + copy touchpoints. Feels disproportionately handmade — this is the "this was made for *us*" layer.

**4.4 Weekly "Our Week" recap** *(shareable image)*
- A 9:16 card: both faces, both mood lines, streak, taps sent, coupons redeemed, one best question. Rendered with `RepaintBoundary` → PNG → system share sheet (`share_plus`, 1 dep). No backend.
- *Market proof:* Tap's "relationship recap", Between's timeline; wrapped-style recaps are the single most shareable artifact a couples app can produce — free acquisition loop.

**4.5 Widgets** — `home_widget` plugin (add `home_widget: ^0.7`, supports iOS 14+ WidgetKit & Android):
- Small: days-together counter (pink heart, day N — pre-rendered, tap opens app).
- Medium: partner mood face + day count + one-tap ♡ button (Android action button / iOS AppIntent is fiddly — v1 just opens app to tap).
- This is what Locket/Tap/Cupla users put on their home screens; invisible value, daily impressions, zero ongoing effort. *Effort is real on iOS (WidgetKit Swift target) — schedule it after P0 ships.*

### P1 — anticipation & memory (3–4 weeks)

**4.6 Love Language onboarding** — 5-minute 5-question quiz (words, quality time, acts, gifts, touch) → store on couple doc → (a) personalize coupon suggestions ("Words? Try 'tell them one specific thing you love'"), (b) flag what questions to prioritize, (c) show both results side by side in Settings like Love Nudge. Reuses nothing, ~2 screens. *Market proof:* Love Nudge is [the most durable free app in the category](https://justuseapp.com/en/app/495326842/love-nudge/reviews).

**4.7 Date Night goal** — "We want a date every {week/2 weeks/month}" → Cupla-style reminder ("Saturday looks open — plan something small?"), one-tap "We did it ✓" stamps, date streak. Backed by the strongest category research: [Cupla's reported 75% friction reduction / 65% more quality time](https://apps.apple.com/us/app/cupla-couples-shared-calendar/id1557764033). Uses existing bucket date ideas as the activity pool — no calendar integration (cut scope).

**4.8 Special dates & countdowns** — add `specialDates[]` on the couple doc (met, first date, proposal, moving in, wedding) with countdown pills on Home ("First date anniversary · 84 days ♡"), auto-added anniversary, and a confetti screen on the day (extend `HeartPop`). Between's killer retention feature, minus the chat.

**4.9 Memory timeline ("Our story")** — one scrollable chronological feed combining: capsules opened, photos completed, both-answer questions (with consent to keep), taps milestones, day-100/200/300 stamps. Read-only, nostalgia-shaped. Between users [call this "why I stay"](https://www.onedateidea.com/reviews/between-app/). All data already exists; it's a new screen + provider, no schema.

### P2 — delight & depth (later, only if P0/P1 stick)
- Shared notebook (two columns, alternating prompts).
- Voice capsules (record 30s, `flutter_sound`, base64 in demo / Storage in firebase).
- Mood overlap insight ("You're both lowest on Sundays — Sundays together fix that 😏") — careful with tone.
- Seasonal skins (Valentine's, anniversary month, winter).
- Photo-to-sticker couple avatar via `image_picker` + on-device crop (research item; do not promise).
- iOS Live Activities for day count / capsule countdown.

### Explicitly DO NOT build
- **Chat** (Between/WhatsApp own it; you can't out-chat the default messenger, and moderation/encryption becomes your job).
- **Full calendar sync** (Google/Apple/Cupla own it; sync bugs destroy trust) — the date-night goal covers the need.
- **Finance** (Honeydue owning; also regulatory blast radius).
- **AI girlfriend/boyfriend** (cheapens the brand; off-mission; privacy nightmare).
- **More chores/goals features** — they're at saturation; reframe, don't grow.

---

## 5. How it works — technical blueprint (mapped to this repo)

### 5.1 New Firestore/demo model additions (all nullable/additive — no migrations)
```
users/{uid}:               + petNameForMe, loveLanguage? (or on couple), answersHiddenCount
couples/{id}:              + title, photoUrl, myPetName, yourPetName, metOn, loveLanguage,
                           + dateNightCadence ('week'|'biweekly'|'monthly'), specialDates[] {label,date},
                           + questionStreak, questionLastKey
couples/{id}/question/current:  {dateKey, questionId, uid, text, createdAt} per partner (two docs or map field)
couples/{id}/moments/{id}:      {type, fromUid, createdAt}   ← append-only, member-only rules
couples/{id}/answers/{day}:     {questionId, answers: {uid: text}}  ← or single "current" doc like live/current
```
Rules: extend the existing `match /couples/{coupleId}/{collection}/{docId}` wildcard — **zero rules changes needed** for moments/answers if nested under the couple. `analysis_options.yaml` untouched.

### 5.2 Demo backend parity checklist (where new features live in `demo_backend.dart`)
- `watchQuestion()`, `saveAnswer()`, `simulatePartnerAnswer()` — mirror `sendLiveRequest`/`_demoAllow` auto-allow timers.
- `sendMoment()`, `watchMoments()` — broadcast streams for badge counts.
- `saveSpecialDate()`, `setDateNightCadence()`, `savePetNames()` — plain persistence + seed for Alex & Sam (met 2024-02-14, title "The Happy Eggs", language: Words for Sam / Quality Time for you — visibly rendered in demo).

### 5.3 Notification plumbing you already own
`NotificationService` (`lib/services/notification_service.dart`) — add: `showDailyQuestion()` (zoned schedule via `flutter_local_notifications` + `flutter_timezone ^4`), `showMoment(name, type)` with action `moment_reply`, `cancelMoment(id)`. `LiveSessionHost` already shows how to route action taps; add `_onMomentEvent`. iOS category `moments` with `Reply` action, Android channel `moments` (high importance).

### 5.4 Widgets
`home_widget` for Android (home screen) + iOS (SwiftUI WidgetKit extension — new `ios/Widget/` target, ~150 lines Swift, reads shared `UserDefaults` group `group.com.youandme.app`). Data source is read from prefs mirror (`widget.snapshot` JSON written on every save) so no network in widget.

### 5.5 Recap image
`RepaintBoundary` around a 320×568 widget → `toImage(pixelRatio: 3)` → temp file → `share_plus ^10`. No server. Works offline in demo.

### 5.6 Love language quiz
Pure Flutter (3 screens, no deps). Scoring: 5 questions × 2 points → ranking; store first language on couple doc. Coupon/question personalization reads it via `sessionProvider` (extend `SessionState` with `loveLanguage`).

### 5.7 Rollout & estimates (solo dev, honest)
| Phase | Contents | Effort |
|---|---|---|
| **0 — Voice & skin** | VOICE.md, copy rewrite, paper/noise texture asset, Caveat font, capsule letter UI, 4-gradient purge, all-caps purge | 1–2 wks |
| **1 — Ritual core** | Today's Question (blind reveal, 90 prompts, demo partner sim, notification), pet names + couple title, mutual pulse card | 2–3 wks |
| **2 — Presence** | Moments (8 tap types, push actions, replies), moments strip on Connect, weekly Our Week recap image | 2 wks |
| **3 — Anticipation** | Special dates + countdowns + day-stamp confetti, date-night goal + nudge, memory timeline | 2 wks |
| **4 — Reach** | `home_widget` both platforms, quiz onboarding, love-language personalization | 2–3 wks |
| **Throughout** | `flutter analyze` clean, tests for new providers (extend demo_backend_test: blind-reveal reveal condition, moment persistence, streak), APK rebuild | — |

### 5.8 Risks & anti-goals
- **Notification fatigue** → one question ping/day (user-set time, default 20:00), taps aggregated hourly, everything else silent. Measure opt-out.
- **Both-partner cold start** → if partner hasn't joined, question still answerable solo; partner join pops "Sam answered yours ✓" once.
- **Scope creep** → P0 ships before any P1 starts. Love language quiz is skippable in onboarding.
- **Timeline consent** → questions only enter "Our story" if both marked "keep".
- **Don't ship half-built widgets** to iOS without testing on-device; Android-only first is acceptable if iOS target slips.
- **Metric north star:** 7-day mutual-question completion rate ≥ 40%; taps/couple/week ≥ 5 by week 4; D30 retention ≥ 35%; notification opt-out < 20%.

---

## 6. Summary — the three moves

1. **Give YOU&ME a daily heartbeat:** Today's Question (blind both-answer reveal). This is what Paired sells for $70/yr; YOU&ME can own it with warmth.
2. **Make touch free:** one-tap Thinking-of-You hearts with haptics and reply-from-notification. Between vibes, Tap mechanics, zero typing.
3. **Hand it back to humans:** paper, handwriting, pet names, inside jokes, no all-caps, and a voice doc. Delete the generator gloss before adding a single feature.

Everything else — bucket lists, goals, chores, capsules, live map — is already competent. Polished but faceless. Personality is the product gap, not features.

---

## Sources
- Paired reviews & pricing: [App Store reviews](https://apps.apple.com/us/app/paired-couples-relationship/id1469609343) · [Paired review](https://panoramicposts.com/paired-app-review/) · [feelclose long-term review](https://feelclose.app/blog/paired-couples-app-review/) · [UI why-it-works](https://www.lemon8-app.com/experience/best-features-of-paired-couples-app-interface)
- Between: [review](https://www.onedateidea.com/reviews/between-app/) · [comparison](https://habi.app/insights/best-couple-apps/) · [review drawbacks](https://www.onedateidea.com/reviews/between-app/)
- Love Nudge: [App Store](https://apps.apple.com/au/app/love-nudge/id495326842) · [review notes](https://justuseapp.com/en/app/495326842/love-nudge/reviews)
- Cupla: [App Store](https://apps.apple.com/us/app/cupla-couples-shared-calendar/id1557764033) · [blog / research claims](https://cupla.app/blog/best-shared-calendar-apps-for-couples-in-2026/)
- Tap / obimy / NUJJ / Locket: [Tap on Google Play](https://play.google.com/store/apps/details?id=com.tapapp.tap) · [LDR apps list](https://www.wikihow.com/Apps-for-Long-Distance-Couples)
- Agapé & category overview: [Best couples apps for iPhone](https://ourio.app/best-couples-apps/) · [unite.ai 10 best](https://www.unite.ai/best-ai-apps-for-couples/) · [Match.com roundup](https://www.match.com/p/dating-advice/best-couples-apps/)
- Why apps die: [r/Marriage](https://www.reddit.com/r/Marriage/comments/1qt8f1l/are_couple_apps_worth_the_money/) · [r/apps](https://www.reddit.com/r/apps/comments/1qao3tr/any_good_couples_apps_youd_recommend/) · [Privé Game: maintenance vs moment](https://privegame.com/en/blog/best-apps-for-couples) · [Cupla busy schedules](https://cutestcouple.app/best-couple-apps-for-busy-schedules/)
- Anti-AI design: [AI + human imperfection](https://www.marcfriedmanportfolio.com/blog/ai-imperfect-aesthetics/) · [soulless AI design](https://cda.academy/ai-generated-design-soulless/) · [intentional imperfection guide](https://www.illustration.app/blog/how-to-add-intentional-imperfection-to-ai-generated-designs)
