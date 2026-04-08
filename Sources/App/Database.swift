import SQLite
import Foundation

// Make SQLite Connection sendable for async/await usage
extension Connection: @unchecked Sendable {}

struct Database {
    let db: Connection

    // Table and columns
    let games       = Table("games")
    let id          = Expression<Int64>("id")
    let title       = Expression<String>("title")
    let platform    = Expression<String>("platform")
    let genre       = Expression<String>("genre")
    let status      = Expression<String>("status")
    let releaseYear = Expression<Int?>("release_year")
    let hoursPlayed = Expression<Double>("hours_played")
    let rating      = Expression<Int?>("rating")
    let notes       = Expression<String>("notes")

    init() throws {
        db = try Connection("db.sqlite3")
        try createTable()
    }

    func createTable() throws {
        try db.run(games.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(title)
            t.column(platform)
            t.column(genre)
            t.column(status)
            t.column(releaseYear)
            t.column(hoursPlayed, defaultValue: 0.0)
            t.column(rating)
            t.column(notes, defaultValue: "")
        })
    }

    // MARK: - Read

    func getAllGames(filterStatus: String? = nil, search: String? = nil, sortBy: String? = nil) throws -> [GameItem] {
        var query = games

        // Filter by status
        if let filterStatus = filterStatus, !filterStatus.isEmpty, filterStatus != "tous" {
            query = query.filter(status == filterStatus)
        }

        // Search by title
        if let search = search, !search.isEmpty {
            query = query.filter(title.like("%\(search)%"))
        }

        // Sorting
        switch sortBy {
        case "title":
            query = query.order(title.asc)
        case "hours":
            query = query.order(hoursPlayed.desc)
        case "rating":
            query = query.order(rating.desc)
        case "year":
            query = query.order(releaseYear.desc)
        default:
            query = query.order(id.desc)
        }

        return try db.prepare(query).map { row in
            GameItem(
                id: row[id],
                title: row[title],
                platform: row[platform],
                genre: row[genre],
                status: row[status],
                releaseYear: row[releaseYear],
                hoursPlayed: row[hoursPlayed],
                rating: row[rating],
                notes: row[notes]
            )
        }
    }

    func getGame(byId gameId: Int64) throws -> GameItem? {
        let query = games.filter(id == gameId)
        return try db.prepare(query).map { row in
            GameItem(
                id: row[id],
                title: row[title],
                platform: row[platform],
                genre: row[genre],
                status: row[status],
                releaseYear: row[releaseYear],
                hoursPlayed: row[hoursPlayed],
                rating: row[rating],
                notes: row[notes]
            )
        }.first
    }

    // MARK: - Create

    func createGame(_ game: GameItem) throws {
        try db.run(games.insert(
            title       <- game.title,
            platform    <- game.platform,
            genre       <- game.genre,
            status      <- game.status,
            releaseYear <- game.releaseYear,
            hoursPlayed <- game.hoursPlayed,
            rating      <- game.rating,
            notes       <- game.notes
        ))
    }

    // MARK: - Update

    func updateGame(_ game: GameItem) throws {
        guard let gameId = game.id else { return }
        let row = games.filter(id == gameId)
        try db.run(row.update(
            title       <- game.title,
            platform    <- game.platform,
            genre       <- game.genre,
            status      <- game.status,
            releaseYear <- game.releaseYear,
            hoursPlayed <- game.hoursPlayed,
            rating      <- game.rating,
            notes       <- game.notes
        ))
    }

    // MARK: - Delete

    func deleteGame(byId gameId: Int64) throws {
        let row = games.filter(id == gameId)
        try db.run(row.delete())
    }

    // MARK: - Stats

    struct Stats {
        let total: Int
        let enCours: Int
        let termines: Int
        let wishlist: Int
        let abandonnes: Int
        let totalHours: Double
    }

    func getStats() throws -> Stats {
        let allGames = try getAllGames()
        let total     = allGames.count
        let enCours   = allGames.filter { $0.status == "en_cours" }.count
        let termines  = allGames.filter { $0.status == "termine" }.count
        let wishlist  = allGames.filter { $0.status == "wishlist" }.count
        let abandonnes = allGames.filter { $0.status == "abandonne" }.count
        let totalHours = allGames.reduce(0.0) { $0 + $1.hoursPlayed }
        return Stats(total: total, enCours: enCours, termines: termines,
                     wishlist: wishlist, abandonnes: abandonnes, totalHours: totalHours)
    }
}