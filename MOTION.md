# Lattice — Motion Direction

Motion system for the Lattice landing page (`index.html`), built on the visual language in the Graphite style reference (`DESIGN.md`).

**Status:** Direction for review. Items marked **[PROPOSED]** are new ideas that need your approval before they are built.

---

## 0. Sources and evidence

| Source | What it gives us | Confidence |
|---|---|---|
| DESIGN.md (style reference) | Colors, type, components, and the statement that color is reserved for "animated-looking technical graphics" and "animated graphic borders" | Visual direction: **VERIFIED** (written in the file). Exact motion behavior: **INFERRED** (the file describes a still look, not timings) |
| Current build (`styles.css`, `script.js`) | The motion that exists today | **VERIFIED** (checked in a browser at 1440px and 390px) |
| Website Analyzer report | None provided | **UNKNOWN**: no real recording of the reference site's motion was analyzed |

Because the reference site's actual motion was never analyzed, everything below comes from the reference's visual principles plus established motion design. None of it copies observed timings.

---

## 1. Global motion system

### Motion personality: "precise instrument"
The page should feel like a calm, well-built developer tool that is switched on. Nothing bounces, wobbles or overshoots. Movement is exact, quiet and confident, the way a terminal cursor or a progress bar moves.

### The core principle: light means activity
The yellow → white → blue Solar Spectrum is the only "alive" color in the system. In motion it gets one job:

> **Spectral light only appears where something is working:** processing, running, or in progress.

- Hero polygon beams → "the system is on"
- Demo frame top edge → "this product is live"
- Merge-queue bars that are still running → "CI in progress"
- [PROPOSED] Active demo-tab progress line → "this view is playing"

Finished or idle things are monochrome. This turns decoration into meaning, and it keeps the gradient from spreading everywhere.

### Motion density: low, concentrated
Strong motion lives in **three places only**: the hero polygon, the product demo, and the closing CTA polygon. Everything else gets only the shared reveal and hover states.

### Timing scale
| Token | Duration | Used for |
|---|---|---|
| `--t-instant` | 150ms | Hover color, button press |
| `--t-quick` | 250ms | Arrow nudges, tab switch, border highlight |
| `--t-base` | 450ms | Panel swaps, card lift |
| `--t-reveal` | 700ms | Scroll reveals, headline lines |
| `--t-hero` | 1400ms | Hero polygon entrance (once) |
| Ambient | 4–64s, linear, infinite | Ring rotation, beams |
| Stagger | 80ms | Sibling cards and lines |

### Easing family (one family only)
| Token | Curve | Used for |
|---|---|---|
| `--ease-out` | `cubic-bezier(.16, 1, .3, 1)` (expo-out) | All entrances, reveals, panel swaps |
| `--ease-standard` | `cubic-bezier(.2, .7, .2, 1)` | Hovers and state changes |
| `linear` | n/a | Ambient loops and travelling light only |

No spring, bounce or elastic easing anywhere.

### Reveal language
- Rise 16px + fade from 0 to 1, 700ms, `--ease-out`, **once** (never replays on scroll up).
- Starts when 15% of the element is visible.
- Siblings stagger by 80ms, **counted within their own group**, never across the page.

### Transition language
- Content swaps (demo tabs): outgoing content disappears instantly; incoming content rises 8px and fades in over 450ms. No crossfade overlap, so the change reads as crisp.
- No page transitions or section-to-section wipes. Sections simply arrive as you scroll.

