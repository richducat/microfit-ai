# Decisions

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
