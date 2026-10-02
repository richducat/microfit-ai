# Risks

## Open

- The local `asc` CLI has no stored credentials and the App Store Connect browser session has expired. This no longer blocks 2.1 TestFlight delivery because Apple confirmed automatic internal distribution, but future App Store Connect metadata or submission work will require refreshed authentication.
- The trainer directory launches empty until real trainers apply and the owner reviews their credentials; the UI must not imply that fictional or unreviewed trainers are hireable.
- Email-based application and match requests require the user to send the prepared draft from a mail-capable app; the app needs a share-sheet fallback and must not claim the request was sent merely because a draft opened.
- Publishing trainer contact information requires explicit applicant consent and a removal path. Only approved fields may be added to the public JSON directory.
- Future automatic publishing, messaging, scheduling, group services, or payments would add backend, moderation, account-deletion, privacy, and App Store purchase requirements and are not silently included in this slice.

## Closed

- Version 2.1 TestFlight delivery: closed; Apple confirmed microfit.AI 2.1 (2026071302) is available to the existing tester on iOS 18 or later.
- Trainer-directory deployment: closed; the owned GitHub Pages trainer, privacy, support, and versioned JSON endpoints are live, and the in-app founding-network state was reverified against the remote directory.
- Version 2.0 public propagation: closed; the U.S. storefront lookup shows microfit.AI 2.0 with a current release date of July 12, 2026.
- Guideline 2.3.3 screenshot accuracy: closed in App Store Connect by deleting both stale legacy-specific sets and configuring the legacy slots to inherit the current 6.9-inch iPhone and 13-inch iPad screenshots.
- Guideline 2.1 AI data-sharing information: closed by adding explicit answers to review notes and the App Review reply; no data, health data, or personal data is shared with an AI service provider.
- Corrected App Review resubmission: closed; unchanged version 2.0 build 2026070901 returned to Waiting for Review on July 11, 2026 at 10:07 AM EDT.
- App Privacy: closed; Data Not Collected is published for the 2.0 submission.
- Public URLs: closed; owned GitHub Pages marketing, support, and privacy URLs are live and attached to the submission while `microfit.ai` remains unconfigured.
- App Store access and agreements: closed for this submission; the authenticated account accepted the corrected resubmission.
- Foundation Models availability: closed as a release blocker; eligible-device behavior and the automatic deterministic fallback were both tested.
- Distribution signing: closed; the signed App Store IPA was exported, uploaded, processed, and attached successfully.
- Risk of modifying Lab Studio: closed by separate clone, native-only delta import, and removal of the clone remote.
- Risk of depending on Lab Studio production: product architecture decision removes all Lab API/auth/commerce dependencies.

## October 2 deletion-race repair
Plan: invalidate asynchronous coaching/reminder work during local-data deletion, use distinct reminder request IDs to isolate stale cleanup, and retain IDs across process restarts. Source patch applied; simulator build and diff checks pass. Suspended coaching/authorization/add regression tests remain pending; no upload or submission.

Deletion repair verified October2: five deterministic XCTest races pass on macOS26.6.2 with the actual app state/model source and controlled coaching/notification providers. iOS simulator build passes with production defaults. No physical device/model/notification-service or release upload verification yet. Regression runner: ios/DeletionRegression/README.md.

## October 2 release preparation
Corrected build has not been uploaded. Historical July sign-off does not establish October runtime or review readiness. Physical TestFlight, native model and real notification-service behavior remain unverified.

October 2 notification failure follow-up: iPad Pro 13-inch M5/iOS27 extended UI test passed with no XCTest runtime warnings. Screens showed simulator notification scheduling rejection; actual partial scheduling cleanup was missing. A sixth regression reproduced leftover reminder and stored IDs, then passed after cleanup was added. All six regression tests pass. Phone/tablet UI results precede this narrowly scoped error-path patch; successful real notification delivery remains unverified. Signed archive next.
