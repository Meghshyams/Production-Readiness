#!/usr/bin/env bash
# Comprehensive validation tests for the production-readiness plugin.
# Run from the repository root: bash tests/validate-plugin.sh

set -euo pipefail

PASS=0
FAIL=0
SKILL_DIR="skills/production-readiness"
SKILL_FILE="$SKILL_DIR/SKILL.md"

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

section() { echo ""; echo "--- $1 ---"; }

# -------------------------------------------------------
section "1. Required files exist"
# -------------------------------------------------------
required_files=(
  ".claude-plugin/plugin.json"
  ".claude-plugin/marketplace.json"
  "$SKILL_FILE"
  "README.md"
  "LICENSE"
  "CONTRIBUTING.md"
  "PRIVACY.md"
  "examples/take-screenshots.qa.ts"
  "$SKILL_DIR/cache-management.md"
  "$SKILL_DIR/report-format.md"
  "$SKILL_DIR/phases/01-detect.md"
  "$SKILL_DIR/phases/02-security.md"
  "$SKILL_DIR/phases/03-quality.md"
  "$SKILL_DIR/phases/04-testing.md"
  "$SKILL_DIR/phases/05-errors.md"
  "$SKILL_DIR/phases/06-build.md"
  "$SKILL_DIR/phases/07-visual.md"
  "$SKILL_DIR/phases/08-performance.md"
  "$SKILL_DIR/phases/09-accessibility.md"
  "$SKILL_DIR/phases/10-ai-llm.md"
  "$SKILL_DIR/phases/11-save.md"
)

for f in "${required_files[@]}"; do
  if [ -f "$f" ]; then
    pass "$f exists"
  else
    fail "$f is missing"
  fi
done

# -------------------------------------------------------
section "2. SKILL.md frontmatter"
# -------------------------------------------------------
if head -1 "$SKILL_FILE" | grep -q "^---$"; then
  pass "Frontmatter opens with ---"
else
  fail "Frontmatter missing opening ---"
fi

if awk 'NR>1 && /^---$/{found=1; exit} END{exit !found}' "$SKILL_FILE"; then
  pass "Frontmatter closes with ---"
else
  fail "Frontmatter not closed"
fi

for field in "name:" "description:" "user-invocable:" "allowed-tools:"; do
  if sed -n '2,/^---$/p' "$SKILL_FILE" | grep -q "^$field"; then
    pass "Frontmatter has '$field'"
  else
    fail "Frontmatter missing '$field'"
  fi
done

# -------------------------------------------------------
section "3. All 9 pillars referenced in SKILL.md"
# -------------------------------------------------------
pillars=(
  "Security"
  "Code Quality"
  "Testing"
  "Error Handling"
  "Configuration & Build"
  "Visual QA"
  "Performance"
  "Accessibility"
  "AI/LLM Safety"
)

for pillar in "${pillars[@]}"; do
  if grep -qi "$pillar" "$SKILL_FILE"; then
    pass "Pillar found: $pillar"
  else
    fail "Pillar missing: $pillar"
  fi
done

# -------------------------------------------------------
section "4. Internal markdown links resolve"
# -------------------------------------------------------
# Extract relative markdown links from SKILL.md — e.g., [text](phases/01-detect.md)
links=$(sed -n 's/.*](\([^)]*\.md\)).*/\1/p' "$SKILL_FILE" || true)
for link in $links; do
  target="$SKILL_DIR/$link"
  if [ -f "$target" ]; then
    pass "Link resolves: $link -> $target"
  else
    fail "Broken link: $link (expected $target)"
  fi
done

# Check cross-references from phase files back to cache-management.md
for phase_file in "$SKILL_DIR"/phases/*.md; do
  phase_links=$(sed -n 's/.*](\([^)]*\.md\)).*/\1/p' "$phase_file" || true)
  for link in $phase_links; do
    target="$SKILL_DIR/phases/$link"
    if [ -f "$target" ]; then
      pass "Link in $(basename "$phase_file") resolves: $link"
    else
      fail "Broken link in $(basename "$phase_file"): $link"
    fi
  done
done

# -------------------------------------------------------
section "5. Phase files are non-empty and have headings"
# -------------------------------------------------------
for i in 01 02 03 04 05 06 07 08 09 10 11; do
  actual=""
  for candidate in "$SKILL_DIR"/phases/"${i}"-*.md; do
    if [ -f "$candidate" ]; then actual="$candidate"; break; fi
  done
  if [ -z "$actual" ]; then
    fail "No phase file matching ${i}-*.md"
    continue
  fi
  lines=$(wc -l < "$actual")
  if [ "$lines" -gt 5 ]; then
    pass "$(basename "$actual") has content ($lines lines)"
  else
    fail "$(basename "$actual") looks empty ($lines lines)"
  fi
  if grep -q "^## " "$actual"; then
    pass "$(basename "$actual") has a heading"
  else
    fail "$(basename "$actual") missing heading"
  fi
