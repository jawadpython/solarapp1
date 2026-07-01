# 🍎 Apple App Store Update Report – Tawfir Energy

**Preparing a major update for App Store submission**

This report covers everything you need to do and change for your app update (including account/password and other changes) to maximize the chance of Apple acceptance.

---

## Executive Summary

Your app **Tawfir Energy** (com.tawfir.energy) uses:
- Firebase Auth (email/password)
- Firestore, Storage, Cloud Functions
- Image picker (camera/photo library)
- URL launcher
- Connectivity detection

To pass App Review, you must address **technical setup**, **privacy**, **authentication**, and **store listing**.

---

## Part 1: Technical Preparation

### 1.1 Version & Build Numbers

**Current (from pubspec.yaml):** `1.0.2+8`

For a major update:
- **Version (CFBundleShortVersionString):** e.g. `1.1.0` or `2.0.0` – must be greater than the current App Store version  
- **Build (CFBundleVersion):** e.g. `9` – must be greater than any previously submitted build

**Action:**
1. Check the latest version on App Store Connect.
2. Update `pubspec.yaml`:
   ```yaml
   version: 1.1.0+9   # or 2.0.0+9 for major update
   ```

### 1.2 iOS Code Signing & Provisioning

**Required:**
- Apple Developer Program membership ($99/year)
- Distribution certificate
- App Store provisioning profile for `com.tawfir.energy`

**Actions:**
1. In **Xcode**: Runner → Signing & Capabilities
2. Select your **Team**
3. Use **Automatically manage signing** for simplicity
4. Ensure **Release** configuration uses the **App Store** profile

### 1.3 Build for Archive & Upload

```bash
# 1. Clean and get dependencies
flutter clean
flutter pub get

# 2. Build release iOS (no simulator)
flutter build ios --release

# 3. Open in Xcode and archive
open ios/Runner.xcworkspace
```

In Xcode:
1. **Product → Scheme → Runner** (not any other scheme)
2. **Product → Destination → Any iOS Device**
3. **Product → Archive**
4. After archive: **Distribute App** → **App Store Connect** → **Upload**

---

## Part 2: Privacy & Permissions (Required Fixes)

### 2.1 Info.plist – Missing Privacy Keys ⚠️

Your app uses `image_picker` for photos (technician registration, admin products) but **Info.plist is missing required usage descriptions**. Without them, the app can crash when accessing camera or photos, and Apple may reject.

**Add to `ios/Runner/Info.plist`** (inside `<dict>`):

```xml
<!-- Camera - for taking photos -->
<key>NSCameraUsageDescription</key>
<string>Tawfir Energy needs camera access to take photos for technician applications and project submissions.</string>

<!-- Photo Library - for choosing existing photos -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Tawfir Energy needs photo library access to upload images for your profile and project documents.</string>
```

**Optional (if you save photos back):**
```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Tawfir Energy saves photos from the app to your photo library.</string>
```

### 2.2 Privacy Nutrition Labels (App Store Connect)

When submitting, you must declare:

| Data Type              | Collected | Purpose          | Linked to User |
|------------------------|-----------|------------------|----------------|
| Email Address          | Yes       | Account          | Yes            |
| Name                   | Yes       | Account          | Yes            |
| Photos                 | Yes       | Project docs     | Yes            |
| Device ID (Firebase)   | Yes       | Analytics/Auth   | Yes            |

**Encryption:** You already have `ITSAppUsesNonExemptEncryption` = `false` – correct for standard HTTPS/Firebase.

### 2.3 App Tracking Transparency (ATT)

If you do **not** use IDFA or third‑party tracking:
- You do **not** need to add ATT or `NSUserTrackingUsageDescription`.

If you add analytics/tracking later, you will need to:
- Add the App Tracking Transparency framework
- Request permission before tracking
- Declare tracking in App Store Connect

---

## Part 3: Account & Authentication

### 3.1 Sign in with Apple (Guideline 4.8)

**Current:** Email/password sign-in via Firebase Auth.

**Apple:** If you use third‑party or social sign‑in, you should offer a privacy‑focused option. Apple still often expects **Sign in with Apple** in that case.

**Recommendation:** Add Sign in with Apple alongside email/password.

**Steps:**
1. Add capability in Apple Developer Portal:
   - Certificates, IDs & Profiles → Identifiers → Your App ID → Enable **Sign in with Apple**
2. Enable in Xcode:
   - Runner → Signing & Capabilities → **+ Capability** → Sign in with Apple
3. Add Flutter package:
   ```yaml
   dependencies:
     sign_in_with_apple: ^6.0.0
   ```
4. Implement Sign in with Apple in your login/signup flow

**If you choose not to add it:**  
- Ensure sign-up and sign-in flows are clear and secure  
- Provide a “Forgot password” option  
- Document in App Review notes that you only use your own account system, if applicable  

### 3.2 Account & Password Quality

**Checklist:**
- [ ] Clear error messages for wrong password / account not found
- [ ] “Forgot password” / reset flow implemented and working
- [ ] Sign-up includes email verification (you already send verification email)
- [ ] Sign-out is clearly available
- [ ] No obvious security holes (e.g. hardcoded credentials)

