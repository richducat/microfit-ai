# Status

Updated: 2026-07-11

## Current phase

App Review rejection remediation in progress in the independent clone at `/Users/richardducat/GITHUB/microfit-ai`.

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
- Uploaded and processed version 2.0 build 2026070901, assigned it to the internal TestFlight group, and verified Richard Ducat installed it.
- Submitted App Review submission `188ff39a-fe9a-4cc6-8fe5-77532a23bf06` on July 9, 2026.
- Diagnosed Apple's July 11 Guideline 2.3.3 rejection: stale 5.5-inch iPhone and iPad Pro (2nd Gen) screenshots remained in legacy media slots.
- Produced and validated six current-build replacement screenshots for each rejected legacy slot.

## In progress

- Upload the two replacement legacy-size screenshot sets and resubmit the unchanged version 2.0 build 2026070901.

## Pending

- Verify the resubmission returns to Waiting for Review or In Review.
- After approval, verify version 2.0, screenshots, privacy/support links, and automatic release on the public listing.
