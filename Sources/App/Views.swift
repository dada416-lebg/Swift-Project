import Hummingbird

struct HTML: ResponseGenerator {
    let body: String
    func response(from request: Request, context: some RequestContext) throws -> Response {
        var headers = HTTPFields()
        headers[.contentType] = "text/html; charset=utf-8"
        return Response(status: .ok, headers: headers, body: .init(byteBuffer: .init(string: body)))
    }
}

// MARK: - Shared CSS & JS

private let sharedHead = """
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>GameTracker</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=SF+Pro+Display:wght@300;400;500;600;700&family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,400;0,9..40,500;0,9..40,600;1,9..40,300&display=swap" rel="stylesheet">
<style>
  :root {
    --bg: #f5f5f7;
    --surface: #ffffff;
    --surface2: #f2f2f2;
    --border: rgba(0,0,0,0.08);
    --text: #1d1d1f;
    --text2: #6e6e73;
    --text3: #aeaeb2;
    --accent: #0071e3;
    --accent-hover: #0077ed;
    --red: #ff3b30;
    --green: #34c759;
    --orange: #ff9f0a;
    --yellow: #ffd60a;
    --purple: #bf5af2;
    --shadow: 0 2px 16px rgba(0,0,0,0.07);
    --shadow-lg: 0 8px 40px rgba(0,0,0,0.10);
    --radius: 14px;
    --radius-sm: 10px;
    --radius-xs: 8px;
    --transition: 0.18s cubic-bezier(0.4,0,0.2,1);
  }
  [data-theme="dark"] {
    --bg: #000000;
    --surface: #1c1c1e;
    --surface2: #2c2c2e;
    --border: rgba(255,255,255,0.10);
    --text: #f5f5f7;
    --text2: #aeaeb2;
    --text3: #636366;
    --shadow: 0 2px 16px rgba(0,0,0,0.40);
    --shadow-lg: 0 8px 40px rgba(0,0,0,0.50);
  }
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
  html { font-size: 16px; -webkit-font-smoothing: antialiased; }
  body {
    font-family: 'DM Sans', -apple-system, BlinkMacSystemFont, sans-serif;
    background: var(--bg);
    color: var(--text);
    min-height: 100vh;
    transition: background var(--transition), color var(--transition);
  }

  /* NAV */
  nav {
    position: sticky; top: 0; z-index: 100;
    background: rgba(255,255,255,0.82);
    backdrop-filter: saturate(180%) blur(20px);
    -webkit-backdrop-filter: saturate(180%) blur(20px);
    border-bottom: 1px solid var(--border);
    padding: 0 24px;
    height: 56px;
    display: flex; align-items: center; justify-content: space-between;
    transition: background var(--transition);
  }
  [data-theme="dark"] nav {
    background: rgba(28,28,30,0.82);
  }
  .nav-brand {
    font-family: 'DM Sans', sans-serif;
    font-weight: 700;
    font-size: 1.1rem;
    letter-spacing: -0.02em;
    color: var(--text);
    text-decoration: none;
  }
  .nav-brand span { color: var(--accent); }
  .nav-right { display: flex; align-items: center; gap: 12px; }

  /* BUTTONS */
  .btn {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 8px 18px;
    border-radius: 980px;
    font-family: inherit; font-size: 0.875rem; font-weight: 500;
    cursor: pointer; border: none; text-decoration: none;
    transition: all var(--transition);
    white-space: nowrap;
  }
  .btn-primary { background: var(--accent); color: #fff; }
  .btn-primary:hover { background: var(--accent-hover); transform: scale(1.02); }
  .btn-secondary {
    background: var(--surface2); color: var(--text);
    border: 1px solid var(--border);
  }
  .btn-secondary:hover { background: var(--border); }
  .btn-danger { background: transparent; color: var(--red); border: 1px solid var(--red); }
  .btn-danger:hover { background: var(--red); color: #fff; }
  .btn-sm { padding: 5px 12px; font-size: 0.8rem; }
  .btn-icon {
    padding: 8px;
    background: var(--surface2);
    border: 1px solid var(--border);
    border-radius: 980px;
    cursor: pointer;
    font-size: 1rem;
    line-height: 1;
    color: var(--text);
    transition: all var(--transition);
  }
  .btn-icon:hover { background: var(--border); }

  /* LAYOUT */
  .page { max-width: 1100px; margin: 0 auto; padding: 32px 24px; }

  /* STATS */
  .stats-grid {
    display: grid;
    grid-template-columns: repeat(5, 1fr);
    gap: 12px;
    margin-bottom: 28px;
  }
  @media (max-width: 800px) { .stats-grid { grid-template-columns: repeat(2, 1fr); } }
  .stat-card {
    background: var(--surface);
    border-radius: var(--radius);
    padding: 20px;
    box-shadow: var(--shadow);
    border: 1px solid var(--border);
    transition: box-shadow var(--transition), transform var(--transition);
  }
  .stat-card:hover { box-shadow: var(--shadow-lg); transform: translateY(-2px); }
  .stat-number { font-size: 2rem; font-weight: 700; letter-spacing: -0.04em; line-height: 1; }
  .stat-label { font-size: 0.78rem; color: var(--text2); margin-top: 4px; font-weight: 500; display: flex; align-items: center; gap: 4px; }

  /* FILTERS */
  .filters-bar {
    display: flex; align-items: center; gap: 10px;
    flex-wrap: wrap;
    margin-bottom: 20px;
  }
  .filter-pills { display: flex; gap: 6px; flex-wrap: wrap; }
  .pill {
    padding: 6px 14px;
    border-radius: 980px;
    font-size: 0.82rem; font-weight: 500;
    background: var(--surface);
    border: 1px solid var(--border);
    color: var(--text2);
    cursor: pointer;
    text-decoration: none;
    transition: all var(--transition);
  }
  .pill:hover, .pill.active {
    background: var(--accent);
    color: #fff;
    border-color: var(--accent);
  }
  .sort-select {
    margin-left: auto;
    padding: 6px 12px;
    border-radius: var(--radius-xs);
    border: 1px solid var(--border);
    background: var(--surface);
    color: var(--text);
    font-family: inherit; font-size: 0.82rem;
    cursor: pointer;
    outline: none;
  }
  .search-bar {
    display: flex; gap: 8px; margin-bottom: 20px;
  }
  .search-input {
    flex: 1;
    padding: 10px 16px;
    border-radius: var(--radius-xs);
    border: 1px solid var(--border);
    background: var(--surface);
    color: var(--text);
    font-family: inherit; font-size: 0.9rem;
    outline: none;
    transition: border-color var(--transition), box-shadow var(--transition);
  }
  .search-input:focus {
    border-color: var(--accent);
    box-shadow: 0 0 0 3px rgba(0,113,227,0.15);
  }
  .search-input::placeholder { color: var(--text3); }

  /* GAME CARDS GRID */
  .games-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 16px;
  }
  .game-card {
    background: var(--surface);
    border-radius: var(--radius);
    border: 1px solid var(--border);
    box-shadow: var(--shadow);
    overflow: hidden;
    transition: box-shadow var(--transition), transform var(--transition);
    display: flex; flex-direction: column;
  }
  .game-card:hover { box-shadow: var(--shadow-lg); transform: translateY(-3px); }
  .game-card-header {
    padding: 18px 18px 12px;
    display: flex; justify-content: space-between; align-items: flex-start;
  }
  .game-title { font-size: 1.05rem; font-weight: 600; letter-spacing: -0.02em; }
  .game-body { padding: 0 18px 12px; flex: 1; }
  .game-meta { display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 10px; }
  .meta-tag {
    padding: 3px 10px;
    background: var(--surface2);
    border-radius: 980px;
    font-size: 0.75rem; font-weight: 500; color: var(--text2);
    display: flex; align-items: center; gap: 4px;
  }
  .game-notes { font-size: 0.83rem; color: var(--text2); line-height: 1.5; }
  .game-footer {
    padding: 12px 18px;
    border-top: 1px solid var(--border);
    display: flex; gap: 8px; justify-content: flex-end;
    background: var(--surface2);
  }
  .stars { color: var(--yellow); font-size: 0.8rem; letter-spacing: 1px; }

  /* STATUS BADGE */
  .badge {
    display: inline-flex; align-items: center; gap: 4px;
    padding: 3px 10px;
    border-radius: 980px;
    font-size: 0.72rem; font-weight: 600;
    letter-spacing: 0.04em; text-transform: uppercase;
  }
  .badge-en_cours  { background: rgba(0,113,227,0.12); color: var(--accent); }
  .badge-termine   { background: rgba(52,199,89,0.12);  color: var(--green); }
  .badge-wishlist  { background: rgba(255,159,10,0.12); color: var(--orange); }
  .badge-abandonne { background: rgba(255,59,48,0.12);  color: var(--red); }

  /* EMPTY STATE */
  .empty {
    text-align: center; padding: 80px 24px;
    color: var(--text2);
  }
  .empty-icon { font-size: 3rem; margin-bottom: 12px; }
  .empty h3 { font-size: 1.2rem; font-weight: 600; margin-bottom: 6px; color: var(--text); }
  .empty p { font-size: 0.9rem; margin-bottom: 20px; }

  /* MODAL */
  .modal-overlay {
    display: none; position: fixed; inset: 0; z-index: 200;
    background: rgba(0,0,0,0.4);
    backdrop-filter: blur(4px);
    align-items: center; justify-content: center;
    padding: 24px;
  }
  .modal-overlay.open { display: flex; }
  .modal {
    background: var(--surface);
    border-radius: 20px;
    box-shadow: var(--shadow-lg);
    width: 100%; max-width: 520px;
    max-height: 90vh; overflow-y: auto;
    border: 1px solid var(--border);
    animation: modalIn 0.22s cubic-bezier(0.4,0,0.2,1);
  }
  @keyframes modalIn {
    from { opacity: 0; transform: scale(0.96) translateY(8px); }
    to   { opacity: 1; transform: scale(1) translateY(0); }
  }
  .modal-header {
    padding: 24px 24px 0;
    display: flex; justify-content: space-between; align-items: center;
    margin-bottom: 20px;
  }
  .modal-title { font-size: 1.2rem; font-weight: 700; letter-spacing: -0.02em; }
  .modal-body { padding: 0 24px 24px; }

  /* FORM */
  .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
  .form-group { display: flex; flex-direction: column; gap: 6px; }
  .form-group.full { grid-column: 1 / -1; }
  label { font-size: 0.82rem; font-weight: 500; color: var(--text2); }
  input[type=text], input[type=number], select, textarea {
    padding: 10px 14px;
    border: 1px solid var(--border);
    border-radius: var(--radius-xs);
    background: var(--surface2);
    color: var(--text);
    font-family: inherit; font-size: 0.9rem;
    outline: none;
    transition: border-color var(--transition), box-shadow var(--transition);
    width: 100%;
  }
  input:focus, select:focus, textarea:focus {
    border-color: var(--accent);
    box-shadow: 0 0 0 3px rgba(0,113,227,0.12);
  }
  textarea { resize: vertical; min-height: 80px; }
  .form-actions { display: flex; gap: 10px; justify-content: flex-end; margin-top: 20px; }

  /* DETAIL PAGE */
  .detail-header {
    display: flex; align-items: flex-start; gap: 20px;
    margin-bottom: 28px;
  }
  .detail-icon {
    width: 72px; height: 72px;
    background: linear-gradient(135deg, var(--accent), var(--purple));
    border-radius: 18px;
    display: flex; align-items: center; justify-content: center;
    font-size: 2rem; flex-shrink: 0;
  }
  .detail-info h1 { font-size: 1.8rem; font-weight: 700; letter-spacing: -0.04em; }
  .detail-info .meta { display: flex; gap: 8px; flex-wrap: wrap; margin-top: 8px; }
  .detail-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 24px; }
  .detail-card {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: var(--radius);
    padding: 18px;
    box-shadow: var(--shadow);
  }
  .detail-card h3 { font-size: 0.78rem; font-weight: 600; color: var(--text2); text-transform: uppercase; letter-spacing: 0.06em; margin-bottom: 8px; }
  .detail-card .value { font-size: 1.3rem; font-weight: 700; }
  .back-link { display: inline-flex; align-items: center; gap: 6px; color: var(--accent); font-size: 0.88rem; text-decoration: none; font-weight: 500; margin-bottom: 24px; }
  .back-link:hover { text-decoration: underline; }
  .edit-form-card {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: var(--radius);
    padding: 24px;
    box-shadow: var(--shadow);
  }
  .edit-form-card h2 { font-size: 1.05rem; font-weight: 600; margin-bottom: 18px; }

  /* TOAST */
  .toast {
    position: fixed; bottom: 24px; right: 24px; z-index: 300;
    background: var(--text); color: var(--bg);
    padding: 12px 20px; border-radius: var(--radius-sm);
    font-size: 0.85rem; font-weight: 500;
    box-shadow: var(--shadow-lg);
    animation: toastIn 0.25s ease, toastOut 0.25s ease 2.5s forwards;
    pointer-events: none;
  }
  @keyframes toastIn  { from { opacity:0; transform: translateY(12px); } to { opacity:1; transform: translateY(0); } }
  @keyframes toastOut { to   { opacity:0; transform: translateY(12px); } }
</style>
"""

