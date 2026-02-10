# Firebase Authentication – Login page not showing

## 1. Run the correct app entry point

The app that shows **Login first** uses **`lib/main.dart`**.

- In **VS Code**: Run with **F5** or **Run > Start Debugging** (default is `lib/main.dart`).
- In **Android Studio**: Use the default run configuration (main.dart).
- From **terminal**:  
  `flutter run`  
  (do not use `-t lib/main_admin_v2.dart` or another file).

If you run **`main_admin_v2.dart`** or another entry point, you will not see the login flow from `main.dart`.

---

## 2. Firebase Console – Enable Email/Password sign-in

1. Open [Firebase Console](https://console.firebase.google.com/) and select project **tawfir-energy-prod-98053**.
2. Go to **Build > Authentication**.
3. Open the **Sign-in method** tab.
4. Click **Email/Password**.
5. Turn **Enable** ON and save.

Without this, sign-up and login will not work.

---

## 3. Clean and rebuild

Sometimes an old build is cached:

```bash
flutter clean
flutter pub get
flutter run
```

---

## 4. Confirm you see Login

- On start you should see: **Tawfir Energy**, **Sign in to continue**, email and password fields, **Login** button, and **Sign up** link.
- If you see a screen with bottom navigation (Home, Espace Pro, etc.), that is **HomeScreen** from a different flow, not the auth flow from `lib/main.dart`. Run as in step 1.

---

## 5. Force Login on every start (already in code)

In **`lib/main.dart`** at the top:

```dart
const bool kForceLoginScreenOnStart = true;
```

With this `true`, the app signs out on start so the Login page is always shown first. Keep it `true` until you confirm the login screen appears.
