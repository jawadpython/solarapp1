# Tawfir Energy – App Improvements Roadmap

This document lists suggested improvements you can add to the app. It considers everything currently in the app: **Firebase Auth (login/signup with name)**, **offline overlay**, **removed file/image upload** (to add later), **HomeScreen after login**, **calculator**, **project study**, **installation/maintenance**, **pumping**, **marketplace**, **profile**, **search**, **Espace Pro**, **localization (AR/EN/FR)**, and **admin** tooling.

**No code is modified by this file; it is a reference for future work.**

---

## 1. Authentication & Account

| # | Improvement | Description | Where | Priority |
|---|-------------|-------------|--------|----------|
| 1.1 | **Forgot password** | Add "Forgot password?" on login page → send reset email via `FirebaseAuth.sendPasswordResetEmail()`. | `login_page.dart`, `auth_service.dart` (method exists, wire UI) | High |
| 1.2 | **Email verification** | After signup, send verification email and optionally restrict access until verified. | `auth_service.dart`, signup flow, auth gate in `main.dart` | Medium |
| 1.3 | **Profile: edit name** | Let user change display name in Profile; call `user.updateProfile(displayName: newName)`. | `profile_screen.dart`, `auth_service.dart` | Medium |
| 1.4 | **Profile: show email** | Display current user email (and name) in Profile screen. | `profile_screen.dart` (read from `AuthService.instance.currentUser`) | Low |
| 1.5 | **Remember me / biometrics** | Optional local-auth (fingerprint/Face) to unlock app when already logged in. | New service + login flow | Low |
| 1.6 | **Sign out confirmation** | Before logout, show dialog "Are you sure you want to sign out?" | `home_screen.dart` menu (Logout ListTile) | Low |

---

## 2. Offline & Connectivity

| # | Improvement | Description | Where | Priority |
|---|-------------|-------------|--------|----------|
| 2.1 | **Retry when back online** | When user goes online again, auto-retry failed requests or show "Tap to retry" on the overlay. | `offline_overlay.dart`, optional queue in services | Medium |
| 2.2 | **Cache critical data** | Cache calculator regions, sun hours, or last results so key screens work offline (read-only). | `region_service.dart`, local DB (e.g. sqflite/hive) or shared_preferences | Medium |
| 2.3 | **Queue actions offline** | Queue devis/request submissions when offline and sync when online. | New sync service, Firestore offline persistence (already supported) | Low |

---

## 3. File & Image Upload (Re‑enable Later)

| # | Improvement | Description | Where | Priority |
|---|-------------|-------------|--------|----------|
| 3.1 | **Enable Firebase Storage** | Enable Storage in Firebase Console and add `firebase_storage` + `image_picker` (and optionally `file_picker`) to the app. | `pubspec.yaml`, Firebase Console | When ready |
| 3.2 | **Upload bill (facture)** | Re-add "Upload bill" in Étude Devis and Devis Request; upload file to Storage, save URL in Firestore. | `etude_devis_screen.dart`, `devis_request_screen.dart`, new upload service | When ready |
| 3.3 | **Partner/Technician documents** | Re-add document upload in partner and technician registration; store URLs in Firestore. | `partner_registration_screen.dart`, `technician_registration_screen.dart` | When ready |
| 3.4 | **Image compression** | Compress images before upload to save bandwidth and storage. | New utility or package (e.g. `flutter_image_compress`) | Low |

---

## 4. User Experience (UX) & UI

| # | Improvement | Description | Where | Priority |
|---|-------------|-------------|--------|----------|
| 4.1 | **Loading skeletons** | Replace generic `CircularProgressIndicator` with skeleton placeholders on list screens (partners, technicians, marketplace). | List screens, new skeleton widgets | Medium |
| 4.2 | **Pull-to-refresh** | Add pull-to-refresh on lists (partners, technicians, notifications, admin lists). | Each list/scroll view | Medium |
| 4.3 | **Empty states** | When a list is empty, show an illustration + short message + CTA instead of blank. | Partners, technicians, search results, admin tables | Medium |
| 4.4 | **Success feedback** | After submitting a devis/request, show a clear success screen or dialog with "Done" and optional reference number. | Devis/request submit flows | High |
| 4.5 | **Form validation messages** | Use localized strings for all validation messages (already have l10n; ensure auth and forms use them). | `login_page.dart`, `signup_page.dart`, forms across app | Low |
| 4.6 | **Haptic feedback** | Light haptic on button tap and important actions (e.g. submit, logout). | Theme or global button wrapper | Low |
| 4.7 | **Dark mode** | App has `darkTheme`; add a switch in Settings/Profile to toggle theme (save in SharedPreferences). | `main.dart`, profile/settings, `LanguageService` or new `ThemeService` | Low |

