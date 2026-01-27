# ✅ iOS App Store Publishing Checklist

Quick reference checklist for publishing Tawfir Energy to the App Store.

---

## 📱 Phase 1: Prerequisites

- [ ] **Apple Developer Account** ($99/year)
  - [ ] Account created and active
  - [ ] Payment method added
  - [ ] Access to App Store Connect verified

- [ ] **Xcode Installed**
  - [ ] Latest version from Mac App Store
  - [ ] Command line tools installed
  - [ ] Xcode license agreed to

- [ ] **CocoaPods Working**
  - [ ] `pod --version` shows installed version
  - [ ] `cd ios && pod install` completes successfully

---

## 🔧 Phase 2: Configuration

### Apple Developer Portal
- [ ] App ID created: `com.tawfir.energy`
- [ ] App ID capabilities configured (if needed)

### App Store Connect
- [ ] App created in App Store Connect
- [ ] Bundle ID matches: `com.tawfir.energy`
- [ ] SKU set: `tawfir-energy-ios`

### Xcode Configuration
- [ ] Project opened in Xcode: `ios/Runner.xcworkspace`
- [ ] Signing & Capabilities configured
- [ ] Team selected (Apple Developer account)
- [ ] Automatic signing enabled
- [ ] Bundle Identifier: `com.tawfir.energy`
- [ ] iOS Deployment Target: 13.0

---

## 🏗️ Phase 3: Build & Upload

- [ ] Flutter clean: `flutter clean`
- [ ] Dependencies installed: `flutter pub get`
- [ ] CocoaPods updated: `cd ios && pod install`
- [ ] iOS release build: `flutter build ios --release`
- [ ] Xcode archive created (Product → Archive)
- [ ] Archive uploaded to App Store Connect
- [ ] Build visible in App Store Connect (under TestFlight)

---

## 📝 Phase 4: App Store Listing

### App Information
- [ ] App name: "Tawfir Energy"
- [ ] Subtitle: (Optional) "Solar Energy Solutions"
- [ ] Primary category: Utilities or Business
- [ ] Secondary category: (Optional)

### Pricing & Availability
- [ ] Price set: Free (or paid)
- [ ] Availability: All countries or selected

### App Privacy (REQUIRED)
- [ ] Privacy questionnaire completed
- [ ] Data collection declared:
  - [ ] Location data
  - [ ] Contact information
  - [ ] User content (if applicable)
- [ ] Privacy Policy URL provided (REQUIRED)

### Version Information
- [ ] Version number: 1.0.0
- [ ] "What's New" text written
- [ ] Description written (up to 4000 characters)
- [ ] Keywords added (up to 100 characters): `solar,energy,Morocco,calculator`
- [ ] Support URL provided (REQUIRED)
- [ ] Marketing URL (optional)
- [ ] Copyright information

---

## 🎨 Phase 5: Assets

### App Icon
- [ ] App icon (1024×1024 PNG) uploaded
- [ ] Icon follows Apple guidelines (no transparency, rounded corners added by Apple)

### Screenshots (REQUIRED)
- [ ] iPhone 6.7" screenshots (1290×2796) - at least 2
- [ ] iPhone 6.5" screenshots (1242×2688) - at least 2
- [ ] iPhone 5.5" screenshots (1242×2208) - at least 2
- [ ] Screenshots show key features:
  - [ ] Home screen
  - [ ] Solar calculator
  - [ ] Calculator results
  - [ ] Request form

### App Preview Video (Optional)
- [ ] App preview video created (15-30 seconds)
- [ ] Video uploaded for each device size

---

## 🔍 Phase 6: Review Information

- [ ] Contact information provided
- [ ] Phone number provided
- [ ] Demo account credentials (if app requires login)
- [ ] Review notes (optional, for special instructions)

---

## ✅ Phase 7: Final Verification

### Technical
- [ ] Build processed successfully in App Store Connect
- [ ] No build errors or warnings
- [ ] App tested on real iOS device
- [ ] All features working:
  - [ ] Firebase authentication
  - [ ] Location services
  - [ ] Forms submission
  - [ ] Calculator functionality
  - [ ] Language switching

### Content
- [ ] All required fields completed
- [ ] Privacy policy URL accessible
- [ ] Support URL accessible
- [ ] No placeholder text
- [ ] No test/beta content

### Compliance
- [ ] App follows App Store Review Guidelines
- [ ] Privacy policy clearly explains data usage
- [ ] All third-party content properly licensed
- [ ] No copyright violations

---

## 🚀 Phase 8: Submission

- [ ] All sections show green checkmarks ✅
- [ ] Build selected for submission
- [ ] **"Submit for Review"** clicked
- [ ] Confirmation email received

---

## 📊 Post-Submission

- [ ] Monitor review status in App Store Connect
- [ ] Respond to any reviewer questions promptly
- [ ] After approval: App goes live automatically
- [ ] Monitor downloads and ratings
- [ ] Respond to user reviews

---

## ⏱️ Timeline Tracker

- [ ] **Day 1**: Account setup, configuration, build
- [ ] **Day 2**: App Store listing, assets, submission
- [ ] **Day 3-7**: Waiting for review
- [ ] **After Approval**: App live in App Store! 🎉

---

## 🆘 If Rejected

- [ ] Review rejection reason in App Store Connect
- [ ] Address all issues mentioned
- [ ] Update app/build if needed
- [ ] Resubmit with explanation in notes
- [ ] Contact App Review if needed

---

## 📞 Quick Reference

- **App Store Connect**: https://appstoreconnect.apple.com/
- **Apple Developer Portal**: https://developer.apple.com/
- **Review Guidelines**: https://developer.apple.com/app-store/review/guidelines/
- **Status**: Check in App Store Connect → My Apps → Tawfir Energy

---

**Status**: ⬜ Not Started | 🟡 In Progress | ✅ Complete | ❌ Blocked

**Last Updated**: [Today's Date]
