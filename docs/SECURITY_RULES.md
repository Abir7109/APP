# Security Rules

YOU&ME uses **Firebase Anonymous Authentication**. There is no login screen; each device gets a stable anonymous UID. Pairing is a six-digit PIN that maps to a couple document.

The deployable rules are:

- [`firestore.rules`](../firestore.rules)
- [`storage.rules`](../storage.rules)

Deploy with:

```bash
firebase deploy --only firestore:rules,storage
```

## Firestore model

- `users/{uid}` — readable/updatable only by the owner. Partners can read each other because the app queries `users` filtered by `coupleId`, and the list rule only allows documents whose `coupleId` matches the caller’s own `coupleId`.
- `pins/{pin}` — readable by any signed-in user by exact document ID (needed to resolve an invite), never listable. A PIN document cannot be updated. It can be deleted by a couple member or after the couple is gone.
- `couples/{coupleId}` — readable only by members or by a signed-in user who is actively joining (no current space, space has fewer than two members). Only members can update/delete. A join may only append the caller’s UID to `memberIds`.
- `couples/{coupleId}/**` — every feature subcollection is readable and writable only by members of that couple.

## Storage

Photo challenge uploads live at `couples/{coupleId}/photos/{fileName}`. Reads and writes require membership in the couple, and writes are limited to images under 8 MB.

## What is intentionally not included

These are documented MVP trade-offs, not oversights:

- **No push delivery.** The app stores a Firebase Installation ID on the user document, but sending notifications requires a trusted server/Cloud Function.
- **No custom claims or admin roles.** Membership is the only authorization boundary.
- **PIN deletion is broad by design.** Any signed-in user can delete a PIN document if they are a member or the couple no longer exists. Tighten this if PIN recycling becomes a concern.
- **No rate limiting.** Firestore/App Check should be added before a public launch.

## Recommended production hardening

1. Enable **Firebase App Check** for Android/iOS/Web.
2. Add **Cloud Functions** for push delivery and for privileged PIN operations.
3. Add **TTL** or cleanup for abandoned `pins` documents.
4. Restrict Storage content types and sizes further if needed.
5. Add a **delete-account** flow that removes the user document and membership.
