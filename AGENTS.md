# App delivery working agreement

## Mission
Ship an approvable, testable, release-ready iOS app update with honest metadata, complete review access, and a repeatable release path.

## Execution model
- This repository is operated by one delivery owner. Do not delegate work to other agents.
- The active owner maintains the control docs and is the only human-facing coordinator.
- The active owner personally performs the final QA and release gate before any build is uploaded or submitted.

## Core operating rules
- Plan first, then change code.
- Keep `docs/ai/status.md`, `docs/ai/decisions.md`, `docs/ai/risks.md`, and `docs/ai/release.md` current.
- Make the smallest viable set of changes that closes the goal.
- Run relevant build, lint, typecheck, and test commands before claiming completion.
- Never invent test results, upload results, screenshots, review notes, credentials, or URLs.
- Never commit secrets, certificates, API keys, passwords, session cookies, or 2FA codes.
- Use environment variables or secure local secret references only.
- If a secret is missing, finish everything else and report the exact missing items once.
- Never edit, clean, commit, deploy, or push `/Users/richardducat/GITHUB/labstudio-app`; it is source reference only.

## Apple release guardrails
- Treat App Store compliance as a launch blocker, not a polish task.
- No risky purchase-linking behavior in the app unless explicitly allowed for the target storefronts.
- If the app uses social or third-party login for the primary account, verify the required equivalent login option.
- If the app creates accounts, verify in-app account deletion.
- Ensure demo mode or review credentials exist and are valid before release.
- Screenshots and metadata must reflect the real product.
- If In-App Purchases changed, prepare their separate review steps too.

## Handoff template
Every release handoff must contain these sections:
1. Objective
2. What I checked
3. What changed
4. Evidence
5. Risks / blockers
6. Recommended next owner

## Definition of done
Done means:
- product changes merged locally,
- checks passed,
- App Store blockers addressed or explicitly listed,
- release artifacts prepared,
- and the active owner has recorded an upload/submission result or a precise blocker list.
