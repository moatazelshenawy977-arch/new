import './style.css';
import * as THREE from 'three';
import { gsap } from 'gsap';
import { CARDS } from './cards.js';
import { BRAND } from './brand.js';
import { STR } from './i18n.js';

const $ = (s) => document.querySelector(s);
const root = document.documentElement;
const canvas = $('#gl');
const reduced = matchMedia('(prefers-reduced-motion: reduce)').matches;
const lerp = (a, b, t) => a + (b - a) * t;
const clamp = (v, a, b) => Math.min(b, Math.max(a, v));

/* ---------- renderer / camera (1 world unit = 1 CSS px) ---------- */
let renderer;
try {
  renderer = new THREE.WebGLRenderer({ canvas, alpha: true, antialias: true });
} catch (e) {
  document.body.classList.add('no-webgl'); // static gradient + labels remain
}
const scene = new THREE.Scene();
const FOV = 35;
const camera = new THREE.PerspectiveCamera(FOV, 1, 10, 6000);
let W = innerWidth, H = innerHeight;

function resize() {
  W = innerWidth; H = innerHeight;
  if (!renderer) return;
  renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
  renderer.setSize(W, H, false);
  camera.aspect = W / H;
  camera.position.z = H / 2 / Math.tan((FOV * Math.PI) / 360);
  camera.updateProjectionMatrix();
  layout();
}

/* ---------- card shader: bend, velocity skew, RGB split, rounded corners ---------- */
const vert = /* glsl */`
  uniform float uVel; uniform float uBend; uniform float uHover;
  varying vec2 vUv;
  void main() {
    vUv = uv;
    vec3 p = position;
    float wx = (modelMatrix * vec4(p, 1.0)).x;
    p.z -= pow(abs(wx) / 520.0, 2.0) * 120.0 * uBend;
    p.y += (uv.x - 0.5) * uVel * 0.06;
    p.xy *= 1.0 + uHover * 0.04;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(p, 1.0);
  }`;
const frag = /* glsl */`
  precision highp float;
  uniform sampler2D uTex; uniform vec2 uRes; uniform vec2 uImg;
  uniform float uVel; uniform float uHover; uniform float uAlpha; uniform float uTime;
  varying vec2 vUv;
  float sdBox(vec2 p, vec2 b, float r) { vec2 q = abs(p) - b + r; return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r; }
  void main() {
    // cover-fit the image inside the card
    float ra = uRes.x / uRes.y, ia = uImg.x / uImg.y;
    vec2 uv = vUv - 0.5;
    uv *= ra > ia ? vec2(1.0, ia / ra) : vec2(ra / ia, 1.0);
    uv += 0.5;
    float split = (abs(uVel) * 0.012 + uHover * 0.004);
    float g = step(0.97, fract(sin(floor(vUv.y * 40.0 + uTime * 8.0) * 91.3) * 437.5)) * abs(uVel) * 0.02;
    vec4 c;
    c.r = texture2D(uTex, uv + vec2(split + g, 0.0)).r;
    c.g = texture2D(uTex, uv).g;
    c.b = texture2D(uTex, uv - vec2(split + g, 0.0)).b;
    c.a = 1.0;
    float d = sdBox((vUv - 0.5) * uRes, uRes * 0.5, 6.0);
    float a = 1.0 - smoothstep(-1.0, 1.0, d);
    c.rgb = mix(c.rgb * 0.92, c.rgb * 1.05, uHover);
    gl_FragColor = vec4(c.rgb, a * uAlpha);
  }`;

/* ---------- placeholder art (used until the photo loads, or if it fails) ---------- */
function artTexture(card, i) {
  const c = document.createElement('canvas');
  c.width = 512; c.height = 720;
  const x = c.getContext('2d');
  const g = x.createLinearGradient(0, 0, 512, 720);
  g.addColorStop(0, card.art[0]); g.addColorStop(1, card.art[1]);
  x.fillStyle = g; x.fillRect(0, 0, 512, 720);
  x.globalAlpha = 0.35; x.fillStyle = '#fff';
  for (let k = 0; k < 5; k++) {
    x.beginPath();
    x.arc(((i * 97 + k * 131) % 512), ((i * 53 + k * 173) % 720), 60 + k * 38, 0, Math.PI * 2);
    x.fill();
  }
  const t = new THREE.CanvasTexture(c);
  t.colorSpace = THREE.SRGBColorSpace;
  return t;
}

