# 📱 iOS App Store Publishing Guide - Tawfir Energy

Complete guide to publish your Flutter app to the Apple App Store.

---

## ✅ Current App Configuration Status

### App Information
- **App Name**: Tawfir Energy
- **Bundle Identifier**: `com.tawfir.energy`
- **Version**: 1.0.0 (Build 5)
- **Minimum iOS Version**: 13.0
- **Supported Devices**: iPhone & iPad

### Configuration Status
- ✅ **Bundle ID**: Configured (`com.tawfir.energy`)
- ✅ **App Icons**: All sizes present in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- ✅ **Launch Screen**: Configured
- ✅ **Info.plist**: Location permissions configured
- ✅ **Firebase**: GoogleService-Info.plist present
- ✅ **Podfile**: iOS 13.0 deployment target configured
- ⚠️ **Apple Developer Account**: Required ($99/year)
- ⚠️ **Code Signing**: Needs to be configured in Xcode

---

## 📋 Prerequisites

### 1. Apple Developer Account
- **Cost**: $99 USD per year
- **Sign up**: https://developer.apple.com/programs/
- **Required for**: App Store publishing, TestFlight testing, distribution certificates

### 2. Xcode
- **Version**: Latest version from Mac App Store
- **Required**: For building, archiving, and uploading to App Store Connect
- **Verify**: `xcode-select --print-path` should show Xcode installation

### 3. App Store Connect Access
- **Access**: Automatically available with Apple Developer account
- **URL**: https://appstoreconnect.apple.com/
- **Required**: To create app listing and submit for review

---

## 🔧 Step 1: Prepare Your Development Environment

### 1.1 Verify Flutter Setup
```bash
cd "/Users/pc/Desktop/solarapp1 copy"
flutter doctor -v
```

**Ensure:**
- ✅ Flutter SDK installed
- ✅ Xcode installed and configured
- ✅ CocoaPods installed (for iOS dependencies)
- ✅ iOS toolchain working

### 1.2 Install CocoaPods Dependencies
```bash
cd ios
pod install
cd ..
```

**Note**: If you get Ruby version errors, see the CocoaPods installation notes in the project.

### 1.3 Clean and Get Dependencies
```bash
flutter clean
flutter pub get
```

---

## 📱 Step 2: Configure App Store Connect

### 2.1 Create App ID in Apple Developer Portal

1. Go to: https://developer.apple.com/account/resources/identifiers/list
2. Click **"+"** to create new identifier
3. Select **"App IDs"** → **"Continue"**
4. Select **"App"** → **"Continue"**
5. **Description**: Tawfir Energy
6. **Bundle ID**: Select **"Explicit"** → Enter: `com.tawfir.energy`
7. **Capabilities**: Enable if needed (Push Notifications, etc.)
8. Click **"Continue"** → **"Register"**

### 2.2 Create App in App Store Connect

1. Go to: https://appstoreconnect.apple.com/
2. Click **"My Apps"** → **"+"** → **"New App"**
3. Fill in:
   - **Platform**: iOS
   - **Name**: Tawfir Energy
   - **Primary Language**: English (or your preferred language)
   - **Bundle ID**: Select `com.tawfir.energy`
   - **SKU**: `tawfir-energy-ios` (unique identifier, internal use only)
   - **User Access**: Full Access (or restricted if needed)
4. Click **"Create"**

---

## 🔐 Step 3: Configure Code Signing in Xcode

### 3.1 Open Project in Xcode
```bash
open ios/Runner.xcworkspace
```

**Important**: Always open `.xcworkspace`, NOT `.xcodeproj`

### 3.2 Configure Signing & Capabilities

1. In Xcode, select **"Runner"** in the project navigator
2. Select **"Runner"** target (under TARGETS)
3. Go to **"Signing & Capabilities"** tab
4. Check **"Automatically manage signing"**
5. Select your **Team** (Apple Developer account)
6. **Bundle Identifier** should show: `com.tawfir.energy`

**Xcode will automatically:**
- Create/update provisioning profiles
- Generate distribution certificates
- Configure signing for App Store distribution

### 3.3 Verify Build Settings

1. Still in **"Signing & Capabilities"** tab
2. Under **"Build Settings"**:
   - **iOS Deployment Target**: 13.0 (should match Podfile)
   - **Product Bundle Identifier**: `com.tawfir.energy`
   - **Version**: 1.0.0
   - **Build**: 5

---

## 🏗️ Step 4: Build for Release

### 4.1 Prepare Build
```bash
cd "/Users/pc/Desktop/solarapp1 copy"
flutter clean
flutter pub get
cd ios
pod install
cd ..
```

