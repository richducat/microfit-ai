# App Review Notes

Use this file as the exact reviewer-facing source for the build being submitted.

## Build identity

- App: microfit.AI
- Existing Apple ID: 1341965047
- Bundle ID: com.microfit.app
- Version: 2.1
- Build: 2026071302

## Summary for App Review

microfit.AI 2.1 adds an optional Human Trainers mode to the approved local-first fitness experience. Athletes can read an owner-reviewed public directory and prepare a one-to-one match request. Fitness professionals can prepare a structured application for human review. The app has no account, remote database, ads, analytics, tracking, purchases, or subscriptions; fitness history stays on device.

## Login

- Login required: No
- Demo username: Not applicable
- Demo password: Not applicable
- Extra login steps: Not applicable

## How to test the core flow

1. Launch the app and complete the short onboarding. No account or contact information is requested for the core fitness experience.
2. On Today, change Energy, Sleep, Soreness, or Stress and observe the readiness score and recommended plan update.
3. Open Plan, choose a workout, complete at least one set, and tap Finish & Log. Move provides a shorter timed-session path.
4. Open Coach → AI Coach and choose a prompt. Eligible iOS 26 devices use Apple’s on-device Foundation Models; all other supported devices automatically use the offline adaptive coach.
5. Open Coach → Human Trainers. The first public directory may be empty while founding applications are reviewed; this is an intentional honest state. Request a Trainer Match or Apply to Join to inspect the structured flows.
6. The match/application action opens a prepared draft in Mail (or Share). The user must review and send it; the app does not silently transmit the form and does not claim it was sent merely because the draft opened.
7. Open Me → Privacy & Data to review local storage, the trainer handoff disclosure, policy/support links, and Delete All My Data.

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

## Privacy, trainer network, and AI

- No personal or fitness data is automatically collected by the developer or third parties.
- There are no analytics, ad, attribution, social-login, or third-party AI SDKs.
- Human Trainers fetches a versioned static JSON directory from the owned GitHub Pages site. No fitness history or app user identifier is added to the request.
- Match requests and applications are created in local view state. They leave the app only when the user explicitly opens and sends the prepared message through another app.
- A basic profile summary is optional and off by default. Readiness, workout, nutrition, habit, and coach history are never attached.
- Trainer applications require adult status, accuracy confirmation, and consent before approved public fields may be published. Applications never publish automatically.
- Athlete match requests require an adult or parent/guardian and consent to follow-up.
- On eligible devices, coaching uses Apple Foundation Models locally. Prompts and fitness history are not sent to a Microfit server.
- Data shared with AI service providers: None.
- Health or personal data shared with AI service providers: None.
- The complete offline coach keeps the feature functional when Apple Foundation Models are unavailable.
- All local records and pending reminders can be removed with Me → Delete All My Data.

## Additional reviewer notes

- The trainer directory is curated by the developer. User applications do not become user-generated content in the app until the owner reviews and deliberately publishes an approved profile.
- No in-app payment is offered. The request starts a conversation for one-to-one fitness training; it does not book, charge, sell group access, or deliver a digital product.
- A "credentials reviewed" badge means only that the submitted credential reference was checked before publication. The UI explicitly states that it is not a background check, medical referral, or outcome guarantee.
- Verified devices:
  - iPhone 17 Pro on iOS 26.5
  - iPhone 16 Pro on iOS 18.2
  - iPad Air 11-inch (M4) on iPadOS 26.5 in portrait and landscape
- Known non-blocking limits:
  - Apple Foundation Models availability varies by compatible hardware, language, region, and Apple Intelligence state. The offline coach is automatic and requires no setup.
- Anything Apple should not misinterpret:
  - The product name contains “AI,” but the app does not call an external AI service or collect prompts. “Private on-device AI” is shown only when Apple’s local model is actually available.
  - Microfit provides general fitness and wellness guidance, not diagnosis or treatment.
  - Human Trainers does not require a login and does not reduce access to any previously approved local feature when the directory is offline or empty.
