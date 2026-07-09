# App Store Launch Checklist

Use this checklist only after the app is actually feature-complete.

## Account and business

- [ ] Apple Developer membership is active.
- [ ] If the app is paid or uses IAP, Paid Apps Agreement is `Active`.
- [ ] Banking information is complete if the app is paid or uses IAP.
- [ ] Tax information is complete if the app is paid or uses IAP.
- [ ] EU trader status is reviewed if the app is available in the EU.

## App record

- [ ] App name is 2 to 30 characters and defensible under Apple metadata rules.
- [ ] Subtitle is 30 characters or fewer.
- [ ] Bundle ID matches Xcode exactly.
- [ ] Age rating questionnaire is completed and current.
- [ ] Categories are set accurately.

## Public URLs

- [ ] Marketing URL is live if used.
- [ ] Support URL is live and contains real contact info.
- [ ] Privacy policy URL is live.
- [ ] User privacy choices URL is live if offered.
- [ ] Terms or EULA link is live if subscriptions exist.

## Privacy and legal

- [ ] App Privacy answers are updated for the current build.
- [ ] Privacy policy is accessible inside the app.
- [ ] Permission strings clearly explain why access is needed.
- [ ] If accounts can be created, in-app account deletion exists.
- [ ] Privacy manifest and required-reason APIs were reviewed for the app and third-party SDKs.
- [ ] Export compliance questions were answered.
- [ ] Export compliance plist key or approved documentation is in place.

## Monetization

- [ ] Digital unlocks use Apple in-app purchase.
- [ ] All IAP products are configured and available.
- [ ] Subscriptions show clear value, restore, privacy, and terms.
- [ ] Ads, if present, are reflected in privacy disclosures.
- [ ] Free, paid, and restored states were all tested.

## Assets and metadata

- [ ] Screenshots show the app in use.
- [ ] iPhone screenshot set is attached.
- [ ] iPad screenshot set is attached if the app runs on iPad.
- [ ] Metadata does not over-promise or show non-shipping UI.
- [ ] What's New text matches the actual release.
- [ ] Review notes mention the exact build being submitted.

## QA

- [ ] Fresh install launch passes.
- [ ] Settings screens do not freeze or dead-end.
- [ ] Core app flow passes on iPhone.
- [ ] Core app flow passes on iPad if supported.
- [ ] Notifications, background flows, and permissions were tested if used.
- [ ] Purchase flow and restore flow were tested if used.
- [ ] Ad flow was tested if ads are enabled.
- [ ] No clipping or layout overflow on supported devices.

## Submission

- [ ] Attached build is the build referenced in review notes.
- [ ] Required app-review contact info is filled in.
- [ ] Demo credentials are included if login is required.
- [ ] Release setting is intentional: manual, automatic, or scheduled.
- [ ] Preflight script passes with zero errors.
