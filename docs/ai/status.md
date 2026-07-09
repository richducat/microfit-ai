# Status

Updated: 2026-07-09

## Current phase

Release preparation in progress in the independent clone at `/Users/richardducat/GITHUB/microfit-ai`.

## Completed

- Verified existing store identity: MicroFit, Apple ID `1341965047`, bundle ID `com.microfit.app`, live version 1.5.
- Cloned the Lab Studio repository without changing the original checkout.
- Imported the original checkout's current native-only delta into the clone.
- Removed the clone's Git remote to prevent accidental Lab Studio pushes.
- Scaffolded release-control docs and a Microfit App Store launch manifest.
- Defined a local-first product direction against current Trainerize and Trainify feature sets.
- Generated a distinct Microfit app icon.
- Replaced the Lab target with a standalone native `MicrofitAI` target while preserving bundle ID `com.microfit.app` for the existing listing.
- Removed inherited Lab web, deployment, CRM, and automation code from this clone only.
- Implemented onboarding, readiness, adaptive plans, full workout logging, timed micro-sessions, nutrition anchors, habits, progress, achievements, reminders, and local deletion.
- Added Apple Foundation Models coaching on eligible iOS 26 devices and a complete deterministic fallback on iOS 18+.
- Added privacy manifest, in-app privacy/support links, App Store metadata, review notes, and fail-closed release scripts.
- Passed Swift unit tests and simulator builds; exercised iPhone/iPad, iOS 18/26, portrait/landscape, VoiceOver labels, and large Dynamic Type.
- Built and browser-tested a static marketing, support, and privacy site with no tracking.

## In progress

- App Store screenshot capture, signed archive, independent GitHub publication, and App Store Connect staging.

## Pending

- Publish the independent repository and verify live support/privacy/marketing URLs.
- Capture and validate 6.9-inch iPhone and 13-inch iPad App Store screenshot sets.
- Complete App Store Connect privacy, age-rating, trader-status, category, metadata, and review-detail fields.
- Produce a signed archive, upload build 2026070901, verify processing/TestFlight, and submit version 2.0 for review.
