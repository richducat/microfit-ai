# microfit.AI for iOS

`microfit.AI` is a local-first SwiftUI fitness coach for iPhone and iPad. Version 2.0 replaces the existing MicroFit App Store binary while preserving its original quick-workout promise.

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
- one-tap deletion of all local data

The app has no account, remote database, analytics SDK, ads, subscription, Lab Studio API dependency, or third-party AI endpoint.

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
- Version: `2.0`
- Build: `2026070901`
- Apple team: `WN3K69XEP4`

Release metadata and QA evidence live under `app-store/releases/microfit-ai/` and `docs/ai/`.
