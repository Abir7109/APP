# Live Distance

Live Distance is a consent-first, temporary location share between two partners.
One person asks, the other says yes, and for a short window the app shows a
cute map with both of them and the distance between their hearts.

It is **not** continuous background tracking. A session starts with an explicit
request, needs an explicit Allow, and ends automatically.

## Experience

1. On Home, the partner taps the **Live distance** card.
2. The app asks for the device location permission (first time only) and sends
   a live request with their current point.
3. The requester sees a waiting state: "Waiting for Sam to allow".
4. The partner gets a local notification:
   **"Sam misses you"** / *Tap Allow to share your location for a little while.*
   with **Allow** and **Not now** actions. If the app is open, the same prompt
   appears as a floating card above whatever screen they are on.
5. If the partner allows, their device resolves a location and the session
   becomes active. Both phones watch the same session and see:
   - two illustrated heart pins,
   - a dashed pink path,
   - a distance pill ("1.2 km apart", "Right next to you" under 100 m),
   - a small "live until 14:32" label.
6. Location updates stream while the map is open. The active session expires
   after 15 minutes, or either person can tap **End**.
7. Denied, ended, and expired sessions are shown with a gentle explanation and
   a **Ask again** action.

Demo mode simulates the partner: the request auto-allows after ~4 seconds, the
partner drifts slowly, and **Preview incoming request** (demo only) lets the
user test the notification/popup flow without a second device.

## States

| Status | Meaning | UI |
| --- | --- | --- |
| `pending` | Request sent, waiting for consent | Waiting card + cancel |
| `allowed` | Both points available | Map + distance |
| `denied` | Partner said not now | Soft message + ask again |
| `ended` | Either person ended it | Soft message + ask again |
| expired | Pending past `expiresAt` | Soft message + ask again |

`expired` is derived on the client, not stored.

## Data model

```text
LiveSession
  requesterId, requesterName
  status: pending | allowed | denied | ended
  createdAt, respondedAt?, expiresAt?
  points: { uid: LivePoint }

LivePoint
  latitude, longitude, updatedAt, accuracy?
```

Firestore stores one document per couple:

```text
couples/{coupleId}/live/current
```

Fields mirror `LiveSession.toMap()`. The existing
`couples/{coupleId}/{collection}/{docId}` member rule covers it. Location points
are deleted when the session ends? No: the document is kept for the ended state
but points are cleared on end. This keeps a tiny audit-free state and avoids
stale pins if the screen is reopened.

## Architecture

- `AppBackend` gains:
  - `watchLiveSession()`
  - `sendLiveRequest(requesterName, point)`
  - `respondToLiveRequest(allow, point)`
  - `updateLiveLocation(point)`
  - `endLiveSession()`
  - `simulateIncomingLiveRequest(...)` (demo only)
- `DemoBackend` persists the session in SharedPreferences, auto-allows after a
  short delay, simulates partner drift, and supports preview requests.
- `FirebaseBackend` reads/writes the `live/current` document and uses dotted
  field updates (`points.{uid}`) so the two clients do not overwrite each other.
- `LiveDistanceController` (Riverpod `Notifier`) owns the user-facing actions:
  request, allow/deny, end, location stream subscription, timers, errors.
- `LiveSessionHost` sits inside the app shell. It watches the session, shows the
  floating request prompt, displays notifications, handles notification
  actions, and starts/stops the location stream.
- `LocationService` wraps `geolocator` and returns friendly errors for
  permission denied, denied forever, and location services off.
- `NotificationService` wraps `flutter_local_notifications`:
  - Android channel `live_distance` with high importance.
  - Actions `live_allow` / `live_deny` with `showsUserInterface: true`, so
    tapping one opens the app and runs the normal in-app callback.
  - iOS/macOS category `live_distance` with foreground actions.
  - Handles cold-start launches via `getNotificationAppLaunchDetails`.

## Map

- Real OpenStreetMap-based CartoDB Positron tiles, tinted soft pink.
- Two heart markers, a dashed rose polyline, a distance pill, and a "you" halo.
- `CameraFit.coordinates` frames both points with comfortable padding.
- Attribution: "© OpenStreetMap · © CARTO".
- If tiles fail (offline, rate limit), the map still renders a pastel
  background, pins, path, and distance. The distance math does not depend on
  tiles.
- Demo mode uses a fallback point (Eiffel Tower) if the device has no location,
  so the experience can be previewed anywhere.

## Privacy and safety

- No background location. Updates only run while the session is `allowed` and
  the app is in the foreground.
- Location is shared only with the linked partner through the couple-scoped
  document.
- 15-minute cap, visible end time, and one-tap End.
- Notifications only say "misses you"; precise coordinates never appear in the
  notification.
- A denied request cannot be retried automatically; the requester must ask
  again (no spam loop).

## Failure handling

| Failure | Behavior |
| --- | --- |
| Permission denied | Friendly sheet with "Open settings" |
| Services off | Friendly sheet with "Open location settings" |
| No fix / timeout | Use last known point; otherwise explain and stop |
| Partner offline | Request stays pending until expiry |
| Tiles offline | Pastel fallback map; pins and distance still work |
| Notification permission denied | In-app popup still works |

## Rollout phases

1. Data + demo simulation (works without Firebase).
2. Location + notifications + host popup.
3. Map screen and active session polish.
4. Firebase backend parity + rules check.
5. Home/nav redesign around the new card.
6. Tests, docs, and platform config.

## Platform config

- Android: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`,
  `POST_NOTIFICATIONS`; `compileSdk 37` + core library desugaring for
  `flutter_local_notifications` 23.x; notification icon
  `@drawable/ic_stat_heart`.
- iOS: `NSLocationWhenInUseUsageDescription`.
- Web: the map and distance math work, but notifications and geolocation are
  best-effort; the UI explains when unavailable.
