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
