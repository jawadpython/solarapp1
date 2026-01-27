#!/bin/bash

# iOS App Store Release Preparation Script
# This script prepares your Flutter app for iOS App Store submission

set -e  # Exit on error

echo "🚀 Preparing Tawfir Energy for iOS App Store Release..."
echo ""

# Navigate to project directory
PROJECT_DIR="/Users/pc/Desktop/solarapp1 copy"
cd "$PROJECT_DIR"

echo "📦 Step 1: Cleaning Flutter build..."
flutter clean

echo ""
echo "📥 Step 2: Getting Flutter dependencies..."
flutter pub get

echo ""
echo "📦 Step 3: Installing CocoaPods dependencies..."
cd ios
if command -v pod &> /dev/null; then
    pod install
else
    echo "⚠️  CocoaPods not found. Installing..."
    echo "Please install CocoaPods: sudo gem install cocoapods"
    exit 1
fi
cd ..

echo ""
echo "🔍 Step 4: Running Flutter analyze..."
flutter analyze

echo ""
echo "🏗️  Step 5: Building iOS release..."
flutter build ios --release

echo ""
echo "✅ Preparation complete!"
echo ""
echo "📋 Next steps:"
echo "1. Open Xcode: open ios/Runner.xcworkspace"
echo "2. Select 'Any iOS Device' in Xcode"
echo "3. Product → Archive"
echo "4. Distribute App → App Store Connect"
echo ""
echo "📖 For detailed instructions, see: IOS_APP_STORE_PUBLISHING_GUIDE.md"
