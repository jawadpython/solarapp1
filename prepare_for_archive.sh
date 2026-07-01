#!/bin/bash
# Prepare project for Xcode archive by copying to a path WITHOUT SPACES
# This fixes: ProcessException: No such file or directory

set -e
SRC="/Users/pc/Desktop/solarapp/solarapp1 copy"
DEST="/Users/pc/Desktop/solarapp1"

echo "Copying project to path without spaces..."
echo "From: $SRC"
echo "To:   $DEST"

rm -rf "$DEST" 2>/dev/null || true
cp -R "$SRC" "$DEST"

echo ""
echo "Running flutter clean and pub get..."
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
cd "$DEST"
flutter clean
flutter pub get

echo ""
echo "Running pod install..."
cd "$DEST/ios"
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
pod install

echo ""
echo "Fixing Pods script permissions (fixes archive 'Permission denied')..."
chmod +x "$DEST/ios/Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks.sh" 2>/dev/null || true

echo ""
echo "Done! Now:"
echo "  1. Open: open $DEST/ios/Runner.xcworkspace"
echo "  2. In Xcode: Product → Archive → Distribute App"
echo ""
