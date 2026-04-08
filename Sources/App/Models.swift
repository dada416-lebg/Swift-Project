import Foundation

struct GameItem: Codable, Sendable {
    let id: Int64?
    var title: String
    var platform: String      // PC, PS5, Xbox, Switch, Mobile
    var genre: String         // Action, RPG, Sport, etc.
    var status: String        // en_cours, termine, wishlist, abandonne
    var releaseYear: Int?
    var hoursPlayed: Double
    var rating: Int?          // 1-5, nullable
    var notes: String
}