### Interaction language
- Hover = **border brightens** (#262626 → #464646) plus a small lift (max 3px) on cards. Never scale whole cards up.
- Links: arrow moves 4px right.
- Press: button moves 1px down.
- Nothing follows the cursor except the hero polygon's slight parallax.

### Parallax intensity
Hero polygon only, max **8px**, smoothed (it eases toward the pointer, never jumps). Off on touch devices.

### Spatial behavior
Flat and frontal. Depth comes from blur duplicates and glow, not 3D camera moves or perspective tilt.

### Typography motion
- Headlines: **[PROPOSED]** line-by-line reveal (see §3, H2).
- Body copy: shared reveal only. Text never animates letter by letter, except code in product mockups, where typing *is* the story.

### Responsive motion rules
| | Desktop (≥961px) | Tablet (641–960px) | Phone (≤640px) |
|---|---|---|---|
| Polygon | All rings + blurred duplicates | All rings | Crisp rings + beams only, no blurred duplicates |
| Parallax | On (fine pointer only) | Off | Off |
| Demo typing + tab rotation | On | On | On |
| Reveals | On | On | On, 12px rise instead of 16px |
| Card hover lift | On | Off (touch) | Off |

### Reduced motion (`prefers-reduced-motion: reduce`)
All loops stop, the polygon shows a still frame with one beam segment visible, code appears fully written, charts show final values, and reveals become instant. Already implemented; keep it.

---

## 2. Audit of current motion: USE / ADAPT / TRANSFORM / IGNORE

| # | Current motion | Decision | Priority | Notes |
|---|---|---|---|---|
| A1 | Hero polygon: 5 rings rotating at different speeds | **ADAPT** | ESSENTIAL | Slow everything ~25% so it reads as calm, not busy. Keep the center hollow. |
| A2 | Spectral beams travelling around rings | **USE** | ESSENTIAL | This is the signature motion. |
| A3 | Blurred duplicate rings rotating | **ADAPT** | ESSENTIAL | **Performance problem:** rotating an SVG group that contains an SVG blur filter makes the browser redraw the blur every frame. Move the blurred layer into its own `<svg>` element blurred with a CSS `filter`, and rotate that element itself so the graphics card can handle it. |
| A4 | Hero art entrance (scale + rotate in) | **USE** | ESSENTIAL | Duration → `--t-hero`, easing → `--ease-out`. |
| A5 | Pointer parallax (12px, instant) | **ADAPT** | OPTIONAL | Reduce to 8px and add smoothing (easing toward the target each frame). Currently it jumps. |
| A6 | Announcement-bar orange pulse | **ADAPT** | OPTIONAL | Orange is reserved for links and arrows. Make the dot Cloud White with a soft white pulse, or keep orange as a deliberate single exception. |
| A7 | Demo frame spectral top edge | **USE** | ESSENTIAL | Fits "light means activity." |
| A8 | Code typing in demo | **USE** | ESSENTIAL | The product proof. Keep typing speed under ~3s total. |
| A9 | Demo tabs auto-rotate every 7s | **ADAPT** | ESSENTIAL | Content changes with no visible reason. Needs a timer indicator (see H3), a pause on hover, and a pause when off-screen. |
| A10 | Merge-queue running bars (spectral sweep) | **USE** | ESSENTIAL | Textbook "light means activity." |
| A11 | AI typing dots | **USE** | OPTIONAL | |
| A12 | Card hover lift + logo scale | **USE** | OPTIONAL | Lift only on hover-capable devices. |
| A13 | Carousel smooth scroll | **USE** | ESSENTIAL | |
| A14 | CLI lines appear in sequence | **USE** | ESSENTIAL | |
| A15 | Bar chart grows on reveal | **USE** | OPTIONAL | Switch to `--ease-out`. |
| A16 | Card reveal stagger | **ADAPT** | ESSENTIAL | **Bug:** stagger is counted across all page elements, so card delays are inconsistent. Count per group. |
| A17 | Ambient loops run off-screen | **ADAPT** | ESSENTIAL | Pause polygon, beams and demo loops when not visible (saves battery on phones). |

---

## 3. Proposed additions

### H1 [PROPOSED]: Pause-when-hidden for all ambient motion
- **Why:** Loops currently run even when scrolled away or when the tab is in the background.
- **Problem solved:** Battery and processor use on phones and low-end laptops.
- **Fit:** Invisible to the user, protects the "precise" feel (no stutter).
- **Risk:** Very low.
- **Priority:** ESSENTIAL

### H2 [PROPOSED]: Headline line reveal
- **Design decision:** Each line of the hero headline rises out of a clipped line box, 80ms apart. The subline, buttons and note follow on the same rhythm.
- **Experience intent:** The headline lands like a terminal printing output: ordered and exact. It sets the "instrument" tone in the first second.
- **Motion spec:** Each line moves from 100% → 0% Y inside an `overflow: hidden` line wrapper, 700ms `--ease-out`. Line 1 at 200ms, line 2 at 280ms, line 3 at 360ms; lead text at 500ms; buttons at 600ms. Polygon entrance runs in parallel from 0ms.
- **Risk:** Low. Lines must be wrapped by hand (three `<span>`s) because automatic line detection breaks when the text wraps differently on phones. On phones, reveal the whole headline as one block.
- **Priority:** OPTIONAL

### H3 [PROPOSED]: Tab progress line (spectral timer)
- **Design decision:** The active demo tab shows a 1px Solar Spectrum line along its bottom edge that fills left to right over 7s. When full, the next tab activates.
- **Experience intent:** It explains *why* the content changes and invites a click. It also applies "light means activity" directly.
- **Motion spec:** `scaleX` 0 → 1, 7000ms `linear`, `transform-origin: left`. Hover on the demo pauses the timer. A click stops auto-rotation for good and hides the line.
- **Risk:** Low.
- **Priority:** ESSENTIAL (fixes a real usability gap in A9)

### H4 [PROPOSED]: Light hand-off from hero to demo
- **Design decision:** As the user scrolls from the hero into the demo, the polygon rings spread slightly apart and fade, while the demo frame's top-edge light becomes brighter. Light visibly "moves" from the brand mark into the product.
- **Experience intent:** It ties the abstract hero to the concrete product: the glow you saw *is* the product running.
- **Motion spec:** Driven by scroll position (not time) over the first 60% of the viewport height. Rings scale 1 → 1.08 with staggered rotation offsets; polygon opacity 1 → 0.35; demo top edge opacity 0.5 → 1.
- **Technology:** CSS scroll-driven animations (`animation-timeline: view()`) as progressive enhancement. Browsers without support simply show the static state.
- **Risk:** Medium. Scroll-linked effects can feel heavy if overdone, and browser support is still uneven.
- **Priority:** EXPERIMENTAL (prototype first, keep only if it feels calm)

### H5 [PROPOSED]: CTA polygon responds to the main button
- **Design decision:** Hovering "Start for free" in the closing CTA makes the beam travel 2× faster and brighten.
- **Experience intent:** A small reward that ties the call to action to the system "starting up."
- **Risk:** Low.
- **Priority:** OPTIONAL

---

## 4. Rejected patterns

| Pattern | Why rejected |
|---|---|
| WebGL / Three.js 3D scene | Heavy, slow on phones, and against the flat, frontal spatial language. The SVG polygon already delivers the glow. |
| Smooth-scroll / scroll-jacking libraries | Takes control away from developers, who are the audience. Feels un-tool-like. |
| Custom cursor / magnetic buttons | Decorative. Conflicts with "precise instrument." |
| Page or section wipe transitions | Adds wait time and no meaning on a single page. |
| Spring / bounce easing | Playful tone. Wrong personality. |
| Animated gradient backgrounds on sections | DESIGN.md forbids broad color bands; the gradient is reserved for linework. |

---

## 5. Implementation handoff

| | |
|---|---|
| **Technology** | Plain CSS animations + vanilla JS + `IntersectionObserver`. **No GSAP needed**: the motion is simple, and avoiding a library keeps the page fast. CSS scroll-driven animations only for the experimental H4. |
| **Easing/timing** | Add the tokens from §1 to `:root` and replace all hard-coded durations and curves with them. |
| **Animate only** | `transform`, `opacity`, `stroke-dashoffset`. Never animate width, height, top/left, or box-shadow in loops. |
| **SVG filters** | Never rotate or move an element *inside* an SVG that has a blur filter. Move the element that carries the filter instead (see A3). |
| **Visibility** | One shared `IntersectionObserver` toggles a `.is-paused` class (`animation-play-state: paused`) on the hero, demo and CTA. Also pause on `visibilitychange`. |
| **Stagger** | Compute delays per group using `--i` set on each child. |
| **Responsive** | Follow the table in §1. Detect hover devices with `(hover: hover) and (pointer: fine)`. |
| **Reduced motion** | Keep the current global override, and make sure H2–H5 respect it. |

### Performance budget
- Smooth 60fps scrolling on a mid-range Android phone (test with 4× CPU slowdown in Chrome DevTools).
- No layout shifts caused by animation (CLS = 0 from motion).
- Zero added JavaScript libraries.

### Quality bar
It should feel like opening a premium developer tool: quiet, exact, and clearly *on*. If someone can name more than three things moving at once on any screen, there's too much motion. When in doubt, slow it down and remove it.

---

## 6. Project knowledge update (candidate, not yet approved)

All items below are **CANDIDATE** knowledge. They become trusted patterns only after they are built, tested on real devices, and reused successfully.

- **New pattern: "Light means activity."** A single accent gradient reserved for in-progress states gives motion meaning and keeps color disciplined. Reusable for any SaaS or product site with a signature accent.
- **New pattern: Spectral timer on auto-rotating tabs.** Solves the "content changes by itself" problem in product demos.
- **Performance lesson:** Rotating SVG groups that contain blur filters forces the blur to be redrawn every frame. Move the filtered element itself with a CSS transform instead.
- **Implementation lesson:** Compute stagger delays per group, not with a page-wide index.
- **Responsive lesson:** Drop blurred duplicate layers on phones first. They cost the most and add the least at small sizes.
- **Creative lesson:** A style reference with no motion analysis gives visual principles, not timings. Always mark motion derived from it as INFERRED.
