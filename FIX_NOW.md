# 🔧 FIX RELEASE SIGNING - DO THIS NOW

## ⚠️ Current Status
Your AAB is being built with **DEBUG signing**. Google Play will **REJECT** it.

## ✅ Quick Fix (5 minutes)

### Step 1: Create Keystore

**Open PowerShell or CMD in your project root, then run:**

```cmd
cd android
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**You'll be asked:**
1. **Keystore password**: Enter a strong password (REMEMBER IT!)
2. **Re-enter password**: Type it again
3. **First and last name**: Your name or company (e.g., "Tawfir Energy")
4. **Organizational unit**: (Press Enter to skip)
5. **Organization**: Your company (e.g., "Tawfir Energy")
6. **City**: Your city
7. **State/Province**: (Press Enter to skip)
8. **Country code**: 2 letters (e.g., "MA" for Morocco, "FR" for France, "DZ" for Algeria)
9. **Confirm**: Type "yes"
10. **Key password**: Press Enter to use same as keystore, or enter different one

**Example:**
```
Enter keystore password: MySecurePass123!
Re-enter new password: MySecurePass123!
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
Enter key password for <upload>
        (RETURN if same as keystore password): 
[Storing upload-keystore.jks]
```

---

### Step 2: Create key.properties File

**Create file:** `android/key.properties`

**Copy this content and REPLACE the passwords:**

```properties
storePassword=MySecurePass123!
keyPassword=MySecurePass123!
keyAlias=upload
storeFile=upload-keystore.jks
```

**⚠️ IMPORTANT:** Replace `MySecurePass123!` with the **actual password** you used in Step 1!

---

### Step 3: Rebuild AAB

```cmd
cd ..
flutter clean
flutter build appbundle --release
```

**You should now see:**
- ✅ No warning about debug signing
- ✅ AAB file created successfully

---

### Step 4: Verify Release Signing

**Check if AAB is properly signed:**

```cmd
jarsigner -verify -verbose -certs build\app\outputs\bundle\release\app-release.aab
```

**You should see:**
- ✅ "jar verified."
- ✅ Certificate info (NOT "CN=Android Debug")

---

### Step 5: Upload to Google Play

Upload: `build/app/outputs/bundle/release/app-release.aab`

**It should now be accepted!** ✅

---

## 🔒 CRITICAL: Backup Your Keystore!

**DO THIS NOW:**
1. Copy `android/upload-keystore.jks` to a secure location (USB drive, cloud backup)
2. Save your passwords in a password manager
3. **If you lose the keystore, you CANNOT update your app on Google Play!**

---

## 🐛 Troubleshooting

### "keytool is not recognized"
- Install Java JDK
- Or use full path: `"C:\Program Files\Java\jdk-XX\bin\keytool.exe" -genkey ...`

### "Could not find keystore file"
- Make sure `upload-keystore.jks` is in `android/` folder
- Check `storeFile=upload-keystore.jks` in `key.properties`

### Still getting debug signing warning?
1. Delete old AAB
2. Run `flutter clean`
3. Verify `key.properties` has correct passwords
4. Rebuild

---

## ✅ Checklist

- [ ] Keystore created (`android/upload-keystore.jks`)
- [ ] `key.properties` created with correct passwords
- [ ] Keystore backed up to secure location
- [ ] Passwords saved
- [ ] `flutter clean` executed
- [ ] `flutter build appbundle --release` completed
- [ ] No debug signing warning
- [ ] Verified with `jarsigner` command
- [ ] Ready to upload to Google Play!

---

**After completing these steps, your AAB will be properly signed for Google Play! 🚀**

