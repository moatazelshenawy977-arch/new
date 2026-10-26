# NILE.LAB: fidelity notes

**Mode:** Reference. The design system and experience of https://exp.fiddle.digital/ are rebuilt with a placeholder brand (NILE.LAB, AI and automation for real estate and sales). No original text, logo, fonts, images or 3D assets are used.

## How to run
```
npm install
npm run dev      # development
npm run build    # production build in dist/
```

## Matches (taken from the page's HTML and CSS)
- Colour tokens: black #101214, red #ff4f36, green #0f7f69, yellow #f4ff1e, blue #3687ff, berry #c8c2cf, grey #e6dfe4.
- Type scale ratio 1.333, base 1rem, tight negative letter-spacing, mono UI labels in uppercase.
- Easings: cubic(.22,.31,0,1), cubic-in(.69,0,0,1), smooth(.5,0,.3,1).
- 14-column grid on desktop, 6 on mobile; fixed header and footer labels; vertical progress line.
- Splash: 10x10 black grid that dissolves in random order.
- Footer colour themes (Black, Red, Green, Yellow, Blue) recolour all UI and the cube.
- List / Grid toggle; cookie dialog (light theme, 540px max).

## Approximated (observed, not measured live)
- Card shader: bend, velocity skew, RGB split and glitch bands are tuned by eye. The original uses its own glitch shaders.
- Background gradient is four blurred colour blobs, matched by eye to one screenshot.
- Scroll feel (inertia 0.085, wheel x1.1, drag x1.4) is a guess.
- The detail panel is simplified. The grid view (4x2 desktop, 2x4 phone) blends smoothly with the carousel but is my own design, not copied from the original.

## Not available from outside
- Licensed fonts (KH Teka, KH Teka Mono): replaced with Space Grotesk, JetBrains Mono (open licence).
- Original media, 3D models, sound effects (the sfx toggle is visual only), exact shader source.
- The original home page loads its cards at runtime. A live capture (hover states, scroll timelines, network list) was not possible because the sandbox blocked the host, so motion values above are estimates.

## Assets and licences
- Card photos: Unsplash (Unsplash License, free for commercial use). Linked directly from images.unsplash.com; see `src/cards.js`. Replace with your own images before launch if you want full control.
- Fonts via Google Fonts: Space Grotesk, JetBrains Mono, Manrope, Noto Sans JP (SIL OFL).
- Analytics and tracking from the original are not included.

## To do before launch
- Rename the brand, email and about text in `src/brand.js`; edit the 8 service cards in `src/cards.js`.
- Host fonts and images yourself for speed and privacy.
- Test on a mid-range phone; the 3D pixel ratio is already capped at 2.

## Property listings
- `src/cards.js` holds 8 SAMPLE listings (made-up names, prices and details). Replace with real inventory before launch.
- `src/brand.js` has the WhatsApp number (`whatsapp`, international format) and email. Both are placeholders.
- Listing photos are Unsplash images and may not match the listed property. Use your own photos for real listings.

## Features added in the final pass
- Country filter (All / Egypt / Saudi Arabia / UAE) that reshapes both the carousel and the grid.
- English / Arabic switch (UI, listing text, WhatsApp messages, cookie notice). Remembers the visitor's choice.
- "Let's talk" form: name, phone and what they need, sent as a WhatsApp message to your number in `src/brand.js`. There is no server; nothing is stored.
- Sample prices were calibrated to public 2026 market averages (Global Property Guide, Tranio, Engel & Voelkers). They are still demo values, not offers.

## Publish
`npm run build` creates `dist/`. Upload that folder to any static host (Netlify, Vercel, GitHub Pages, Cloudflare Pages). No server is needed.
