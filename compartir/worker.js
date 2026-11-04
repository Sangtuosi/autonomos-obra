// Cloudflare Worker: devuelve una página con foto y título del perfil para que
// WhatsApp muestre una tarjeta bonita, y después lleva a la web.
const SB = 'https://seezeqqtddffxqsbjhrj.supabase.co';
const KEY = 'sb_publishable_voo3MNUbTFUzHaFAvTtJew_99iyqgBw'; // clave pública
const SITE = 'https://sangtuosi.github.io/autonomos-obra/';
const esc = s => String(s ?? '').replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

export default {
  async fetch(req) {
    const u = new URL(req.url);
    const id = u.searchParams.get('p') || u.pathname.split('/').filter(Boolean).pop() || '';
    if (!/^[0-9a-f-]{36}$/i.test(id)) return Response.redirect(SITE, 302);
    let p = null;
    try {
      const r = await fetch(`${SB}/rest/v1/profiles?id=eq.${id}&select=name,trade,zone,years,bio,photos`, { headers: { apikey: KEY } });
      const rows = await r.json();
      p = Array.isArray(rows) ? rows[0] : null;
    } catch (e) {}
    const dest = `${SITE}?p=${id}`;
    const title = p ? `${p.name} · ${p.trade} en ${p.zone}` : 'Obra Directa';
    const desc = p ? `${p.years || 0} años de experiencia. ${(p.bio || 'Mira su perfil con fotos de trabajos.').slice(0, 140)}` : 'Autónomos de obra, sin intermediarios.';
    const img = (p && p.photos && p.photos[0]) || SITE + 'icon-512.png';
    const html = `<!doctype html><html lang="es"><head><meta charset="utf-8"><title>${esc(title)}</title>
<meta property="og:type" content="profile"><meta property="og:site_name" content="Obra Directa">
<meta property="og:title" content="${esc(title)}"><meta property="og:description" content="${esc(desc)}">
<meta property="og:image" content="${esc(img)}"><meta property="og:url" content="${esc(dest)}">
<meta name="twitter:card" content="summary_large_image"><meta name="description" content="${esc(desc)}">
<meta http-equiv="refresh" content="0;url=${esc(dest)}"></head>
<body><script>location.replace(${JSON.stringify(dest)})</script><a href="${esc(dest)}">Ver perfil</a></body></html>`;
    return new Response(html, { headers: { 'content-type': 'text/html; charset=utf-8', 'cache-control': 'public, max-age=300' } });
  }
};