### 4.2 Build iOS Release
```bash
flutter build ios --release
```

**This will:**
- Compile Dart code
- Build iOS app bundle
- Prepare for archiving

### 4.3 Archive in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. **Important**: Select **"Any iOS Device"** or **"Generic iOS Device"** (NOT a simulator)
3. Go to **Product** → **Archive**
4. Wait for archive process to complete (5-10 minutes)
5. Xcode Organizer will open automatically

**If Archive is grayed out:**
- Make sure you selected "Any iOS Device" (not simulator)
- Clean build folder: **Product** → **Clean Build Folder**
- Try again

---

## 📤 Step 5: Upload to App Store Connect

### 5.1 Distribute App from Xcode Organizer

1. In **Xcode Organizer** (Window → Organizer if not open)
2. Select your archive (should show "Tawfir Energy" with today's date)
3. Click **"Distribute App"**
4. Select **"App Store Connect"** → **"Next"**
5. Select **"Upload"** → **"Next"**
6. **Distribution Options**:
   - ✅ Include bitcode for iOS content (if enabled)
   - ✅ Upload your app's symbols (recommended for crash reports)
   - Click **"Next"**
7. **Automatically manage signing** (recommended) → **"Next"**
8. Review summary → **"Upload"**
9. Wait for upload to complete (may take 10-30 minutes)

### 5.2 Verify Upload

1. Go to: https://appstoreconnect.apple.com/
2. Select **"My Apps"** → **"Tawfir Energy"**
3. Go to **"TestFlight"** tab
4. Your build should appear under **"Processing"** (wait 5-30 minutes)
5. Once processed, it will show under **"iOS Builds"**

---

## 📝 Step 6: Complete App Store Listing

### 6.1 App Information

Go to **App Store Connect** → **My Apps** → **Tawfir Energy** → **App Information**:

1. **Name**: Tawfir Energy
2. **Subtitle**: (Optional) Solar Energy Solutions
3. **Category**:
   - Primary: **Utilities** or **Business**
   - Secondary: (Optional) **Productivity** or **Lifestyle**
4. **Content Rights**: 
   - ✅ "I have the rights to use all content in this app"
   - ✅ "My app does not contain, display, or access third-party content"
5. **Bundle ID**: `com.tawfir.energy` (should be pre-filled)

### 6.2 Pricing and Availability

1. Go to **Pricing and Availability**
2. **Price**: Free (or set price if paid)
3. **Availability**: Select countries/regions (default: all)
4. **Save**

### 6.3 App Privacy (REQUIRED)

1. Go to **App Privacy**
2. Click **"Get Started"** or **"Edit"**
3. Answer questions about data collection:
   - **Location**: Yes (Precise Location)
   - **Contact Info**: Yes (Name, Email, Phone Number)
   - **User Content**: Possibly (if users submit forms)
   - **Usage Data**: Possibly (for analytics)
   - **Diagnostics**: Possibly (crash reports)
4. For each data type, specify:
   - **Purpose**: App Functionality, Analytics, etc.
   - **Linked to User**: Yes/No
   - **Used for Tracking**: Usually No
5. **Save**

### 6.4 Prepare App Store Assets

#### Required Assets:

1. **App Icon** (1024×1024 PNG)
   - ✅ Already in project: `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png`
   - Upload to App Store Connect: **App Information** → **App Icon**

2. **Screenshots** (Required for each device size):
   - **iPhone 6.7"** (iPhone 14 Pro Max, 15 Pro Max): 1290 × 2796 pixels
   - **iPhone 6.5"** (iPhone 11 Pro Max, XS Max): 1242 × 2688 pixels
   - **iPhone 5.5"** (iPhone 8 Plus): 1242 × 2208 pixels
   - **Minimum**: 2 screenshots per size (maximum: 10)
   - **Recommended screenshots**:
     1. Home screen
     2. Solar calculator
     3. Calculator results
     4. Request form
     5. Marketplace/products

3. **App Preview Video** (Optional but recommended):
   - 15-30 second video showcasing app
   - Same sizes as screenshots
   - Maximum file size: 500 MB

4. **Description** (Required):
   - **Name**: Tawfir Energy (30 characters max)
   - **Subtitle**: (Optional, 30 characters max)
   - **Description**: (4000 characters max)
     ```
     Tawfir Energy is your comprehensive solar energy solution app. Calculate your solar system requirements, explore products, and request quotes directly from your mobile device.

     Features:
     • Solar System Calculator - Calculate requirements for ON-GRID, HYBRID, OFF-GRID, and Solar Pumping systems
     • Product Marketplace - Browse solar panels, inverters, batteries, and accessories
     • Quote Requests - Submit requests for solar installations
     • GPS Integration - Automatically fill location data
     • Multi-language Support - Available in French, Arabic, and English
     • Environmental Impact - See your carbon footprint reduction

     Perfect for homeowners and businesses looking to switch to solar energy.
     ```
   - **Keywords**: solar, energy, Morocco, calculator, renewable, green, photovoltaic (100 characters max, comma-separated)
   - **Support URL**: Your website or support page (required)
   - **Marketing URL**: (Optional) Your marketing website
   - **Promotional Text**: (Optional, 170 characters max) - What's new, promotions, etc.

5. **Privacy Policy URL** (REQUIRED):
   - Must be publicly accessible
   - Must clearly describe how you collect, use, and share user data
   - Can host on your website or use a free service

### 6.5 Version Information

1. Go to your app version (1.0.0) in App Store Connect
2. **What's New in This Version**:
   ```
   Initial release of Tawfir Energy app!

   Features:
   • Solar calculator for all system types
   • Product marketplace
   • Quote request system
   • Multi-language support (FR/AR/EN)
   • GPS location integration
   • Environmental impact calculations
   ```
3. **Screenshots**: Upload screenshots for each device size
4. **App Preview**: (Optional) Upload app preview video
5. **Description**: Copy from section 6.4
6. **Keywords**: `solar,energy,Morocco,calculator,renewable,photovoltaic`
7. **Support URL**: (Required) Your support website
8. **Marketing URL**: (Optional)
9. **Copyright**: © 2024 Tawfir Energy (or your company name)

---

## ✅ Step 7: Submit for Review

### 7.1 Final Checklist

Before submitting, verify:

- [ ] Build uploaded successfully to App Store Connect
- [ ] Build appears in TestFlight (if using)
- [ ] App information completed
- [ ] Screenshots uploaded (at least 2 per device size)
- [ ] App description written
- [ ] Keywords added
- [ ] Support URL provided
- [ ] Privacy Policy URL provided (REQUIRED)
- [ ] App Privacy questionnaire completed
- [ ] Pricing set
- [ ] Version "What's New" text added
- [ ] Contact information correct

### 7.2 Submit for Review

1. In App Store Connect, go to your app version
2. Scroll to **"App Review Information"** section
3. Fill in:
   - **Contact Information**: Your contact details
   - **Phone**: Your phone number
   - **Notes**: (Optional) Any special instructions for reviewers
   - **Demo Account**: (If app requires login)
     - Username: `demo@example.com`
     - Password: `demo123`
4. Go to **"Version Information"** section
5. Ensure all required fields are filled
6. Click **"Add for Review"** button
7. Select the build you want to submit
8. Click **"Submit for Review"**

**Review Process:**
- Usually takes 24-48 hours
- Can take up to 7 days
- You'll receive email notifications about status

---

## 🧪 Step 8: TestFlight Testing (Optional but Recommended)

### 8.1 Internal Testing

1. In App Store Connect → **TestFlight** tab
2. Add **Internal Testers** (up to 100 people in your organization)
3. Select build → **Start Testing**
4. Internal testers receive email invitation

### 8.2 External Testing

1. Create **External Testing Group**
2. Add build to testing group
3. Submit for Beta App Review (usually faster than production review)
4. Add external testers (up to 10,000)
5. Once approved, testers can download via TestFlight app

**Benefits:**
- Test app before public release
- Gather feedback
- Catch bugs before production

---

## 🔄 Step 9: Update Version (For Future Updates)

When you need to update the app:

1. **Update version** in `pubspec.yaml`:
   ```yaml
   version: 1.0.1+6  # Version.Build
   ```

2. **Build and archive** (same process as Step 4-5)

3. **Upload new build** to App Store Connect

4. **Create new version** in App Store Connect:
   - Version number: 1.0.1
   - Add "What's New" text
   - Update screenshots if needed

5. **Submit for review**

---

## ⚠️ Common Issues & Solutions

### Issue 1: Archive Option Grayed Out

**Solution:**
- Make sure you selected **"Any iOS Device"** (not simulator)
- Clean build folder: **Product** → **Clean Build Folder**
- Close and reopen Xcode

### Issue 2: Code Signing Errors

**Error**: "No signing certificate found"

**Solution:**
1. In Xcode → **Signing & Capabilities**
2. Check **"Automatically manage signing"**
3. Select your **Team**
4. If errors persist, go to Apple Developer Portal and check certificates

### Issue 3: Upload Fails

**Error**: "Unable to process application"

**Solutions:**
- Check bundle identifier matches App Store Connect
- Verify app version is higher than previous version
- Ensure all required Info.plist keys are present
- Check for missing app icons

### Issue 4: Build Processing Takes Too Long

**Solution:**
- Normal processing time: 5-30 minutes
- If stuck > 1 hour, try uploading again
- Check App Store Connect for error messages

### Issue 5: App Rejected

**Common reasons:**
- Missing privacy policy
- Incomplete app description
- App crashes during review
- Missing required permissions descriptions
- Guideline violations

**Solution:**
- Review rejection reason in App Store Connect
- Fix issues
- Submit again with explanation in "Notes" field

### Issue 6: CocoaPods Installation Issues

**If you get Ruby version errors:**

```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Ruby 3.x
brew install ruby

# Install CocoaPods
gem install cocoapods

# Then run
cd ios
pod install
```

---

## 📋 Complete Pre-Submission Checklist

### Technical Requirements
- [ ] Flutter project builds successfully
- [ ] iOS build completes without errors
- [ ] Archive created in Xcode
- [ ] Build uploaded to App Store Connect
- [ ] Build processed successfully (visible in TestFlight)

### App Store Connect Setup
- [ ] App created in App Store Connect
- [ ] Bundle ID matches (`com.tawfir.energy`)
- [ ] App information completed
- [ ] Pricing set (Free or Paid)
- [ ] Availability set (countries)

### Content Requirements
- [ ] App name: Tawfir Energy
- [ ] App description (4000 chars max)
- [ ] Keywords added (100 chars max)
- [ ] Support URL provided
- [ ] Privacy Policy URL provided (REQUIRED)
- [ ] Marketing URL (optional)

### Assets Required
- [ ] App icon (1024×1024 PNG)
- [ ] Screenshots for iPhone 6.7" (at least 2)
- [ ] Screenshots for iPhone 6.5" (at least 2)
- [ ] Screenshots for iPhone 5.5" (at least 2)
- [ ] App preview video (optional)

### Privacy & Compliance
- [ ] App Privacy questionnaire completed
- [ ] Privacy policy URL is accessible
- [ ] All data collection declared
- [ ] Location permission description in Info.plist

### Review Information
- [ ] Contact information provided
- [ ] Phone number provided
- [ ] Demo account (if app requires login)
- [ ] Review notes (if needed)

### Final Steps
- [ ] All sections show green checkmarks ✅
- [ ] Build selected for submission
- [ ] Ready to submit for review

---

## 📞 Support & Resources

### Apple Resources
- **App Store Connect**: https://appstoreconnect.apple.com/
- **Apple Developer Portal**: https://developer.apple.com/
- **App Review Guidelines**: https://developer.apple.com/app-store/review/guidelines/
- **App Store Connect Help**: https://help.apple.com/app-store-connect/

### Flutter Resources
- **Flutter iOS Deployment**: https://docs.flutter.dev/deployment/ios
- **Flutter iOS Setup**: https://docs.flutter.dev/get-started/install/macos#ios-setup

### Firebase Resources
- **Firebase iOS Setup**: https://firebase.google.com/docs/ios/setup
- **Firebase Console**: https://console.firebase.google.com/

---

## 🎉 After Approval

Once your app is approved:

1. **Go Live**: App will be available in App Store within 24 hours
2. **Monitor**: Check App Store Connect for downloads, ratings, reviews
3. **Update**: Respond to user reviews
4. **Analytics**: Monitor app performance in App Store Connect
5. **Marketing**: Share your app launch!

---

## ⏱️ Timeline Estimate

- **Account Setup**: 1-2 hours (if Apple Developer account ready)
- **Build & Upload**: 1-2 hours
- **App Store Listing**: 2-4 hours
- **App Review**: 24-48 hours (can take up to 7 days)
- **Total**: 3-7 days from start to App Store

---

## 🚀 Quick Start Commands

```bash
# 1. Clean and prepare
cd "/Users/pc/Desktop/solarapp1 copy"
flutter clean
flutter pub get
cd ios && pod install && cd ..

# 2. Build iOS release
flutter build ios --release

# 3. Open in Xcode
open ios/Runner.xcworkspace

# 4. In Xcode:
# - Select "Any iOS Device"
# - Product → Archive
# - Distribute App → App Store Connect
```

---

**Good luck with your App Store submission! 🎊**

**Last Updated**: Based on current project configuration
**Next Step**: Follow steps 1-7 in order
