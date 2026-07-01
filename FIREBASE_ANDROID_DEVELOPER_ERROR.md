# Fix Android "DEVELOPER_ERROR" (ConnectionResult statusCode=17)

The logs show **DEVELOPER_ERROR** when using Google Play Services / Firebase. This usually means your app’s **SHA-1 fingerprint** is not registered in Firebase, so the server rejects the app.

## Fix

### 1. Get your SHA-1 (and SHA-256)

**Debug builds** (what you use when running from Android Studio / `flutter run`):

```bash
# Windows (PowerShell) – default debug keystore
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

**Release builds** (when you build the APK for Play Store or release):

```bash
# Use your release keystore path and alias
keytool -list -v -keystore path\to\your\upload-keystore.jks -alias your-key-alias
```

From the output, copy the **SHA-1** and **SHA-256** lines (e.g. `SHA1: AB:CD:EF:...`).

**Your current debug keystore fingerprints** (add these in Firebase if you use the default debug keystore):

| Type  | Fingerprint |
|-------|-------------|
| SHA-1 | `20:D1:58:66:D5:A7:6A:32:32:F7:69:CE:79:03:22:6A:34:F5:BB:D4` |
| SHA-256 | `D1:B6:D5:96:72:B5:1B:BB:C7:95:04:1A:F6:9E:C5:FC:6F:4B:25:E9:78:47:FE:69:C3:1B:4E:71:5B:C8:18:AC` |

### 2. Add fingerprints in Firebase

1. Open [Firebase Console](https://console.firebase.google.com) → project **tawfir-energy-prod-98053**.
2. Click the gear **Project settings**.
3. Under **Your apps**, select your **Android** app (package `com.tawfir.energy`).
4. Click **Add fingerprint** and paste:
   - Your **debug** SHA-1 (and optionally SHA-256) for development.
   - Your **release** SHA-1 (and optionally SHA-256) for the signed release APK.
5. Save.

### 3. Rebuild and run

- Clean and run again:
  ```bash
  flutter clean
  flutter pub get
  flutter run
  ```
- Or build and install the APK again on the device.

After adding the correct SHA-1 for the keystore you use to sign the app, **DEVELOPER_ERROR** should stop and Firebase Auth (and Cloud Functions) will work on that device.

---

## Other log messages (can often be ignored)

- **gralloc4 / Empty SMPTE 2094-40 data** – Device/GPU driver messages (e.g. some MediaTek/Xiaomi). Harmless for your app.
- **ProviderInstaller / DynamiteModule** – Related to Play Services security provider; often appears on emulators or restricted devices. If login and Firebase work after fixing SHA-1, you can ignore these.
- **FlagRegistrar / Phenotype.API** – Google internal feature flags. Not required for Firebase Auth to work.
