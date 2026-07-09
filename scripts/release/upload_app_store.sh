#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
APP_ID="1341965047"
BUILD_NUMBER="2026070901"
BUILD_DIR="${MICROFIT_BUILD_DIR:-$ROOT/build}"
ARCHIVE_PATH="$BUILD_DIR/MicrofitAI.xcarchive"
IPA_PATH="${MICROFIT_IPA_PATH:-$BUILD_DIR/export/MicrofitAI.ipa}"
UPLOAD_OPTIONS="$ROOT/app-store/releases/microfit-ai/UploadOptions.plist"

if [[ "${1:-}" != "--confirm-upload" ]]; then
  echo "Upload is fail-closed. Re-run with --confirm-upload after verifying the archive identity."
  echo "Expected: com.microfit.app 2.0 ($BUILD_NUMBER), Apple ID $APP_ID"
  exit 2
fi

[[ -d "$ARCHIVE_PATH" ]] || { echo "Missing archive. Run scripts/release/build_archive.sh first." >&2; exit 1; }

if command -v asc >/dev/null && asc auth status >/dev/null 2>&1 && [[ -f "$IPA_PATH" ]]; then
  asc builds upload --app "$APP_ID" --ipa "$IPA_PATH"
  asc builds wait --app "$APP_ID" --build-number "$BUILD_NUMBER" --timeout 30m
else
  echo "No App Store Connect API profile is available; using the signed-in Xcode account."
  xcodebuild \
    -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$BUILD_DIR/upload" \
    -exportOptionsPlist "$UPLOAD_OPTIONS" \
    -allowProvisioningUpdates
fi

echo "Upload request completed for build $BUILD_NUMBER."

