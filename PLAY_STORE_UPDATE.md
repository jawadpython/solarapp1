# Update Your App on Google Play Store

Use this guide to publish an update of your app (e.g. after Firebase migration, fixes, or new features).

---

## 1. Version (bump before each Play upload)

Set **`pubspec.yaml`** line `version: X.Y.Z+BUILD`:

- **`X.Y.Z`** → **versionName** (shown to users in Play Store).
- **`BUILD`** → **versionCode** (integer, **must always increase** for each upload). It must be **greater than** the latest versionCode accepted by Play Console for this app.

**Current project baseline:** `1.1.1+10` → versionName `1.1.1`, versionCode `10`. Before your **next** release after this, bump both parts again (e.g. `1.1.2+11`).

If Play Console already shows a higher **version code** for the live app, set `+BUILD` to a number **above** that value (Play rejects equal or lower codes).

```yaml
version: 1.1.1+10   # versionName=1.1.1, versionCode=10
```

---

## 2. Signing (required for Play Store)

Your release build must be signed with the **same upload key** you used for the existing app on Play Store.

- **Already set up:** `android/key.properties` and your keystore (e.g. `upload-keystore.jks`) are configured in `android/app/build.gradle.kts`.
- **First time or new key:** See `FIX_RELEASE_SIGNING.md` for creating `key.properties` and the keystore. The keystore you use for **updates** must be the same as the one used for the **first** upload of this app; otherwise Play Console will reject the update.

---

## 3. Build the Android App Bundle (AAB)

Google Play prefers (or requires) **AAB** for new uploads and updates. From the project root:

```powershell
cd "d:\solarappnew\solarapp1"
flutter clean
flutter pub get
flutter build appbundle --release
```

When it succeeds, the file is here:

- **`build/app/outputs/bundle/release/app-release.aab`**

This is the file you upload to Play Console.

---

## 4. Upload in Google Play Console

1. Open [Google Play Console](https://play.google.com/console) and select your app (e.g. **Tawfir Energy** / **Noor Energy**).
2. Go to **Release** → **Production** (or **Testing** → **Internal/Closed/Open testing** if you want to test first).
3. Click **Create new release**.
4. Upload **`app-release.aab`** (from `build/app/outputs/bundle/release/`).
5. Add **Release name** (e.g. `1.1.1 — Calculator & fixes`).
6. Add **Release notes** (what’s new for users), then **Save** and **Review release**.
7. If everything is correct, click **Start rollout to Production** (or to your chosen track).

---

## 5. Checklist before upload

| Item | Check |
|------|--------|
| Version code | Strictly higher than the latest upload on Play (current target in repo: **10**) |
| Signing | Same upload key as existing app; `key.properties` present |
| AAB path | `build/app/outputs/bundle/release/app-release.aab` |
| Testing | Test the release build on a device before uploading |

---

## 6. Optional: Build release APK (for side install / testing)

If you need an APK (e.g. for direct install or testing), run:

```powershell
flutter build apk --release
```

Output: **`build/app/outputs/flutter-apk/app-release.apk`**  
Do **not** use this APK for Play Store if you already use AAB; use the AAB from step 3.
