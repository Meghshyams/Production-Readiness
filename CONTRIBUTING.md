# Contributing to Production Readiness

Thanks for your interest in improving this plugin! This guide covers how to contribute effectively.

## How the Plugin Works

This is a **Claude Code plugin** — it's not traditional software with runtime code. The core is a set of modular markdown files under `skills/production-readiness/`. The hub file `SKILL.md` defines the role, arguments, execution flow, and guidelines, and references individual phase files in `phases/` for each audit pillar. When a user runs `/production-readiness`, Claude reads SKILL.md, which pulls in the relevant phase files to audit the project.

This means:
- Changes are mostly **editing markdown** (the skill instructions)
- Testing means **running the skill on real projects** and checking the report quality
- "Bugs" are usually Claude doing the wrong check, missing something, or producing false positives

## What You Can Contribute

### New Checks
Add checks to existing pillars. For example:
- Security: new secret patterns, new vulnerability checks
- Performance: new anti-patterns to detect
- Code Quality: new lint rules or code smells

### New Framework/Tool Support
The detection phase identifies the project stack. You can add detection for:
- New frameworks (SvelteKit, Remix, Astro, etc.)
- New test runners, lint tools, ORMs
- New CI/CD platforms

### Better Severity Calibration
If a check produces false positives (flags something that's actually fine) or false negatives (misses real issues), adjust the instructions to be more precise.

### New Pillars
Want to add accessibility, i18n, or documentation checks? Propose a new pillar.

## Making Changes

### 1. Fork and Clone

```bash
git clone https://github.com/YOUR_USERNAME/production-readiness.git
cd production-readiness
```

### 2. Create a Branch

```bash
git checkout -b feat/add-accessibility-checks
```

Use prefixes: `feat/`, `fix/`, `docs/`, `refactor/`

### 3. Edit the Relevant File

The skill is modular. Choose what to edit based on your change:

- **Adding or modifying checks within an existing pillar** — edit the relevant phase file in `skills/production-readiness/phases/` (e.g., `02-security.md` for security checks, `04-testing.md` for testing checks).
- **Adding a new pillar** — create a new phase file (e.g., `10-accessibility.md`) in `phases/` and reference it from `SKILL.md`.
- **Changing execution flow, arguments, or guidelines** — edit `skills/production-readiness/SKILL.md`.
- **Changing the report format** — edit `skills/production-readiness/report-format.md`.
- **Changing cache behavior** — edit `skills/production-readiness/cache-management.md`.

Each phase file has a consistent structure:

```markdown
## PHASE N: PILLAR NAME

### N.1 Check Name

- What to look for (grep patterns, files to check, commands to run)
- What's acceptable vs what's a problem
- **Severity**: CRITICAL / WARNING / INFO with clear criteria
```

When adding a new check, follow this format exactly. Every check needs:
- **Clear instructions** — what files to search, what patterns to grep, what commands to run
- **What's OK vs what's not** — Claude needs to distinguish real issues from false positives
- **Severity level** — with criteria for when to use each level
- **Exclusions** — what to skip (test files, config files, etc.)

### 4. Test Your Changes

Run the skill on a real project to verify:

```bash
# Load the plugin locally
claude --plugin-dir ./production-readiness

# Run it
/production-readiness
```

Check that:
- Your new check runs without errors
- It produces meaningful findings (not just noise)
- It doesn't produce false positives on common patterns
- The severity levels are calibrated correctly

Test on at least 2 different projects if possible (e.g., a Next.js app and an Express API).

### 5. Submit a PR

```bash
git add -A
git commit -m "feat: add accessibility checks to Visual QA pillar"
git push origin feat/add-accessibility-checks
```

Open a PR with:
- **What** you changed
- **Why** (what problem does it solve, what false positives does it fix)
- **How you tested** (which projects did you run it on, what did the report look like)

## Guidelines

### Do
- Keep instructions clear and specific — Claude follows them literally
- Include exclusion patterns (test files, node_modules, etc.) to prevent false positives
- Use the existing severity scale consistently (CRITICAL = must fix, WARNING = should fix, INFO = nice to have)
- Test on real projects before submitting

### Don't
- Add checks that only apply to one specific framework without guarding them behind detection
- Set severity too high — CRITICAL should mean "this will cause real problems in production"
- Add vague instructions like "check for bad code" — be specific about what patterns to look for
- Change the report format without discussion (it's designed for consistency)

## File Structure

```
production-readiness/
├── .claude-plugin/
│   ├── plugin.json            # Plugin name, version, description
│   └── marketplace.json       # Marketplace distribution config
├── skills/
│   └── production-readiness/
│       ├── SKILL.md           # Hub: role, args, execution flow, guidelines
│       ├── cache-management.md  # Incremental caching logic
│       ├── report-format.md   # Report output format
│       └── phases/            # One file per audit pillar
│           ├── 01-detect.md
│           ├── 02-security.md
│           ├── 03-quality.md
│           ├── 04-testing.md
│           ├── 05-errors.md
│           ├── 06-build.md
│           ├── 07-visual.md
│           ├── 08-performance.md
│           ├── 09-save.md
│           └── 10-accessibility.md
├── tests/
│   └── validate-plugin.sh     # Plugin validation tests
├── .github/
│   └── workflows/
│       └── validate.yml       # CI checks
├── CONTRIBUTING.md             # This file
├── LICENSE                     # MIT
└── README.md                   # User-facing docs
```

## Questions?

Open an issue to discuss before making large changes. This helps avoid duplicate work and ensures your approach aligns with the project direction.
