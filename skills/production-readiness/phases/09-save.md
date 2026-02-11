## Phase 9: Save Results

After the report is generated, persist all results for future incremental reruns:

1. **Create directory**: Create `.production-readiness/` in the project root if it doesn't exist.
2. **Write `cache.json`**: Save all phase results, detection data, the current git commit hash, dirty file list, and timestamp in the cache structure defined in [cache-management.md](../cache-management.md).
3. **Write `last-report.md`**: Save the full rendered report for quick reference (so users can read it without rerunning).
4. **Suggest `.gitignore`**: If `.production-readiness/` is not already in `.gitignore`, suggest adding it:
   ```
   # Production readiness audit cache
   .production-readiness/
   ```

This phase is silent — do not include it in the report. Just save the files and briefly note: "Results cached to `.production-readiness/` for faster reruns."
