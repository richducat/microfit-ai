#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PROJECT="$ROOT/ios/MicrofitAI/MicrofitAI.xcodeproj"
SCHEME="MicrofitAI"
CONFIGURATION="Release"
TEAM_ID="WN3K69XEP4"
BUNDLE_ID="com.microfit.app"
VERSION="2.0"
BUILD_NUMBER="2026070901"
BUILD_DIR="${MICROFIT_BUILD_DIR:-$ROOT/build}"
ARCHIVE_PATH="$BUILD_DIR/MicrofitAI.xcarchive"
EXPORT_DIR="$BUILD_DIR/export"
EXPORT_OPTIONS="$ROOT/app-store/releases/microfit-ai/ExportOptions.plist"

command -v xcodebuild >/dev/null
command -v plutil >/dev/null

mkdir -p "$BUILD_DIR"
rm -rf "$ARCHIVE_PATH" "$EXPORT_DIR"

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  CODE_SIGN_STYLE=Automatic \
  MARKETING_VERSION="$VERSION" \
  CURRENT_PROJECT_VERSION="$BUILD_NUMBER" \
  -allowProvisioningUpdates \
  clean archive

APP_PATH="$ARCHIVE_PATH/Products/Applications/MicrofitAI.app"
[[ -d "$APP_PATH" ]] || { echo "Archive is missing MicrofitAI.app" >&2; exit 1; }

ACTUAL_BUNDLE_ID="$(plutil -extract CFBundleIdentifier raw "$APP_PATH/Info.plist")"
ACTUAL_VERSION="$(plutil -extract CFBundleShortVersionString raw "$APP_PATH/Info.plist")"
ACTUAL_BUILD="$(plutil -extract CFBundleVersion raw "$APP_PATH/Info.plist")"

[[ "$ACTUAL_BUNDLE_ID" == "$BUNDLE_ID" ]] || { echo "Bundle ID mismatch: $ACTUAL_BUNDLE_ID" >&2; exit 1; }
[[ "$ACTUAL_VERSION" == "$VERSION" ]] || { echo "Version mismatch: $ACTUAL_VERSION" >&2; exit 1; }
[[ "$ACTUAL_BUILD" == "$BUILD_NUMBER" ]] || { echo "Build mismatch: $ACTUAL_BUILD" >&2; exit 1; }

codesign --verify --deep --strict --verbose=2 "$APP_PATH"

xcodebuild \
  -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_DIR" \
  -exportOptionsPlist "$EXPORT_OPTIONS" \
  -allowProvisioningUpdates

IPA_PATH="$(find "$EXPORT_DIR" -maxdepth 1 -name '*.ipa' -print -quit)"
[[ -n "$IPA_PATH" && -f "$IPA_PATH" ]] || { echo "No IPA was exported" >&2; exit 1; }

echo "Archive: $ARCHIVE_PATH"
echo "IPA: $IPA_PATH"
echo "Identity: $ACTUAL_BUNDLE_ID $ACTUAL_VERSION ($ACTUAL_BUILD)"

