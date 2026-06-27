## Phase 4: Testing

### 4.1 Run Test Suites

Run all detected test suites (use the runner found in Phase 1 — Vitest, Jest, `bun test`, Mocha, etc.):
- Unit tests: `npm run test:unit` or equivalent (`vitest run`, `jest`, `bun test`)
- E2E tests: `npm run test:e2e` or equivalent (only if app is running) — Playwright, Cypress
- Other test scripts found in package.json
- Python: `pytest` or `python -m pytest`
- Go: `go test ./...`
- Rust: `cargo test`
- Ruby: `bundle exec rspec` or `rake test`
- Java: `mvn test` or `gradle test`

Report: total tests, passed, failed, skipped.
**Severity**: CRITICAL if tests fail

### 4.2 Coverage

If coverage is configured:
- Run with coverage flag
- Report line/branch/function coverage percentages
- Vitest: `vitest run --coverage` (v8/istanbul). Jest: `jest --coverage`. Bun: `bun test --coverage`
- Python: `pytest --cov` or `coverage run`
- Go: `go test -coverprofile=coverage.out ./...` then `go tool cover -func=coverage.out`
- Rust: `cargo tarpaulin` or `cargo llvm-cov`
- Ruby: SimpleCov (check for `simplecov` in Gemfile)
- **Severity**: WARNING if coverage below 60%, INFO if below 80%

### 4.3 Critical Path Coverage

Check if these critical paths have test coverage (search for test files covering them):
- Authentication flows (login, signup, logout, password reset)
- Payment/checkout flows
- API routes that handle sensitive data
- Data mutation endpoints (create, update, delete)

**Severity**: WARNING if critical paths have no tests

### 4.4 Test Health & Reliability

- **Skipped/disabled tests**: grep for `.skip`, `.only`, `xit(`, `xdescribe(`, `test.todo`, `@pytest.mark.skip`, `t.Skip(`. A committed `.only` silently disables the rest of the suite — WARNING. Skipped tests — INFO with count.
- **Flakiness signals**: check whether CI retries tests to mask flakes (`retries:` in Playwright/Vitest config, `jest.retryTimes`, `--flake-finder`). Heavy reliance on retries hides real instability — INFO.
- **Determinism smells**: tests depending on real time, real network, or random data without seeding/mocking — INFO.
- **Severity**: WARNING for committed `.only`; INFO for skipped tests, retry masking, and non-deterministic patterns.
