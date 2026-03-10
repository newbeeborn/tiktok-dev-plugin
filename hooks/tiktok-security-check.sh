#!/usr/bin/env bash
# TikTok API Security Pre-Commit Check
# Blocks commits that expose TikTok credentials or use insecure patterns

set -e

ERRORS=0
WARNINGS=0

echo "🔍 TikTok Dev Plugin: Running security checks..."

# --- Check 1: Hardcoded client secret ---
if git diff --cached --diff-filter=ACMR -U0 | grep -E "client_secret\s*[:=]\s*['\"][a-zA-Z0-9_\-]{10,}" > /dev/null 2>&1; then
  echo "❌ [CRITICAL] Possible hardcoded TikTok client_secret detected in staged files."
  echo "   The client_secret must NEVER be committed. Use environment variables instead:"
  echo "   TIKTOK_CLIENT_SECRET=your_secret in .env (and add .env to .gitignore)"
  ERRORS=$((ERRORS + 1))
fi

# --- Check 2: Access token in code ---
if git diff --cached --diff-filter=ACMR -U0 | grep -E "(access_token|Bearer)\s*[:=]\s*['\"]act\.[a-zA-Z0-9_\-]{20,}" > /dev/null 2>&1; then
  echo "❌ [CRITICAL] Possible hardcoded TikTok access_token detected."
  echo "   Access tokens must not be committed to source control."
  ERRORS=$((ERRORS + 1))
fi

# --- Check 3: Using deprecated v1 API endpoints ---
if git diff --cached --diff-filter=ACMR -U0 | grep -E "open\.tiktokapis\.com/v1/" > /dev/null 2>&1; then
  echo "⚠️  [WARNING] Detected use of deprecated TikTok API v1 endpoint."
  echo "   Migrate to v2: https://developers.tiktok.com/doc/tiktok-api-v2-introduction"
  WARNINGS=$((WARNINGS + 1))
fi

# --- Check 4: Missing HTTPS for TikTok API calls ---
if git diff --cached --diff-filter=ACMR -U0 | grep -E "http://open\.tiktokapis\.com" > /dev/null 2>&1; then
  echo "❌ [CRITICAL] TikTok API calls must use HTTPS, not HTTP."
  ERRORS=$((ERRORS + 1))
fi

# --- Check 5: client_secret in frontend files ---
FRONTEND_FILES=$(git diff --cached --name-only --diff-filter=ACMR | grep -E "\.(jsx?|tsx?|vue|html)$" || true)
if [ -n "$FRONTEND_FILES" ]; then
  for file in $FRONTEND_FILES; do
    if git show ":$file" 2>/dev/null | grep -E "client_secret" > /dev/null 2>&1; then
      echo "❌ [CRITICAL] client_secret found in frontend file: $file"
      echo "   The client_secret must only exist in server-side code."
      ERRORS=$((ERRORS + 1))
    fi
  done
fi

# --- Summary ---
echo ""
if [ $ERRORS -gt 0 ]; then
  echo "🚫 Commit blocked: $ERRORS critical TikTok security issue(s) found."
  echo "   Fix the issues above before committing."
  echo "   Docs: https://developers.tiktok.com/doc/oauth-user-access-token-management"
  exit 1
elif [ $WARNINGS -gt 0 ]; then
  echo "✅ Commit allowed with $WARNINGS warning(s). Review the warnings above."
  exit 0
else
  echo "✅ TikTok security checks passed."
  exit 0
fi
