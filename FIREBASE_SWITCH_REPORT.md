# Firebase Project Switch – What to Change and How

This report lists everything you need to change to link this app to a **new** Firebase project instead of the current one (`tawfir-energy-prod-98053`).

---

## 1. Create and configure the new Firebase project

1. Go to [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project** (or use an existing project).
3. Complete the wizard (name, Analytics optional).
4. In the project, add your apps:
   - **Android**: Register app with package name `com.tawfir.energy` (or your real package name). Download `google-services.json`.
   - **iOS**: Register app with bundle ID `com.tawfir.energy` (or your real bundle ID). Download `GoogleService-Info.plist`.
   - **Web**: Add a Web app. You will get a config object (apiKey, authDomain, projectId, etc.) – keep it for step 3.

5. In the new project, enable:
   - **Authentication** (e.g. Email/Password, Google, etc.).
   - **Cloud Firestore** (create database if needed).
   - **Cloud Storage** (if you use uploads).
   - **Cloud Functions** (if you use them; requires Blaze plan).

---

## 2. Replace config files (Android & iOS)

These files are **replaced entirely** with the ones from the new project. Do not edit them by hand; always use the files from the Firebase Console.

| What to change | Where | How |
|----------------|--------|-----|
| **Android** | `android/app/google-services.json` | In the new Firebase project: Project settings → Your apps → Android app → Download `google-services.json`. Replace the existing file with this one. |
| **iOS** | `ios/Runner/GoogleService-Info.plist` | In the new Firebase project: Project settings → Your apps → iOS app → Download `GoogleService-Info.plist`. Replace the existing file with this one. |

After replacing, **do not** commit the old files. Use only the new project’s files.

---

## 3. Update Dart code (Web / default config)

The app uses **hardcoded** `FirebaseOptions` for **web**. You must update them in **two** places with the values from the new Firebase project (Project settings → Your apps → Web app → Config).

### 3.1 Main app – `lib/main.dart`

Find this block (around lines 36–45):

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "AIzaSyBIJ17OtVeS218IBjnmf1UoWsxsu3YY0-k",
    authDomain: "tawfir-energy-prod-98053.firebaseapp.com",
    projectId: "tawfir-energy-prod-98053",
    storageBucket: "tawfir-energy-prod-98053.firebasestorage.app",
    messagingSenderId: "751649516744",
    appId: "1:751649516744:web:a43278ec8ae222cba449fd",
  ),
);
```


Replace with the **new project’s** values, for example:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "YOUR_NEW_WEB_API_KEY",
    authDomain: "YOUR_NEW_PROJECT_ID.firebaseapp.com",
    projectId: "YOUR_NEW_PROJECT_ID",
    storageBucket: "YOUR_NEW_PROJECT_ID.firebasestorage.app",
    messagingSenderId: "YOUR_NEW_MESSAGING_SENDER_ID",
    appId: "YOUR_NEW_WEB_APP_ID",
  ),
);
```

Get these from: Firebase Console → Project settings → General → Your apps → Web app → “SDK setup and configuration” (or “Config”).

### 3.2 Admin app – `lib/main_admin_v2.dart`

Find the same `FirebaseOptions` block (around lines 23–31) and replace it with the **same** new project values as in `lib/main.dart`.

---

## 4. Firebase CLI default project (`.firebaserc`)

Used for `firebase deploy`, hosting, functions, Firestore, Storage.

**File:** `.firebaserc` (project root)

**Current content:**

```json
{
  "projects": {
    "default": "tawfir-energy-prod-98053"
  }
}
```

**Change to:**

```json
{
  "projects": {
    "default": "YOUR_NEW_PROJECT_ID"
  }
}
```

Replace `YOUR_NEW_PROJECT_ID` with the **Project ID** of the new Firebase project (e.g. in Project settings → General).

---

## 5. Optional: use FlutterFire to avoid hardcoding (recommended later)

Right now the app uses **hardcoded** `FirebaseOptions` in Dart for web. To avoid editing them manually when switching projects:

1. Install FlutterFire CLI:  
   `dart pub global activate flutterfire_cli`
2. Run in project root:  
   `flutterfire configure`
3. This generates `lib/firebase_options.dart` from your current Firebase project and updates the app to use it. After that, when you switch projects you run `flutterfire configure` again and select the new project.

This report assumes you keep the current approach (manual edits). If you switch to FlutterFire, you would replace the hardcoded blocks in `main.dart` and `main_admin_v2.dart` with `DefaultFirebaseOptions.currentPlatform` (see FlutterFire docs).

---

## 6. Checklist summary

| Step | Item | Action |
|------|------|--------|
| 1 | New Firebase project | Create and add Android, iOS, Web apps; enable Auth, Firestore, Storage, Functions if needed. |
| 2a | Android | Replace `android/app/google-services.json` with the new project’s file. |
| 2b | iOS | Replace `ios/Runner/GoogleService-Info.plist` with the new project’s file. |
| 3a | Web (main app) | Update `FirebaseOptions` in `lib/main.dart` with new project’s web config. |
| 3b | Web (admin) | Update `FirebaseOptions` in `lib/main_admin_v2.dart` with the same web config. |
| 4 | CLI | In `.firebaserc`, set `"default": "YOUR_NEW_PROJECT_ID"`. |

---

## 7. After switching

- **Auth**: Existing users do **not** move. Users must sign up again (or you migrate them manually in the new project).
- **Firestore / Storage**: Data stays in the old project. You need to export/import or re-create data in the new project if required.
- **Cloud Functions**: Redeploy to the new project:  
  `firebase deploy --only functions`  
  (after updating `.firebaserc` and any env vars in `functions/.env` if you use a different project.)
- **Deploy hosting**:  
  `firebase deploy --only hosting`  
  (and/or `flutter build web` then deploy the `build/web` folder.)
- **Test**: Run the app on Android, iOS, and web and verify login, Firestore, Storage, and (if used) Functions against the new project.

---

## 8. Current project reference (old)

For your records, the **current** project is:

- **Project ID:** `tawfir-energy-prod-98053`
- **Auth domain:** `tawfir-energy-prod-98053.firebaseapp.com`
- **Storage bucket:** `tawfir-energy-prod-98053.firebasestorage.app`
- **Messaging sender ID:** `751649516744`

All of these will change when you use the new project’s config and files.
