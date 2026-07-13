# Status

Updated: 2026-07-13

## Current phase

Version 2.1 implementation in the independent clone at `/Users/richardducat/GITHUB/microfit-ai`: add athlete-to-trainer matching and a trainer application path without changing Lab Studio.

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
- Verified the public App Store listing propagated as microfit.AI 2.0 on July 12, 2026, with the new icon, current description and release notes, iOS 18 minimum, and owned marketing URL.
- Reverified the owned marketing, support, and privacy URLs return HTTP 200.
- Implemented Human Trainers inside Coach with an owner-reviewed remote directory, honest empty/offline states, athlete search and filters, trainer profiles, a structured trainer-match request, and a structured trainer application.
- Kept all trainer and athlete contact transmission user-controlled through a review-before-send mail/share handoff; optional local profile-summary sharing is off by default.
- Added trainer application validation, matching logic, and email validation coverage to MicrofitCore; all seven unit tests pass.
- Passed iPhone and iPad simulator validation on iOS/iPadOS 18.2 and iOS 26.5, including VoiceOver labels and accessibility-extra-extra-extra-large Dynamic Type.
- Passed JSON, plist, sitemap, shell, launch-manifest, and signed-artifact validation for version 2.1 build 2026071302.
- Exported a valid App Store distribution IPA for `com.microfit.app` 2.1 (2026071302) with `get-task-allow=false` and uploaded it successfully on July 13, 2026 at 12:05 PM EDT. Apple accepted the package for processing.
- Published and live-verified the trainer-network page, updated privacy/support pages, and version 1 trainer directory at `https://richducat.github.io/microfit-ai/`; the founding directory intentionally contains zero profiles until real applicants are reviewed.
- Relaunched the app against the live directory endpoint and verified the Human Trainers surface loads its honest founding-network state without relying on Lab Studio.
- Confirmed Apple finished processing and distributed version 2.1 build 2026071302 to the existing TestFlight tester. Apple's July 13, 2026 at 12:07 PM EDT notification says the build is ready to install on iOS 18 or later.

## In progress

- None for the version 2.1 internal TestFlight release.

## Pending

- Install and exercise the TestFlight build on a physical device before any later App Review submission.
- Version 2.1 has not been submitted to App Review; public version 2.0 remains unchanged.