/* ---------- build cards ---------- */
const CARD_W_RATIO = 0.72; // width / height
const group = new THREE.Group();
scene.add(group);
const loader = new THREE.TextureLoader();
loader.setCrossOrigin('anonymous');

const items = CARDS.map((card, i) => {
  const uniforms = {
    uTex: { value: artTexture(card, i) },
    uRes: { value: new THREE.Vector2(300, 420) },
    uImg: { value: new THREE.Vector2(512, 720) },
    uVel: { value: 0 }, uBend: { value: 1 }, uHover: { value: 0 }, uAlpha: { value: 0 }, uTime: { value: 0 },
  };
  const mat = new THREE.ShaderMaterial({ uniforms, vertexShader: vert, fragmentShader: frag, transparent: true });
  const mesh = new THREE.Mesh(new THREE.PlaneGeometry(1, 1, 24, 1), mat);
  mesh.userData.i = i;
  group.add(mesh);
  if (card.image) {
    loader.load(card.image, (t) => {
      t.colorSpace = THREE.SRGBColorSpace;
      t.anisotropy = 4;
      uniforms.uTex.value = t;
      uniforms.uImg.value.set(t.image.width, t.image.height);
    }, undefined, () => { /* keep generated art */ });
  }
  return { card, mesh, u: uniforms, x: 0, y: 0, tx: 0, ty: 0, hover: 0, w: 300, h: 420 };
});

/* ---------- 3D logo cube ---------- */
const cube = new THREE.Group();
const edge = new THREE.LineSegments(
  new THREE.EdgesGeometry(new THREE.BoxGeometry(1, 1, 1)),
  new THREE.LineBasicMaterial({ color: 0x101214 })
);
const glass = new THREE.Mesh(
  new THREE.BoxGeometry(1, 1, 1),
  new THREE.MeshBasicMaterial({ color: 0xffffff, transparent: true, opacity: 0.22 })
);
const crossMat = new THREE.MeshBasicMaterial({ color: 0x101214 });
const bar1 = new THREE.Mesh(new THREE.BoxGeometry(0.62, 0.16, 0.16), crossMat);
const bar2 = new THREE.Mesh(new THREE.BoxGeometry(0.16, 0.62, 0.16), crossMat);
const bar3 = new THREE.Mesh(new THREE.BoxGeometry(0.16, 0.16, 0.62), crossMat);
cube.add(glass, edge, bar1, bar2, bar3);
scene.add(cube);

/* ---------- language + country filter ---------- */
let lang = 'en', filter = 'all';
try { lang = localStorage.getItem('nile-lang') || ((navigator.language || '').startsWith('ar') ? 'ar' : 'en'); } catch {}
const T = (k) => STR[lang][k];
const L = (i) => (lang === 'ar' ? { ...CARDS[i], ...CARDS[i].ar } : CARDS[i]);
let vis = items.slice(); // cards that pass the current filter, in order
items.forEach((it) => { it.on = 1; it.vi = 0; });
function applyFilter() {
  vis = items.filter((it) => filter === 'all' || it.card.country === filter);
  items.forEach((it) => { it.on = vis.includes(it) ? 1 : 0; });
  vis.forEach((it, k) => { it.vi = k; });
  target = pos = 0; closePanel();
}

/* ---------- layout (list = curved carousel, grid = compact grid) ---------- */
let mode = 'list';
let gridMix = 0; // 0 = carousel, 1 = grid; every card blends by this one value
let GAP = 40, CW = 300, CH = 420;
function layout() {
  CH = clamp(H * 0.42, 240, 520);
  CW = CH * CARD_W_RATIO;
  GAP = clamp(W * 0.022, 16, 48);
  cube.scale.setScalar(clamp(H * (W < 700 ? 0.06 : 0.09), 44, 96));
  cube.position.set(W < 700 ? W * 0.3 : 0, W < 700 ? -H * 0.36 : -H * 0.3, 40);
  items.forEach((it) => { it.w = CW; it.h = CH; it.u.uRes.value.set(CW, CH); it.mesh.scale.set(CW, CH, 1); });
}
const STEP = () => CW + GAP;
const TOTAL = () => STEP() * Math.max(1, vis.length);

