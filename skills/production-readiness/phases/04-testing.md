## Phase 4: Testing

### 4.1 Run Test Suites

Run all detected test suites:
- Unit tests: `npm run test:unit` or equivalent
- E2E tests: `npm run test:e2e` or equivalent (only if app is running)
- Other test scripts found in package.json

Report: total tests, passed, failed, skipped.
**Severity**: CRITICAL if tests fail

### 4.2 Coverage

If coverage is configured:
- Run with coverage flag
- Report line/branch/function coverage percentages
- **Severity**: WARNING if coverage below 60%, INFO if below 80%

### 4.3 Critical Path Coverage

Check if these critical paths have test coverage (search for test files covering them):
- Authentication flows (login, signup, logout, password reset)
- Payment/checkout flows
- API routes that handle sensitive data
- Data mutation endpoints (create, update, delete)

**Severity**: WARNING if critical paths have no tests
