import Foundation
import SwiftData

@Model
final class EducationCard {
    @Attribute(.unique) var cardId: String
    var title: String
    var summary: String
    var detailMarkdown: String
    var refs: [String]
    
    init(
        cardId: String,
        title: String,
        summary: String,
        detailMarkdown: String,
        refs: [String]
    ) {
        self.cardId = cardId
        self.title = title
        self.summary = summary
        self.detailMarkdown = detailMarkdown
        self.refs = refs
    }
}