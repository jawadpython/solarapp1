/**
 * Standalone auth email API — same job as Firebase Cloud Functions + Resend,
 * but runs on Render/Railway/etc. Works when Firebase Blaze billing is off.
 *
 * Endpoints:
 *   POST /v1/send-verification   Authorization: Bearer <Firebase ID token>
 *   POST /v1/send-password-reset Body: { "email": "user@example.com" }
 *   GET  /health
 */

import cors from "cors";
import express from "express";
import { getApps, initializeApp, cert } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { Resend } from "resend";

const EMAIL_VERIFIED_CONTINUE_URL =
  "https://solar-app-f698e.firebaseapp.com/email-verified.html";
const PASSWORD_RESET_CONTINUE_URL =
  "https://solar-app-f698e.firebaseapp.com/password-reset-complete.html";

function requireEnv(name) {
  const value = process.env[name];
  if (!value) {
    throw new Error(`Missing required environment variable: ${name}`);
  }
  return value;
}

function initFirebase() {
  if (getApps().length) return;

  const raw = requireEnv("FIREBASE_SERVICE_ACCOUNT_JSON");
  const serviceAccount = JSON.parse(raw);
  initializeApp({ credential: cert(serviceAccount) });
}

function getResend() {
  const apiKey = requireEnv("RESEND_API_KEY");
  const fromEmail = requireEnv("RESEND_FROM_EMAIL");
  const fromName = process.env.RESEND_FROM_NAME || "Tawfir Energy";
  const fromDisplay = fromName ? `${fromName} <${fromEmail}>` : fromEmail;
  return {
    client: new Resend(apiKey),
    fromEmail: fromDisplay,
    fromEmailRaw: fromEmail,
  };
}

function verificationHtml(link) {
  return `<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head>
<body style="font-family:system-ui,sans-serif;max-width:560px;margin:0 auto;padding:24px;color:#333;">
  <h2 style="color:#1a1a1a;">Verify your email</h2>
  <p>Thanks for signing up for Tawfir Energy. Please confirm your email address by clicking the button below.</p>
  <p style="margin:28px 0;">
    <a href="${link}" style="display:inline-block;background:#0d6efd;color:#fff;text-decoration:none;padding:12px 24px;border-radius:8px;font-weight:600;">Verify email</a>
  </p>
  <p style="font-size:14px;color:#666;">If you didn't create an account, you can ignore this email.</p>
  <p style="font-size:14px;color:#666;">— Tawfir Energy</p>
</body>
</html>`;
}

function resetHtml(link) {
  return `<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head>
<body style="font-family:system-ui,sans-serif;max-width:560px;margin:0 auto;padding:24px;color:#333;">
  <h2 style="color:#1a1a1a;">Reset your password</h2>
  <p>You requested a password reset for your Tawfir Energy account. Click the button below to set a new password.</p>
  <p style="margin:28px 0;">
    <a href="${link}" style="display:inline-block;background:#0d6efd;color:#fff;text-decoration:none;padding:12px 24px;border-radius:8px;font-weight:600;">Reset password</a>
  </p>
  <p style="font-size:14px;color:#666;">If you didn't request this, you can ignore this email. Your password will not change.</p>
  <p style="font-size:14px;color:#666;">— Tawfir Energy</p>
</body>
</html>`;
}

initFirebase();
const auth = getAuth();
const app = express();

app.use(cors());
app.use(express.json({ limit: "32kb" }));

app.get("/health", (_req, res) => {
  res.json({ ok: true, service: "auth-email-api" });
});

app.post("/v1/send-verification", async (req, res) => {
  try {
    const header = req.headers.authorization || "";
    const token = header.startsWith("Bearer ") ? header.slice(7) : "";
    if (!token) {
      return res.status(401).json({ error: "Missing Authorization Bearer token." });
    }

    const decoded = await auth.verifyIdToken(token);
    const email = decoded.email;
    if (!email) {
      return res.status(400).json({ error: "No email on account." });
    }

    const link = await auth.generateEmailVerificationLink(email, {
      url: EMAIL_VERIFIED_CONTINUE_URL,
      handleCodeInApp: false,
    });

    const subject = "Verify your email – Tawfir Energy";
    const text = `Verify your email – Tawfir Energy\n\nThanks for signing up. Open this link to confirm your email:\n\n${link}\n\n— Tawfir Energy`;

    const { client, fromEmail, fromEmailRaw } = getResend();
    const { data, error } = await client.emails.send({
      from: fromEmail,
      to: [email],
      reply_to: fromEmailRaw,
      subject,
      html: verificationHtml(link),
      text,
      headers: { "X-Entity-Ref-ID": `verify-${Date.now()}-${email}` },
    });

    if (error) {
      console.error("Resend verification failed", error);
      return res.status(500).json({ error: "Failed to send verification email." });
    }

    return res.json({ ok: true, id: data?.id });
  } catch (e) {
    console.error("send-verification error", e);
    return res.status(500).json({ error: "Internal error." });
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
      link = await auth.generatePasswordResetLink(email, {
        url: PASSWORD_RESET_CONTINUE_URL,
        handleCodeInApp: false,
      });
    } catch (e) {
      if (e.code === "auth/user-not-found") {
        return res.json({ ok: true });
      }
      console.error("generatePasswordResetLink failed", e);
      return res.status(500).json({ error: "Could not generate reset link." });
    }

    const subject = "Reset your password – Tawfir Energy";
    const text = `Reset your password – Tawfir Energy\n\nOpen this link to set a new password:\n\n${link}\n\n— Tawfir Energy`;

    const { client, fromEmail, fromEmailRaw } = getResend();
    const { data, error } = await client.emails.send({
      from: fromEmail,
      to: [email],
      reply_to: fromEmailRaw,
      subject,
      html: resetHtml(link),
      text,
      headers: { "X-Entity-Ref-ID": `reset-${Date.now()}-${email}` },
    });

    if (error) {
      console.error("Resend reset failed", error);
      return res.status(500).json({ error: "Failed to send reset email." });
    }

    return res.json({ ok: true, id: data?.id });
  } catch (e) {
    console.error("send-password-reset error", e);
    return res.status(500).json({ error: "Internal error." });
  }
});

const port = Number(process.env.PORT || 8080);
app.listen(port, () => {
  console.log(`auth-email-api listening on port ${port}`);
});
