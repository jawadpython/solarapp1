# Migrate Storage, Functions & Admin to New Account (solar-app-f698e)

## Done in code

- **Functions** – `functions/index.js` now uses the new project URL for email links:  
  `https://solar-app-f698e.firebaseapp.com` (verification + password reset).
- **.firebaserc** – Default project is `solar-app-f698e`.
- **Admin panel** – Already uses the new Firebase config in `lib/main_admin_v2.dart` (same as main app). No extra code change needed.

---

## What you need to do locally

### 1. Use the correct Firebase project and account

In a terminal (PowerShell) in the project folder:

```powershell
firebase login
```

Log in with the Google account that owns **solar-app-f698e**.

Then:

```powershell
firebase use solar-app-f698e
```

You should see: `Now using project solar-app-f698e`.

---

### 2. Deploy Storage rules

You said you already created Storage in the new project. Deploy the rules so uploads (e.g. technician certificates, products) are allowed:

```powershell
firebase deploy --only storage
```

---

### 3. Deploy Firestore rules (optional but recommended)

So the new project has the same security rules:

```powershell
firebase deploy --only firestore
```

---

### 4. Deploy Cloud Functions

- The new project must be on the **Blaze (pay-as-you-go)** plan to use Functions.
- Set the same **environment variables** (Resend) for the new project.

**Option A – Firebase Console (recommended)**  
1. Firebase Console → **solar-app-f698e** → **Functions** → **Environment variables** (or **Secrets**).  
2. Add:
   - `RESEND_API_KEY` = your Resend API key  
   - `RESEND_FROM_EMAIL` = e.g. `noreply@yourdomain.com`  
   - `RESEND_FROM_NAME` = e.g. `Tawfir Energy`

**Option B – CLI (if you use params)**  
If your functions use Firebase params, set them as in your old project.

Then deploy:

```powershell
firebase deploy --only functions
```

---

### 5. Admin panel on the new account

The **admin panel app** already talks to **solar-app-f698e** (config in `lib/main_admin_v2.dart`). You don’t need to change code.

- **Run locally:**  
  `flutter run -d chrome -t lib/main_admin_v2.dart`  
  It will use the new project.

- **Deploy admin to Firebase Hosting (new project):**  
  1. Build the admin web app:  
     `flutter build web -t lib/main_admin_v2.dart`  
  2. Deploy:  
     `firebase deploy --only hosting`  
  That will overwrite the current `build/web` with the admin app. If you also want to host the main app, use two sites or build/deploy each app when needed.

---

## Quick checklist

| Step | Command / action |
|------|-------------------|
| 1 | `firebase login` then `firebase use solar-app-f698e` |
| 2 | `firebase deploy --only storage` |
| 3 | `firebase deploy --only firestore` (optional) |
| 4 | Set Resend env vars in Console for **solar-app-f698e**, then `firebase deploy --only functions` |
| 5 | Admin: run with `-t lib/main_admin_v2.dart` or build + `firebase deploy --only hosting` |

If `firebase use solar-app-f698e` says “Invalid project selection”, the logged-in account does not have access to **solar-app-f698e**. Use the Google account that owns that project and run `firebase login` again.