/* ---------- scroll physics (wheel + drag + touch, with inertia) ---------- */
let target = 0, pos = 0, vel = 0, dragging = false, lastX = 0, activeIdx = 0, moved = 0;
addEventListener('wheel', (e) => {
  if (panelOpen) return;
  target += (Math.abs(e.deltaX) > Math.abs(e.deltaY) ? e.deltaX : e.deltaY) * 1.1;
}, { passive: true });
canvas.addEventListener('pointerdown', (e) => { dragging = true; lastX = e.clientX; moved = 0; canvas.setPointerCapture(e.pointerId); canvas.classList.add('-drag'); });
canvas.addEventListener('pointermove', (e) => {
  pointer.set((e.clientX / W) * 2 - 1, -(e.clientY / H) * 2 + 1);
  if (dragging) { const dx = e.clientX - lastX; lastX = e.clientX; target -= dx * 1.4; moved += Math.abs(dx); }
});
const endDrag = () => { dragging = false; canvas.classList.remove('-drag'); };
canvas.addEventListener('pointerup', (e) => { endDrag(); if (moved < 5) pick(e); });
canvas.addEventListener('pointercancel', endDrag);
addEventListener('keydown', (e) => {
  if (e.key === 'ArrowRight') target += STEP();
  if (e.key === 'ArrowLeft') target -= STEP();
  if (e.key === 'Escape') closePanel();
});

/* ---------- hover + click ---------- */
const ray = new THREE.Raycaster();
const pointer = new THREE.Vector2(9, 9);
let hovered = -1;
function hit() {
  ray.setFromCamera(pointer, camera);
  const h = ray.intersectObjects(vis.map((it) => it.mesh))[0];
  return h ? h.object.userData.i : -1;
}
function pick() {
  const i = hit();
  if (i >= 0) openPanel(i);
}

/* ---------- panel ---------- */
let panelOpen = false;
function showPanel() { $('#panel').classList.add('-open'); $('#panel').setAttribute('aria-hidden', 'false'); panelOpen = true; }
function openPanel(i) {
  const c = L(i);
  $('#lead').hidden = true;
  $('#pTitle').textContent = c.title;
  $('#pText').textContent = c.text;
  const facts = [[T('price'), c.price], [T('type'), c.type], [T('size'), c.size], [T('bb'), c.beds === 0 ? `${T('studio')} / ${c.baths}` : `${c.beds} / ${c.baths}`]];
  const dl = $('#pFacts'); dl.replaceChildren();
  facts.forEach(([k, v]) => { const d = document.createElement('div'); const dt = document.createElement('dt'); const dd = document.createElement('dd'); dt.textContent = k; dd.textContent = v; d.append(dt, dd); dl.appendChild(d); });
  const cta = $('#pCta'); cta.hidden = false; cta.textContent = T('cta');
  cta.href = `https://wa.me/${BRAND.whatsapp}?text=${encodeURIComponent(STR[lang].hello(c.title, c.tag, c.price))}`;
  $('#pMeta').textContent = `${String(i + 1).padStart(2, '0')} / ${String(CARDS.length).padStart(2, '0')} — ${c.tag} — ${T('sample')}`;
  panelState = { kind: 'property', i };
  showPanel();
}
let panelState = null;
function closePanel() { $('#panel').classList.remove('-open'); $('#panel').setAttribute('aria-hidden', 'true'); panelOpen = false; panelState = null; }
$('#close').addEventListener('click', closePanel);
function openAbout() {
  $('#lead').hidden = true; $('#pCta').hidden = true; $('#pFacts').replaceChildren();
  $('#pTitle').textContent = T('noAbout');
  $('#pText').textContent = lang === 'ar' ? BRAND.aboutAr : BRAND.about;
  $('#pMeta').textContent = `${BRAND.name} — ${BRAND.year}`;
  panelState = { kind: 'about' }; showPanel();
}
function openContact() {
  $('#pCta').hidden = true; $('#pFacts').replaceChildren();
  $('#pTitle').textContent = T('cTitle'); $('#pText').textContent = T('cText'); $('#pMeta').textContent = BRAND.name;
  $('#fName').placeholder = T('cName'); $('#fPhone').placeholder = T('cPhone'); $('#fWant').placeholder = T('cWant'); $('#fSend').textContent = T('cSend');
  $('#lead').hidden = false;
  panelState = { kind: 'contact' }; showPanel();
}
$('#aboutBtn').addEventListener('click', openAbout);
$('#talkBtn').addEventListener('click', openContact);
$('#lead').addEventListener('submit', (e) => {
  e.preventDefault();
  const n = $('#fName').value.trim(), ph = $('#fPhone').value.trim(), w = $('#fWant').value.trim();
  if (!n || !ph || !w) return;
  // show a real link instead of window.open, which pop-up blockers and embedded views refuse
  const cta = $('#pCta');
  cta.href = `https://wa.me/${BRAND.whatsapp}?text=${encodeURIComponent(STR[lang].cMsg(n, ph, w))}`;
  cta.textContent = T('cSend'); cta.hidden = false;
  e.target.reset(); $('#lead').hidden = true;
  $('#pText').textContent = T('cReady');
});

