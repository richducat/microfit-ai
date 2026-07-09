# microfit.AI

An independent, native iOS fitness app that replaces the legacy MicroFit App Store build (com.microfit.app, Apple ID 1341965047) without modifying the Lab Studio source repository.

microfit.AI adapts training to daily readiness and keeps a useful fallback available when time or recovery is limited. The app is local-first: no account, backend, ads, analytics, tracking, purchases, or subscription.

## Product

- Five-step local onboarding
- Energy, sleep, soreness, and stress readiness scoring
- Adaptive strength, conditioning, balance, and recovery plans
- Set, rep, load, rest, duration, and effort logging
- Three-to-five-minute timed micro-sessions
- Nutrition anchors for protein, fiber, plants, and water
- Habits, streaks, XP, achievements, history, and progress insights
- Opt-in local movement reminders
- Apple Foundation Models coaching on eligible iOS 26 devices
- Complete deterministic offline coach on every supported device
- In-app privacy disclosure and local data deletion

## Requirements

- Xcode 26.5 or later
- iOS/iPadOS 18.0 deployment target
- Apple team WN3K69XEP4 for signed archives

## Build and test

~~~sh
xcodebuild -project ios/MicrofitAI/MicrofitAI.xcodeproj \
  -scheme MicrofitAI \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build

swift test --package-path ios/MicrofitCore
~~~

A debug launch with --microfit-demo seeds deterministic, screenshot-ready local data.

## Release

~~~sh
scripts/release/build_archive.sh
scripts/release/upload_app_store.sh --confirm-upload
scripts/release/submit_review.sh --confirm-submit
~~~

The upload and submission scripts fail closed. See app-store/releases/microfit-ai/ and docs/ai/release.md for the exact metadata and gate status.

## Public pages

The static site under site/ is deployed through GitHub Pages:

- Marketing: https://richducat.github.io/microfit-ai/
- Support: https://richducat.github.io/microfit-ai/support/
- Privacy: https://richducat.github.io/microfit-ai/privacy/

