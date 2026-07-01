/// URLs Firebase Auth opens **after** the user completes an email action in the browser.
///
/// These must be deployed as static files under `web/` (copied to `build/web/` on
/// `flutter build web`) and the domain must stay in Firebase Console → Authentication
/// → Settings → **Authorized domains**.
///
/// In Firebase Console → Authentication → **Templates**, do not set an “action URL”
/// that resolves to `/` only, or Firebase may bake `continueUrl=…firebaseapp.com` with
/// **no path** into every link — which loads the SPA (admin login) instead of these pages.
///
/// Sending a **new** verification email after deploying fixes stale links whose
/// continueUrl was already persisted as the bare domain.
///
/// Keep URLs in sync with `functions/index.js` (generateEmailVerificationLink /
/// generatePasswordResetLink).
const String kFirebaseAuthContinueDomain = 'https://solar-app-f698e.firebaseapp.com';

/// After email verification — **not** the main SPA root (which may load admin login).
const String kEmailVerifiedContinueUrl =
    '$kFirebaseAuthContinueDomain/email-verified.html';

/// After password reset flow — **not** the main SPA root.
const String kPasswordResetContinueUrl =
    '$kFirebaseAuthContinueDomain/password-reset-complete.html';
