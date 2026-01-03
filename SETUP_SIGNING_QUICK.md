# ⚡ Quick Fix: Release Signing Setup

## The Problem
Your AAB is being signed in **debug mode** because the release keystore is missing.

## Quick Solution (Choose One)

---

### 🚀 Option 1: Automated Script (Windows)

**Run this command:**
```cmd
create_keystore.bat
```

This will:
1. Create the keystore file
2. Create `key.properties` template
3. Guide you to fill in passwords

**Then edit `android/key.properties`** and replace:
- `YOUR_KEYSTORE_PASSWORD_HERE` → Your actual password
- `YOUR_KEY_PASSWORD_HERE` → Your key password (or same)

---

### 🛠️ Option 2: Manual Setup

#### Step 1: Create Keystore
```cmd
cd android
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Enter when prompted:**
- Keystore password: (Remember this!)
- Key password: (Press Enter to use same, or enter different)
- Your name/company info
- Country code (e.g., MA, FR, DZ)

#### Step 2: Create key.properties

Create file: `android/key.properties`

```properties
storePassword=YOUR_ACTUAL_PASSWORD
keyPassword=YOUR_ACTUAL_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

**Replace `YOUR_ACTUAL_PASSWORD` with the password you entered in Step 1.**

#### Step 3: Rebuild
```cmd
cd ..
flutter clean
flutter build appbundle --release
```

---

### ✅ Verify It Worked

After building, check the output. You should see:
- ✅ No warning about debug signing
- ✅ AAB file created at: `build/app/outputs/bundle/release/app-release.aab`

---

### 🔒 Security Reminder

**BACKUP YOUR KEYSTORE!**
- Copy `android/upload-keystore.jks` to a secure location
- Save your passwords in a password manager
- **If you lose it, you CANNOT update your app on Google Play!**

---

## 📁 Files You Need

After setup, you should have:
- ✅ `android/upload-keystore.jks` (keystore file)
- ✅ `android/key.properties` (with your passwords)

Both files are already in `.gitignore` (safe from Git).

---

**After setup, run: `flutter build appbundle --release`** 🚀

