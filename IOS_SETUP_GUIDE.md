# 📱 iOS Setup & Publishing Guide - Tawfir Energy

This guide will help you verify and configure your app for iOS publishing.

---

## ✅ Pre-Publishing Checklist

### 1. Firebase Configuration (CRITICAL)

**Required:** `GoogleService-Info.plist` file must be added to `ios/Runner/`

**Steps:**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `tawfir-energy-prod-98053`
3. Go to **Project Settings** → **Your apps**
4. If iOS app doesn't exist, click **Add app** → **iOS**
5. Download `GoogleService-Info.plist`
6. Place it in: `ios/Runner/GoogleService-Info.plist`
7. Make sure it's added to Xcode project (drag into Xcode if needed)

**Verify:**
```bash
# Check if file exists
ls ios/Runner/GoogleService-Info.plist
```

**Note:** The app currently uses hardcoded Firebase config in `lib/main.dart`, but iOS requires `GoogleService-Info.plist` for proper initialization.

---

### 2. Podfile Configuration

**Check if Podfile exists:**
```bash
ls ios/Podfile
```

**If missing, create `ios/Podfile` with:**
```ruby
# Uncomment this line to define a global platform for your project
platform :ios, '12.0'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig, then run flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
```

**Then run:**
```bash
cd ios
pod install
cd ..
```

---

### 3. Info.plist Permissions (VERIFIED ✅)

**Current permissions in `ios/Runner/Info.plist`:**
- ✅ `NSLocationWhenInUseUsageDescription` - Location permission
- ✅ `NSLocationAlwaysUsageDescription` - Location permission (always)

**Status:** ✅ Location permissions are properly configured

**Note:** If you add photo/video features later, you'll need:
```xml
<key>NSCameraUsageDescription</key>
<string>Cette application a besoin d'accéder à votre caméra pour prendre des photos.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Cette application a besoin d'accéder à votre galerie pour sélectionner des photos.</string>
```

---

### 4. Bundle Identifier & Version

**Check in Xcode:**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** target
3. Go to **General** tab
4. Verify:
   - **Bundle Identifier:** `com.tawfir.energy` (should match Android)
   - **Version:** `1.0.0`
   - **Build:** `5`

**Current version in `pubspec.yaml`:** `1.0.0+5` ✅

---

### 5. iOS Deployment Target

**Minimum iOS Version:** Should be iOS 12.0 or higher

**Check in Xcode:**
1. Open `ios/Runner.xcworkspace`
2. Select **Runner** project (not target)
3. Go to **Build Settings**
4. Search for `IPHONEOS_DEPLOYMENT_TARGET`
5. Set to: `12.0` (or higher)

**Or in Podfile:** Already set to `12.0` ✅

---

### 6. App Icons & Launch Screen

**Status:** ✅ Icons are present in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

**Verify all sizes are present:**
- 20x20 (@1x, @2x, @3x)
- 29x29 (@1x, @2x, @3x)
- 40x40 (@1x, @2x, @3x)
- 60x60 (@2x, @3x)
- 76x76 (@1x, @2x)
- 83.5x83.5 (@2x)
- 1024x1024 (@1x) - **Required for App Store**

**Launch Screen:** ✅ Present at `ios/Runner/Assets.xcassets/LaunchImage.imageset/`

---

### 7. Code Signing & Certificates

**Required for Publishing:**

1. **Apple Developer Account** (paid membership required)
2. **App ID** registered in Apple Developer Portal
3. **Provisioning Profile** for distribution
4. **Distribution Certificate**

**Steps:**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** target → **Signing & Capabilities**
3. Select your **Team** (Apple Developer account)
4. Xcode will automatically manage certificates and profiles

**For App Store:**
- Use **Automatic Signing** (recommended)
- Or manually create **Distribution Provisioning Profile**

---

### 8. URL Launcher Configuration

**Status:** ✅ `url_launcher` package is configured

**iOS Configuration:**
- No additional setup needed
- Works out of the box with `url_launcher: ^6.3.2`

**Test:** Make sure phone calls and web links work on iOS device

---

### 9. Geolocator iOS Configuration

**Status:** ✅ Properly configured

**Info.plist permissions:** ✅ Present
**Location service code:** ✅ Uses proper permission handling

**Test on device:**
- Location permission prompt should appear
- GPS detection should work

---

### 10. Build & Test

**Build for iOS:**
```bash
flutter build ios --release
```