/* ---------- filters ---------- */
$('#filters').addEventListener('click', (e) => {
  const b = e.target.closest('button'); if (!b) return;
  filter = b.dataset.f;
  document.querySelectorAll('#filters button').forEach((x) => x.classList.toggle('-active', x === b));
  applyFilter();
});

/* ---------- language ---------- */
function applyLang() {
  root.lang = lang;
  $('#lang').textContent = lang === 'ar' ? 'EN' : 'AR';
  const [l, g] = document.querySelectorAll('#toggle span[data-mode]'); l.textContent = T('list'); g.textContent = T('grid');
  $('#aboutBtn').textContent = T('about'); $('#talkBtn').textContent = T('talk'); $('.hub').textContent = T('hub'); $('#close').textContent = T('close');
  document.querySelectorAll('#filters button').forEach((b) => { b.textContent = T(b.dataset.f); });
  const ck = $('#cookie'); if (ck) { ck.querySelector('b').textContent = T('cookieT'); ck.querySelector('p').textContent = T('cookieP'); const bs = ck.querySelectorAll('button'); bs[0].textContent = T('accept'); bs[1].textContent = T('reject'); }
  document.querySelector('meta[name="description"]').content = lang === 'ar' ? BRAND.descriptionAr : BRAND.description;
  document.title = `${BRAND.name} — ${lang === 'ar' ? BRAND.taglineAr : BRAND.tagline}`;
  activeIdx = -1;
  if (panelState?.kind === 'property') openPanel(panelState.i); else if (panelState?.kind === 'about') openAbout(); else if (panelState?.kind === 'contact') openContact();
}
$('#lang').addEventListener('click', () => { lang = lang === 'en' ? 'ar' : 'en'; try { localStorage.setItem('nile-lang', lang); } catch {} applyLang(); });

/* ---------- list / grid toggle ---------- */
$('#toggle').addEventListener('click', () => {
  mode = mode === 'list' ? 'grid' : 'list';
  document.querySelectorAll('#toggle span[data-mode]').forEach((s) => s.classList.toggle('-active', s.dataset.mode === mode));
});

/* ---------- colour themes ---------- */
$('#colours').addEventListener('click', (e) => {
  const b = e.target.closest('button'); if (!b) return;
  document.querySelectorAll('#colours button').forEach((x) => x.classList.toggle('-active', x === b));
  ['-red', '-green', '-yellow', '-blue'].forEach((c) => root.classList.remove(c));
  if (b.dataset.theme !== 'black') root.classList.add('-' + b.dataset.theme);
  const hex = { black: 0x101214, red: 0xff4f36, green: 0x0f7f69, yellow: 0x7d8400, blue: 0x3687ff }[b.dataset.theme];
  edge.material.color.setHex(hex); crossMat.color.setHex(hex);
});

/* ---------- sfx toggle (visual state only; add audio later) ---------- */
$('#sfx').addEventListener('click', (e) => e.currentTarget.setAttribute('aria-pressed', String(e.currentTarget.getAttribute('aria-pressed') !== 'true')));

/* ---------- cookie banner ---------- */
const cookie = $('#cookie');
try { if (localStorage.getItem('nile-cookie')) cookie.remove(); } catch {}
cookie.querySelectorAll('[data-c]').forEach((b) => b.addEventListener('click', () => {
  try { localStorage.setItem('nile-cookie', b.textContent); } catch {}
  cookie.classList.add('-leave'); setTimeout(() => cookie.remove(), 200);
}));

/* ---------- brand text ---------- */
$('.logo').textContent = BRAND.name; $('#title').textContent = CARDS[0].title;
$('.mark').textContent = BRAND.jp;
$('.year').textContent = `©${BRAND.year}`;
applyLang();

