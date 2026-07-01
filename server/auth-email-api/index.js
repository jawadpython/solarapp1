/**
 * Standalone auth email API — sends auth emails via Resend (no Blaze plan).
 */

import cors from "cors";
import express from "express";
import { getApps, initializeApp, cert } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { Resend } from "resend";

const EMAIL_VERIFIED_CONTINUE_URL =
  process.env.EMAIL_VERIFIED_CONTINUE_URL ||
  "https://solar-app-f698e.firebaseapp.com/email-verified.html";
const PASSWORD_RESET_CONTINUE_URL =
  process.env.PASSWORD_RESET_CONTINUE_URL ||
  "https://solar-app-f698e.firebaseapp.com/password-reset-complete.html";

/** Only set FIREBASE_AUTH_LINK_DOMAIN if that domain is connected in Firebase Auth */
const AUTH_LINK_DOMAIN = process.env.FIREBASE_AUTH_LINK_DOMAIN?.trim() || undefined;

function requireEnv(name) {
  const value = process.env[name];
  if (!value) {
    throw new Error(`Missing required environment variable: ${name}`);
  }
  return value;
}

function parseServiceAccountJson(raw) {
  const trimmed = raw.trim();
  try {
    return JSON.parse(trimmed);
  } catch {
    // Render env sometimes stores JSON with broken newlines in private_key
    const fixed = trimmed
      .replace(/\r\n/g, "\\n")
      .replace(/\n/g, "\\n")
      .replace(/\\n/g, "\n")
      .replace(/"private_key": "-----BEGIN PRIVATE KEY-----\\n/, '"private_key": "-----BEGIN PRIVATE KEY-----\n')
      .replace(/\\n-----END PRIVATE KEY-----\\n"/, '\n-----END PRIVATE KEY-----\n"');
    return JSON.parse(fixed);
  }
}

function initFirebase() {
  if (getApps().length) return;
  const raw = requireEnv("FIREBASE_SERVICE_ACCOUNT_JSON");
  initializeApp({ credential: cert(parseServiceAccountJson(raw)) });
}

function getResend() {
  const apiKey = requireEnv("RESEND_API_KEY");
  const fromEmail = requireEnv("RESEND_FROM_EMAIL");
  const fromName = process.env.RESEND_FROM_NAME || "Tawfir Energy";
  const replyTo = process.env.RESEND_REPLY_TO || fromEmail;
  const fromDisplay = fromName ? `${fromName} <${fromEmail}>` : fromEmail;
  return {
    client: new Resend(apiKey),
    fromEmail: fromDisplay,
    replyTo,
  };
}

function actionCodeSettings(continueUrl) {
  const settings = {
    url: continueUrl,
    handleCodeInApp: false,
  };
  if (AUTH_LINK_DOMAIN) {
    settings.linkDomain = AUTH_LINK_DOMAIN;
  }
  return settings;
}

function mapFirebaseError(e) {
  const code = e?.code || e?.errorInfo?.code || "";
  const message = e?.message || "Unknown error";

  if (
    code === "auth/too-many-requests" ||
    message.includes("TOO_MANY_ATTEMPTS_TRY_LATER")
  ) {
    return {
      status: 429,
      error: "Too many verification emails sent. Please wait 15–30 minutes and try again.",
      code,
    };
  }

  if (code === "auth/invalid-continue-uri" || code === "auth/unauthorized-continue-uri") {
    return {
      status: 500,
      error: "Email link configuration error. Contact support.",
      code,
      detail: message,
    };
  }

  if (code === "auth/invalid-dynamic-link-domain" || message.includes("linkDomain")) {
    return {
      status: 500,
      error: "Invalid FIREBASE_AUTH_LINK_DOMAIN on server. Remove it from Render env vars.",
      code,
      detail: message,
    };
  }

  return { status: 500, error: "Internal error.", code, detail: message };
}

function transactionalHtml({ title, intro, buttonLabel, link, footerNote }) {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>${title}</title>
</head>
<body style="margin:0;padding:0;background:#f4f6f8;font-family:Arial,Helvetica,sans-serif;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#f4f6f8;padding:24px 12px;">
    <tr>
      <td align="center">
        <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:560px;background:#ffffff;border-radius:12px;padding:32px 28px;">
          <tr>
            <td style="color:#1e293b;font-size:22px;font-weight:700;padding-bottom:12px;">Tawfir Energy</td>
          </tr>
          <tr>
            <td style="color:#1e293b;font-size:20px;font-weight:600;padding-bottom:12px;">${title}</td>
          </tr>
          <tr>
            <td style="color:#475569;font-size:15px;line-height:1.6;padding-bottom:24px;">${intro}</td>
          </tr>
          <tr>
            <td style="padding-bottom:24px;">
              <a href="${link}" style="display:inline-block;background:#3A80BA;color:#ffffff;text-decoration:none;padding:14px 28px;border-radius:8px;font-size:15px;font-weight:600;">${buttonLabel}</a>
            </td>
          </tr>
          <tr>
            <td style="color:#64748b;font-size:13px;line-height:1.6;padding-bottom:8px;">
              If the button does not work, copy and paste this link into your browser:
            </td>
          </tr>
          <tr>
            <td style="color:#3A80BA;font-size:12px;line-height:1.5;word-break:break-all;padding-bottom:24px;">${link}</td>
          </tr>
          <tr>
            <td style="color:#94a3b8;font-size:12px;line-height:1.5;border-top:1px solid #e2e8f0;padding-top:16px;">
              ${footerNote}<br>
              Tawfir Energy
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>`;
}

async function sendTransactionalEmail({ to, subject, html, text }) {
  const { client, fromEmail, replyTo } = getResend();
  return client.emails.send({
    from: fromEmail,
    to: [to],
    replyTo,
    subject,
    html,
    text,
  });
}

initFirebase();
const auth = getAuth();
const app = express();

app.use(cors());
app.use(express.json({ limit: "32kb" }));

app.get("/health", (_req, res) => {
  res.json({
    ok: true,
    service: "auth-email-api",
    version: 2,
    resendConfigured: Boolean(process.env.RESEND_API_KEY && process.env.RESEND_FROM_EMAIL),
    linkDomain: AUTH_LINK_DOMAIN || null,
  });
});

app.post("/v1/send-verification", async (req, res) => {
  try {
    const header = req.headers.authorization || "";
    const token = header.startsWith("Bearer ") ? header.slice(7) : "";
    if (!token) {
      return res.status(401).json({ error: "Missing Authorization Bearer token." });
    }

    let decoded;
    try {
      decoded = await auth.verifyIdToken(token);
    } catch (e) {
      console.error("verifyIdToken failed", e);
      return res.status(401).json({
        error: "Session expired. Sign out and sign in again, then resend.",
        detail: e?.message,
      });
    }

    const email = decoded.email;
    if (!email) {
      return res.status(400).json({ error: "No email on account." });
    }

    let link;
    try {
      link = await auth.generateEmailVerificationLink(
        email,
        actionCodeSettings(EMAIL_VERIFIED_CONTINUE_URL),
      );
    } catch (e) {
      console.error("generateEmailVerificationLink failed", e);
      const mapped = mapFirebaseError(e);
      return res.status(mapped.status).json(mapped);
    }

    const subject = "Confirm your Tawfir Energy account";
    const text =
      `Confirm your Tawfir Energy account\n\n` +
      `Open this link to verify your email:\n\n${link}\n\n` +
      `If you did not create an account, ignore this email.\n\n` +
      `Tawfir Energy`;

    const html = transactionalHtml({
      title: "Confirm your email",
      intro:
        "Thanks for signing up for Tawfir Energy. Please confirm your email address to activate your account.",
      buttonLabel: "Confirm email",
      link,
      footerNote: "If you did not create an account, you can safely ignore this email.",
    });

    const { data, error } = await sendTransactionalEmail({ to: email, subject, html, text });

    if (error) {
      console.error("Resend verification failed", error);
      return res.status(500).json({
        error: "Failed to send verification email.",
        detail: error.message,
      });
    }

    console.log(`Verification email sent to ${email} id=${data?.id}`);
    return res.json({ ok: true, id: data?.id, provider: "resend" });
  } catch (e) {
    console.error("send-verification error", e);
    const mapped = mapFirebaseError(e);
    return res.status(mapped.status).json(mapped);
  }
});

app.post("/v1/send-password-reset", async (req, res) => {
  try {
    const email = typeof req.body?.email === "string" ? req.body.email.trim() : "";
    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      return res.status(400).json({ error: "Valid email is required." });
    }

    let link;
    try {
      link = await auth.generatePasswordResetLink(
        email,
        actionCodeSettings(PASSWORD_RESET_CONTINUE_URL),
      );
    } catch (e) {
      if (e.code === "auth/user-not-found") {
        return res.json({ ok: true });
      }
      console.error("generatePasswordResetLink failed", e);
      const mapped = mapFirebaseError(e);
      return res.status(mapped.status).json(mapped);
    }

    const subject = "Reset your Tawfir Energy password";
    const text =
      `Reset your Tawfir Energy password\n\n` +
      `Open this link to choose a new password:\n\n${link}\n\n` +
      `Tawfir Energy`;

    const html = transactionalHtml({
      title: "Reset your password",
      intro: "We received a request to reset your Tawfir Energy account password.",
      buttonLabel: "Reset password",
      link,
      footerNote:
        "If you did not request a password reset, ignore this email. Your password will not change.",
    });

    const { data, error } = await sendTransactionalEmail({ to: email, subject, html, text });

    if (error) {
      console.error("Resend reset failed", error);
      return res.status(500).json({
        error: "Failed to send reset email.",
        detail: error.message,
      });
    }

    console.log(`Password reset email sent to ${email} id=${data?.id}`);
    return res.json({ ok: true, id: data?.id, provider: "resend" });
  } catch (e) {
    console.error("send-password-reset error", e);
    const mapped = mapFirebaseError(e);
    return res.status(mapped.status).json(mapped);
  }
});

const port = Number(process.env.PORT || 8080);
app.listen(port, () => {
  console.log(`auth-email-api v2 listening on port ${port}`);
});