**Or in Xcode:**
1. Open `ios/Runner.xcworkspace`
2. Select **Any iOS Device** or connected device
3. Product → Archive (for App Store)
4. Or Product → Run (for testing)

**Test Checklist:**
- [ ] App launches without crashes
- [ ] Firebase authentication works
- [ ] Location/GPS detection works
- [ ] All forms submit correctly
- [ ] Navigation works smoothly
- [ ] Language switching works (FR/AR/EN)
- [ ] Calculator features work
- [ ] Pumping calculator works

---

## 🚀 Publishing to App Store

### Step 1: Prepare for Archive

1. **Update version** in `pubspec.yaml` if needed
2. **Clean build:**
   ```bash
   flutter clean
   flutter pub get
   cd ios && pod install && cd ..
   ```

3. **Build release:**
   ```bash
   flutter build ios --release
   ```

### Step 2: Create Archive in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Any iOS Device** (not simulator)
3. **Product** → **Archive**
4. Wait for archive to complete

### Step 3: Upload to App Store Connect

1. In Xcode Organizer (Window → Organizer)
2. Select your archive
3. Click **Distribute App**
4. Choose **App Store Connect**
5. Follow the wizard:
   - Select distribution method
   - Choose signing options
   - Upload to App Store Connect

### Step 4: Submit for Review

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Create new app (if first time)
3. Fill in app information:
   - **Name:** Tawfir Energy
   - **Subtitle:** Solar Energy Solutions
   - **Category:** Utilities / Business
   - **Description:** (Write compelling description)
   - **Keywords:** solar, energy, Morocco, calculator
   - **Support URL:** (Your website)
   - **Privacy Policy URL:** (Required)

4. **App Store Information:**
   - Screenshots (required sizes):
     - iPhone 6.7" (1290 x 2796)
     - iPhone 6.5" (1242 x 2688)
     - iPhone 5.5" (1242 x 2208)
   - App Preview (optional but recommended)
   - App Icon (1024x1024)

5. **Version Information:**
   - What's New in This Version
   - Description
   - Keywords
   - Support URL
   - Marketing URL (optional)

6. **Submit for Review**

---

## ⚠️ Common Issues & Solutions

### Issue 1: Firebase Not Working on iOS

**Solution:**
- Ensure `GoogleService-Info.plist` is in `ios/Runner/`
- Verify it's added to Xcode project
- Run `pod install` in `ios/` directory
- Clean and rebuild

### Issue 2: Location Permission Not Appearing

**Solution:**
- Check `Info.plist` has `NSLocationWhenInUseUsageDescription`
- Test on real device (not simulator)
- Check location services are enabled in Settings

### Issue 3: Build Errors

**Solution:**
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
flutter build ios --release
```

### Issue 4: Code Signing Errors

**Solution:**
- Ensure Apple Developer account is active
- Check Team is selected in Xcode
- Verify Bundle ID matches App Store Connect
- Use Automatic Signing (recommended)

### Issue 5: Archive Fails

**Solution:**
- Select **Any iOS Device** (not simulator)
- Clean build folder (Product → Clean Build Folder)
- Check deployment target is iOS 12.0+
- Verify all dependencies are compatible

---

## 📋 Final Pre-Publishing Checklist

- [ ] `GoogleService-Info.plist` added to `ios/Runner/`
- [ ] Podfile exists and `pod install` completed
- [ ] Info.plist has all required permissions
- [ ] Bundle ID matches App Store Connect
- [ ] Version number is correct
- [ ] App icons are complete (all sizes)
- [ ] Launch screen configured
- [ ] Tested on real iOS device
- [ ] All features work (Firebase, Location, Forms)
- [ ] App Store Connect app created
- [ ] Screenshots prepared
- [ ] Privacy Policy URL ready
- [ ] App description written
- [ ] Keywords selected

---

## 🔗 Useful Links

- [Apple Developer Portal](https://developer.apple.com/)
- [App Store Connect](https://appstoreconnect.apple.com/)
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)

---

## 📞 Support

If you encounter issues:
1. Check Flutter doctor: `flutter doctor -v`
2. Check iOS-specific: `flutter doctor -v` (look for iOS toolchain)
3. Review Xcode build logs
4. Check Firebase console for errors

---

**Last Updated:** Based on current project state
**Next Steps:** Add `GoogleService-Info.plist` and test on iOS device