/* ---------- render loop ---------- */
const titleEl = $('#title'), progressEl = $('#progress');
const clock = new THREE.Clock();
let visible = true;
new IntersectionObserver((e) => { visible = e[0].isIntersecting; }).observe(canvas);
let entered = 0; // 0..1 intro progress

function frame() {
  requestAnimationFrame(frame);
  if (!renderer || !visible) return;
  const t = clock.getElapsedTime();

  const prev = pos;
  pos = lerp(pos, target, reduced ? 1 : 0.085);
  vel = lerp(vel, pos - prev, 0.2);
  const v = clamp(vel / 40, -1.5, 1.5);

  const step = STEP(), total = TOTAL(), n = vis.length;
  hovered = dragging || panelOpen ? hovered : hit();
  canvas.classList.toggle('-hover', hovered >= 0 && !dragging);

  gridMix = lerp(gridMix, mode === 'grid' ? 1 : 0, reduced ? 1 : 0.09);
  const small = W < 700;
  const cols = small ? 2 : Math.min(4, Math.max(1, n)), rows = Math.max(1, Math.ceil(n / cols));
  // scale the grid so all rows fit the viewport under the header and title
  const gridS = Math.min(((small ? H * 0.5 : H * 0.58) - GAP * (rows - 1)) / (rows * CH), (W * 0.9 - GAP * (cols - 1)) / (cols * CW), 0.62);
  const gw = CW * gridS + GAP * 0.6, gh = CH * gridS + GAP * 0.6;

  let nearest = 0, nearestD = 1e9;
  items.forEach((it) => {
    const i = it.vi;
    let lx = i * step - pos;
    lx = ((((lx + total / 2) % total) + total) % total) - total / 2;
    const gx = ((i % cols) - (cols - 1) / 2) * gw;
    const gy = (((rows - 1) / 2) - Math.floor(i / cols)) * gh + (small ? H * 0.06 : H * 0.02);
    it.x = lerp(lx, gx, gridMix);
    it.y = lerp(0, gy, gridMix);
    const sc = lerp(1, gridS, gridMix);
    it.mesh.scale.set(CW * sc, CH * sc, 1);
    it.mesh.position.set(it.x, it.y + (1 - entered) * -H * 0.3, 0);
    it.mesh.rotation.y = clamp(-it.x / 3200, -0.4, 0.4) * (1 - gridMix);
    it.hover = lerp(it.hover, hovered === i ? 1 : 0, 0.12);
    it.u.uHover.value = it.hover;
    it.u.uVel.value = v * (1 - gridMix);
    it.u.uBend.value = 1 - gridMix;
    it.u.uTime.value = t;
    it.on = vis.includes(it) ? 1 : 0;
    it.u.uAlpha.value = lerp(it.u.uAlpha.value, entered * it.on, 0.12);
    it.mesh.visible = it.u.uAlpha.value > 0.01;
    const d = it.on ? Math.abs(lx) : 1e9;
    if (d < nearestD) { nearestD = d; nearest = it.mesh.userData.i; }
  });
  const shown = hovered >= 0 ? hovered : nearest;
  if (shown !== activeIdx) { activeIdx = shown; titleEl.textContent = L(shown).title; }
  progressEl.style.setProperty('--p', String((((pos / total) % 1) + 1) % 1));

  cube.rotation.x = t * 0.5; cube.rotation.y = t * 0.7 + v * 2;
  renderer.render(scene, camera);
}

/* ---------- intro: 10x10 grid dissolve ---------- */
const splash = $('#splash'), sg = $('#splashGrid');
for (let i = 0; i < 100; i++) { const s = document.createElement('span'); sg.appendChild(s); }
function intro() {
  splash.classList.add('-in');
  const spans = [...sg.children];
  gsap.delayedCall(reduced ? 0 : 1.4, () => {
    splash.classList.add('-out'); root.classList.remove('-preload');
    gsap.to(spans, { opacity: 0, duration: 0.01, stagger: { each: 0.0075, from: 'random' }, onComplete: () => splash.classList.add('-gone') });
    gsap.to({ v: 0 }, { v: 1, duration: reduced ? 0.01 : 1.6, ease: 'expo.out', onUpdate() { entered = this.targets()[0].v; } });
  });
}

resize();
addEventListener('resize', resize);
frame();
intro();
