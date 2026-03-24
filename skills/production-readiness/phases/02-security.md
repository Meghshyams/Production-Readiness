## Phase 2: Security Audit

### 2.1 Hardcoded Secrets

Search source code (excluding `node_modules/`, `.next/`, `dist/`, `build/`, `.git/`, lock files) for:

```
Patterns to grep for:
- sk-[a-zA-Z0-9]{20,}          (OpenAI / Stripe secret keys)
- sk_live_[a-zA-Z0-9]+          (Stripe live keys)
- sk_test_[a-zA-Z0-9]+          (Stripe test keys — WARNING level)
- AKIA[0-9A-Z]{16}              (AWS access keys)
- ghp_[a-zA-Z0-9]{36}           (GitHub personal access tokens)
- api[_-]?key\s*[:=]\s*['"][^'"]{10,}  (generic API keys)
- password\s*[:=]\s*['"][^'"]+['"]      (hardcoded passwords)
- secret\s*[:=]\s*['"][^'"]+['"]        (hardcoded secrets — exclude .env.example)
- -----BEGIN (RSA |EC |DSA )?PRIVATE KEY  (private keys in source)
- Bearer\s+[a-zA-Z0-9\-._~+/]+=*        (bearer tokens)
- sk-ant-[a-zA-Z0-9]{20,}              (Anthropic API keys)
- xoxb-[0-9]+-[a-zA-Z0-9]+             (Slack bot tokens)
- xoxp-[0-9]+-[a-zA-Z0-9]+             (Slack user tokens)
- glpat-[a-zA-Z0-9\-_]{20,}            (GitLab personal access tokens)
- vercel_[a-zA-Z0-9]{24,}              (Vercel tokens)
- sbp_[a-zA-Z0-9]{40,}                 (Supabase service role keys)
- SG\.[a-zA-Z0-9\-_]+\.[a-zA-Z0-9\-_]+  (SendGrid API keys)
- eyJ[a-zA-Z0-9]{30,}\.eyJ[a-zA-Z0-9]{30,}  (JWT tokens — WARNING level)
```

**Exclude from scanning**: `.env.example`, `*.test.*`, `*.spec.*`, `*.md`, documentation files, lock files.
**Severity**: CRITICAL for any real secret found in committed source code.

### 2.2 Environment Safety

- Check if `.env` is in `.gitignore` — CRITICAL if missing
- Check if `.env.example` or `.env.sample` exists — WARNING if missing
- If `.env.example` exists, read it and flag any lines that look like real values (not placeholders)
- Check if any `.env.local` or `.env.production` files are tracked in git: `git ls-files '*.env*'`

### 2.3 Dependency Vulnerabilities

Run the appropriate audit command:
- npm: `npm audit --json` (parse JSON for severity counts)
- yarn: `yarn audit --json`
- pnpm: `pnpm audit --json`
- bun: `bun audit` (if available)
- pip: `pip audit` or `safety check` (Python)
- Go: `govulncheck ./...` or `nancy` (Go modules)
- Rust: `cargo audit` (Rust)
- Ruby: `bundle audit check --update` (Ruby)
- Java: check for OWASP dependency-check or Snyk integration

Report: count of critical/high/moderate/low vulnerabilities.
**Severity**: CRITICAL if any critical vulnerabilities, WARNING if high.

### 2.4 Input Validation

- Search API route files for request body parsing
- Check if validation library is used (zod, joi, yup, class-validator, marshmallow, etc.)
- Look for routes that use `req.body` or `request.json()` without validation
- **Severity**: WARNING if API routes exist without input validation

### 2.5 Authentication Security

- Check for password hashing: grep for `bcrypt`, `argon2`, `scrypt`, `pbkdf2`
- Check session config: look for `httpOnly`, `secure`, `sameSite` in cookie/session settings
- Check for CSRF protection: look for csrf tokens, `sameSite` cookies, or CSRF middleware
- Check NextAuth/Auth.js config for secure settings
- Django: check for `django.contrib.auth`, `CSRF_COOKIE_SECURE`, `SESSION_COOKIE_SECURE`, `SESSION_COOKIE_HTTPONLY` in settings.py
- Flask: check for Flask-Login, Flask-WTF CSRF, `SESSION_COOKIE_SECURE`
- Rails: check for `has_secure_password`, `protect_from_forgery`, `config.force_ssl`
- Go: check for `golang.org/x/crypto/bcrypt`, CSRF middleware (gorilla/csrf)
- **Severity**: CRITICAL if passwords stored in plain text, WARNING for missing CSRF

### 2.6 Rate Limiting

- Search for rate limit middleware or implementation
- Check API routes for rate limiting (express-rate-limit, upstash ratelimit, custom implementation)
- **Severity**: WARNING if no rate limiting found on auth or payment routes

### 2.7 Security Headers

Search middleware, server config, or framework config for:
- `Content-Security-Policy` or `CSP`
- `X-Frame-Options`
- `X-Content-Type-Options`
- `Strict-Transport-Security` (HSTS)
- `Referrer-Policy`
- `Permissions-Policy`

Also check `next.config.js`/`next.config.mjs` headers config, Express helmet, etc.
**Severity**: WARNING for missing security headers

### 2.8 Error Exposure

- Search API route error handlers for patterns that might expose internals:
  - Stack traces in responses (`err.stack`, `error.stack`)
  - Full error messages passed to client (`error.message` in JSON response)
  - Database error details in responses
- **Severity**: WARNING if stack traces could leak to clients

### 2.9 SQL Injection / Query Safety

- If using ORM (Prisma, Drizzle, etc.): INFO — ORMs generally prevent SQL injection
- If using raw SQL: check for string concatenation in queries vs parameterized queries
- Look for `$queryRaw`, `$executeRaw` (Prisma) or equivalent without parameterization
- **Severity**: CRITICAL if raw string concatenation in SQL queries

### 2.10 XSS Protection

- Search for `dangerouslySetInnerHTML` — check if input is sanitized (DOMPurify, sanitize-html)
- Search for `v-html` (Vue) without sanitization
- Check if framework provides default escaping (React JSX does)
- **Severity**: CRITICAL if unsanitized user input in `dangerouslySetInnerHTML`

### 2.11 CORS Configuration

- Search middleware, server config, or framework config for CORS settings
- Check for `Access-Control-Allow-Origin: *` — WARNING if used in production (allows any origin)
- Check for wildcard origins with credentials (`Access-Control-Allow-Credentials: true` with `*` origin) — CRITICAL
- Look for CORS middleware: `cors()`, `django-cors-headers`, `rack-cors`, etc.
- Check if allowed origins are restricted to known domains
- **Severity**: WARNING if CORS is too permissive, CRITICAL if credentials with wildcard

### 2.12 Dependency License Audit

- Run `npx license-checker --summary` or equivalent
- Flag GPL/AGPL licenses in dependencies for commercial projects — WARNING
- Check for `license` field in package.json — INFO if missing
- Note: this is an INFO-level check, not blocking
- **Severity**: WARNING for copyleft licenses in commercial code, INFO for missing license info
