#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
APP_ID="1341965047"
VERSION="2.0"
BUILD_NUMBER="2026070901"
METADATA_DIR="$ROOT/app-store/releases/microfit-ai/asc-metadata"
BUILD_ID="${MICROFIT_BUILD_ID:-}"

if [[ "${1:-}" != "--confirm-submit" ]]; then
  echo "Review submission is fail-closed. Re-run with --confirm-submit only after asc validate is clean."
  exit 2
fi

command -v asc >/dev/null || { echo "asc is required for review submission." >&2; exit 1; }
command -v jq >/dev/null || { echo "jq is required to resolve the build ID." >&2; exit 1; }
asc auth status >/dev/null 2>&1 || {
  echo "No App Store Connect API credentials are configured. Run 'asc auth login' or use the authenticated App Store Connect web session." >&2
  exit 1
}

if [[ -z "$BUILD_ID" ]]; then
  BUILD_JSON="$(asc builds info --app "$APP_ID" --build-number "$BUILD_NUMBER" --output json)"
  BUILD_ID="$(printf '%s' "$BUILD_JSON" | jq -r '.data.id // .id // .build.id // empty')"
fi

[[ -n "$BUILD_ID" ]] || { echo "Could not resolve App Store Connect build ID for $BUILD_NUMBER." >&2; exit 1; }

asc metadata validate --dir "$METADATA_DIR"
asc release stage \
  --app "$APP_ID" \
  --version "$VERSION" \
  --build "$BUILD_ID" \
  --metadata-dir "$METADATA_DIR/version/$VERSION" \
  --strict-validate \
  --confirm

asc validate --app "$APP_ID" --version "$VERSION" --platform IOS --strict --output table
asc review submit --app "$APP_ID" --version "$VERSION" --build "$BUILD_ID" --confirm

echo "Submitted microfit.AI $VERSION build $BUILD_NUMBER for App Review."

