#!/bin/bash
# Run Flutter app on iOS simulator with proper UTF-8 encoding for CocoaPods
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
cd "$(dirname "$0")"
flutter run -d "iPhone 14 Pro Max" "$@"
