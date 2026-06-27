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
- Python logging module with formatters (or `structlog`)
- Or if only `console.log/error` is used for production error logging
- Prefer JSON-formatted logs in production (machine-parseable for log aggregators) over plain string logs — INFO if logs are unstructured strings
- Check that log level is configurable via env (not hardcoded `debug` in production)

**Severity**: INFO — recommend structured (JSON) logging for production

### 5.5 Sensitive Data in Logs

Search log statements for patterns that might log:
- User passwords, tokens, API keys
- Full request bodies on auth routes
- PII (email, phone, SSN patterns)

**Severity**: WARNING if sensitive data appears in log statements

### 5.6 Distributed Tracing & Correlation IDs

For services (APIs, microservices, anything that calls other services):
- Check for distributed tracing instrumentation: OpenTelemetry (`@opentelemetry/*`, `opentelemetry-*`), or vendor tracing (Sentry tracing, DataDog `dd-trace`, New Relic, Honeycomb).
- Check for a request/correlation ID propagated through logs (`x-request-id`, `traceparent`, AsyncLocalStorage request context, `requestId` in log lines) so a single request can be followed across logs/services.
- Check that traces/logs are correlated (trace ID present in log lines).
- **Severity**: INFO for missing tracing on a single service; WARNING if a multi-service/microservice architecture has no correlation IDs (debugging production incidents becomes very hard).

### 5.7 Graceful Shutdown & Resource Cleanup

For long-running servers (especially containerized):
- Check for `SIGTERM`/`SIGINT` handlers that drain in-flight requests and close DB connections/pools before exit — important for zero-downtime deploys and rolling updates.
- Check that DB pools, queues, and file handles are closed on shutdown.
- Next.js/Vercel serverless can usually skip this; classic Node servers, workers, and containers should not.
- **Severity**: INFO — recommend graceful shutdown for containerized/long-running services.
