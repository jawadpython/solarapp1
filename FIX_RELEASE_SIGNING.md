# 🔐 Fix: Release Signing for Google Play

## Problem
Your AAB is signed in debug mode because `key.properties` file is missing or not configured.

## Solution: Create Keystore & Configure Signing

---

## STEP 1: Create Your Release Keystore

Open PowerShell or Command Prompt in your project root and run:

```powershell
cd android
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**You will be prompted to enter:**
1. **Keystore password**: (Remember this! You'll need it)
2. **Re-enter password**: (Confirm)
3. **First and last name**: Your name or company name
4. **Organizational unit**: (Optional, press Enter to skip)
5. **Organization**: Your company name (e.g., "Tawfir Energy")
6. **City**: Your city
7. **State/Province**: Your state/province
8. **Country code**: (e.g., "MA" for Morocco, "FR" for France)
9. **Key password**: (Press Enter to use same as keystore password, or enter different one)

**Example:**
```
Enter keystore password: MySecurePassword123!
Re-enter new password: MySecurePassword123!
What is your first and last name?
  [Unknown]: Tawfir Energy
What is the name of your organizational unit?
  [Unknown]: 
What is the name of your organization?
  [Unknown]: Tawfir Energy
What is the name of your City or Locality?
  [Unknown]: Casablanca
What is the name of your State or Province?
  [Unknown]: 
What is the two-letter country code for this unit?
  [Unknown]: MA
Is CN=Tawfir Energy, OU=Unknown, O=Tawfir Energy, L=Casablanca, ST=Unknown, C=MA correct?
  [no]: yes

Generating 2,048 bit RSA key pair and self-signed certificate (SHA256withRSA) with a validity of 10,000 days
        for: CN=Tawfir Energy, OU=Unknown, O=Tawfir Energy, L=Casablanca, ST=Unknown, C=MA
Enter key password for <upload>
        (RETURN if same as keystore password): 
[Storing upload-keystore.jks]
```

✅ **After this step, you should have:** `android/upload-keystore.jks`

---

## STEP 2: Create key.properties File

1. **Copy the template:**
   ```powershell
   Copy-Item android\key.properties.template android\key.properties
   ```

2. **Edit `android/key.properties`** and fill in your actual values:

   ```properties
   storePassword=MySecurePassword123!
   keyPassword=MySecurePassword123!
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```

   **Replace:**
   - `MySecurePassword123!` → Your actual keystore password
   - `MySecurePassword123!` → Your actual key password (or same as storePassword)
   - `upload` → Your alias name (usually "upload")
   - `upload-keystore.jks` → Your keystore filename

---

## STEP 3: Verify key.properties Location

Make sure `key.properties` is in: `android/key.properties`

**File structure should be:**
```
solarapp1/
├── android/
│   ├── key.properties          ← HERE
│   ├── upload-keystore.jks     ← HERE
│   └── app/
│       └── build.gradle.kts
```

---

## STEP 4: Clean & Rebuild AAB

```powershell
# Clean previous builds
flutter clean

# Build release AAB (this will now use release signing)
flutter build appbundle --release
```

---

## STEP 5: Verify Release Signing

After build completes, verify the AAB is signed correctly:

```powershell
# Check signing info
jarsigner -verify -verbose -certs build\app\outputs\bundle\release\app-release.aab
```

**You should see:**
- ✅ "jar verified."
- ✅ Certificate information (not debug certificate)

---

## STEP 6: Upload to Google Play

Now upload the new AAB:
- Location: `build/app/outputs/bundle/release/app-release.aab`
- This should now be accepted by Google Play!

---

## 🔒 Security Notes

### ⚠️ IMPORTANT: Keep Your Keystore Safe!

1. **Backup your keystore:**
   - Copy `android/upload-keystore.jks` to a secure location
   - Store passwords in a password manager
   - **If you lose the keystore, you CANNOT update your app on Google Play!**

2. **Never commit to Git:**
   - ✅ `key.properties` is already in `.gitignore`
   - ✅ `*.jks` files are already in `.gitignore`
   - Double-check these files are NOT in your repository

3. **Store passwords securely:**
   - Use a password manager
   - Keep a backup of keystore + passwords in a secure location

---

## 🐛 Troubleshooting

### Error: "keytool is not recognized"
- **Solution**: Add Java to PATH, or use full path:
  ```powershell
  "C:\Program Files\Java\jdk-XX\bin\keytool.exe" -genkey ...
  ```

### Error: "keystore.properties file not found"
- **Solution**: Make sure `key.properties` is in `android/` folder (not `android/app/`)

### Error: "Could not find keystore file"
- **Solution**: Check `storeFile` path in `key.properties`:
  - If keystore is in `android/`, use: `storeFile=upload-keystore.jks`
  - If keystore is in `android/app/`, use: `storeFile=app/upload-keystore.jks`

### Still getting "debug mode" error?
- **Solution**: 
  1. Delete old AAB: `build/app/outputs/bundle/release/app-release.aab`
  2. Run `flutter clean`
  3. Rebuild: `flutter build appbundle --release`
  4. Verify with `jarsigner` command above

---

## ✅ Quick Checklist

- [ ] Keystore created (`android/upload-keystore.jks`)
- [ ] `key.properties` file created with correct values
- [ ] Keystore backed up to secure location
- [ ] Passwords saved in password manager
- [ ] `flutter clean` executed
- [ ] `flutter build appbundle --release` completed successfully
- [ ] Verified signing with `jarsigner` command
- [ ] New AAB uploaded to Google Play

---

## 📝 Example key.properties

```properties
storePassword=MySecurePassword123!
keyPassword=MySecurePassword123!
keyAlias=upload
storeFile=upload-keystore.jks
```

**Note:** Use your actual passwords, not the example ones!

---

**After completing these steps, your AAB will be properly signed for release! 🎉**

