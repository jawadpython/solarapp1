# 🚀 Complete Google Play Store Publishing Guide
## Tawfir Energy - Step-by-Step Instructions

This is your complete guide to publish your app to Google Play Store. Follow each step carefully.

---

## 📋 PRE-PUBLICATION CHECKLIST

Before starting, ensure you have:

- [ ] Google account (Gmail)
- [ ] $25 USD (one-time Google Play Developer registration fee)
- [ ] Credit/debit card for payment
- [ ] App icon (512×512 PNG)
- [ ] Screenshots of your app (at least 2)
- [ ] Privacy policy URL (can create free)
- [ ] 1-2 hours of time

---

## PART 1: PREPARE YOUR APP

### Step 1.1: Verify App Configuration

Your app is already configured with:
- ✅ Application ID: `com.tawfir.energy`
- ✅ Version: `1.0.0+5` (from pubspec.yaml)
- ✅ Signing configuration: Ready

**Action**: Verify your version number in `pubspec.yaml`:
```yaml
version: 1.0.0+5  # Format: versionName+versionCode
```

**Important**: 
- `versionName` (1.0.0) = User-visible version
- `versionCode` (5) = Internal version (must increase with each release)

---

### Step 1.2: Create/Verify Release Keystore

**If you already have a keystore**, skip to Step 1.3.

**If you need to create one**:

1. **Open Command Prompt/Terminal** in your project root

2. **Navigate to android folder**:
   ```bash
   cd android
   ```

3. **Create keystore** (Windows):
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

   Or use the provided script:
   ```bash
   create_keystore.bat
   ```

