## Phase 10: Accessibility

**Note**: This phase applies primarily to projects with a frontend/UI. Skip for backend-only APIs with a note.

### 10.1 Semantic HTML

Search component/page files for:
- `<div onClick` or `<span onClick` — should be `<button>` or `<a>` for interactive elements
- Missing `<main>`, `<nav>`, `<header>`, `<footer>` landmarks — check layout/root components
- `<table>` without `<thead>`, `<th>`, or `scope` attributes
- Heading hierarchy: check for skipped levels (e.g., `<h1>` followed by `<h3>`)
- **Severity**: WARNING for clickable divs/spans, INFO for missing landmarks

### 10.2 ARIA Labels & Attributes

Search for:
- `<img` tags without `alt` attribute (not `next/image` which requires it)
- `<svg` used as icons without `aria-label` or `aria-hidden="true"`
- Form inputs without associated `<label>` or `aria-label`
- Interactive elements without accessible names
- Icon-only buttons without `aria-label`
- **Severity**: WARNING for missing alt text, WARNING for unlabeled form inputs

### 10.3 Keyboard Navigation

Check for:
- `tabIndex` with positive values (disrupts natural tab order) — WARNING
- `outline: none` or `outline: 0` in CSS without a visible focus alternative — WARNING
- Click handlers without corresponding keyboard handlers (`onKeyDown`, `onKeyPress`) on non-button elements
- Modal/dialog components: check for focus trap implementation
- Skip-to-content link at the top of the page — INFO if missing
- **Severity**: WARNING for suppressed focus indicators, INFO for missing skip links

### 10.4 Color Contrast & Visual

Check CSS/theme files for:
- Text colors against background colors — flag obvious low-contrast combinations
- Check for `prefers-reduced-motion` media query support — INFO if animations exist without it
- Check for `prefers-color-scheme` support if dark mode is implemented
- Ensure text is not conveyed by color alone (e.g., error states should have icons/text, not just red color)
- **Severity**: WARNING for likely contrast issues, INFO for missing motion preferences

### 10.5 Screen Reader Support

Check for:
- `aria-live` regions for dynamic content updates (toast notifications, form errors, loading states)
- `role` attributes on custom components (e.g., `role="alert"`, `role="dialog"`, `role="tablist"`)
- Visually hidden text utility class for screen-reader-only content (`sr-only`, `visually-hidden`)
- `aria-expanded`, `aria-selected`, `aria-checked` on interactive widgets (accordions, tabs, toggles)
- **Severity**: INFO — recommended for inclusive UX

### 10.6 Automated Accessibility Testing

Check for:
- Accessibility testing tools in devDependencies: `@axe-core/react`, `jest-axe`, `@axe-core/playwright`, `pa11y`, `lighthouse`
- Accessibility-related ESLint plugin: `eslint-plugin-jsx-a11y`
- Playwright accessibility testing: check for `page.accessibility.snapshot()` usage in e2e tests
- **Severity**: INFO if no automated a11y testing configured
