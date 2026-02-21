import Foundation

enum ProgressionDecision {
    case progress(reason: String)
    case `repeat`(reason: String)
    case regress(reason: String)
    case pausePlan(reason: String)
}