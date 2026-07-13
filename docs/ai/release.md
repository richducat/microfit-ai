# Release record

## App identity
- App name: microfit.AI
- Bundle id: com.microfit.app
- App Store Connect app id: 1341965047
- Apple team id: WN3K69XEP4
- Platform: iOS

## Build settings
- Workspace: Not used
- Project: ios/MicrofitAI/MicrofitAI.xcodeproj
- Scheme: MicrofitAI
- Configuration: Release
- Version: 2.1
- Build number: 2026071302
- Export options plist: app-store/releases/microfit-ai/ExportOptions.plist
- Upload options plist: app-store/releases/microfit-ai/UploadOptions.plist

## Review access
- Demo mode path: Not needed; no login
- Demo username: Not applicable
- Demo password reference: Not applicable
- Special setup steps: Fresh launch onboarding can be completed with any choices; all core fitness data is generated and stored on device. Coach → Human Trainers loads a curated public directory and supports match/application email handoff.

## Compliance paths
- Marketing URL: https://richducat.github.io/microfit-ai/
- Support URL: https://richducat.github.io/microfit-ai/support/
- Privacy URL: https://richducat.github.io/microfit-ai/privacy/
- Account deletion path in app: Not applicable; no account. Settings includes Delete All My Data.
- Purchase path summary: No purchases, subscriptions, or external checkout
- Login methods: None
- Third-party AI/data sharing summary: None. Eligible devices use Apple's on-device Foundation Models; fallback coaching is local deterministic logic. The Human Trainers feature fetches a static public directory without fitness data or a user identifier; applications and match requests leave the app only through an explicit user-controlled mail/share action.

## Metadata
- Subtitle: Adaptive fitness, built daily
- Keywords: workout,fitness,trainer,strength,exercise,habit,nutrition,readiness,mobility,recovery
- What's New: Human Trainers directory, athlete matching, and trainer application details in the 2.1 metadata
- Review notes path: app-store/releases/microfit-ai/review-notes.md
- Screenshot asset folder: app-store/releases/microfit-ai/screenshots/

## Release commands
- Build/archive command: scripts/release/build_archive.sh
- Upload command: scripts/release/upload_app_store.sh
- Submit review command: scripts/release/submit_review.sh

## Status
- Compliance sign-off: Complete. App Store Connect shows a completed 9+ age rating, a non-regulated-medical-device declaration, and published Data Not Collected privacy details
- QA sign-off: Complete for 2.1. Seven core unit tests, Debug simulator compilation, iPhone/iPad layouts, iOS 18.2/iOS 26.5 behavior, accessibility-extra-extra-extra-large Dynamic Type, VoiceOver labels, privacy copy, JSON, plist, sitemap, shell, and launch-manifest checks pass.
- Archive status: Complete. App Store distribution IPA exported at `build/2.1-2026071302/export/MicrofitAI.ipa`; verified as `com.microfit.app` 2.1 (2026071302), distribution-signed, `get-task-allow=false`, and beta-reporting enabled. The prior signed 2.0 archive remains unchanged.
- Upload status: Successful. Xcode uploaded build 2026071302 on July 13, 2026 at 12:05 PM EDT and App Store Connect accepted the package for processing.
- TestFlight status: Public 2.0 and its prior internal build remain intact. Build 2026071302 is processing; internal-group availability still requires App Store Connect confirmation after processing.
- Public trainer directory status: Live and verified. `/trainers/`, `/data/trainers.json`, `/privacy/`, and `/support/` return HTTP 200; directory schema version is 1 and the initial reviewed profile count is zero.
- Screenshot status: Six ordered iPhone 6.9-inch and six ordered iPad 13-inch screenshots are attached; the stale legacy-specific sets were deleted, the 5.5-inch iPhone slot now uses the 6.9-inch set, and iPad Pro (2nd Gen) now uses the 13-inch set
- Release configuration: Automatically release immediately to all users after App Review approval; phased release is off
- Review submission status: Version 2.0 is approved and publicly live. Version 2.1 has not been submitted for App Review.