done

# -------------------------------------------------------
section "6. Check counts in phase files"
# -------------------------------------------------------
# phase_number:expected_check_count:file
check_specs=(
  "2:17:02-security.md"
  "3:6:03-quality.md"
  "4:4:04-testing.md"
  "5:8:05-errors.md"
  "6:13:06-build.md"
  "7:2:07-visual.md"
  "8:12:08-performance.md"
  "9:8:09-accessibility.md"
  "10:7:10-ai-llm.md"
)

for spec in "${check_specs[@]}"; do
  phase_num="${spec%%:*}"
  rest="${spec#*:}"
  expected="${rest%%:*}"
  file="${rest#*:}"
  path="$SKILL_DIR/phases/$file"

  n=1
  while [ "$n" -le "$expected" ]; do
    if grep -q "### ${phase_num}\.${n} " "$path"; then
      pass "$file check ${phase_num}.${n} present"
    else
      fail "$file check ${phase_num}.${n} missing"
    fi
    n=$((n + 1))
  done

  # No extra checks beyond the expected count (catches stale test expectations)
  extra=$((expected + 1))
  if grep -q "### ${phase_num}\.${extra} " "$path"; then
    fail "$file has unexpected check ${phase_num}.${extra} — update check_specs and SKILL.md counts"
  else
    pass "$file has exactly $expected checks"
  fi
done

# -------------------------------------------------------
section "7. JSON config files are valid and versions match"
# -------------------------------------------------------
if python3 -c "import json; json.load(open('.claude-plugin/plugin.json'))" 2>/dev/null; then
  pass "plugin.json is valid JSON"
else
  fail "plugin.json is invalid JSON"
fi

if python3 -c "import json; json.load(open('.claude-plugin/marketplace.json'))" 2>/dev/null; then
  pass "marketplace.json is valid JSON"
else
  fail "marketplace.json is invalid JSON"
fi

if python3 -c "import json; d=json.load(open('.claude-plugin/plugin.json')); assert 'name' in d and 'description' in d" 2>/dev/null; then
  pass "plugin.json has name and description"
else
  fail "plugin.json missing name or description"
fi

if python3 -c "import json; d=json.load(open('.claude-plugin/marketplace.json')); assert 'plugins' in d and len(d['plugins'])>0" 2>/dev/null; then
  pass "marketplace.json has plugins array"
else
  fail "marketplace.json missing plugins"
fi

if python3 -c "
import json
p = json.load(open('.claude-plugin/plugin.json'))
m = json.load(open('.claude-plugin/marketplace.json'))
assert p['version'] == m['metadata']['version'] == m['plugins'][0]['version'], (p['version'], m['metadata']['version'], m['plugins'][0]['version'])
" 2>/dev/null; then
  pass "plugin.json and marketplace.json versions match"
else
  fail "Version mismatch between plugin.json and marketplace.json"
fi

# -------------------------------------------------------
section "8. No orphaned phase files"
# -------------------------------------------------------
for phase_file in "$SKILL_DIR"/phases/*.md; do
  basename_file=$(basename "$phase_file")
  if grep -q "$basename_file" "$SKILL_FILE"; then
    pass "$basename_file is linked from SKILL.md"
  else
    fail "$basename_file is NOT linked from SKILL.md"
  fi
done

# -------------------------------------------------------
section "9. Supporting files linked from SKILL.md"
# -------------------------------------------------------
for support_file in "cache-management.md" "report-format.md"; do
  if grep -q "$support_file" "$SKILL_FILE"; then
    pass "$support_file linked from SKILL.md"
  else
    fail "$support_file NOT linked from SKILL.md"
  fi
done

# -------------------------------------------------------
section "10. Cache-management has phase mapping table"
# -------------------------------------------------------
cache_file="$SKILL_DIR/cache-management.md"
for phase in security quality testing errors build visual performance accessibility ai; do
  if grep -q "| $phase " "$cache_file"; then
    pass "Cache mapping includes $phase"
  else
    fail "Cache mapping missing $phase"
  fi
done

# -------------------------------------------------------
section "11. Report format has required sections"
# -------------------------------------------------------
report_file="$SKILL_DIR/report-format.md"
for section_name in "Verdict Logic" "CRITICAL Issues" "Warnings" "Info" "What's Good" "Next Steps"; do
  if grep -qi "$section_name" "$report_file"; then
    pass "Report has section: $section_name"
  else
    fail "Report missing section: $section_name"
  fi
done

# -------------------------------------------------------
# Summary
# -------------------------------------------------------
echo ""
echo "==============================="
echo "  Results: $PASS passed, $FAIL failed"
echo "==============================="

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
