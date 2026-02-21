import Foundation
import SwiftData

@Model
final class Reference {
    @Attribute(.unique) var key: String
    var type: String
    var title: String
    var authors: String
    var year: Int
    var journal: String
    var doi: String
    var url: String
    var notes: String
    
    init(
        key: String,
        type: String,
        title: String,
        authors: String,
        year: Int,
        journal: String,
        doi: String,
        url: String,
        notes: String
    ) {
        self.key = key
        self.type = type
        self.title = title
        self.authors = authors
        self.year = year
        self.journal = journal
        self.doi = doi
        self.url = url
        self.notes = notes
    }
}