## Phase 2: Security & Supply Chain Audit

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
- Verify the ignore rule also covers `.env.*.local`, `.env.local`, and `.env.production` (a bare `.env` rule does NOT match these) — WARNING if these can leak
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

### 2.13 Git History Secret Scanning

A secret committed and later "removed" still lives in git history and is effectively public once pushed.

- Scan history for high-signal secret patterns: `git log -p --all -S 'sk-' -S 'AKIA' -S 'PRIVATE KEY' --source` (sample; adapt patterns from 2.1). For a faster pass, grep the patterns over `git rev-list --all` blobs or recommend a dedicated scanner.
- If `gitleaks` or `trufflehog` is available, run it (`gitleaks detect --no-banner`) and report findings.
- A current-tree-only scan (2.1) is NOT sufficient — note explicitly whether history was scanned.
- **Severity**: CRITICAL for any live secret found in history (it must be rotated, not just deleted); INFO if no history-scanning tool is available and only a pattern sample was run.

### 2.14 Lockfile Integrity & Dependency Pinning

- Confirm a lockfile exists and is committed (`package-lock.json` / `yarn.lock` / `pnpm-lock.yaml` / `bun.lock` / `poetry.lock` / `Cargo.lock` / `Gemfile.lock` / `go.sum`) — WARNING if missing (non-reproducible installs).
- Check CI installs use the frozen-lockfile path (`npm ci`, `pnpm install --frozen-lockfile`, `yarn install --immutable`, `bun install --frozen-lockfile`) rather than a plain `install` that can mutate the lockfile — WARNING if CI uses a mutating install.
- Flag dependencies pinned to floating ranges on security-sensitive packages where a pinned version would be safer — INFO.
- Check for risky install-time execution surface: `postinstall`/`preinstall` scripts in `package.json` and dependencies — INFO (supply-chain execution vector).
- **Severity**: WARNING for missing/uncommitted lockfile or non-frozen CI installs.

### 2.15 Build Provenance & SBOM

- Check whether the project produces a Software Bill of Materials (SBOM) — `syft`, `cyclonedx`, `npm sbom`, or a committed `*.cdx.json` / `*.spdx.json` — INFO if absent.
- Check CI/CD for artifact signing or provenance attestation (SLSA provenance, `cosign`, npm `--provenance`, GitHub artifact attestations) — INFO if absent.
- Check whether release/commit signing is used (signed tags/commits) — INFO.
- These are maturity signals, not blockers, but increasingly expected for software shipped to others.
- **Severity**: INFO — recommend SBOM generation and provenance for distributed software.

### 2.16 Dependency Freshness

Outdated dependencies accumulate unpatched CVEs and make future upgrades riskier.

- Run `npm outdated` (or `pip list --outdated`, `cargo outdated`, `bundle outdated`, `go list -u -m all`) and summarize.
- Flag dependencies that are **multiple major versions behind** or appear unmaintained (no release in 2+ years for actively-developed ecosystems) — INFO.
- Flag a framework major that is past end-of-life / out of security support (e.g., an EOL Next.js/Django/Rails major) — WARNING.
- Check for automated update tooling (`renovate.json`, `.github/dependabot.yml`) — INFO if absent.
- **Severity**: WARNING for EOL framework majors; INFO for outdated deps and missing update automation.

### 2.17 Webhook & Callback Signature Verification

- If the app receives inbound webhooks (Stripe, GitHub, Slack, Clerk, payment/IPN, third-party callbacks), check that the handler verifies the signature (e.g., `stripe.webhooks.constructEvent`, HMAC comparison, `svix` verification) before trusting the payload.
- Check that signature comparison is constant-time (`crypto.timingSafeEqual` / framework helper) rather than `===`.
- Check that the raw request body is used for verification (not a re-serialized/parsed body, which breaks HMAC).
- **Severity**: CRITICAL for an unverified webhook that triggers privileged actions (fulfilling orders, granting access); WARNING for non-constant-time comparison.
