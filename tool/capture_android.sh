#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
device="${1:-emulator-5554}"
capture_screen="${2:-}"
adb_path="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}/platform-tools/adb"
if [[ ! -x "$adb_path" ]]; then adb_path="$(command -v adb)"; fi
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart --dart-define="CAPTURE_SCREEN=$capture_screen" --keep-app-running -d "$device"
mkdir -p docs/screenshots
remote_dir="$("$adb_path" -s "$device" shell run-as com.barber.barber find . -type d -name barber-screenshots | tr -d '\r' | head -n 1)"
if [[ -z "$remote_dir" ]]; then echo "Screenshot directory not found" >&2; exit 1; fi
if [[ -n "$capture_screen" ]]; then
  "$adb_path" -s "$device" exec-out run-as com.barber.barber \
    cat "$remote_dir/$capture_screen.png" > "docs/screenshots/$capture_screen.png"
else
  "$adb_path" -s "$device" exec-out run-as com.barber.barber \
    tar -C "$remote_dir" -cf - . | tar -xf - -C docs/screenshots
fi