private let themeScript = """
<script>
  // Apply saved theme immediately to avoid flash
  (function() {
    const t = localStorage.getItem('gt-theme') || 'light';
    if (t === 'dark') document.documentElement.setAttribute('data-theme', 'dark');
  })();
  function toggleTheme() {
    const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
    const next = isDark ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', next);
    localStorage.setItem('gt-theme', next);
    document.getElementById('theme-btn').textContent = next === 'dark' ? '☀️' : '🌙';
  }
  window.addEventListener('DOMContentLoaded', function() {
    const t = localStorage.getItem('gt-theme') || 'light';
    const btn = document.getElementById('theme-btn');
    if (btn) btn.textContent = t === 'dark' ? '☀️' : '🌙';
  });
</script>
"""

private func nav(search: String = "", currentSort: String = "") -> String {
    """
    <nav>
      <a class="nav-brand" href="/"><span>Game</span>Tracker</a>
      <div class="nav-right">
        <form method="get" action="/" style="display:flex;gap:8px;align-items:center;">
          <input class="search-input" style="width:220px;" type="text" name="search" placeholder="Rechercher un jeu..." value="\(search)">
          <input type="hidden" name="sort" value="\(currentSort)">
          <button class="btn btn-secondary btn-sm" type="submit">🔍</button>
        </form>
        <button class="btn btn-primary btn-sm" onclick="document.getElementById('add-modal').classList.add('open')">+ Ajouter</button>
        <button class="btn-icon" id="theme-btn" onclick="toggleTheme()">🌙</button>
      </div>
    </nav>
    """
}

