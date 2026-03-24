# Production Readiness — Claude Code Plugin

> Like having a senior engineer + QA tester do a final review before you deploy.

A comprehensive production readiness audit for [Claude Code](https://claude.com/claude-code). Run `/production-readiness` on any project to get a structured report covering security, visual QA, code quality, testing, error handling, build configuration, performance, and accessibility — with actionable fixes for every issue found.

## Why This Exists

Deploying to production is stressful. You check one thing, forget another. Did you leave `console.log` in? Are there hardcoded API keys? Does the mobile layout break? Is the build even passing?

This plugin runs **60+ automated checks** across 8 categories and produces a single, prioritized report. It adapts to whatever tech stack you're using — no configuration needed.

## The 8 Pillars

| # | Pillar | What's Checked |
|---|--------|---------------|
| 1 | **Security** | Hardcoded secrets, `.env` safety, dependency vulnerabilities, input validation, auth config, rate limiting, security headers, error exposure, SQL injection, XSS, CORS configuration, dependency licenses |
| 2 | **Visual QA** | Screenshots every page at desktop + mobile viewports, then inspects each for layout issues, spelling mistakes, responsive problems, broken UI, and visual inconsistencies |
| 3 | **Code Quality** | `console.log` / `debugger` statements, TODO/FIXME comments, lint errors, type errors, unused dependencies |
| 4 | **Testing** | Runs your test suites, reports pass/fail and coverage, flags untested critical paths (auth, payments, mutations) |
| 5 | **Error Handling** | Error boundaries, error tracking (Sentry etc.), health check endpoints, structured logging, sensitive data in logs |
| 6 | **Config & Build** | Build passes, env vars documented, source maps hidden, no dev-only leaks, HTTPS redirects, Docker security, container orchestration, platform deployment configs |
| 7 | **Performance** | Image optimization, bundle size, caching headers, N+1 query patterns, lazy loading, Core Web Vitals, font optimization, third-party scripts, API response size |
| 8 | **Accessibility** | Semantic HTML, ARIA labels, keyboard navigation, color contrast, screen reader support, automated a11y testing |

## Install

```bash
claude plugin add Meghshyams/production-readiness
```

Or clone and use locally:

```bash
git clone https://github.com/Meghshyams/production-readiness.git
claude --plugin-dir ./production-readiness
```

## Usage

```bash
# Full audit — all 8 pillars
/production-readiness

# Run specific pillars only
/production-readiness --only=security,testing

# Skip specific pillars
/production-readiness --skip=visual,performance

# Override dev server port
/production-readiness --port=3000
```

**Pillar names for `--only` / `--skip`:** `security`, `visual`, `quality`, `testing`, `build`, `errors`, `performance`, `accessibility`

## How It Works

```
Phase 1: DETECT
├── Identifies your framework, package manager, test runner, lint tool, ORM
├── Finds your page/route list
├── Checks for cached results from previous runs
└── Shows summary table + cache status before proceeding

Phase 2-8: AUDIT
├── Skips phases with valid cached results (no relevant files changed)
├── Reruns phases where source files changed since last audit
├── Runs phases in parallel where possible for faster execution
├── Takes screenshots if Playwright is available (Visual QA)
├── Checks accessibility (semantic HTML, ARIA, keyboard nav, contrast)
└── Collects all findings with severity levels

Phase 9: REPORT
├── Merges fresh and cached results into a unified report
├── Labels each phase as Fresh or Cached with date
├── Verdict: READY / NEEDS FIXES / BLOCKED
└── Prioritized next steps

Phase 10: SAVE
└── Caches all results for future incremental reruns
```

## Smart Caching (Incremental Reruns)

When you fix issues and rerun the audit, the plugin automatically **skips phases where nothing changed** — saving time without compromising quality.

### Git-Based Change Detection

After each run, results are cached in `.production-readiness/cache.json`. On the next run, the plugin uses `git diff` to detect which files changed and only reruns the phases affected by those changes. Dependency vulnerability checks (`npm audit`) always run fresh regardless of cache, since new CVEs are external.

### Flags

```bash
# Rerun only phases affected by your changes (default behavior)
/production-readiness

# Force a complete fresh audit (ignore cache)
/production-readiness --fresh

# View the last audit report without running anything
/production-readiness --cached
```

### Cache Status Table

On a cached rerun, Phase 1 shows which phases will rerun and which are cached:

```
| Phase          | Status     | Reason                         |
|----------------|------------|--------------------------------|
| Security       | RERUNNING  | 3 source files changed         |
| Code Quality   | CACHED     | No relevant files changed      |
| Testing        | RERUNNING  | Test files changed             |
| Error Handling | CACHED     | No relevant files changed      |
| Config & Build | CACHED     | No relevant files changed      |
| Visual QA      | RERUNNING  | UI components changed          |
| Performance    | CACHED     | No relevant files changed      |
| Accessibility  | RERUNNING  | UI components changed          |
```

### What's Always Fresh

- **Dependency vulnerability checks** (`npm audit`) — new CVEs can appear at any time
- **Detection phase** — always runs to ensure context is current
- **Any phase where `package.json` or lock files changed** — dependency changes affect everything

### Cache Location

Results are stored in `.production-readiness/` in your project root. Add this to `.gitignore` — these are local audit artifacts, not meant to be committed.

### Combining with Other Flags

`--fresh` works with `--skip`, `--only`, and `--port`. For example, `--fresh --only=security` runs a fresh security-only audit.

## Adapts to Any Stack

The plugin detects your tools and adapts automatically. No config file needed.

| Category | Supported |
|----------|-----------|
| Frameworks | Next.js, React, Vue, Angular, Svelte, SvelteKit, Nuxt, Remix, Astro, Express, Fastify, Django, Flask, Rails, Go, Rust |
| Languages | JavaScript/TypeScript, Python, Go, Rust, Ruby, Java |
| Package managers | npm, yarn, pnpm, bun |
| Test runners | Vitest, Jest, Mocha, Playwright, Cypress, pytest, RSpec, Go test |
| Lint tools | ESLint, Biome, Prettier, Ruff, RuboCop, golangci-lint |
| ORMs | Prisma, Drizzle, TypeORM, Sequelize, Django ORM, SQLAlchemy, ActiveRecord |
| Deployment | Docker, Kubernetes, Vercel, Netlify, Fly.io, Render, Heroku, Railway |

## Example Report Output

```
# Production Readiness Report

**Project**: my-app
**Date**: 2026-03-23
**Verdict**: NEEDS FIXES

| Pillar         | Status | Critical | Warnings | Info |
|----------------|--------|----------|----------|------|
| Security       | FAIL   | 1        | 2        | 0    |
| Visual QA      | PASS   | 0        | 1        | 3    |
| Code Quality   | PASS   | 0        | 4        | 2    |
| Testing        | PASS   | 0        | 1        | 0    |
| Error Handling | PASS   | 0        | 1        | 1    |
| Config & Build | PASS   | 0        | 0        | 2    |
| Performance    | PASS   | 0        | 2        | 1    |
| Accessibility  | PASS   | 0        | 3        | 1    |
| **TOTAL**      |        | **1**    | **14**   | **10**|

## CRITICAL Issues
### [CRITICAL] Hardcoded API key in source
- Pillar: Security
- Location: src/lib/api-client.ts:14
- Fix: Move to environment variable, add to .env.example
...
```

## Optional: Project-Level Screenshot Helper

For faster Visual QA, you can add a Playwright screenshot script to your project that the plugin will auto-detect and use:

**1. Create the script** (`e2e/qa/take-screenshots.qa.ts`):
```typescript
import { test } from '@playwright/test'

// Screenshots all your pages at desktop (1440x900) and mobile (375x812)
// See the resume-builder example for a full implementation:
// https://github.com/Meghshyams/production-readiness/blob/main/examples/take-screenshots.qa.ts
```

**2. Add the npm script**:
```json
{
  "scripts": {
    "qa:screenshots": "npx playwright test e2e/qa/take-screenshots.qa.ts --project='Desktop Chrome'"
  }
}
```

**3. Gitignore the output**:
```
e2e/qa-screenshots/
```

If this script doesn't exist, the plugin takes screenshots directly using Playwright (if available).

## Plugin Structure

```
production-readiness/
├── .claude-plugin/
│   ├── plugin.json           # Plugin metadata
│   └── marketplace.json      # Marketplace distribution manifest
├── skills/
│   └── production-readiness/
│       ├── SKILL.md           # Hub: role, args, execution flow, guidelines
│       ├── cache-management.md  # Cache logic, structure, file-pattern mapping
│       ├── report-format.md     # Report template, verdict logic, cached labels
│       └── phases/
│           ├── 01-detect.md     # Phase 1: Detection + cache status check
│           ├── 02-security.md   # Phase 2: Security audit (12 checks)
│           ├── 03-quality.md    # Phase 3: Code quality (5 checks)
│           ├── 04-testing.md    # Phase 4: Testing (3 checks)
│           ├── 05-errors.md     # Phase 5: Error handling & observability (5 checks)
│           ├── 06-build.md      # Phase 6: Configuration & build (9 checks)
│           ├── 07-visual.md     # Phase 7: Visual QA (2 checks)
│           ├── 08-performance.md  # Phase 8: Performance (9 checks)
│           ├── 09-save.md       # Phase 9: Save results
│           └── 10-accessibility.md  # Phase 10: Accessibility (6 checks)
├── tests/
│   └── validate-plugin.sh    # Plugin structure validation tests
├── .github/
│   └── workflows/
│       └── validate.yml      # CI: validates plugin structure
├── CONTRIBUTING.md            # How to contribute
├── LICENSE                    # MIT
└── README.md

# Generated in the audited project (gitignore this):
<project>/
└── .production-readiness/
    ├── cache.json             # Cached audit results
    └── last-report.md         # Last generated report
```

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

Common ways to contribute:
- Add new checks to existing pillars
- Add support for more frameworks/tools in the detection phase
- Improve severity calibration (fewer false positives)
- Add new pillars (i18n, SEO, etc.)

## License

[MIT](LICENSE)
