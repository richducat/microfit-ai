# Status

Updated: 2026-07-11

## Current phase

App Review monitoring after a corrected resubmission from the independent clone at `/Users/richardducat/GITHUB/microfit-ai`.

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
- Removed the stale legacy screenshots in App Store Connect and configured the 5.5-inch iPhone and iPad Pro (2nd Gen) slots to inherit the current six-frame 6.9-inch iPhone and 13-inch iPad sets.
- Answered Apple's Guideline 2.1 questions in both the review notes and App Review reply: no data, health data, or personal data is shared with an AI service provider; eligible devices use Apple's on-device Foundation Models and the fallback coach is local.
- Resubmitted unchanged version 2.0 build 2026070901 under submission `188ff39a-fe9a-4cc6-8fe5-77532a23bf06` on July 11, 2026 at 10:07 AM EDT and verified the state is Waiting for Review.
- Reverified the internal App Store Connect Users TestFlight group has one tester and one build; `richducat@gmail.com` has 2.0 (2026070901) installed.

## In progress

- Monitor submission `188ff39a-fe9a-4cc6-8fe5-77532a23bf06` while it is Waiting for Review.

## Pending

- After approval, verify version 2.0, screenshots, privacy/support links, and automatic release on the public listing.
