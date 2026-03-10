---
description: Generate correct TikTok OAuth 2.0 + PKCE implementation code for Web, Node.js, iOS, or Android when a user asks for auth setup or login flow help.
disable-model-invocation: false
---

# TikTok OAuth Helper

When a user asks how to implement TikTok login, OAuth, or user authorization, generate a complete, production-ready implementation for their platform.

Official docs: https://developers.tiktok.com/doc/oauth-user-access-token-management

---

## PKCE Flow (Required for Web Apps)

### Step 1 — Generate Code Verifier & Challenge
```javascript
// utils/pkce.js
export function generateCodeVerifier() {
  const array = new Uint8Array(32);
  crypto.getRandomValues(array);
  return btoa(String.fromCharCode(...array))
    .replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');
}

export async function generateCodeChallenge(verifier) {
  const encoder = new TextEncoder();
  const data = encoder.encode(verifier);
  const digest = await crypto.subtle.digest('SHA-256', data);
  return btoa(String.fromCharCode(...new Uint8Array(digest)))
    .replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');
}
```

### Step 2 — Build Authorization URL
```javascript
// auth/tiktok.js
const TIKTOK_AUTH_URL = 'https://www.tiktok.com/v2/auth/authorize/';

export async function getTikTokAuthUrl(scopes = ['user.info.basic']) {
  const codeVerifier = generateCodeVerifier();
  const codeChallenge = await generateCodeChallenge(codeVerifier);
  const state = crypto.randomUUID(); // CSRF protection

  // Store for callback verification
  sessionStorage.setItem('tiktok_code_verifier', codeVerifier);
  sessionStorage.setItem('tiktok_state', state);

  const params = new URLSearchParams({
    client_key: process.env.TIKTOK_CLIENT_KEY,
    scope: scopes.join(','),
    response_type: 'code',
    redirect_uri: process.env.TIKTOK_REDIRECT_URI,
    state,
    code_challenge: codeChallenge,
    code_challenge_method: 'S256',
  });

  return `${TIKTOK_AUTH_URL}?${params}`;
}
```

### Step 3 — Handle Callback & Exchange Code
```javascript
// Server-side only — never expose client_secret in browser code
// api/auth/callback.js (Next.js / Express example)

export async function handleTikTokCallback(code, state) {
  // Verify state to prevent CSRF
  const savedState = sessionStorage.getItem('tiktok_state');
  if (state !== savedState) throw new Error('State mismatch — possible CSRF attack');

  const codeVerifier = sessionStorage.getItem('tiktok_code_verifier');

  const res = await fetch('https://open.tiktokapis.com/v2/oauth/token/', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      client_key: process.env.TIKTOK_CLIENT_KEY,
      client_secret: process.env.TIKTOK_CLIENT_SECRET, // SERVER SIDE ONLY
      code,
      grant_type: 'authorization_code',
      redirect_uri: process.env.TIKTOK_REDIRECT_URI,
      code_verifier: codeVerifier,
    }),
  });

  const data = await res.json();
  if (data.error) throw new Error(`TikTok OAuth error: ${data.error_description}`);

  return {
    accessToken: data.access_token,        // Expires in 24 hours
    refreshToken: data.refresh_token,      // Expires in 365 days
    openId: data.open_id,                  // User identifier (app-scoped)
    expiresIn: data.expires_in,
    scope: data.scope,
  };
}
```

### Step 4 — Refresh Access Token
```javascript
export async function refreshTikTokToken(refreshToken) {
  const res = await fetch('https://open.tiktokapis.com/v2/oauth/token/', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      client_key: process.env.TIKTOK_CLIENT_KEY,
      client_secret: process.env.TIKTOK_CLIENT_SECRET,
      grant_type: 'refresh_token',
      refresh_token: refreshToken,
    }),
  });

  const data = await res.json();
  if (data.error) throw new Error(`Token refresh failed: ${data.error_description}`);

  return {
    accessToken: data.access_token,
    refreshToken: data.refresh_token, // New refresh token issued
    expiresIn: data.expires_in,
  };
}
```

---

## Client Access Token (No User Required)
For server-to-server calls that don't need user authorization:

```javascript
export async function getClientAccessToken() {
  const res = await fetch('https://open.tiktokapis.com/v2/oauth/token/', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      client_key: process.env.TIKTOK_CLIENT_KEY,
      client_secret: process.env.TIKTOK_CLIENT_SECRET,
      grant_type: 'client_credentials',
    }),
  });
  const data = await res.json();
  return data.access_token; // No refresh token — just re-request when expired
}
```

---

## Environment Variables Needed
```bash
# .env
TIKTOK_CLIENT_KEY=your_client_key        # Public — shown in TikTok dev portal
TIKTOK_CLIENT_SECRET=your_client_secret  # Private — NEVER expose in frontend
TIKTOK_REDIRECT_URI=https://yourapp.com/auth/callback
```

---

## Security Checklist
- ✅ Use PKCE for all web OAuth flows
- ✅ Validate `state` parameter in callback to prevent CSRF
- ✅ Keep `client_secret` server-side only
- ✅ Store tokens securely (httpOnly cookies, not localStorage)
- ✅ Handle token expiry: refresh before making API calls
- ✅ Revoke tokens on logout: `POST /v2/oauth/revoke/`
- ✅ Register exact `redirect_uri` in TikTok Developer Portal

## Common OAuth Errors
| Error | Meaning | Fix |
|-------|---------|-----|
| `invalid_client` | Wrong `client_key` or `client_secret` | Check app credentials |
| `invalid_grant` | Auth code already used or expired | Codes are single-use; re-authorize |
| `invalid_scope` | Scope not approved for your app | Enable scope in Developer Portal |
| `redirect_uri_mismatch` | URI doesn't match registration | Match exactly, including trailing slash |
