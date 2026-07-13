# microfit.AI for iOS

`microfit.AI` is a local-first SwiftUI fitness coach for iPhone and iPad. Version 2.0 replaced the existing MicroFit App Store binary; version 2.1 adds the founding Human Trainers network while preserving the original quick-workout promise.

## Product surface

- personalized onboarding and readiness check-ins
- adaptive workout recommendation plus a stable plan library
- set, rep, load, rest, duration, and effort tracking
- timed 3–5 minute micro-workouts
- protein, fiber, plant, and hydration logging
- daily habits, XP, streaks, milestones, and seven-day activity trends
- local movement reminders
- private on-device generative coaching on eligible Apple Intelligence devices
- complete deterministic coaching fallback on every supported device
- owner-reviewed trainer directory, athlete matching requests, and trainer applications
- explicit email/share handoff; no match request or application is silently uploaded
- one-tap deletion of all local data

The app has no account, remote database, analytics SDK, ads, subscription, Lab Studio API dependency, or third-party AI endpoint. The optional Human Trainers screen reads a static public directory from the owned microfit.AI site; core fitness features remain offline-capable.

## Open and build

1. Open `ios/MicrofitAI/MicrofitAI.xcodeproj` in Xcode.
2. Select the `MicrofitAI` scheme.
3. Confirm Apple Developer Team `WN3K69XEP4` and bundle ID `com.microfit.app`.
4. Build for an iOS 18+ simulator or device.

Command-line simulator build:

```bash
xcodebuild -project ios/MicrofitAI/MicrofitAI.xcodeproj \
  -scheme MicrofitAI \
  -configuration Debug \
  -sdk iphonesimulator \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## Release identity

- App Store Connect Apple ID: `1341965047`
- Bundle ID: `com.microfit.app`
- Version: `2.1`
- Build: `2026071302`
- Apple team: `WN3K69XEP4`

Release metadata and QA evidence live under `app-store/releases/microfit-ai/` and `docs/ai/`.
