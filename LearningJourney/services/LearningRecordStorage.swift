
import Foundation

struct LearningRecordStorage {

    func load(for goalID: UUID) -> [LearningDayRecord] {
        let key = "learningRecords_\(goalID.uuidString)"

        guard let data = UserDefaults.standard.data(forKey: key),
              let records = try? JSONDecoder().decode(
                  [LearningDayRecord].self,
                  from: data
              ) else {
            return []
        }

        return records
    }

    func save(
        _ records: [LearningDayRecord],
        for goalID: UUID
    ) {
        let key = "learningRecords_\(goalID.uuidString)"

        guard let data = try? JSONEncoder().encode(records) else {
            return
        }

        UserDefaults.standard.set(data, forKey: key)
    }
}