4. **Enter information when prompted**:
   - **Keystore password**: (Save this! You'll need it forever)
   - **Re-enter password**: (Same password)
   - **Key password**: (Can be same as keystore password)
   - **Your name**: Your name or company name
   - **Organizational unit**: (Optional)
   - **Organization**: Your company name
   - **City**: Your city
   - **State**: Your state/province
   - **Country code**: MA (for Morocco) or your country code

5. **Verify keystore created**:
   - File should be at: `android/upload-keystore.jks`

6. **Update `android/key.properties`**:
   ```properties
   storePassword=YourActualPassword
   keyPassword=YourActualPassword
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```

   ⚠️ **CRITICAL**: 
   - **BACKUP YOUR KEYSTORE FILE** (`upload-keystore.jks`)
   - **SAVE YOUR PASSWORDS** in a secure password manager
   - **If you lose the keystore, you CANNOT update your app!**

---

### Step 1.3: Build Release App Bundle (AAB)

1. **Open terminal** in your project root

2. **Clean previous builds** (optional but recommended):
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Build App Bundle**:
   ```bash
   flutter build appbundle --release
   ```

4. **Wait for build to complete** (may take 2-5 minutes)

5. **Verify AAB file created**:
   - Location: `build/app/outputs/bundle/release/app-release.aab`
   - Size: Should be reasonable (10-50MB typically)

6. **Test the AAB** (optional but recommended):
   ```bash
   # Install bundletool (if not installed)
   # Download from: https://github.com/google/bundletool/releases
   
   # Generate APK from AAB for testing
   bundletool build-apks --bundle=build/app/outputs/bundle/release/app-release.aab --output=app.apks
   ```

---

## PART 2: GOOGLE PLAY CONSOLE SETUP

### Step 2.1: Create Google Play Developer Account

1. **Go to**: https://play.google.com/console/signup

2. **Sign in** with your Google account

3. **Pay registration fee**:
   - Click "Continue to payment"
   - Pay $25 USD (one-time fee, valid for lifetime)
   - Accept terms and conditions

4. **Complete account setup**:
   - **Developer name**: Your name or company name (this appears on Play Store)
   - **Email address**: Your contact email
   - **Phone number**: Your contact phone
   - **Website** (optional): Your website URL

5. **Complete account verification** (if required):
   - Google may ask for identity verification
   - Follow their instructions

---

### Step 2.2: Create Your App

1. **Go to Google Play Console**: https://play.google.com/console

2. **Click "Create app"** button (top right)

3. **Fill in app details**:
   - **App name**: "Tawfir Energy" (or your preferred name, max 50 characters)
   - **Default language**: 
     - French (Français) - if targeting French-speaking countries
     - Arabic (العربية) - if targeting Arabic-speaking countries
     - Or English (English) - for international
   - **App or game**: Select **"App"**
   - **Free or paid**: Select **"Free"**

4. **Accept declarations**:
   - ✅ Check "I understand and agree to the Google Play Developer Distribution Agreement"
   - ✅ Check "I understand and agree to the Export Compliance"
   - ✅ Check "I understand and agree to the US export laws"

5. **Click "Create app"**

6. **Wait for app creation** (takes a few seconds)

---

## PART 3: UPLOAD YOUR APP

### Step 3.1: Upload App Bundle to Production

1. **In Google Play Console**, go to your app dashboard

2. **Navigate to**: **"Release" → "Production"** (left sidebar)

3. **Click "Create new release"**

4. **Upload your AAB**:
   - Click **"Upload"** button
   - Select file: `build/app/outputs/bundle/release/app-release.aab`
   - Wait for upload (may take 2-5 minutes)
   - Google will validate the AAB automatically

5. **Add release name**:
   - Example: "1.0.0 - Initial Release"
   - Or: "Version 1.0"

6. **Add release notes** (What's new):
   ```
   Initial release of Tawfir Energy app
   
   Features:
   - Solar calculator for ON-GRID, HYBRID, and OFF-GRID systems
   - Solar pumping calculator
   - Energy savings calculations
   - Regional sun hours data for Morocco
   - Multi-language support (French/Arabic)
   ```

7. **Click "Save"** (don't publish yet!)

---

## PART 4: STORE LISTING

### Step 4.1: Complete Main Store Listing

1. **Navigate to**: **"Store presence" → "Main store listing"**

2. **Fill in required information**:

   **App name** (max 50 characters):
   ```
   Tawfir Energy
   ```

   **Short description** (max 80 characters):
   ```
   Solutions solaires intelligentes pour économiser l'énergie au Maroc
   ```
   Or in English:
   ```
   Smart solar solutions to save energy in Morocco
   ```

   **Full description** (max 4000 characters):
   ```
   Tawfir Energy est votre application complète pour les solutions solaires au Maroc.
   
   🏠 CALCULATEUR SOLAIRE
   Calculez la taille optimale de votre installation solaire:
   - Systèmes ON-GRID (connectés au réseau)
   - Systèmes HYBRID (avec batterie)
   - Systèmes OFF-GRID (autonomes)
   - Pompage solaire
   
   💰 ÉCONOMIES
   - Calculez vos économies d'énergie
   - Estimation des coûts
   - Retour sur investissement
   
   📍 DONNÉES RÉGIONALES
   - Heures d'ensoleillement par région
   - Tarifs d'électricité marocains
   - Calculs précis pour le Maroc
   
   🌍 MULTILINGUE
   - Support français et arabe
   - Interface intuitive
   
   Téléchargez Tawfir Energy et commencez à économiser dès aujourd'hui!
   ```

3. **Upload graphics**:

   **App icon** (Required - 512×512 PNG):
   - Must be 512×512 pixels
   - PNG format
   - No transparency (solid background)
   - High quality
   - Click "Upload" and select your icon

   **Feature graphic** (Required - 1024×500 PNG):
   - Must be 1024×500 pixels
   - PNG format
   - Banner for Play Store
   - Should showcase your app
   - Click "Upload" and select your graphic

   **Screenshots** (Required - At least 2, max 8):
   - **Phone screenshots**: At least 2 required
   - Recommended size: 1080×1920 or 1440×2560
   - Formats: PNG or JPEG
   - Show key features:
     1. Home screen / Dashboard
     2. Solar calculator
     3. Results screen
     4. Marketplace (if applicable)
     5. Request form
   
   **How to take screenshots**:
   - Use Android Studio Emulator
   - Or take on a real device
   - Edit with Canva, Figma, or Photoshop (optional)

4. **App category**:
   - Select: **"Productivity"** or **"Business"** or **"Utilities"**

5. **Contact details**:
   - **Email**: Your support email
   - **Phone** (optional): Your support phone
   - **Website** (optional): Your website URL

6. **Click "Save"** at the bottom

---

### Step 4.2: Privacy Policy (REQUIRED)

**You MUST have a privacy policy URL**. Here are your options:

**Option 1: Create Free Privacy Policy**

1. Go to: https://www.privacypolicygenerator.info/
2. Fill in your app details
3. Generate privacy policy
4. Copy the HTML code
5. Host it on:
   - GitHub Pages (free)
   - Your website
   - Google Sites (free)

**Option 2: Use Template**

Create a simple privacy policy page with:

```
Privacy Policy for Tawfir Energy

Last updated: [Date]

1. Information We Collect
   - Location data (optional, user-initiated)
   - User contact information (name, phone, email)
   - Device information

2. How We Use Information
   - To provide solar calculation services
   - To process quote requests
   - To improve app functionality

3. Data Storage
   - Data stored in Firebase (Google Cloud)
   - Secure and encrypted

4. Your Rights
   - Access your data
   - Delete your data
   - Contact us: [your-email@example.com]

5. Contact Us
   Email: [your-email@example.com]
```

**Add Privacy Policy URL**:
1. In Play Console, go to **"Policy" → "App content"**
2. Scroll to **"Privacy Policy"**
3. Enter your privacy policy URL
4. Click "Save"

---

## PART 5: APP CONTENT & COMPLIANCE

### Step 5.1: Data Safety Form

1. **Navigate to**: **"Policy" → "App content" → "Data safety"**

2. **Answer questions about data collection**:

   **Does your app collect or share any of the required user data types?**
   - Select **"Yes"** (if you collect location data)

   **Data types collected**:
   - ✅ **Approximate location** (COARSE_LOCATION)
     - Purpose: Pre-fill GPS coordinates in forms
     - Collection: Optional, user-initiated
     - Sharing: Not shared with third parties
   
   - ✅ **Precise location** (FINE_LOCATION)
     - Purpose: Accurate GPS coordinates
     - Collection: Optional, user-initiated
     - Sharing: Not shared with third parties

   - ✅ **Personal info** (name, email, phone)
     - Purpose: Process quote requests
     - Collection: User-provided
     - Sharing: Not shared with third parties

3. **Data security**:
   - Select: "Data is encrypted in transit"
   - Select: "Users can request data deletion"

4. **Click "Save"**

---

### Step 5.2: Content Rating

1. **Navigate to**: **"Policy" → "App content" → "Content rating"**

2. **Click "Start questionnaire"**

3. **Answer questions**:
   - **Does your app allow users to interact or share content?** → Usually "No"
   - **Does your app allow users to communicate with each other?** → Usually "No"
   - **Does your app contain user-generated content?** → Usually "No"
   - **Does your app allow users to purchase digital goods?** → "No" (if free app)
   - **Does your app contain violence, profanity, or mature content?** → "No"

4. **Complete questionnaire** (takes 2-5 minutes)

5. **Get rating certificate** (usually "Everyone" or "Everyone 10+")

6. **Click "Save"**

---

### Step 5.3: Target Audience

1. **Navigate to**: **"Policy" → "App content" → "Target audience"**

2. **Select target age**:
   - Usually: **"Everyone"** or **"Everyone 10+"**

3. **Click "Save"**

---

## PART 6: PRICING & DISTRIBUTION

### Step 6.1: Set Pricing

1. **Navigate to**: **"Monetization setup" → "Products" → "In-app products"**

2. **If your app is free**: No action needed

3. **If you want to add paid features later**: You can set this up now or later

---

### Step 6.2: Countries & Regions

1. **Navigate to**: **"Monetization setup" → "Countries/regions"**

2. **Select countries**:
   - **All countries** (recommended for maximum reach)
   - Or select specific countries (e.g., Morocco, France, etc.)

3. **Click "Save"**

---

## PART 7: FINAL REVIEW & SUBMISSION

### Step 7.1: Review Checklist

Before submitting, verify all sections show ✅ (green checkmarks):

1. **Dashboard** - Check all sections:
   - ✅ Store listing (complete)
   - ✅ App content (complete)
   - ✅ Pricing & distribution (complete)
   - ✅ Production release (AAB uploaded)

2. **Store listing**:
   - ✅ App name
   - ✅ Short description
   - ✅ Full description
   - ✅ App icon (512×512)
   - ✅ Feature graphic (1024×500)
   - ✅ Screenshots (at least 2)

3. **App content**:
   - ✅ Privacy policy URL
   - ✅ Data safety form
   - ✅ Content rating

4. **Release**:
   - ✅ AAB uploaded
   - ✅ Release notes added

---

### Step 7.2: Submit for Review

1. **Go to Dashboard**

2. **Review all sections** - Ensure everything is complete

3. **Click "Submit for review"** button (top right)

4. **Confirm submission**

5. **Wait for review**:
   - **Typical review time**: 1-7 days
   - **Average**: 2-3 days
   - You'll receive email notifications about status

---

## PART 8: AFTER SUBMISSION

### Step 8.1: Monitor Review Status

1. **Check Play Console** regularly for updates

2. **Email notifications**: Google will email you about:
   - Review started
   - Review completed
   - Any issues found

3. **Common statuses**:
   - **"In review"**: Being reviewed by Google
   - **"Pending publication"**: Approved, waiting to go live
   - **"Published"**: Live on Play Store! 🎉
   - **"Rejected"**: Issues found (will explain what to fix)

---

### Step 8.2: If Rejected

If Google rejects your app:

1. **Read the rejection reason** carefully

2. **Common rejection reasons**:
   - Missing privacy policy
   - Incomplete data safety form
   - Misleading app name/description
   - Missing required graphics
   - App crashes on launch
   - Policy violations

3. **Fix the issues**

4. **Resubmit** for review

---

### Step 8.3: After Approval

Once your app is approved and published:

1. **Your app goes live** on Google Play Store

2. **Share your app link**:
   - Format: `https://play.google.com/store/apps/details?id=com.tawfir.energy`
   - Share on social media, website, etc.

3. **Monitor performance**:
   - Downloads
   - Ratings and reviews
   - Crashes and ANRs (Application Not Responding)
   - User feedback

---

## PART 9: UPDATING YOUR APP

When you want to release a new version:

### Step 9.1: Update Version

1. **Edit `pubspec.yaml`**:
   ```yaml
   version: 1.0.1+6  # Increment both numbers
   ```
   - `1.0.1` = New version name
   - `6` = New version code (must be higher than previous)

2. **Build new AAB**:
   ```bash
   flutter clean
   flutter pub get
   flutter build appbundle --release
   ```

### Step 9.2: Upload Update

1. **Go to Play Console** → Your app

2. **Navigate to**: **"Release" → "Production"**

3. **Click "Create new release"**

4. **Upload new AAB**

5. **Add release notes**:
   ```
   Version 1.0.1
   
   What's new:
   - Fixed calculation errors in solar calculator
   - Improved UI/UX
   - Bug fixes and performance improvements
   ```

6. **Click "Save"** → **"Review release"** → **"Start rollout"**

---

## 📝 QUICK REFERENCE CHECKLIST

Before submitting, ensure:

- [ ] AAB file built and uploaded
- [ ] App name filled (max 50 chars)
- [ ] Short description filled (max 80 chars)
- [ ] Full description filled (max 4000 chars)
- [ ] App icon uploaded (512×512 PNG)
- [ ] Feature graphic uploaded (1024×500 PNG)
- [ ] At least 2 screenshots uploaded
- [ ] Privacy policy URL added
- [ ] Data safety form completed
- [ ] Content rating completed
- [ ] Target audience set
- [ ] Countries/regions selected
- [ ] Release notes added
- [ ] All sections show green checkmarks ✅

---

## 🆘 TROUBLESHOOTING

### Issue: "Privacy policy required"
**Solution**: Create privacy policy and add URL in "Policy" → "App content"

### Issue: "Screenshots required"
**Solution**: Upload at least 2 phone screenshots in "Store presence" → "Main store listing"

### Issue: "Data safety form incomplete"
**Solution**: Complete all questions in "Policy" → "App content" → "Data safety"

### Issue: "Content rating required"
**Solution**: Complete questionnaire in "Policy" → "App content" → "Content rating"

### Issue: "App signing key"
**Solution**: Already handled - your AAB is signed with release keystore

### Issue: Build fails
**Solution**: 
1. Run `flutter clean && flutter pub get`
2. Check `key.properties` exists and is correct
3. Verify keystore file exists

---

## 📞 RESOURCES & HELP

- **Google Play Console Help**: https://support.google.com/googleplay/android-developer
- **Flutter Publishing Guide**: https://docs.flutter.dev/deployment/android
- **Play Store Policies**: https://play.google.com/about/developer-content-policy/
- **Bundletool**: https://github.com/google/bundletool

---

## 🎉 CONGRATULATIONS!

You're now ready to publish your app to Google Play Store!

**Timeline Summary**:
- **Account setup**: 30 minutes
- **App preparation**: 1 hour
- **Store listing**: 1-2 hours
- **Review process**: 1-7 days
- **Total**: ~1 week from start to live

**Good luck with your app launch! 🚀**

---

## 📧 SUPPORT

If you encounter any issues:
1. Check this guide first
2. Review Google Play Console help
3. Check Flutter documentation
4. Contact Google Play support (if needed)

---

**Last Updated**: 2024
**App**: Tawfir Energy
**Package**: com.tawfir.energy
**Version**: 1.0.0+5
