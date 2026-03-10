# TikTok Dev Plugin for Claude Code

A Claude Code plugin that turns Claude into a TikTok developer expert — with code review, API guidance, OAuth helpers, and security pre-commit checks, all grounded in the [official TikTok for Developers documentation](https://developers.tiktok.com/doc/overview).

---

## Installation

### From Anthropic's Official Directory *(after submission approval)*
```bash
/plugin install tiktok-dev@claude-plugin-directory
```

### Via this repo's marketplace
```bash
/plugin install tiktok-dev@tiktok-dev-marketplace 
```

### Local development
```bash
claude --plugin-dir ./tiktok-dev-plugin
```

---

## What's Included

### Skills (3)

#### `/tiktok-dev:review-tiktok-code`
Paste any TikTok API integration code and get a structured review covering:
- OAuth & PKCE correctness
- Required scopes and App Review requirements
- Correct Content Posting API upload flow
- TikTok-specific error handling (`error.code`, not HTTP status)
- Rate limit compliance
- Webhook signature verification
- Security issues (exposed secrets, token handling)

**Trigger**: Run the command, or paste TikTok code — Claude will detect it automatically.

#### `/tiktok-dev:tiktok-api-guide`
Ask any question about TikTok APIs and get answers backed by official docs:
- Endpoint URLs, request formats, required fields
- Scopes reference table (which require App Review)
- Integration patterns with working code examples
- Login Kit, Content Posting API, Display API, Research API, Share Kit, Webhooks, Minis

**Trigger**: Ask questions like *"How do I post a video to TikTok?"* or *"What scopes do I need for the Display API?"*

#### `/tiktok-dev:tiktok-oauth-helper`
Get a complete, production-ready OAuth 2.0 + PKCE implementation for your platform:
- Web (vanilla JS / Next.js / Express)
- PKCE code verifier + challenge generation
- Token exchange, refresh, and revocation
- Client credentials flow (no user required)
- Environment variable setup
- Security checklist

**Trigger**: Ask *"How do I implement TikTok login?"* or *"Generate TikTok OAuth code for Node.js"*

---

### Hook: Pre-Commit Security Check

Automatically runs before every `git commit` in projects where this plugin is active.

**Blocks commits that contain:**
- Hardcoded `client_secret`
- Hardcoded access tokens
- `client_secret` in frontend files (`.js`, `.jsx`, `.ts`, `.tsx`, `.vue`, `.html`)
- HTTP (non-HTTPS) TikTok API URLs

**Warns about:**
- Deprecated v1 API endpoints (should migrate to v2)

---

## Quick Reference

| What | Where |
|------|-------|
| TikTok Dev Portal | https://developers.tiktok.com |
| API Overview | https://developers.tiktok.com/doc/overview |
| OAuth Docs | https://developers.tiktok.com/doc/oauth-user-access-token-management |
| Content Posting API | https://developers.tiktok.com/doc/content-posting-api-get-started |
| Display API | https://developers.tiktok.com/doc/display-api-overview |
| Scopes Reference | https://developers.tiktok.com/doc/tiktok-api-scopes |
| Rate Limits | https://developers.tiktok.com/doc/tiktok-api-v2-rate-limit |
| Error Handling | https://developers.tiktok.com/doc/tiktok-api-v2-error-handling |
| Webhooks | https://developers.tiktok.com/doc/webhooks-overview |
| TikTok Minis | https://developers.tiktok.com/doc/minis-overview |

---

## Plugin Structure

```
tiktok-dev-plugin/
├── .claude-plugin/
│   └── plugin.json                        # Plugin manifest
├── skills/
│   ├── review-tiktok-code/
│   │   └── SKILL.md                       # Code review skill
│   ├── tiktok-api-guide/
│   │   └── SKILL.md                       # API knowledge base
│   └── tiktok-oauth-helper/
│       └── SKILL.md                       # OAuth code generator
├── hooks/
│   ├── pre-commit-tiktok-check.json       # Hook configuration
│   └── tiktok-security-check.sh          # Security check script
└── README.md
```
