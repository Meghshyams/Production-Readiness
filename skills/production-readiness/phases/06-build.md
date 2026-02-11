## Phase 6: Configuration & Build

### 6.1 Build Verification

Run the build command:
- `npm run build` or equivalent
- Capture and report any warnings or errors

**Severity**: CRITICAL if build fails

### 6.2 Environment Documentation

Check:
- Does `.env.example` exist and list all required env vars?
- Does README mention environment setup?
- Are all env vars referenced in code documented?

**Severity**: WARNING if env vars are undocumented

### 6.3 Source Maps

Check production build config:
- Next.js: `productionBrowserSourceMaps` in `next.config.js` (should be false or absent)
- Webpack: `devtool` setting for production
- Vite: `build.sourcemap` setting

**Severity**: WARNING if source maps exposed in production

### 6.4 Development Leaks

Search production config for:
- `localhost` URLs in production config or environment
- `debug: true` or `DEBUG=*` in production config
- Development-only middleware or features not behind environment checks
- `if (process.env.NODE_ENV === 'development')` guarding debug features (this is GOOD)

**Severity**: WARNING for unguarded debug code

### 6.5 Redirects & HTTPS

Check for:
- HTTP to HTTPS redirect configuration
- www to non-www (or vice versa) redirect
- Framework/hosting config for redirects (next.config.js redirects, vercel.json, nginx config)

**Severity**: INFO — depends on hosting setup
