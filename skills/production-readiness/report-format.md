## Report Format

After all phases complete, present a structured report.

If any phases used cached results, add this note at the top of the report:

> **Note**: This report includes cached results for unchanged phases. Run with `--fresh` for a complete re-audit.

Each phase section header should indicate its source:
- Fresh phase: `## Security Audit`
- Cached phase: `## Security Audit [CACHED — from Jan 15]`

```markdown
# Production Readiness Report

**Project**: [name from package.json or directory]
**Date**: [current date]
**Verdict**: READY / NEEDS FIXES / BLOCKED

## Summary

| Pillar          | Status | Critical | Warnings | Info | Source              |
|-----------------|--------|----------|----------|------|---------------------|
| Security        | PASS/FAIL | N     | N        | N    | Fresh               |
| Visual QA       | PASS/FAIL | N     | N        | N    | Cached (Jan 15)     |
| Code Quality    | PASS/FAIL | N     | N        | N    | Fresh               |
| Testing         | PASS/FAIL | N     | N        | N    | Cached (Jan 15)     |
| Error Handling  | PASS/FAIL | N     | N        | N    | Cached (Jan 15)     |
| Config & Build  | PASS/FAIL | N     | N        | N    | Fresh               |
| Performance     | PASS/FAIL | N     | N        | N    | Cached (Jan 15)     |
| **TOTAL**       |        | **N**    | **N**    | **N**|                     |

## Verdict Logic
- **READY**: Zero CRITICAL issues, fewer than 5 WARNINGs
- **NEEDS FIXES**: Zero CRITICAL issues but 5+ WARNINGs, OR 1-2 non-blocking CRITICALs
- **BLOCKED**: 3+ CRITICAL issues that prevent safe deployment

---

## CRITICAL Issues (must fix before deploy)

### [CRITICAL] Issue title
- **Pillar**: Security / Code Quality / etc.
- **Location**: `file/path:line` or general area
- **Details**: What's wrong and why it matters
- **Fix**: Specific actionable recommendation

---

## Warnings (should fix, not blocking)

### [WARNING] Issue title
- **Pillar**: ...
- **Location**: ...
- **Details**: ...
- **Fix**: ...

---

## Info (recommendations for improvement)

### [INFO] Issue title
- **Pillar**: ...
- **Details**: ...
- **Suggestion**: ...

---

## What's Good (things done right)

List positive findings — security measures in place, good test coverage, proper error handling, etc. This is important for morale and to confirm what doesn't need changing.

---

## Next Steps

Prioritized list of actions:
1. [CRITICAL] Fix X in file Y
2. [CRITICAL] Fix A in file B
3. [WARNING] Address C
4. ...
```
