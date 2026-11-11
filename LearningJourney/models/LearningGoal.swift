import Foundation

struct LearningGoal: Identifiable, Codable, Hashable {

    let id: UUID
    var topic: String
    var duration: LearningDuration
    let createdAt: Date

    init(topic: String, duration: LearningDuration) {
        self.id = UUID()
        self.topic = topic
        self.duration = duration
        self.createdAt = Date()
    }
}
