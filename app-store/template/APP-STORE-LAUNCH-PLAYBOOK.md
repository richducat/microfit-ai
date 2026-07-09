# App Store Launch Playbook

Reviewed against Apple documentation on April 13, 2026.

This playbook is the repeatable path for shipping a new app or an update to the App Store with the fewest avoidable review problems.

## Phase 0: Business readiness

Before product work, confirm the App Store account can legally sell and ship the app.

- Confirm the Apple Developer membership is active.
- If the app is free and has no in-app purchases, you can ship under the standard developer agreement.
- If the app is paid or offers any in-app purchase or subscription, the Account Holder must have the Paid Apps Agreement in `Active` status.
- Confirm banking and tax information are complete if the app is paid or uses in-app purchases.
- If the app is available in the EU, confirm trader status is reviewed and accurate.

## Phase 1: App record setup

Create or confirm the App Store Connect app record and lock in the identifiers that cannot change later.

- App name: 2 to 30 characters.
- Subtitle: 30 characters max.
- Bundle ID: must match Xcode exactly.
- SKU: internal only, but cannot be changed later.
- Primary category and secondary category: choose the closest real fit.
- Copyright line.
- Age rating questionnaire: answer honestly and review the iOS 26 age-rating changes.
- If the app will be distributed in special territories with extra requirements, resolve those first.

## Phase 2: Product-page assets

Make the public-facing surfaces real before the binary goes to review.

- Privacy policy URL must be live.
- Support URL must be live and contain real contact information.
- Marketing URL should be live if used.
- Terms or custom EULA should be live if the app uses subscriptions or if legal review requires it.
- The app icon must be final in the native asset catalog, not just in web assets.
- Screenshots must show the app in use, not just splash or title art.

Recommended screenshot coverage:

- If the app supports iPhone, provide 6.9-inch screenshots or 6.5-inch screenshots at minimum.
- If the app supports iPad, provide 13-inch iPad screenshots.
- Use real screens that show the core value, permissions, monetization states, and any differentiating UI.
- If you use copy overlays, keep them truthful and specific to the screen shown.

## Phase 3: App privacy and permissions

Treat privacy and permission work as submission blockers, not polish.

- Add a privacy policy link in App Store Connect metadata.
- Make the privacy policy easy to find inside the app.
- Complete App Privacy answers in App Store Connect for the app and all third-party SDK behavior.
- Keep App Privacy answers current whenever SDKs or tracking behavior change.
- Review every permission prompt string and make sure it clearly explains the actual use.
- If the app creates accounts, the app must provide in-app account deletion.
- If the app uses third-party or social login for the primary account, make sure the Sign in with Apple equivalence rule is satisfied when required.
- Review privacy manifests and required-reason APIs for the app and bundled third-party SDKs.

## Phase 4: Monetization rules

Pick the correct monetization branch and satisfy the matching rules.

### Paid app or in-app purchase

- Use Apple in-app purchase for digital goods, features, subscriptions, or premium unlocks.
- Confirm the Paid Apps Agreement is active before trying to submit or test paid flows.
- Create the in-app purchase product record and keep its metadata clean.
- Test sandbox purchase availability before submission.

### Subscriptions

- Explain exactly what the user gets for the price before the purchase ask.
- Show restore purchases inside the app.
- Keep Privacy Policy and Terms accessible in the subscription UI.
- Add subscription testing steps to review notes.
- If the app description or screenshots feature premium content, make it clear when additional purchase is required.

### Ads

- Update App Privacy answers to match the ad SDK and its data collection.
- If the ad stack uses tracking, implement the required consent flow and ATT behavior.
- If the ad network requires a root-domain verification file, publish it before submission.
- Verify that free and paid ad-free states both work on device.

## Phase 5: Build readiness

The binary must be review-ready, not just buildable.

- Build with the current Apple-required Xcode and SDK baseline.
- As of April 13, 2026, Apple says uploads must use Xcode 26 and the iOS 26 family SDKs beginning April 28, 2026.
- Confirm export-compliance answers for encryption.
- If no export documents are required, keep the Info.plist export-compliance key configured so you do not get blocked on every submission.
- If export documents are required, upload them early and wait for the Apple key if applicable.
- Verify the native icon and launch assets from the archive, not only from Xcode previews.

## Phase 6: QA matrix

Run submission QA on the families Apple is likely to use, not just your personal phone.

Minimum recommended smoke matrix:

- current iPhone simulator or device
- current iPad simulator or device if the app runs on iPad
- fresh install launch
- settings open and close
- permissions flows
- subscription or in-app purchase flows if present
- ad-supported flow and ad-free flow if present
- offline or poor-network resilience for the first-run path
- notification scheduling and delivery if applicable
- calendar, contacts, photos, camera, microphone, location, or health access if applicable

For every release, explicitly verify:

- no startup crash
- no frozen settings or modal screens
- no broken purchase restoration
- no dead-end permission flows
- no clipped layouts on supported devices
- screenshots match the shipping UI closely enough to satisfy metadata accuracy

## Phase 7: Review packet

This is where many avoidable rejections happen.

Prepare build-specific review notes every time:

- exact version and build
- what changed in this build
- whether login is required
- stable demo credentials if login is required
- how to reach the premium flow if subscriptions or IAP exist
- how to test notifications, background behavior, or hardware features
- what permissions appear and why
- whether ads are present and how the paid ad-free state is triggered
- any region-limited, entitlement-limited, or hardware-limited behavior

Rule:

- Do not reuse stale notes from an older build.
- If the build number changes, the review notes must change with it.

## Phase 8: Submission settings

Use the least risky release settings for the moment.

Recommended defaults:

- First release of a brand-new app: `Manual release after approval`
- Risky monetization update: `Manual release after approval`
- Low-risk maintenance update: `Automatic` or `Phased release` if appropriate

Before pressing submit:

- Confirm the build attached to the version is the build described in the notes.
- Confirm the right screenshots are attached for every required family.
- Confirm the privacy policy, support URL, and any subscription terms links are live.
- Confirm App Privacy answers match the shipping build, not last week’s build.
- Confirm the app version notes and in-app purchase notes are both filled if applicable.

## Phase 9: Post-submission monitoring

After submission:

- Watch build-processing status.
- Watch export-compliance status.
- Watch the app version state and the review-submission state.
- Save Apple rejection text verbatim in the repo.
- If rejected, fix the actual issue, re-verify on the cited device class, and update review notes with the exact fix and exact build.

## Rejection loop

When Apple rejects:

1. Save the rejection text in the release folder.
2. Classify it:
   - metadata accuracy
   - app completeness or performance
   - privacy
   - payments or subscriptions
   - legal or regional compliance
3. Reproduce on the cited device family.
4. Fix the issue in code or metadata.
5. Re-run the smoke matrix.
6. Rewrite review notes so they mention the new build and the exact fix.
7. Resubmit only when notes, build, and verification are aligned.

## Lessons encoded from our successful launch

- Reviewer notes are part of the product. Treat them like code.
- iPad must be treated as a first-class review device if the app runs there.
- Privacy/support/legal URLs must be live before the version is submitted.
- Subscription review fails fast when legal links, restore, or product availability are incomplete.
- Ads change privacy disclosures and need their own QA pass.
- Build-specific verification screenshots and notes are worth the time because they shorten review loops.
