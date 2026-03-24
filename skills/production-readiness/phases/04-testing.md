## Phase 4: Testing

### 4.1 Run Test Suites

Run all detected test suites:
- Unit tests: `npm run test:unit` or equivalent
- E2E tests: `npm run test:e2e` or equivalent (only if app is running)
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
