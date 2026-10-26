// Image slots. Unsplash photos (Unsplash License: free for commercial use, no permission needed).
// Swap `image` for your own assets at any time; `art` is the generated fallback if a link fails.
const U = (id) => `https://images.unsplash.com/photo-${id}?fm=jpg&q=80&w=900&h=1260&fit=crop&auto=format`;

export const CARDS = [
  { title: 'Liquid Signal',  tag: 'Shader / 2026', text: 'A fluid surface that reacts to the pointer and bends light across the screen.', image: U('1791960296842-2c748982383e'), art: ['#0f7f69', '#b8ecd8'] },
  { title: 'Soft Orbit',     tag: 'WebGL / 2026',  text: 'Objects drifting on slow orbits with depth of field and gentle parallax.',        image: U('1791960297289-903de2570d63'), art: ['#6a4cff', '#f1c4dc'] },
  { title: 'Glass Type',     tag: 'Type / 2026',   text: 'Letterforms refracted through a glass plane. Drag to rotate the lens.',          image: U('1791960467057-9de83e2f1286'), art: ['#3687ff', '#d3c2f5'] },
  { title: 'Pulse Grid',     tag: 'Motion / 2026', text: 'A grid that breathes with scroll velocity and sound.',                           image: U('1791960297015-3120d553e763'), art: ['#ff4f36', '#f1c4dc'] },
  { title: 'Night Garden',   tag: 'Scene / 2026',  text: 'A small 3D scene lit by moving points of light.',                                image: U('1791960297273-6c4a76657fde'), art: ['#101214', '#6a4cff'] },
  { title: 'Chroma Drift',   tag: 'Shader / 2026', text: 'Colour channels drifting apart under motion, then snapping back together.',      image: U('1791960466942-a056e967961a'), art: ['#f4ff1e', '#0f7f69'] },
  { title: 'Holo Paper',     tag: 'Material / 2026', text: 'Holographic foil that shifts with the camera angle.',                          image: U('1792121796712-4f8dcf54de70'), art: ['#9fb0f5', '#f1c4dc'] },
  { title: 'Deep Surface',   tag: 'Texture / 2026', text: 'A slow liquid surface in cyan and blue, built from layered noise.',             image: U('1784142269410-2b5ddb689a04'), art: ['#3687ff', '#b8ecd8'] },
];

export const CREDITS = 'Photos: Unsplash (Unsplash License). Fonts: Space Grotesk, JetBrains Mono, Manrope, Noto Sans JP (SIL OFL).';