private func addModal() -> String {
    """
    <div class="modal-overlay" id="add-modal" onclick="if(event.target===this)this.classList.remove('open')">
      <div class="modal">
        <div class="modal-header">
          <span class="modal-title">Ajouter un jeu</span>
          <button class="btn-icon" onclick="document.getElementById('add-modal').classList.remove('open')">✕</button>
        </div>
        <div class="modal-body">
          <form method="post" action="/add">
            <div class="form-grid">
              <div class="form-group full">
                <label>Titre *</label>
                <input type="text" name="title" placeholder="Ex: Elden Ring" required>
              </div>
              <div class="form-group">
                <label>Plateforme</label>
                <select name="platform">
                  <option value="PC">PC</option>
                  <option value="PS5">PS5</option>
                  <option value="PS4">PS4</option>
                  <option value="Xbox">Xbox</option>
                  <option value="Switch">Switch</option>
                  <option value="Mobile">Mobile</option>
                </select>
              </div>
              <div class="form-group">
                <label>Genre</label>
                <select name="genre">
                  <option value="Action">Action</option>
                  <option value="RPG">RPG</option>
                  <option value="FPS">FPS</option>
                  <option value="Sport">Sport</option>
                  <option value="Stratégie">Stratégie</option>
                  <option value="Aventure">Aventure</option>
                  <option value="Simulation">Simulation</option>
                  <option value="Plateforme">Plateforme</option>
                  <option value="Autre">Autre</option>
                </select>
              </div>
              <div class="form-group">
                <label>Statut</label>
                <select name="status">
                  <option value="en_cours">🎮 En cours</option>
                  <option value="termine">✅ Terminé</option>
                  <option value="wishlist">🔖 Wishlist</option>
                  <option value="abandonne">❌ Abandonné</option>
                </select>
              </div>
              <div class="form-group">
                <label>Année de sortie</label>
                <input type="number" name="release_year" placeholder="Ex: 2022" min="1980" max="2030">
              </div>
              <div class="form-group">
                <label>Heures jouées</label>
                <input type="number" name="hours_played" placeholder="Ex: 42" min="0" step="0.5" value="0">
              </div>
              <div class="form-group">
                <label>Note (1–5)</label>
                <input type="number" name="rating" placeholder="Ex: 4" min="1" max="5">
              </div>
              <div class="form-group full">
                <label>Notes personnelles</label>
                <textarea name="notes" placeholder="Ton avis, progression..."></textarea>
              </div>
            </div>
            <div class="form-actions">
              <button type="button" class="btn btn-secondary" onclick="document.getElementById('add-modal').classList.remove('open')">Annuler</button>
              <button type="submit" class="btn btn-primary">Ajouter le jeu</button>
            </div>
          </form>
        </div>
      </div>
    </div>
    """
}

