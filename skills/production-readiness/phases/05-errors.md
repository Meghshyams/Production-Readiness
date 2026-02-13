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

### 5.6 Unhandled Promise Rejections

Check for global unhandled promise rejection handlers to catch async errors that escape try-catch blocks.

**Node.js / Next.js (server-side):**

Search for process-level handlers:

```bash
grep -rn "process\.on\(['\"]unhandledRejection" --include="*.{ts,js,tsx,jsx}" .
```

Check in server startup files: `server.ts`, `server.js`, `instrumentation.ts`, `next.config.js`

**Browser (client-side):**

Search for window-level handlers:

```bash
grep -rn "window\.addEventListener\(['\"]unhandledrejection" --include="*.{ts,tsx,js,jsx}" src/ app/
```

Check in main entry files: `src/main.tsx`, `src/main.ts`, `src/index.tsx`, `app/layout.tsx`

**What's acceptable:**

```javascript
// Node.js (server-side)
process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled Rejection', { reason, promise });
  // Send to error tracking service
  Sentry.captureException(reason);
});

// Browser (client-side)
window.addEventListener('unhandledrejection', (event) => {
  logger.error('Unhandled promise rejection', event.reason);
  Sentry.captureException(event.reason);
});
```

**What's problematic:**

- No unhandled rejection handler (silent failures in production)
- Handler only logs but doesn't send to error tracking
- Handler doesn't exit process on critical server errors (for long-running services)
- Async errors in React components (Error Boundary won't catch them)

**Why this matters:**

Unhandled promise rejections are one of the most common sources of silent failures. Without a global handler:
- Failed async operations may never be noticed
- Users see broken features with no error logged
- Server processes may be in an inconsistent state

**Severity**: WARNING if no unhandled rejection handler configured
