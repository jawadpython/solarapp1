/// Base URL of the standalone auth email API (Render/Railway/etc.).
///
/// Deploy `server/auth-email-api` and paste the public URL here, e.g.
/// `https://noor-auth-email.onrender.com`
///
/// Or build with:
/// `--dart-define=AUTH_EMAIL_API_URL=https://noor-auth-email.onrender.com`
class AuthEmailApiConfig {
  /// Paste your deployed API URL here (no trailing slash).
  static const String fileBaseUrl = 'https://solarapp1.onrender.com';

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('AUTH_EMAIL_API_URL');
    return fromEnv.isNotEmpty ? fromEnv : fileBaseUrl;
  }

  static bool get isConfigured => baseUrl.isNotEmpty;
}
