## Phase 6: Configuration & Build

### 6.1 Build Verification

Run the build command:
- `npm run build` or equivalent
- Python: `python -m py_compile` or `python setup.py build` or `pip install -e .`
- Go: `go build ./...`
- Rust: `cargo build --release`
- Ruby: `bundle exec rake build` or `bundle exec rails assets:precompile`
- Java: `mvn package` or `gradle build`
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

### 6.6 Docker Configuration

If `Dockerfile` is detected:
- Check for `USER` directive — WARNING if running as root (no non-root user set)
- Check for multi-stage builds — INFO if single stage (larger image)
- Check for `.dockerignore` — WARNING if missing (may include `node_modules`, `.git`, `.env`)
- Check for `COPY . .` without `.dockerignore` — WARNING (may leak secrets)
- Check for pinned base image versions (e.g., `node:20-alpine` vs `node:latest`) — WARNING if using `:latest`
- Check for `HEALTHCHECK` instruction — INFO if missing

**Severity**: WARNING for root user, missing .dockerignore; INFO for optimization suggestions

### 6.7 Docker Compose Security

If `docker-compose.yml` or `compose.yml` is detected:
- Check for hardcoded passwords or secrets in environment variables — CRITICAL
- Check for `env_file` usage vs inline environment values
- Check for exposed ports that should be internal only
- Check for volume mounts that expose sensitive host paths

**Severity**: CRITICAL for hardcoded secrets, WARNING for exposed ports

### 6.8 Container Orchestration

If Kubernetes manifests are detected (`k8s/`, `kubernetes/`, `*.yaml` with `apiVersion`):
- Check for resource limits (`resources.limits.cpu`, `resources.limits.memory`) — WARNING if missing
- Check for liveness and readiness probes — WARNING if missing
- Check for `imagePullPolicy: Always` on production — INFO
- Check for `securityContext.runAsNonRoot: true` — WARNING if missing

**Severity**: WARNING for missing probes and resource limits

### 6.9 Platform Deployment Config

Check for platform-specific deployment configs and validate:
- `vercel.json` — check for valid config, env vars referenced
- `netlify.toml` — check for valid config
- `fly.toml` — check for health check config
- `render.yaml` — check for valid config
- `Procfile` (Heroku) — check for web process defined
- `railway.json` / `railway.toml` — check for valid config
- `app.yaml` (Google App Engine) — check for valid config

**Severity**: INFO — validate detected configs exist and are well-formed
