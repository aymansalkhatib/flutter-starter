---
name: security
description: Non-negotiable security rules for flutter_genesis — encrypted Hive box for tokens/PII, required Dio timeouts, certificate pinning stance, logging prohibitions (no tokens / no PII / no full response bodies), user input sanitization, deep-link argument validation, and FCM / GoogleAuth service lifecycles. Use whenever handling tokens, credentials, PII, external inputs, user-generated content, or push notification / social sign-in logic. Security rules override architecture and style rules on conflict.
---

# Security

**Security rules override every other rule on conflict.**

## 1. Storage encryption

- `HiveStorageService` is **not** encrypted by default.
- **Sensitive data** (auth tokens, refresh tokens, user PII, session state) → dedicated encrypted box (`HiveBoxes.secureBox`) using `HiveAesCipher`.
- The AES key is generated once and stored in `flutter_secure_storage`; retrieved at boot **before** opening the secure box.
- `appBox` is permitted **only** for non-sensitive preferences (theme, locale, onboarding flags).
- Any `@HiveField` holding credentials/PII must carry: `// stored in encrypted box — HiveBoxes.secureBox`.
- **Never** store raw tokens in `SharedPreferences` or an unencrypted Hive box.

## 2. Network security

- **Timeouts are required** — see `data-layer` skill §4. Infinite hangs = unrecoverable UI.
- **Certificate pinning:** declare the project stance in `EnvironmentConfig.certificatePinning` (required / explicitly opted out with reason). If required, implement via `HttpClient.badCertificateCallback` with pinned fingerprints — **never** return `true` to bypass verification.
- **Never** construct a second `Dio` instance; everything routes through `ApiClient`.

## 3. Logging prohibitions

`AppLogger` must **never** receive:

- Auth tokens (access, refresh, API keys).
- Passwords, PINs, biometric data.
- Full API response bodies — log status code + endpoint only.
- Device identifiers (IMEI, advertising ID, FCM token).
- PII (name, email, phone) unless masked.

On unknown errors, **sanitize before logging** — `e.toString()` on unfamiliar exceptions may contain secrets. Prefer `runtimeType` + operation name; pass the raw error as `error:` where the sink can redact.

## 4. User input sanitization

Validation checks format; sanitization removes dangerous content. Both apply to free-text fields sent to the backend.

- Any user-submitted string rendered to other users (bio, comments, display name) must pass `StringUtils.sanitizeForApi(value)` before the API call.
- Not required for fields already constrained to safe formats (email, phone, date, numeric) — `Validator` rejects unsafe input.

## 5. Deep-link / external argument validation

Arguments from **external sources** (deep links, push payloads, inter-app intents) are untrusted. The receiving page must validate before dispatching:

```dart
final args = ModalRoute.of(context)?.settings.arguments as OtpArgs?;
if (args == null || !Validator.validatePhone(context, args.phoneNumber)) {
  NavigationService.pop();
  return;
}
```

Internal `NavigationService.push(...)` calls are trusted by construction.

## 6. Service lifecycles

**FcmService:**
- Register FCM token with backend **only after** successful authentication.
- Deregister on every logout path — including `UnauthorizedInterceptor` forced logout.
- `onTokenRefresh` updates backend atomically; never creates duplicate registrations.
- FCM tokens are device identifiers: never log them, never cache unencrypted.

**GoogleAuthService:**
- ID tokens are one-time and expire in ~1 hour. Send to the backend immediately; never cache.
- **Never** decode the ID token client-side to extract user data — trust only the backend's verified response.
- On acquisition failure, return `Left(ServerFailure(...))` from the repository — no silent retries.