---

## Part 4: App Review Guidelines to Follow

### 4.1 Guideline 2.1 – App Completeness

- App must be fully functional
- No “coming soon” or placeholder content
- No crashes or major bugs in main flows

### 4.2 Guideline 4.2 – Minimum Functionality

- App must provide clear value (solar/energy services, calculator, quotes, etc.)
- No apps that are only a web wrapper without added functionality

### 4.3 Guideline 5.1 – Privacy

- Privacy Policy URL required in App Store Connect
- Must match what the app actually does
- Must explain: data collected, how it’s used, retention, user rights

### 4.4 Guideline 4.8 – Sign in with Apple

- See Part 3.1 above

### 4.5 Guideline 2.3 – Accurate Metadata

- Screenshots must reflect the current app
- Description must match actual features
- No misleading claims

---

## Part 5: App Store Connect – Submission Checklist

### 5.1 App Information

- [ ] **App name:** Tawfir Energy (or your chosen name)
- [ ] **Subtitle:** Short, clear description (max 30 chars)
- [ ] **Privacy Policy URL:** Required – must be a live, valid URL
- [ ] **Category:** e.g. Utilities or Business
- [ ] **Content Rights:** Confirm you own or have rights to all content

### 5.2 Version Information (for this update)

- [ ] **Version number:** e.g. 1.1.0 or 2.0.0
- [ ] **What’s new:** Describe changes (account system, improvements, new features)
- [ ] **Keywords:** Relevant search terms
- [ ] **Support URL:** Working support/contact page
- [ ] **Marketing URL:** Optional

### 5.3 Screenshots (Required)

Sizes for iPhone (6.7", 6.5", 5.5") and iPad if supported:

| Device        | Size          |
|---------------|---------------|
| iPhone 6.7"   | 1290 x 2796   |
| iPhone 6.5"   | 1284 x 2778   |
| iPhone 5.5"   | 1242 x 2208   |

**Tips:**
- Show Login, Home, Calculator, Espace Pro, Profile
- No status bar text (e.g. “1234”) – use clean simulator
- Reflect the new account/login flow if changed

### 5.4 Age Rating & Content

- [ ] Answer the questionnaire honestly
- [ ] Typically 4+ for this type of app

### 5.5 Export Compliance

- [ ] **Uses encryption:** Yes (HTTPS, Firebase)
- [ ] **Uses exempt encryption only:** Yes (standard HTTPS) – aligns with `ITSAppUsesNonExemptEncryption = false`

### 5.6 App Review Information

Provide:
- **Demo account:** Email + password for a test account
- **Notes:** Any special flows (e.g. partner/technician registration, test regions, demo data)
- **Contact:** Phone number for urgent questions

---

## Part 6: Code Changes Summary

### Must-Do Before Submission

| Item | Location | Action |
|------|----------|--------|
| Version & build | `pubspec.yaml` | Set `version: X.Y.Z+N` higher than current store version |
| Camera usage | `ios/Runner/Info.plist` | Add `NSCameraUsageDescription` |
| Photo library usage | `ios/Runner/Info.plist` | Add `NSPhotoLibraryUsageDescription` |
| Sign in with Apple | Optional | Add capability + Flutter package + UI flow |

### Suggested Info.plist Additions

Add these keys to `ios/Runner/Info.plist` before `</dict>`:

```xml
<key>NSCameraUsageDescription</key>
<string>Tawfir Energy needs camera access to take photos for technician applications and project submissions.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Tawfir Energy needs photo library access to upload images for your profile and project documents.</string>
```

---

## Part 7: Pre-Submission Checklist

- [ ] `flutter build ios --release` succeeds
- [ ] Archive and upload from Xcode works
- [ ] Test full flow: sign up → sign in → main features → sign out
- [ ] Test on a real device
- [ ] Privacy Policy URL is live and correct
- [ ] All required usage descriptions in Info.plist
- [ ] Screenshots updated for new version
- [ ] “What’s New” text written
- [ ] Demo account created for App Review
- [ ] Sign in with Apple added (recommended) or documented why not

---

## Part 8: Common Rejection Reasons & Mitigation

| Reason | Mitigation |
|-------|------------|
| Crashes on launch | Test on physical device and simulator; check permissions |
| Missing privacy descriptions | Add `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` |
| Guideline 4.8 (Sign in) | Add Sign in with Apple or document exemption |
| Incomplete app | Remove placeholder content; ensure flows work |
| Privacy Policy missing | Add URL in App Store Connect |
| Misleading screenshots | Use real, current app screenshots |
| Demo account issues | Use a fresh, working test account |

---

## Quick Reference – Build & Upload Commands

```bash
# Set UTF-8 (for CocoaPods in your project path)
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# Clean and build
cd "/path/to/solarapp1 copy"
flutter clean
flutter pub get
flutter build ios --release

# Open Xcode
open ios/Runner.xcworkspace

# In Xcode: Product → Archive → Distribute App → App Store Connect
```

---

**Document version:** 1.0  
**Last updated:** March 2025  
**App:** Tawfir Energy (noor_energy)  
**Bundle ID:** com.tawfir.energy
