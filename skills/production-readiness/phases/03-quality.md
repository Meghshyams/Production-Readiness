## Phase 3: Code Quality

### 3.1 Debug Statements

Search source code (exclude tests, node_modules, .next, dist) for:
- `console.log(` — count occurrences
- `console.debug(` — count occurrences
- `console.warn(` — count occurrences (INFO level, often intentional)
- `debugger` statements — CRITICAL (will pause execution in browser)
- `alert(` — WARNING in non-test files
- Python: `print(` in non-test files, `breakpoint()`, `pdb.set_trace()`, `import pdb`
- Go: `fmt.Println(` in non-test files (should use structured logging)
- Rust: `println!(` / `dbg!(` in non-test files
- Ruby: `puts` / `binding.pry` / `byebug` in non-test files

Report count per file. **Severity**: WARNING for console.log in production paths, CRITICAL for `debugger`.

### 3.2 Unresolved Tech Debt

Search for comments containing:
- `TODO` — count and list with file locations
- `FIXME` — WARNING level (known bugs)
- `HACK` — WARNING level (known workarounds)
- `XXX` — WARNING level
- `@deprecated` — INFO (track for awareness)

### 3.3 Lint

Run the detected lint tool:
- ESLint: `npx eslint . --format json` or `npm run lint`
- Biome: `npx biome check .`
- Other: whatever the project uses
- Python: `ruff check .` or `flake8` or `pylint`
- Go: `golangci-lint run`
- Rust: `cargo clippy`
- Ruby: `rubocop`

Report: error count, warning count. **Severity**: CRITICAL if lint errors, WARNING if warnings.

### 3.4 Type Checking

If TypeScript project:
- Run `npx tsc --noEmit` (or `npm run typecheck` if script exists)
- Report error count
- **Severity**: CRITICAL if type errors

Language-specific type/static analysis:
- Python: `mypy .` or `pyright` (if configured)
- Go: `go vet ./...` (built-in static analysis)
- Rust: type checking is part of `cargo check`

### 3.5 Unused Dependencies

Check `package.json` dependencies:
- Use `npx depcheck` if available, or manually check if key dependencies are imported anywhere
- Focus on large dependencies that would bloat the bundle
- **Severity**: INFO for unused dependencies
