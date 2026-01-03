# 🚨 DO THIS FIRST - Fix Debug Signing Error

## The Problem
Google Play is rejecting your AAB because it's signed in **debug mode**.

## The Solution
You need to create a **release keystore** and configure it.

---

## ⚡ Quick Fix (Choose One Method)

### Method 1: Automated Script (Easiest)

**Run this command in PowerShell:**
```powershell
.\setup_keystore.ps1
```

**Or double-click:** `CREATE_KEYSTORE_NOW.bat`

This will guide you through everything!

---

### Method 2: Manual Setup

#### Step 1: Create Keystore

Open **PowerShell** or **CMD** in your project root, then:

```cmd
cd android
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Enter when prompted:**
- **Keystore password**: `MyPassword123!` (REMEMBER THIS!)
- **Re-enter password**: `MyPassword123!`
- **First and last name**: `Tawfir Energy`
- **Organizational unit**: (Press Enter)
- **Organization**: `Tawfir Energy`
- **City**: `Casablanca` (or your city)
- **State/Province**: (Press Enter)
- **Country code**: `MA` (or your country: FR, DZ, etc.)
- **Confirm**: Type `yes`
- **Key password**: Press Enter (to use same as keystore)

**After this, you'll have:** `android/upload-keystore.jks`

---

#### Step 2: Create key.properties

Create file: **`android/key.properties`**

**Copy this EXACT content (replace with YOUR password):**

```properties
storePassword=MyPassword123!
keyPassword=MyPassword123!
keyAlias=upload
storeFile=upload-keystore.jks
```

**⚠️ REPLACE `MyPassword123!` with the password you used in Step 1!**

---

#### Step 3: Verify Files Exist

You should now have:
- ✅ `android/upload-keystore.jks` (keystore file)
- ✅ `android/key.properties` (with your passwords)

---

#### Step 4: Rebuild AAB

```cmd
cd ..
flutter clean
flutter build appbundle --release
```

**You should see:**
- ✅ No warning about debug signing
- ✅ AAB created successfully

---

#### Step 5: Upload to Google Play

Upload: `build/app/outputs/bundle/release/app-release.aab`

**It will now be accepted!** ✅

---

## 🔒 CRITICAL: Backup Your Keystore!

**DO THIS IMMEDIATELY:**

1. **Copy** `android/upload-keystore.jks` to:
   - USB drive
   - Cloud storage (Google Drive, Dropbox)
   - Secure backup location

2. **Save your passwords** in a password manager

3. **⚠️ If you lose the keystore, you CANNOT update your app on Google Play!**

---

## ✅ Verification Checklist

After setup, verify:

- [ ] `android/upload-keystore.jks` exists
- [ ] `android/key.properties` exists
- [ ] `key.properties` has correct passwords (not placeholders)
- [ ] Keystore backed up to secure location
- [ ] Passwords saved
- [ ] `flutter build appbundle --release` runs without debug signing warning
- [ ] AAB file created at: `build/app/outputs/bundle/release/app-release.aab`

---

## 🐛 Troubleshooting

### "keytool is not recognized"
- **Fix**: Install Java JDK
- **Or use full path**: `"C:\Program Files\Java\jdk-XX\bin\keytool.exe" -genkey ...`

### "Could not find keystore file"
- **Fix**: Make sure `upload-keystore.jks` is in `android/` folder
- Check `storeFile=upload-keystore.jks` in `key.properties`

### Still getting "debug mode" error?
1. Delete old AAB: `build/app/outputs/bundle/release/app-release.aab`
2. Run `flutter clean`
3. Verify `key.properties` has correct passwords (not "YOUR_PASSWORD_HERE")
4. Rebuild: `flutter build appbundle --release`

### Build succeeds but still debug signed?
- Check `key.properties` file - make sure passwords are correct
- Verify keystore file exists: `android/upload-keystore.jks`
- Check build output for any errors

---

## 📝 Example key.properties

**Correct:**
```properties
storePassword=MySecurePass123!
keyPassword=MySecurePass123!
keyAlias=upload
storeFile=upload-keystore.jks
```

**Wrong (will not work):**
```properties
storePassword=YOUR_PASSWORD_HERE
keyPassword=YOUR_PASSWORD_HERE
keyAlias=upload
storeFile=upload-keystore.jks
```

---

## 🎯 Summary

1. **Create keystore** → `android/upload-keystore.jks`
2. **Create key.properties** → `android/key.properties` (with real passwords)
3. **Backup keystore** → Save to secure location
4. **Rebuild** → `flutter build appbundle --release`
5. **Upload** → Google Play will accept it!

---

**After completing these steps, your AAB will be properly signed for Google Play! 🚀**