---

## 5. Localization (l10n)

| # | Improvement | Description | Where | Priority |
|---|-------------|-------------|--------|----------|
| 5.1 | **Auth strings in ARB** | Move "Login", "Sign up", "Name", "Email", "Password", "Logout", errors, etc. into `app_en.arb` / `app_fr.arb` / `app_ar.arb` and use `AppLocalizations` in auth screens. | `lib/l10n/*.arb`, `login_page.dart`, `signup_page.dart`, `home_screen.dart` | High |
| 5.2 | **RTL for Arabic** | Verify all new screens (auth, dialogs) respect RTL when locale is Arabic. | Auth and home screens | Medium |
| 5.3 | **Date/number formatting** | Use `intl` with current locale for dates and numbers in forms and lists. | Forms, admin tables, result screens | Low |

---

## 6. Security & Data

| # | Improvement | Description | Where | Priority |
|---|-------------|-------------|--------|----------|
| 6.1 | **Firestore rules** | Ensure rules restrict read/write by `request.auth != null` and optionally by `userId` for user-specific data. | Firebase Console → Firestore → Rules | High |
| 6.2 | **Sensitive data** | Do not log passwords or tokens; avoid storing sensitive data in plain text in SharedPreferences. | Entire codebase (search for `print`/`debugPrint` with user data) | Medium |
| 6.3 | **HTTPS / certificate pinning** | All Firebase and API calls should use HTTPS; consider pinning for high-security scenarios. | Network layer / Firebase config | Low |

---

## 7. Features (New or Extended)

| # | Improvement | Description | Where | Priority |
|---|-------------|-------------|--------|----------|
| 7.1 | **Notifications** | Use FCM for push notifications (new devis, request status, admin alerts). | New `firebase_messaging` service, notification handler, permissions | High |
| 7.2 | **My requests / history** | Screen listing the current user's devis/installation/maintenance requests with status. | New "My requests" screen, Firestore queries by `userId` | High |
| 7.3 | **Favorites / saved** | Let users save favorite products or technicians; store in Firestore per user. | Marketplace, technicians list, new "Favorites" screen | Medium |
| 7.4 | **Search in app** | Top-bar search (e.g. products, technicians, companies) as already planned in admin; extend to main app. | Search feature, home or app bar | Medium |
| 7.5 | **Calculator from HomeScreen** | Wire the Calculator card on the home screen to the existing calculator flow. | `home_screen.dart` (Calculator card `onTap`) | High |
| 7.6 | **Products from HomeScreen** | Wire the Products card to marketplace or product list. | `home_screen.dart` (Products card `onTap`) | Medium |
| 7.7 | **Support from HomeScreen** | Wire Support card to contact (phone/email) or FAQ screen. | `home_screen.dart` (Support card `onTap`) | Medium |
| 7.8 | **In-app chat** | Optional chat between user and support or technician (e.g. Firestore chat collection). | New chat feature | Low |

---

## 8. Performance

| # | Improvement | Description | Where | Priority |
|---|-------------|-------------|--------|----------|
| 8.1 | **List virtualization** | Ensure long lists (partners, technicians, admin tables) use lazy loading or pagination. | List views, Firestore `.limit()` + `startAfterDocument` | Medium |
| 8.2 | **Image optimization** | Use cached network images and placeholders for marketplace and banners. | `marketplace_screen.dart`, banners, consider `cached_network_image` | Medium |
| 8.3 | **Reduce build size** | Enable code splitting and tree-shaking; review large dependencies. | `pubspec.yaml`, build config | Low |
| 8.4 | **Analytics** | Add Firebase Analytics (or similar) for screen views and key events (signup, devis request) to improve product decisions. | `main.dart`, key screens | Low |

---

