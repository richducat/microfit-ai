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
- Version: 2.0
- Build number: 2026070901
- Export options plist: app-store/releases/microfit-ai/ExportOptions.plist
- Upload options plist: app-store/releases/microfit-ai/UploadOptions.plist

## Review access
- Demo mode path: Not needed; no login
- Demo username: Not applicable
- Demo password reference: Not applicable
- Special setup steps: Fresh launch onboarding can be completed with any choices; all core data is generated and stored on device.

## Compliance paths
- Marketing URL: https://richducat.github.io/microfit-ai/
- Support URL: https://richducat.github.io/microfit-ai/support/
- Privacy URL: https://richducat.github.io/microfit-ai/privacy/
- Account deletion path in app: Not applicable; no account. Settings includes Delete All My Data.
- Purchase path summary: No purchases, subscriptions, or external checkout
- Login methods: None
- Third-party AI/data sharing summary: None. Eligible devices use Apple's on-device Foundation Models; fallback coaching is local deterministic logic.

## Metadata
- Subtitle: Adaptive fitness, built daily
- Keywords: workout,fitness,trainer,strength,exercise,habit,nutrition,readiness,mobility,recovery
- What's New: Complete rebuild details in App Store manifest
- Review notes path: app-store/releases/microfit-ai/review-notes.md
- Screenshot asset folder: app-store/releases/microfit-ai/screenshots/

## Release commands
- Build/archive command: scripts/release/build_archive.sh
- Upload command: scripts/release/upload_app_store.sh
- Submit review command: scripts/release/submit_review.sh

## Status
- Compliance sign-off: Local manifest/privacy review passed; App Store Connect age-rating refresh and App Privacy publication remain
- QA sign-off: Simulator, unit, accessibility, iPad, website desktop/mobile, and iOS 18/26 coach checks passed
- Archive status: Signed distribution IPA exported and verified as com.microfit.app 2.0 (2026070901); SHA-256 acf8274f4ae11a3c095c33f87328ee48bef350f8bf53bdc1b17111493df1c2a9
- Upload status: Upload succeeded; App Store Connect processed build 2026070901 to Ready to Submit (TestFlight build ID 7b33f506-cb1c-451b-9f63-ad524f7f3c3e)
- Review submission status: Version 2.0 creation staged; metadata, screenshots, compliance answers, build attachment, and submission pending
