(() => {
  const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  /* ---------- Mobile menu ---------- */
  const menuBtn = document.getElementById('menuBtn');
  const navLinks = document.getElementById('navLinks');
  menuBtn.addEventListener('click', () => {
    const open = navLinks.classList.toggle('is-open');
    menuBtn.setAttribute('aria-expanded', String(open));
  });
  navLinks.querySelectorAll('a').forEach(a => a.addEventListener('click', () => {
    navLinks.classList.remove('is-open');
    menuBtn.setAttribute('aria-expanded', 'false');
  }));

  /* ---------- Scroll reveal ---------- */
  const io = new IntersectionObserver(entries => {
    entries.forEach(e => {
      if (!e.isIntersecting) return;
      e.target.classList.add('is-in');
      e.target.querySelectorAll('.cli, .bars').forEach(el => el.classList.add('is-in'));
      if (e.target.id === 'demo') startTyping();
      io.unobserve(e.target);
    });
  }, { threshold: 0.15 });
  document.querySelectorAll('.reveal').forEach((el, i) => {
    if (el.classList.contains('story')) el.style.transitionDelay = `${(i % 3) * 80}ms`;
    io.observe(el);
  });

  /* ---------- Diff typing animation ---------- */
  const lines = [
    ['', '<span class="k">import</span> { useMemo } <span class="k">from</span> <span class="s">"react"</span>;'],
    ['', '<span class="k">import</span> { useInvoices } <span class="k">from</span> <span class="s">"./useInvoices"</span>;'],
    ['', ''],
    ['', '<span class="k">export function</span> <span class="f">InvoiceList</span>({ sortKey }) {'],
    ['', '  <span class="k">const</span> invoices = <span class="f">useInvoices</span>();'],
    ['del', '-  <span class="k">const</span> rows = invoices.<span class="f">sort</span>(byKey(sortKey));'],
    ['add', '+  <span class="k">const</span> rows = <span class="f">useMemo</span>('],
    ['add', '+    () =&gt; [...invoices].<span class="f">sort</span>(<span class="f">byKey</span>(sortKey)),'],
    ['add', '+    [invoices, sortKey]'],
    ['add', '+  );'],
    ['', ''],
    ['', '  <span class="k">return</span> &lt;<span class="f">Table</span> rows={rows} empty=<span class="s">"No invoices yet"</span> /&gt;;'],
    ['', '}'],
  ];
  const diffEl = document.getElementById('diffCode');
  const lineHTML = (l, i) =>
    `<span class="ln ${l[0] === 'add' ? 'add-l' : l[0] === 'del' ? 'del-l' : ''}"><i>${i + 1}</i>${l[1] || ' '}</span>`;
  let typed = false;
  function startTyping() {
    if (typed) return;
    typed = true;
    if (reduceMotion) { diffEl.innerHTML = lines.map(lineHTML).join(''); return; }
    let i = 0;
    const step = () => {
      if (i > lines.length) return;
      diffEl.innerHTML = lines.slice(0, i).map(lineHTML).join('') +
        (i < lines.length ? '<span class="ln"><i>' + (i + 1) + '</i><span class="cursor"></span></span>' : '');
      i++;
      setTimeout(step, i < 6 ? 140 : 220);
    };
    step();
  }
  diffEl.innerHTML = '';

  /* ---------- Demo tabs (auto-rotating until user interacts) ---------- */
  const tabs = [...document.querySelectorAll('.tab')];
  const panels = [...document.querySelectorAll('.panel')];
  const showTab = name => {
    tabs.forEach(t => {
      const on = t.dataset.tab === name;
      t.classList.toggle('is-active', on);
      t.setAttribute('aria-selected', String(on));
    });
    panels.forEach(p => p.classList.toggle('is-shown', p.dataset.panel === name));
  };
  let auto = null;
  tabs.forEach(t => t.addEventListener('click', () => { clearInterval(auto); showTab(t.dataset.tab); }));
  if (!reduceMotion) {
    let idx = 0;
    auto = setInterval(() => {
      idx = (idx + 1) % tabs.length;
      showTab(tabs[idx].dataset.tab);
    }, 7000);
  }

  /* ---------- Customer carousel ---------- */
  const carousel = document.getElementById('carousel');
  const page = dir => {
    const card = carousel.querySelector('.story');
    const step = card.getBoundingClientRect().width + 16;
    const max = carousel.scrollWidth - carousel.clientWidth;
    let target = carousel.scrollLeft + dir * step;
    if (target > max + 4) target = 0;
    if (target < -4) target = max;
    carousel.scrollTo({ left: target, behavior: reduceMotion ? 'auto' : 'smooth' });
  };
  document.getElementById('prevBtn').addEventListener('click', () => page(-1));
  document.getElementById('nextBtn').addEventListener('click', () => page(1));

  /* ---------- Subtle parallax on hero polygon ---------- */
  const art = document.querySelector('.hero__art .polygon');
  if (!reduceMotion && art && window.matchMedia('(pointer: fine)').matches) {
    window.addEventListener('pointermove', e => {
      const x = (e.clientX / window.innerWidth - 0.5) * 12;
      const y = (e.clientY / window.innerHeight - 0.5) * 12;
      art.style.transform = `translate(${x}px, ${y}px)`;
    }, { passive: true });
  }
})();
