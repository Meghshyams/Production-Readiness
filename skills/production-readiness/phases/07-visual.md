## Phase 7: Visual QA

**Prerequisites**: Playwright installed AND app running locally (or can be started).

If prerequisites are NOT met, skip this phase with a note explaining why.

### 7.1 Screenshot Collection

Check for a QA screenshot script first:
- Look for `e2e/qa/take-screenshots.qa.ts` or `qa:screenshots` npm script
- If found, run it: `npm run qa:screenshots` or `npx playwright test e2e/qa/take-screenshots.qa.ts`
- If not found, take screenshots manually using Playwright:

For each page found in the page/route list (or by scanning the app router):

```
Desktop viewport: 1440x900
Mobile viewport: 375x812
```

Navigate to each public page, wait for network idle, and screenshot.
For authenticated pages, note them as "requires auth — skipped" unless auth state is available.

Save screenshots to a temporary directory.

### 7.2 Visual Inspection

For EACH screenshot, read the image and evaluate:

**Layout & Spacing**:
- Are elements properly aligned?
- Is spacing consistent (no overlapping, no giant gaps)?
- Does the grid/layout system work correctly?

**Responsive (mobile screenshots)**:
- Is there horizontal overflow / scrolling?
- Is text readable (not too small)?
- Are interactive elements large enough to tap?
- Is content cut off or hidden?

**Content**:
- Any visible spelling mistakes or typos?
- Any broken images (alt text showing instead of image)?
- Any empty sections that should have content?
- Any placeholder text left in ("Lorem ipsum", "TODO", "Coming soon")?

**Visual Consistency**:
- Consistent fonts throughout?
- Consistent color scheme?
- Consistent button/input styling?
- Dark/light mode issues?

**Broken UI**:
- Z-index issues (elements overlapping incorrectly)?
- Overflow issues (text or images breaking containers)?
- Missing icons or broken icon fonts?
- Console errors visible in screenshot?

Report each issue with:
- Page URL
- Viewport (desktop/mobile)
- Description of the issue
- Severity (CRITICAL for broken functionality, WARNING for visual issues, INFO for polish)
