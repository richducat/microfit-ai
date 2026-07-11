# Risks

## Open

- `asc auth status` reports no credentials. The prepared screenshot replacements and resubmission require the authenticated App Store Connect browser session.
- The old listing has no App Privacy disclosure. The 2.0 submission must publish accurate no-tracking/local-data answers before review.
- `microfit.ai` has no DNS record. Live support, privacy, and marketing URLs must use an owned reachable host before submission.
- Existing App Store ownership is evidenced by the developer account/store record, but current agreements/trader status still require an authenticated check.
- Foundation Models behavior varies by device eligibility, language, region, and download state. The deterministic fallback is a release blocker until tested.
- A signed archive may expose provisioning/certificate issues for the legacy bundle ID.

## Closed

- Guideline 2.3.3 screenshot accuracy: closed locally by producing validated current-version 5.5-inch iPhone and iPad Pro (2nd Gen) replacement sets; App Store Connect upload remains pending.
- Risk of modifying Lab Studio: closed by separate clone, native-only delta import, and removal of the clone remote.
- Risk of depending on Lab Studio production: product architecture decision removes all Lab API/auth/commerce dependencies.
