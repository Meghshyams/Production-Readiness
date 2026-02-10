# Production Readiness — Claude Code Plugin

> Like having a senior engineer + QA tester do a final review before you deploy.

A comprehensive production readiness audit for [Claude Code](https://claude.com/claude-code). Run `/production-readiness` on any project to get a structured report covering security, visual QA, code quality, testing, error handling, build configuration, and performance — with actionable fixes for every issue found.

## Why This Exists

Deploying to production is stressful. You check one thing, forget another. Did you leave `console.log` in? Are there hardcoded API keys? Does the mobile layout break? Is the build even passing?

This plugin runs **40+ automated checks** across 7 categories and produces a single, prioritized report. It adapts to whatever tech stack you're using — no configuration needed.

## The 7 Pillars

| # | Pillar | What's Checked |
|---|--------|---------------|
| 1 | **Security** | Hardcoded secrets, `.env` safety, dependency vulnerabilities, input validation, auth config, rate limiting, security headers, error exposure, SQL injection, XSS |
| 2 | **Visual QA** | Screenshots every page at desktop + mobile viewports, then inspects each for layout issues, spelling mistakes, responsive problems, broken UI, and visual inconsistencies |
| 3 | **Code Quality** | `console.log` / `debugger` statements, TODO/FIXME comments, lint errors, type errors, unused dependencies |
| 4 | **Testing** | Runs your test suites, reports pass/fail and coverage, flags untested critical paths (auth, payments, mutations) |
| 5 | **Error Handling** | Error boundaries, error tracking (Sentry etc.), health check endpoints, structured logging, sensitive data in logs |
| 6 | **Config & Build** | Build passes, env vars documented, source maps hidden, no dev-only leaks, HTTPS redirects |
| 7 | **Performance** | Image optimization, bundle size, caching headers, N+1 query patterns |

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
# Full audit — all 7 pillars
/production-readiness

# Run specific pillars only
/production-readiness --only=security,testing

# Skip specific pillars
/production-readiness --skip=visual,performance

# Override dev server port
/production-readiness --port=3000
```

**Pillar names for `--only` / `--skip`:** `security`, `visual`, `quality`, `testing`, `build`, `errors`, `performance`

## How It Works

```
Phase 1: DETECT
├── Identifies your framework, package manager, test runner, lint tool, ORM
├── Finds your page/route list (app-map, file-based routing, etc.)
├── Checks for Playwright (for visual QA screenshots)
└── Shows you a summary table before proceeding

Phase 2-7: AUDIT
├── Runs automated checks (grep, lint, build, tests)
├── Takes screenshots if Playwright is available
├── Reads each screenshot with vision to find visual issues
└── Collects all findings with severity levels

Phase 8: REPORT
├── Structured report organized by pillar
├── Severity: CRITICAL / WARNING / INFO
├── Verdict: READY / NEEDS FIXES / BLOCKED
├── "What's Good" section (things done right)
└── Prioritized next steps
```

## Adapts to Any Stack

The plugin detects your tools and adapts automatically. No config file needed.

| Category | Supported |
|----------|-----------|
| Frameworks | Next.js, React, Vue, Angular, Svelte, Express, Fastify, Django, Flask, Rails, Go, Rust |
| Package managers | npm, yarn, pnpm, bun |
| Test runners | Vitest, Jest, Mocha, Playwright, Cypress, pytest, RSpec, Go test |
| Lint tools | ESLint, Biome, Prettier, Ruff, RuboCop, golangci-lint |
| ORMs | Prisma, Drizzle, TypeORM, Sequelize, Django ORM, SQLAlchemy, ActiveRecord |

## Example Report Output

```
# Production Readiness Report

**Project**: my-app
**Date**: 2026-02-10
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
| **TOTAL**      |        | **1**    | **11**   | **9**|

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
│       └── SKILL.md          # The skill — all 7 audit phases
├── .github/
│   └── workflows/
│       └── validate.yml      # CI: validates plugin structure
├── CONTRIBUTING.md            # How to contribute
├── LICENSE                    # MIT
└── README.md
```

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

Common ways to contribute:
- Add new checks to existing pillars
- Add support for more frameworks/tools in the detection phase
- Improve severity calibration (fewer false positives)
- Add new pillars (accessibility, i18n, etc.)

## License

[MIT](LICENSE)
