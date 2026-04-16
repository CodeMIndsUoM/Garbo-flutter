# Phase Notes: WebSocket Route Integration

## What Was Done In This Phase

- Replaced static sample route data in the collection team routes page with live data from WebSocket snapshots.
- Kept the existing UI flow (route cards, start route, collect/skip/undo bin) while swapping data source from mock to backend stream.
- Added dynamic mapping from snapshot payload to UI models:
- RouteData is built from snapshot route payload.
- BinData lists are generated per route from payload bins.
- Added defensive parsing for common backend key variants to reduce payload-shape breakage.
- Added empty-state behavior when no routes are available from socket data.
- Added cleanup/sync logic so route UI state maps stay valid when route list changes between snapshots.
- Kept snapshot debug preview card to inspect latest socket payload in-app.

## WebSocket Source Used

- Socket URL is generated as: <backend-base-url>/ws
- STOMP topic subscribed: /topic/routes/users/{userId}
- Base URL is resolved from BACKEND_URL dart-define when provided.

## Android USB Debugging Setup (Important)

For physical Android devices over USB, use adb reverse and loopback host:

```bash
adb reverse tcp:8080 tcp:8080
flutter run --dart-define=BACKEND_URL=http://127.0.0.1:8080
```

Notes:
- 10.0.2.2 is for Android emulator only.
- For real devices without adb reverse, use your laptop LAN IP and allow firewall access.

## Suggested Commit Message

Primary suggestion:

```text
feat(collection-team): consume live websocket route snapshots instead of mock route/bin data
```

Alternative options:

```text
feat(routes): wire collection team routes page to STOMP websocket stream and dynamic payload mapping
```

```text
refactor(collection-team): replace sample route fixtures with backend-driven websocket state
```

## Scope Covered

- File touched in this phase:
- lib/presentation/collection_team/pages/routes.dart
