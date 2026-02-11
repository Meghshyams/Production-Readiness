## Phase 1: Detect — Project Analysis

Before running any checks, detect the project stack. Do NOT assume any specific technology.

### Detection Checklist

Run these checks in parallel where possible:

1. **Framework**: Read `package.json`, `requirements.txt`, `go.mod`, `Cargo.toml`, `pom.xml`, `Gemfile`, etc. Identify: Next.js, React, Vue, Angular, Express, Django, Flask, Rails, Go, Rust, etc.

2. **Package manager**: Check for `package-lock.json` (npm), `yarn.lock` (yarn), `pnpm-lock.yaml` (pnpm), `bun.lockb` (bun).

3. **Test runner**: Look for vitest/jest/mocha/playwright/cypress/pytest/rspec/go test configs. Check `package.json` scripts for test commands.

4. **Lint tool**: Check for `.eslintrc*`, `biome.json`, `.prettierrc*`, `pyproject.toml` (ruff/flake8), `.rubocop.yml`, `golangci-lint.yml`.

5. **ORM/Database**: Prisma (`prisma/schema.prisma`), Drizzle, TypeORM, Sequelize, Django ORM, SQLAlchemy, ActiveRecord, raw SQL files.

6. **Page/route list**: Look for `e2e/app-map.ts`, `app-map.*`, route files, or scan `src/app/`, `src/pages/`, `pages/`, `routes/` directories.

7. **Screenshot capability**: Is Playwright installed? Is there a QA screenshot script (`e2e/qa/take-screenshots.qa.ts` or similar)?

8. **Dev server port**: Check `package.json` scripts, framework config files, `.env` files for port configuration.

9. **Build command**: Detect the build command from `package.json` scripts, `Makefile`, `Dockerfile`, etc.

10. **CI/CD**: Check for `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`, `Dockerfile`, `vercel.json`, `netlify.toml`.

### Output

Present findings to the user in a summary table before proceeding:

```
## Project Detection Summary

| Aspect           | Detected                        |
|------------------|---------------------------------|
| Framework        | Next.js 14 (App Router)         |
| Package Manager  | npm                             |
| Test Runner      | Vitest (unit) + Playwright (e2e)|
| Lint Tool        | ESLint                          |
| ORM              | Prisma                          |
| Pages/Routes     | 28 pages (from e2e/app-map.ts)  |
| Screenshot Tool  | Playwright available            |
| Dev Server Port  | 3004                            |
| Build Command    | npm run build                   |
| CI/CD            | GitHub Actions                  |
```

### Cache Status Check

After presenting the detection summary, check for cached results:

- If `--fresh` was passed, note: "Running fresh audit (cache ignored)."
- If `--cached` was passed, read `.production-readiness/cache.json` and display the stored report. Stop here.
- If `.production-readiness/cache.json` exists: determine which phases are stale vs cached (see [cache-management.md](../cache-management.md)) and present a cache status table:

```
## Cache Status

| Phase          | Status     | Reason                         |
|----------------|------------|--------------------------------|
| Security       | RERUNNING  | 3 source files changed         |
| Code Quality   | CACHED     | No relevant files changed      |
| Testing        | RERUNNING  | Test files changed             |
| Error Handling | CACHED     | No relevant files changed      |
| Config & Build | CACHED     | No relevant files changed      |
| Visual QA      | RERUNNING  | UI components changed          |
| Performance    | CACHED     | No relevant files changed      |

Phases marked CACHED will use results from [date]. Use --fresh to rerun all.
```

- If no cache exists, note: "No cached results found. Running full audit."

Ask user: "Proceeding with all 7 phases. Reply with phase names to skip, `--fresh` to rerun all, or press Enter to continue."