private func statusBadge(_ status: String) -> String {
    let label: String
    switch status {
    case "en_cours":  label = "🎮 En cours"
    case "termine":   label = "✅ Terminé"
    case "wishlist":  label = "🔖 Wishlist"
    case "abandonne": label = "❌ Abandonné"
    default: label = status
    }
    return "<span class=\"badge badge-\(status)\">\(label)</span>"
}

private func platformIcon(_ platform: String) -> String {
    switch platform {
    case "PC":     return "🖥"
    case "PS5","PS4": return "🎮"
    case "Xbox":   return "🟢"
    case "Switch": return "🕹"
    case "Mobile": return "📱"
    default:       return "🎯"
    }
}

private func starsHTML(_ rating: Int?) -> String {
    guard let r = rating else { return "" }
    let filled = String(repeating: "★", count: r)
    let empty  = String(repeating: "☆", count: 5 - r)
    return "<span class=\"stars\">\(filled)\(empty)</span>"
}

private func gameCard(_ game: GameItem) -> String {
    let gameId = game.id ?? 0
    let hours = game.hoursPlayed > 0 ? String(format: "%.1fh", game.hoursPlayed) : nil
    let year = game.releaseYear.map { String($0) }

    var metaTags = """
    <span class="meta-tag">\(platformIcon(game.platform)) \(game.platform)</span>
    <span class="meta-tag">🎲 \(game.genre)</span>
    """
    if let y = year { metaTags += "<span class=\"meta-tag\">📅 \(y)</span>" }
    if let h = hours { metaTags += "<span class=\"meta-tag\">⏱ \(h)</span>" }

    let notesHtml = game.notes.isEmpty ? "" : "<p class=\"game-notes\">\(game.notes)</p>"
    let stars = game.rating != nil ? "<br>\(starsHTML(game.rating))" : ""

    return """
    <div class="game-card">
      <div class="game-card-header">
        <span class="game-title">\(game.title)</span>
        \(statusBadge(game.status))
      </div>
      <div class="game-body">
        <div class="game-meta">\(metaTags)</div>
        \(notesHtml)\(stars)
      </div>
      <div class="game-footer">
        <a href="/game/\(gameId)" class="btn btn-secondary btn-sm">Détails</a>
        <form method="post" action="/delete/\(gameId)" onsubmit="return confirm('Supprimer ce jeu ?');" style="display:inline;">
          <button type="submit" class="btn btn-danger btn-sm">Supprimer</button>
        </form>
      </div>
    </div>
    """
}

