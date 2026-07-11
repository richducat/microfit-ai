# App Review Notes

Use this file as the exact reviewer-facing source for the build being submitted.

## Build identity

- App: microfit.AI
- Existing Apple ID: 1341965047
- Bundle ID: com.microfit.app
- Version: 2.0
- Build: 2026070901

## Summary for App Review

microfit.AI 2.0 is a ground-up native replacement for the legacy MicroFit build. It provides adaptive daily readiness, full workout logging, timed micro-sessions, nutrition anchors, habits, progress, and private coaching. It has no account, backend, ads, analytics, tracking, purchases, or subscriptions; user-created data stays on device.

## Login

- Login required: No
- Demo username: Not applicable
- Demo password: Not applicable
- Extra login steps: Not applicable

## How to test the core flow

1. Launch the app and complete the five short onboarding steps. No account or contact information is requested.
2. On Today, change Energy, Sleep, Soreness, or Stress and observe the readiness score and recommended plan update.
3. Open Plan, choose a workout, complete at least one set, and tap Finish & Log. Move provides a shorter timed-session path.
4. Open Coach and choose a prompt. Eligible iOS 26 devices use Apple’s on-device Foundation Models; all other supported devices automatically use the offline adaptive coach.
5. Open Me → Privacy & Data to review local storage details, external policy/support links, and the Delete All My Data control.

## Permissions and background behavior

- Notifications used: Yes. Only opt-in local notifications scheduled on device for movement reminders.
- Push notifications used: No.
- Calendar used: No.
- Photos used: No.
- Camera used: No.
- Location used: No.
- HealthKit used: No.
- Background modes used: No.

## Monetization

- Ads present: No
- In-app purchases present: No
- Subscription present: No
- Paywall or purchase screen: Not applicable
- Restore path: Not applicable

## Privacy and AI

- No data is collected by the developer or third parties.
- There are no analytics, ad, attribution, social-login, or third-party AI SDKs.
- On eligible devices, coaching uses Apple Foundation Models locally. Prompts and fitness history are not sent to a Microfit server.
- Data shared with AI service providers: None.
- Health or personal data shared with AI service providers: None.
- The complete offline coach keeps the feature functional when Apple Foundation Models are unavailable.
- All local records and pending reminders can be removed with Me → Delete All My Data.

## Additional reviewer notes

- Guideline 2.3.3 remediation:
  - The stale legacy-specific screenshot sets were removed in App Store Connect. The 5.5-inch iPhone slot now uses the current 6.9-inch set, and iPad Pro (2nd Gen) now uses the current 13-inch set.
  - The binary is unchanged; this resubmission corrects only the rejected screenshot metadata.
- Verified devices:
  - iPhone 17 Pro on iOS 26.5
  - iPhone 16 Pro on iOS 18.2
  - iPad Air 11-inch (M4) on iPadOS 26.5 in portrait and landscape
- Known non-blocking limits:
  - Apple Foundation Models availability varies by compatible hardware, language, region, and Apple Intelligence state. The offline coach is automatic and requires no setup.
- Anything Apple should not misinterpret:
  - The product name contains “AI,” but the app does not call an external AI service or collect prompts. “Private on-device AI” is shown only when Apple’s local model is actually available.
  - Microfit provides general fitness and wellness guidance, not diagnosis or treatment.