## 9. Testing & Quality

| # | Improvement | Description | Where | Priority |
|---|-------------|-------------|--------|----------|
| 9.1 | **Unit tests** | Add tests for calculator logic, auth service (mocked Firebase), and form validation. | `test/` folder | Medium |
| 9.2 | **Widget tests** | Basic widget tests for login form, signup form, and auth gate. | `test/` folder | Low |
| 9.3 | **Integration tests** | One flow: open app → login → navigate to calculator → fill and submit. | `integration_test/` | Low |
| 9.4 | **Error reporting** | Integrate Crashlytics (or similar) to get crash reports in production. | Firebase Crashlytics, `main.dart` | Medium |

---

## 10. Admin & Back Office

| # | Improvement | Description | Where | Priority |
|---|-------------|-------------|--------|----------|
| 10.1 | **Admin auth** | Restrict admin dashboard to specific emails or a custom claim in Firebase Auth. | Admin entry (e.g. `main_admin_v2.dart` or web dashboard), Firestore rules | High |
| 10.2 | **Audit log** | Log who (admin uid) did what (e.g. status change, assign technician) and when. | Firestore `audit_log` collection, admin actions | Low |
| 10.3 | **Export scheduling** | Optional scheduled export (e.g. daily CSV of new requests) via Cloud Functions. | Firebase Functions (backend) | Low |

---

## 11. DevOps & Release

| # | Improvement | Description | Where | Priority |
|---|-------------|-------------|--------|----------|
| 11.1 | **Environment config** | Use different Firebase projects (or emulators) for dev/staging/prod and switch via env or flavor. | `main.dart`, flavors, `--dart-define` | Medium |
| 11.2 | **Version in UI** | Show app version (e.g. from `package_info_plus`) in Profile or About screen. | Profile/About screen | Low |
| 11.3 | **Force login flag** | Keep `kForceLoginScreenOnStart` only for dev; ensure production build uses `false`. | `main.dart` (document in README or use flavor) | High |
| 11.4 | **CI/CD** | Automate build and upload to Play Store / App Store (e.g. Fastlane, GitHub Actions). | Repo root, scripts | Low |

---

## 12. Accessibility & Compliance

| # | Improvement | Description | Where | Priority |
|---|-------------|-------------|--------|----------|
| 12.1 | **Semantic labels** | Add `Semantics`/`semanticLabel` for important buttons and images for screen readers. | Key screens (auth, home, calculator) | Medium |
| 12.2 | **Font scaling** | Ensure layout works when user sets large text size in system settings. | Theme `textTheme`, avoid fixed font sizes where possible | Low |
| 12.3 | **Privacy policy / Terms** | Add links (or in-app screens) to Privacy Policy and Terms; consider consent for analytics. | Signup flow, Profile/Settings | Medium |

---

## Quick reference – what the app already has

- **Auth:** Login, Sign up (with name), Logout; Firebase Auth only; auth state → Login vs HomeScreen.
- **Offline:** Full-screen overlay when offline with message to connect.
- **Upload:** File/image upload removed; can be re-added later (see §3).
- **Home:** After login → HomeScreen (bottom nav, banner, services); "Hi, Name" in app bar when display name is set.
- **Features:** Calculator, project study (on/off/hybrid/pumping), installation & maintenance requests, pumping, marketplace, profile, search (companies/technicians), Espace Pro (partner/technician registration).
- **L10n:** AR, EN, FR (partially; auth strings still hardcoded in English).
- **Admin:** Admin dashboard (e.g. Admin V2) for requests, technicians, partners, etc.

---

## Suggested order to implement (by impact)

1. **Auth:** Forgot password (1.1), Auth strings in ARB (5.1), then optional email verification (1.2).
2. **UX:** Success feedback after submit (4.4), wire Calculator/Products/Support on home (7.5–7.7).
3. **Features:** "My requests" (7.2), then push notifications (7.1).
4. **Security:** Firestore rules review (6.1), `kForceLoginScreenOnStart = false` in prod (11.3).
5. **Then:** Offline retry (2.1), profile edit name (1.3), loading/empty states (4.1–4.3), and the rest as needed.

---

*Document generated for Tawfir Energy app. Adjust priorities and scope to match your roadmap and resources.*
