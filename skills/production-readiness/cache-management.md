## Cache Management

The plugin supports **git-aware incremental caching** so that reruns only re-execute phases affected by actual code changes. Cached results are clearly labeled, and the user can always force a fresh run.

### Cache File

Results are stored in `.production-readiness/cache.json` in the project root.

### Cache Structure

```json
{
  "version": 1,
  "timestamp": "2025-01-15T10:30:00Z",
  "gitCommitHash": "abc123...",
  "gitDirtyFiles": ["src/app/page.tsx"],
  "projectName": "my-app",
  "detection": { },
  "phases": {
    "security": {
      "status": "PASS",
      "critical": 0,
      "warnings": 2,
      "info": 1,
      "findings": [],
      "relevantFileGlobs": ["src/**", "*.config.*", ".env*"]
    }
  },
  "report": "# Production Readiness Report\n..."
}
```

### On-Run Behavior

1. **If `--fresh` flag**: Skip cache entirely, run all phases, save results at end.
2. **If `--cached` flag**: Read `.production-readiness/cache.json`, display the stored report, and stop. If no cache exists, inform the user and suggest running without `--cached`.
3. **Default (no flag)**:
   a. Check if `.production-readiness/cache.json` exists.
   b. If no cache: run full audit (same as without caching), save results at end.
   c. If cache exists:
      - Read the cache file.
      - Run `git diff --name-only <cachedCommitHash>..HEAD` to get changed committed files.
      - Run `git diff --name-only` to get uncommitted changes.
      - Combine both lists into `changedFiles`.
      - If `changedFiles` is empty AND cache is less than 24 hours old: show cached report with an `[ALL CACHED]` banner at the top.
      - Otherwise: map `changedFiles` to affected phases using the table below, rerun only affected phases + dependency audit (check 2.3, always fresh), merge fresh results with cached results, and save updated cache.

### Phase-to-File-Pattern Mapping

A phase reruns if ANY changed file matches its patterns:

| Phase | Rerun if changed files match |
|-------|------------------------------|
| security | `src/**`, `app/**`, `lib/**`, `server/**`, `api/**`, `*.config.*`, `.env*`, `middleware.*` |
| quality | `src/**`, `app/**`, `lib/**`, `*.config.*`, `tsconfig*`, `.eslintrc*`, `biome.json`, `package.json` |
| testing | `src/**`, `app/**`, `lib/**`, `test/**`, `tests/**`, `__tests__/**`, `*.test.*`, `*.spec.*`, `e2e/**`, `package.json`, `*lock*` |
| errors | `src/**`, `app/**`, `lib/**`, `server/**`, `middleware.*` |
| build | `src/**`, `app/**`, `lib/**`, `*.config.*`, `package.json`, `*lock*`, `tsconfig*`, `public/**` |
| visual | `src/**`, `app/**`, `components/**`, `styles/**`, `*.css`, `*.scss`, `public/**`, `package.json` |
| performance | `src/**`, `app/**`, `lib/**`, `package.json`, `*.config.*` |

### Special Rules

- **`package.json` or lock file changes** → rerun ALL phases (dependencies affect everything).
- **`npm audit` (check 2.3)** → ALWAYS rerun regardless of cache (new CVEs are external).
- **Detection phase (Phase 1)** → ALWAYS runs (it's fast and sets context).
- **`--skip` / `--only` flags** → apply on top of cache logic. A phase that would be cached but is also in `--skip` stays skipped. A phase not in `--only` is skipped even if it would rerun.
