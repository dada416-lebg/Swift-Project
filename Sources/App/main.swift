import Hummingbird
import Foundation

// MARK: - App Setup

let db = try Database()

let router = Router()

// MARK: - Helpers

func parseForm(_ body: String) -> [String: String] {
    var result: [String: String] = [:]
    for pair in body.split(separator: "&") {
        let parts = pair.split(separator: "=", maxSplits: 1)
        if parts.count == 2 {
            let key   = String(parts[0]).removingPercentEncoding?.replacingOccurrences(of: "+", with: " ") ?? ""
            let value = String(parts[1]).removingPercentEncoding?.replacingOccurrences(of: "+", with: " ") ?? ""
            result[key] = value
        }
    }
    return result
}

func gameFromForm(_ form: [String: String], id: Int64? = nil) -> GameItem {
    GameItem(
        id: id,
        title: form["title"] ?? "",
        platform: form["platform"] ?? "PC",
        genre: form["genre"] ?? "Autre",
        status: form["status"] ?? "en_cours",
        releaseYear: form["release_year"].flatMap { Int($0) },
        hoursPlayed: form["hours_played"].flatMap { Double($0) } ?? 0.0,
        rating: form["rating"].flatMap { Int($0) },
        notes: form["notes"] ?? ""
    )
}

func redirect(to path: String) -> Response {
    var headers = HTTPFields()
    headers[.location] = path
    return Response(status: .seeOther, headers: headers)
}

// MARK: - Routes

// GET / — index with filters, search, sort
router.get("/") { request, _ -> HTML in
    let query       = request.uri.queryParameters
    let filterStatus = query["status"].map(String.init) ?? ""
    let search       = query["search"].map(String.init) ?? ""
    let sortBy       = query["sort"].map(String.init) ?? ""
    let games = try db.getAllGames(filterStatus: filterStatus, search: search, sortBy: sortBy)
    let stats = try db.getStats()
    return renderIndex(games: games, stats: stats, filterStatus: filterStatus, search: search, sortBy: sortBy)
}

// GET /game/:id — detail + edit form
router.get("/game/:id") { request, context -> HTML in
    guard let idStr = context.parameters.get("id"),
          let gameId = Int64(idStr),
          let game = try db.getGame(byId: gameId)
    else {
        return renderError(message: "Jeu introuvable.")
    }
    return renderDetail(game: game)
}

// POST /add — create new game
router.post("/add") { request, _ -> Response in
    let bodyBytes = try await request.body.collect(upTo: 1024 * 1024)
    let bodyStr   = String(buffer: bodyBytes)
    let form      = parseForm(bodyStr)
    guard !form["title", default: ""].trimmingCharacters(in: .whitespaces).isEmpty else {
        return redirect(to: "/?error=title_required")
    }
    let game = gameFromForm(form)
    try db.createGame(game)
    return redirect(to: "/?added=1")
}

// POST /update/:id — update existing game
router.post("/update/:id") { request, context -> Response in
    guard let idStr = context.parameters.get("id"),
          let gameId = Int64(idStr)
    else {
        return redirect(to: "/?error=invalid_id")
    }
    let bodyBytes = try await request.body.collect(upTo: 1024 * 1024)
    let bodyStr   = String(buffer: bodyBytes)
    let form      = parseForm(bodyStr)
    let game      = gameFromForm(form, id: gameId)
    try db.updateGame(game)
    return redirect(to: "/game/\(gameId)?updated=1")
}

// POST /delete/:id — delete game
router.post("/delete/:id") { request, context -> Response in
    guard let idStr = context.parameters.get("id"),
          let gameId = Int64(idStr)
    else {
        return redirect(to: "/?error=invalid_id")
    }
    try db.deleteGame(byId: gameId)
    return redirect(to: "/?deleted=1")
}

// POST /toggle/:id — quick status toggle (bonus)
router.post("/toggle/:id") { request, context -> Response in
    guard let idStr = context.parameters.get("id"),
          let gameId = Int64(idStr),
          var game = try db.getGame(byId: gameId)
    else {
        return redirect(to: "/")
    }
    let bodyBytes = try await request.body.collect(upTo: 1024)
    let bodyStr   = String(buffer: bodyBytes)
    let form      = parseForm(bodyStr)
    if let newStatus = form["status"] {
        game.status = newStatus
        try db.updateGame(game)
    }
    return redirect(to: "/")
}

// MARK: - Start server

let app = Application(
    router: router,
    configuration: .init(address: .hostname("0.0.0.0", port: 8080))
)

try await app.runService()