// MARK: - Index Page

func renderIndex(games: [GameItem], stats: Database.Stats, filterStatus: String = "", search: String = "", sortBy: String = "") -> HTML {
    let cards = games.isEmpty
        ? """
          <div class="empty">
            <div class="empty-icon">🎮</div>
            <h3>Aucun jeu trouvé</h3>
            <p>Commence à ajouter des jeux à ta collection !</p>
            <button class="btn btn-primary" onclick="document.getElementById('add-modal').classList.add('open')">+ Ajouter un jeu</button>
          </div>
          """
        : "<div class=\"games-grid\">" + games.map { gameCard($0) }.joined() + "</div>"

    func pill(_ label: String, _ value: String) -> String {
        let active = filterStatus == value ? " active" : ""
        return "<a class=\"pill\(active)\" href=\"/?status=\(value)&sort=\(sortBy)\">\(label)</a>"
    }

    let hoursLabel = stats.totalHours > 0 ? String(format: "%.0fh", stats.totalHours) : "—"

    let html = """
    <!DOCTYPE html>
    <html>
    <head>
      \(sharedHead)
      \(themeScript)
    </head>
    <body>
      \(nav(search: search, currentSort: sortBy))
      \(addModal())
      <div class="page">
        <!-- Stats -->
        <div class="stats-grid">
          <div class="stat-card">
            <div class="stat-number">\(stats.total)</div>
            <div class="stat-label">🗂 Total</div>
          </div>
          <div class="stat-card">
            <div class="stat-number" style="color:var(--accent)">\(stats.enCours)</div>
            <div class="stat-label">🎮 En cours</div>
          </div>
          <div class="stat-card">
            <div class="stat-number" style="color:var(--green)">\(stats.termines)</div>
            <div class="stat-label">✅ Terminés</div>
          </div>
          <div class="stat-card">
            <div class="stat-number" style="color:var(--orange)">\(stats.wishlist)</div>
            <div class="stat-label">🔖 Wishlist</div>
          </div>
          <div class="stat-card">
            <div class="stat-number" style="color:var(--red)">\(stats.abandonnes)</div>
            <div class="stat-label">❌ Abandonnés</div>
          </div>
        </div>
        <!-- Filters -->
        <div class="filters-bar">
          <div class="filter-pills">
            \(pill("Tous", ""))
            \(pill("🎮 En cours", "en_cours"))
            \(pill("✅ Terminés", "termine"))
            \(pill("🔖 Wishlist", "wishlist"))
            \(pill("❌ Abandonnés", "abandonne"))
          </div>
          <form method="get" action="/" style="margin-left:auto;">
            <input type="hidden" name="status" value="\(filterStatus)">
            <input type="hidden" name="search" value="\(search)">
            <select class="sort-select" name="sort" onchange="this.form.submit()">
              <option value="" \(sortBy=="" ? "selected" : "")>Récents</option>
              <option value="title" \(sortBy=="title" ? "selected" : "")>A → Z</option>
              <option value="hours" \(sortBy=="hours" ? "selected" : "")>Heures jouées</option>
              <option value="rating" \(sortBy=="rating" ? "selected" : "")>Note</option>
              <option value="year" \(sortBy=="year" ? "selected" : "")>Année</option>
            </select>
          </form>
        </div>
        <!-- Games -->
        \(cards)
      </div>
      <script>
        // Auto-dismiss toast after 3s
        const toast = document.querySelector('.toast');
        if (toast) setTimeout(() => toast.remove(), 3000);
      </script>
    </body>
    </html>
    """
    return HTML(body: html)
}

