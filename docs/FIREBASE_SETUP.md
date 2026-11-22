# Firebase Setup

YOU&ME runs without Firebase in **Demo Mode**. Follow these steps to enable real sharing between two devices.

## 1. Create a Firebase project

1. Open the [Firebase console](https://console.firebase.google.com/).
2. Create a project (for example `you-and-me`).
3. Add an **Android** app with package name `com.youandme.app`.
4. Add an **iOS** app with bundle ID `com.youandme.app`.
5. Add a **Web** app if you plan to ship the web build.

## 2. Enable services

- **Authentication → Sign-in method → Anonymous**: enable it. The app never shows a login screen; anonymous auth gives each device a stable identity.
- **Firestore Database**: create it in production mode (rules below lock it down).
- **Storage**: enable it for photo challenge uploads.
- **Cloud Messaging**: optional. The app registers an installation ID and stores it on the user document, but push delivery is not part of the MVP.

## 3. Generate Flutter options

Install the FlutterFire CLI and run it from the project root:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This replaces the placeholder `lib/firebase_options.dart` with real project values. The app checks for Firebase at startup and automatically falls back to Demo Mode if initialization fails.

### Android

`flutterfire configure` can add `google-services.json`. If you prefer manual setup:

1. Download `google-services.json` from Firebase.
2. Place it in `android/app/`.
3. Ensure the Google Services Gradle plugin is applied if your FlutterFire version requires it.

### iOS

1. Download `GoogleService-Info.plist`.
2. Add it to `ios/Runner/` in Xcode (target membership: Runner).

### Web

1. Add the Firebase JS SDK config to `web/index.html` if required by your FlutterFire version.
2. For messaging on web, provide a VAPID key when registering.

## 4. Deploy rules

From the project root:

```bash
firebase deploy --only firestore:rules,storage
```

Rules live in `firestore.rules` and `storage.rules`. See `docs/SECURITY_RULES.md` for the full model and caveats.

## 5. Verify

1. Run the app on two devices (or two browser profiles).
2. On device A, create a space. Copy the 6-digit PIN.
3. On device B, choose **Join with PIN** and enter the PIN.
4. Both devices should see the same space, partner name, and shared items.

## Notes

- **No email/password.** Pairing is PIN-based by design.
- **Demo data is local.** Leaving a space in Demo Mode returns you to setup; the demo data stays on the device.
- **Photo storage.** Firebase uploads go to `couples/{coupleId}/photos/`; Demo Mode stores a data URL locally.
- **Push.** Only installation-ID plumbing is included. Sending notifications requires a Cloud Function or server.
