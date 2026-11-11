
import Foundation

enum LearningDayStatus: String, Codable {
    case learned
    case frozen
}

struct LearningDayRecord: Codable {
    let date: Date
    let status: LearningDayStatus
}

