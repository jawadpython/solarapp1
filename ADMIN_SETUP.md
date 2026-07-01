# Admin Panel – How to Add Admin Users

The admin panel only allows users who are listed as **admins** in Firestore. Normal app users cannot access it.

## Quick add – your admin (UID already set)

1. Open [Firebase Console](https://console.firebase.google.com/) → project **solar-app-f698e** → **Firestore**.
2. Click **Start collection** (or **Add collection** if you already have data).
3. **Collection ID:** type exactly: `admins`
4. Click **Next**.
5. **Document ID:** type exactly: `HkMTsIKpbNPeTjuJYethstvNRXS2`
6. (Optional) Add a field: Field = `role`, Type = `string`, Value = `admin` — then click **Save**. Or leave the document empty and click **Save**.

Done. That user can now log in to the admin panel.

---

## How it works

1. User logs in with email/password on the admin page.
2. The app checks Firestore: **`admins/{userUid}`**.
3. If that document **exists** → show the admin dashboard.
4. If it **does not exist** → show "Accès refusé" (Access denied) and sign out.

## Add your first admin

1. **Create a user** in Firebase (if you haven’t already):
   - Firebase Console → **Authentication** → **Users** → **Add user**
   - Enter the email and password you want for the admin account.

2. **Get that user’s UID**:
   - In **Authentication** → **Users**, click the user you just created.
   - Copy the **User UID** (e.g. `xYz123AbC...`).

3. **Add them to the admins list**:
   - Go to **Firestore** → **Start collection** (or open the **admins** collection if it exists).
   - Collection ID: **`admins`**
   - Document ID: **paste the User UID** (the one you copied).
   - Add a field (optional, for your reference): e.g. `email` (string) = `admin@yourdomain.com`
   - Save.

That user can now log in to the admin panel; others will see "Accès refusé".

## Add more admins

Repeat step 3 for each admin: create a Firestore document **`admins/{their-uid}`** (document ID = their User UID from Authentication). The document can be empty or contain fields like `email` for reference.

## Remove admin access

Delete the document **`admins/{uid}`** in Firestore for that user. They will no longer be able to access the admin panel (they can still log in to the normal app if you use the same Firebase Auth for it).

---

## "Permission denied" or "Accès refusé" when logging in

1. **Deploy Firestore rules** (required for the new project):
   ```powershell
   firebase use solar-app-f698e
   firebase deploy --only firestore
   ```
   Without this, the app cannot read the `admins` collection.

2. **Check the document**  
   Firestore → **admins** collection → document with ID exactly: `HkMTsIKpbNPeTjuJYethstvNRXS2` (same as the admin user’s UID).

3. **Check you’re using the right account**  
   The UID of the account you use to log in must match the document ID. In Firebase Console → Authentication → Users, click your user and copy the **User UID**. It must match the document ID in `admins` exactly (including case).

---

## Deploy admin panel to Firebase Hosting

1. **Use the correct Firebase project:**
   ```powershell
   firebase use solar-app-f698e
   ```

2. **Build and deploy in one go (recommended):**
   ```powershell
   .\deploy_admin_v2.ps1
   ```
   This script runs `flutter clean`, `flutter pub get`, builds the admin app with `flutter build web -t lib/main_admin_v2.dart`, then runs `firebase deploy --only hosting`.

3. **Or do it manually:**
   ```powershell
   flutter build web -t lib/main_admin_v2.dart --release
   firebase deploy --only hosting
   ```

After deploy, the admin panel is available at: **https://solar-app-f698e.web.app** (or your custom domain if configured in Hosting).
