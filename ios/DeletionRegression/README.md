# MicroFit deletion regression tests

These macOS XCTest tests compile the app's actual state and model files. Controlled coaching and notification providers suspend the actual asynchronous state methods while deletion runs; they do not invoke Apple's on-device model or schedule real notifications.

Coverage: stale coaching must not restore a deleted snapshot; authorization or notification-add completion after deletion must not restore reminders; stale cleanup must preserve a newer reminder configuration; deletion after restart must clear persisted request identifiers.

Requirements: Xcode supporting macOS 26 and Swift 6, and XcodeGen.

From the repository root:

```sh
xcodegen generate --spec ios/DeletionRegression/project.yml
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild test \
  -project ios/DeletionRegression/MicrofitDeletionRegression.xcodeproj \
  -scheme DeletionRegression -destination 'platform=macOS' \
  CODE_SIGNING_ALLOWED=NO
```

The production defaults remain Apple's on-device coaching and notification APIs. The test providers control asynchronous completion to make deletion races deterministic.
