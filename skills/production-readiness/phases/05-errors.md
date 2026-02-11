## Phase 5: Error Handling & Observability

### 5.1 Global Error Boundary

Check for:
- React: `error.tsx` / `error.js` in app directory, or ErrorBoundary component
- Vue: `errorHandler` in main app config
- Express: global error middleware (4-arg function)
- Next.js: `app/error.tsx`, `app/global-error.tsx`, `pages/_error.tsx`

**Severity**: WARNING if no global error boundary

### 5.2 Error Tracking

Search for integration with:
- Sentry (`@sentry/nextjs`, `@sentry/react`, `@sentry/node`, `Sentry.init`)
- DataDog (`dd-trace`, `@datadog/browser-rum`)
- LogRocket, Bugsnag, Rollbar, New Relic
- Check if DSN/keys are configured (not just installed)

**Severity**: WARNING if no error tracking configured

### 5.3 Health Check Endpoint

Search for:
- `/api/health`, `/health`, `/healthz`, `/api/healthcheck`
- A route that returns 200 OK with basic health info

**Severity**: INFO if no health check (recommended but not critical)

### 5.4 Logging

Check if structured logging is used:
- Winston, Pino, Bunyan, Morgan (Node.js)
- Python logging module with formatters
- Or if only `console.log/error` is used for production error logging

**Severity**: INFO — recommend structured logging for production

### 5.5 Sensitive Data in Logs

Search log statements for patterns that might log:
- User passwords, tokens, API keys
- Full request bodies on auth routes
- PII (email, phone, SSN patterns)

**Severity**: WARNING if sensitive data appears in log statements
