/**
 * QA screenshot helper for the production-readiness plugin's Visual QA phase.
 *
 * Copy this file into your project (e.g. `e2e/qa/take-screenshots.qa.ts`),
 * adjust PAGES and BASE_URL, and add an npm script:
 *
 *   "qa:screenshots": "npx playwright test e2e/qa/take-screenshots.qa.ts --project='Desktop Chrome'"
 *
 * The plugin auto-detects this script and uses it instead of driving
 * Playwright manually. Screenshots land in `e2e/qa-screenshots/`
 * (add that directory to .gitignore).
 */
import { test } from '@playwright/test'

const BASE_URL = process.env.QA_BASE_URL ?? 'http://localhost:3000'
const OUTPUT_DIR = 'e2e/qa-screenshots'

// List every public page you want inspected. For authenticated pages,
// set up storageState in your Playwright config and add them here too.
const PAGES: { name: string; path: string }[] = [
  { name: 'home', path: '/' },
  { name: 'pricing', path: '/pricing' },
  { name: 'about', path: '/about' },
  { name: 'login', path: '/login' },
  { name: 'signup', path: '/signup' },
]

const VIEWPORTS = [
  { label: 'desktop', width: 1440, height: 900 },
  { label: 'mobile', width: 375, height: 812 },
]

for (const viewport of VIEWPORTS) {
  test.describe(`${viewport.label} (${viewport.width}x${viewport.height})`, () => {
    test.use({ viewport: { width: viewport.width, height: viewport.height } })

    for (const page of PAGES) {
      test(`screenshot: ${page.name}`, async ({ page: pw }) => {
        await pw.goto(`${BASE_URL}${page.path}`, { waitUntil: 'networkidle' })
        // Give lazy-loaded images/fonts a beat to settle.
        await pw.waitForTimeout(500)
        await pw.screenshot({
          path: `${OUTPUT_DIR}/${page.name}-${viewport.label}.png`,
          fullPage: true,
        })
      })
    }
  })
}
