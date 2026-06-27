## Phase 8: Performance (Static Analysis)

### 8.1 Image Optimization

- Search for raw `<img` tags (not framework image components)
- Check if `next/image`, `nuxt-img`, or equivalent is used
- Look for large images in `public/` directory without optimization
- **Severity**: WARNING for unoptimized images

### 8.2 Bundle Size

- Check for large library imports that could be tree-shaken or lazy-loaded
- Look for `import moment` (suggest dayjs/date-fns), `import lodash` (suggest lodash-es or individual imports)
- Check for dynamic imports on heavy components (`React.lazy`, `next/dynamic`)
- **Severity**: INFO with specific suggestions

### 8.3 Caching

- Check for cache headers in API routes or middleware
- Check for CDN configuration (Vercel, Cloudflare, etc.)
- Check for `Cache-Control`, `stale-while-revalidate` headers
- Next.js: check for `revalidate` in page configs, ISR usage
- **Severity**: INFO

### 8.4 Database Query Patterns

If ORM is detected:
- Search for N+1 patterns (queries in loops, missing `include`/`eager`)
- Check for missing `select` (fetching all columns when few needed)
- Check for missing pagination on list endpoints
- **Severity**: WARNING for likely N+1 queries

### 8.5 Lazy Loading

- Check for `loading="lazy"` on images below the fold
- Check for dynamic imports on heavy components (`React.lazy`, `next/dynamic`, `defineAsyncComponent` in Vue)
- Check for route-level code splitting
- **Severity**: INFO with specific suggestions

### 8.6 Core Web Vitals Monitoring

- Check if Web Vitals tracking is configured:
  - `web-vitals` package, `next/web-vitals`, `@vercel/analytics`
  - Custom performance observer for LCP, FID/INP, CLS
- Check for `reportWebVitals` function in Next.js
- Check for performance monitoring in error tracking (Sentry performance, DataDog RUM)
- **Severity**: INFO — recommended for production observability

### 8.7 Font Optimization

- Search CSS for `@font-face` declarations without `font-display: swap` (or `optional`)
- Check for font preloading: `<link rel="preload" as="font">`
- Check Next.js `next/font` usage (auto-optimized)
- Look for large font files (multiple weights/styles loaded when few are used)
- **Severity**: INFO

### 8.8 Third-Party Scripts

- Search for external `<script>` tags loaded synchronously (blocking render)
- Check for analytics, chat widgets, marketing pixels loaded without `async` or `defer`
- Look for Google Tag Manager, Intercom, HubSpot, etc. and check loading strategy
- Check for `next/script` with `strategy` prop in Next.js
- **Severity**: WARNING for synchronous third-party scripts in critical path

### 8.9 API Response Size

- Check API routes for endpoints that return full objects without field selection
- Look for list endpoints without pagination (`limit`, `offset`, `cursor`)
- Check for large JSON responses (returning nested relations when not needed)
- Look for GraphQL over-fetching patterns (requesting all fields)
- **Severity**: WARNING for unpaginated list endpoints, INFO for over-fetching

### 8.10 Compression & Transfer

- Check whether responses are compressed: framework/middleware (`compression` in Express, `compress` in Fastify) or platform/CDN-level (Vercel, Cloudflare, nginx `gzip`/`brotli`).
- Prefer Brotli for static text assets where the platform supports it; gzip as the baseline.
- Check that large JSON API responses are compressed (not just HTML).
- Most managed platforms (Vercel/Netlify/Cloudflare) compress automatically — note this rather than flagging; self-hosted servers must configure it.
- **Severity**: WARNING if a self-hosted server serves uncompressed text/JSON; INFO otherwise.

### 8.11 Database Connection Management

- Check for a connection pool with a sane max size (not unbounded, not a new connection per request).
- **Serverless/edge**: a raw pooled DB client per invocation exhausts connections under load — check for a serverless-appropriate driver or external pooler (PgBouncer, Prisma Accelerate, Neon/Supabase pooler, `@neondatabase/serverless`, `postgres.js` with low max). Cross-ref Build 6.10.
- Check that connections are released/closed (no leaks in error paths).
- **Severity**: WARNING for raw pooled connections in serverless or unbounded pools; INFO for tuning opportunities.

### 8.12 Rendering & Asset Delivery

- **Critical CSS / render-blocking**: flag large blocking CSS/JS in `<head>` without `async`/`defer` or inlining of critical CSS (cross-ref 8.8).
- **Unused CSS**: very large CSS bundles relative to app size — recommend purge (Tailwind JIT/v4 handles this automatically; flag legacy setups that don't).
- **Modern image formats**: recommend AVIF/WebP for large raster images (framework image components do this automatically — flag only raw `<img>` with PNG/JPG hero assets).
- **Static vs dynamic rendering**: for Next.js/Nuxt/SvelteKit, flag pages that opt every route into dynamic/SSR rendering when static/ISR would serve faster and cheaper.
- **Severity**: INFO with specific suggestions (these are optimization guidance, rarely blocking).
