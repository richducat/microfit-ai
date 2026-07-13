# Decisions

## 2026-07-13

- Add the trainer network as a second mode inside the existing Coach surface rather than crowding the seven-item tab bar.
- Ship the first trainer-network slice without accounts, embedded payments, or automatically published user content: athletes can request a one-to-one trainer match, and trainers can complete a structured application that opens as a prefilled email they must explicitly send.
- Publish only owner-reviewed trainer profiles through a versioned JSON directory on the owned microfit.AI GitHub Pages site. The app must handle an empty directory and offline loading honestly; no fictional trainer will be presented as hireable.
- Keep the athlete's local fitness history private by default. A match request may include only a concise profile summary when the athlete explicitly enables that option before opening the email draft.
- Do not collect trainer application or athlete inquiry data on a Microfit server in this release. The user's mail client performs the transmission, and the privacy copy must explain the handoff.
- Do not add payments in this slice. Trainers and athletes may discuss terms directly for one-to-one services after contact; group services, digital products, and in-app purchases remain out of scope.
- Prepare this work as version 2.1 after confirming version 2.0 is publicly live; do not alter the live 2.0 binary or the Lab Studio app.

## 2026-07-11

- Treat the Guideline 2.3.3 rejection as a screenshot-only metadata correction; Apple did not report a binary defect.
- Keep version 2.0 build 2026070901 attached and replace only the stale 5.5-inch iPhone and iPad Pro (2nd Gen) screenshot sets.
- Reuse the verified current-build UI and six-frame storyboard so every device-size slot accurately represents microfit.AI 2.0.
- Use App Store Connect's supported screenshot inheritance after deleting the stale legacy-specific sets: 5.5-inch iPhone uses the current 6.9-inch set and iPad Pro (2nd Gen) uses the current 13-inch set.
- Answer Apple's Guideline 2.1 questions explicitly in both review notes and the App Review conversation: no data, health data, or personal data is shared with any AI service provider.
- Do not alter or rebuild the Lab Studio app or checkout as part of this remediation.

## 2026-07-09

- Use the existing App Store record rather than create a new app: Apple ID `1341965047`, bundle ID `com.microfit.app`.
- Ship marketing version `2.0` with build `2026070901` so the update is clearly newer than live version 1.5.
- Keep the app local-first with no account, remote database, analytics SDK, ads, or subscription in this release.
- Preserve the original MicroFit promise through timed 1-10 minute movement breaks while expanding into adaptive workouts, nutrition, habits, progress, and coaching.
- Use Apple's Foundation Models framework for private on-device generative coaching on eligible iOS 26+ devices; use a deterministic context-aware coach everywhere else.
- Use local notifications only for user-configured movement reminders.
- Target iPhone and iPad on iOS/iPadOS 18 or later.
- Do not reuse Lab Studio APIs, commerce, member accounts, copy, contact information, or production assets.
- Preserve the cloned repository history, but make `ios/MicrofitAI` the only release target.
