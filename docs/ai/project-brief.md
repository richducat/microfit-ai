# Project brief

## Objective
Clone the current Lab Studio native iOS experience into this independent repository, rebrand it as microfit.AI, remove all Lab Studio infrastructure and data dependencies, add a competitive adaptive-fitness feature set, and replace the existing MicroFit App Store binary.

## Business goal
Restore the owner-controlled MicroFit product as a modern, independent fitness app without changing or depending on the Lab Studio app, backend, listing, or production data.

## User goal
Create a personal plan, complete guided workouts and short movement breaks, track sets, nutrition, habits, readiness, streaks, and progress, receive reminders, and ask a private on-device coach for useful guidance.

## Release target
- Platform: iOS
- Desired outcome: Upload, TestFlight verification, App Review submission, and manual production release for the existing MicroFit listing
- Deadline: As soon as all release gates pass

## Hard constraints
- No secrets in repo
- Do not modify `/Users/richardducat/GITHUB/labstudio-app` or the Lab Studio App Store record
- Do not call or reuse `app.labstudio.fit`, Lab Studio credentials, customer data, copy, or commerce
- Preserve the existing MicroFit App Store identity: Apple ID `1341965047`, bundle ID `com.microfit.app`
- Work single-owner; do not delegate
- Must pass App Store review goals relevant to this release

## Known risks
- App Store Connect CLI credentials are not currently installed in the system keychain.
- The 2018 listing has no published App Privacy answers and needs a full privacy refresh.
- Support, marketing, and privacy URLs for the new brand must be live before submission.
- Apple Foundation Models are available only on eligible devices; the app needs a complete offline fallback.

## Success criteria
- Original Lab Studio checkout has no new changes from this project.
- Shipped binary contains no Lab Studio names, URLs, bundle identifiers, or customer-specific flows.
- Fresh install supports the complete core experience without login or network access.
- Unit tests, simulator builds, accessibility/visual QA, archive, export, and App Store preflight pass.
- Version 2.0 is attached to the existing MicroFit listing and submitted with current metadata, screenshots, privacy answers, and reviewer notes.
