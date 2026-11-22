# Feature Guide

Every feature works in **Demo Mode** without Firebase. Data is stored locally and a simulated partner is included, so the whole app can be explored on one device.

## Setup and pairing

- **Create a space** — enter your name, an optional partner name, and your anniversary. The app creates a space and a six-digit PIN.
- **Join with PIN** — enter your name and the partner’s PIN. Joining appends your account to the couple.
- **Demo space** — in Demo Mode, “Open the demo space” creates a populated space instantly.
- **Waiting state** — the home screen shows an invite card with the PIN until a partner joins.
- **Settings** — edit your name, copy/share the PIN, switch theme (light/dark/system), view days together, leave the space, and read privacy notes.

Code: `lib/features/setup/`, `lib/features/settings/`, `lib/state/session_provider.dart`

## Home dashboard

The home screen is the daily ritual:

- Greeting and anniversary countdown
- Partner presence and the waiting-for-partner invite card
- Today’s check-in and partner mood
- “Next up” previews (plans, capsules, goals, chores)
- Quick actions into every feature
- Bottom navigation: Home, Plans, Connect, Album, More

Code: `lib/features/home/home_screen.dart`, `lib/features/shell/app_shell.dart`

## 1. Shared bucket list + date ideas

- Add wishes with a title, note, and category (`adventure`, `food`, `travel`, `cozy`, `date idea`, `someday`).
- Mark items done; completed items keep a completion date.
- Filter/scan by category and see progress.
- **Surprise date** — the dice button in the app bar (and “Surprise me” in Plans → Date ideas) opens a random date-idea picker with a shuffle action.

Code: `lib/features/bucket/`

## 2. Daily check-in + mood pulse

- Pick a mood from five levels, add an optional note, and check in once per day.
- See your partner’s latest mood and note.
- **Streak** counts consecutive days; the **14-day history strip** shows each recent day at a glance.
- Re-checking in on the same day updates that day instead of duplicating it.

Code: `lib/features/checkin/`, `lib/core/utils/moods.dart`

## 3. Time capsule letters

- Write a title and letter, then choose an unlock date.
- Locked capsules show a countdown; opening is disabled until the unlock date.
- Unlocked capsules can be opened and read by both partners.
- Capsules are grouped into locked and opened sections.

Code: `lib/features/capsules/`

## 4. Kindness coupon deck

- Start with seeded coupons and add custom ones.
- Redeem a coupon with a confirmation dialog; redeemed coupons move to history with a date.
- The deck shows available and redeemed coupons separately.

Code: `lib/features/coupons/`

## 5. Shared goals + savings

- Create a goal with a target amount, currency, optional deadline, and starting amount.
- Add contributions; the progress bar and remaining amount update.
- Goals show progress, deadline status, and who created them.
- Delete goals you no longer need.

Code: `lib/features/goals/`

## 6. Photo challenges

- A weekly prompt is seeded each week; add custom prompts any time.
- Take a photo or choose one from the gallery, then attach it to the prompt.
- Completed challenges appear in the shared album grid; tap to view full screen.
- Demo Mode stores the image locally as a data URL; Firebase mode uploads to Storage and saves the download URL.

Code: `lib/features/album/`

## 7. Deep-talk prompt cards

- A prompt card opens with a curated question.
- **Swipe** the card or tap **Shuffle prompt** for another question.
- Write an answer and save it as a reflection; reflections show the question, author, answer, and date.

Code: `lib/features/deep_talk/`, `lib/data/seed/seed_content.dart`

## 8. Chores + errands

- Add a task with an optional due date and assign it to you, your partner, or both.
- Mark tasks done; overdue tasks are highlighted.
- The fairness summary shows completed counts per person and the current balance.

Code: `lib/features/chores/`

## Plans and Connect tabs

- **Plans** aggregates bucket items, date ideas, capsules, and goals with section-level quick actions.
- **Connect** aggregates check-in, deep talk, coupons, and chores, plus the shared space PIN and partner status.

Code: `lib/features/plans/`, `lib/features/connect/`

## Theme and branding

- Material 3 theme with the recovered color relationships (pink/coral/peach), light/dark/system modes, and persisted choice.
- Original brand mark and launcher/splash artwork generated from `assets/brand/`.
- Android package, iOS bundle, web manifest, and display names all use **YOU&ME** / `com.youandme.app`.

Code: `lib/core/theme/`, `assets/brand/`, platform folders