// MARK: - Detail Page

func renderDetail(game: GameItem) -> HTML {
    let gameId = game.id ?? 0
    let platforms = ["PC","PS5","PS4","Xbox","Switch","Mobile"]
    let genres = ["Action","RPG","FPS","Sport","Stratégie","Aventure","Simulation","Plateforme","Autre"]
    let statuses = [("en_cours","🎮 En cours"),("termine","✅ Terminé"),("wishlist","🔖 Wishlist"),("abandonne","❌ Abandonné")]

    func opt(_ value: String, _ label: String, _ current: String) -> String {
        "<option value=\"\(value)\" \(value == current ? "selected" : "")>\(label)</option>"
    }

    let html = """
    <!DOCTYPE html>
    <html>
    <head>
      \(sharedHead)
      \(themeScript)
    </head>
    <body>
      \(nav())
      <div class="page">
        <a class="back-link" href="/">← Retour à la collection</a>
        <div class="detail-header">
          <div class="detail-icon">🎮</div>
          <div class="detail-info">
            <h1>\(game.title)</h1>
            <div class="meta">
              \(statusBadge(game.status))
              <span class="meta-tag">\(platformIcon(game.platform)) \(game.platform)</span>
              <span class="meta-tag">🎲 \(game.genre)</span>
              \(game.releaseYear != nil ? "<span class=\"meta-tag\">📅 \(game.releaseYear!)</span>" : "")
              \(starsHTML(game.rating))
            </div>
          </div>
        </div>
        <div class="detail-grid">
          <div class="detail-card">
            <h3>Heures jouées</h3>
            <div class="value">⏱ \(String(format: "%.1f", game.hoursPlayed))h</div>
          </div>
          <div class="detail-card">
            <h3>Note</h3>
            <div class="value">\(game.rating != nil ? starsHTML(game.rating) : "—")</div>
          </div>
        </div>
        \(game.notes.isEmpty ? "" : """
        <div class="detail-card" style="margin-bottom:24px;">
          <h3>Notes personnelles</h3>
          <p style="margin-top:8px;line-height:1.6;color:var(--text2)">\(game.notes)</p>
        </div>
        """)
        <!-- Edit form -->
        <div class="edit-form-card">
          <h2>✏️ Modifier ce jeu</h2>
          <form method="post" action="/update/\(gameId)">
            <div class="form-grid">
              <div class="form-group full">
                <label>Titre</label>
                <input type="text" name="title" value="\(game.title)" required>
              </div>
              <div class="form-group">
                <label>Plateforme</label>
                <select name="platform">\(platforms.map { opt($0, $0, game.platform) }.joined())</select>
              </div>
              <div class="form-group">
                <label>Genre</label>
                <select name="genre">\(genres.map { opt($0, $0, game.genre) }.joined())</select>
              </div>
              <div class="form-group">
                <label>Statut</label>
                <select name="status">\(statuses.map { opt($0.0, $0.1, game.status) }.joined())</select>
              </div>
              <div class="form-group">
                <label>Année de sortie</label>
                <input type="number" name="release_year" value="\(game.releaseYear.map { String($0) } ?? "")" min="1980" max="2030">
              </div>
              <div class="form-group">
                <label>Heures jouées</label>
                <input type="number" name="hours_played" value="\(game.hoursPlayed)" min="0" step="0.5">
              </div>
              <div class="form-group">
                <label>Note (1–5)</label>
                <input type="number" name="rating" value="\(game.rating.map { String($0) } ?? "")" min="1" max="5">
              </div>
              <div class="form-group full">
                <label>Notes personnelles</label>
                <textarea name="notes">\(game.notes)</textarea>
              </div>
            </div>
            <div class="form-actions">
              <a href="/" class="btn btn-secondary">Annuler</a>
              <button type="submit" class="btn btn-primary">Enregistrer les modifications</button>
            </div>
          </form>
        </div>
      </div>
    </body>
    </html>
    """
    return HTML(body: html)
}

// MARK: - Error Page

func renderError(message: String) -> HTML {
    HTML(body: """
    <!DOCTYPE html><html><head>\(sharedHead)\(themeScript)</head><body>
    \(nav())
    <div class="page"><div class="empty">
      <div class="empty-icon">⚠️</div>
      <h3>Erreur</h3>
      <p>\(message)</p>
      <a href="/" class="btn btn-primary">Retour à l'accueil</a>
    </div></div>
    </body></html>
    """)
}