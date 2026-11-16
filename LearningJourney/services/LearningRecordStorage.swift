
import Foundation

struct LearningRecordStorage {

    // MARK: - Load Records for One Goal

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

    // MARK: - Save Records for One Goal

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

    // MARK: - Load Complete Learning History

    func loadAllRecords() -> [LearningDayRecord] {

        let prefix = "learningRecords_"

        // Find every saved goal's learning records.
        let keys = UserDefaults.standard
            .dictionaryRepresentation()
            .keys
            .filter { $0.hasPrefix(prefix) }

        var allRecords: [LearningDayRecord] = []

        for key in keys {

            let goalIDString = String(
                key.dropFirst(prefix.count)
            )

            guard let goalID = UUID(
                uuidString: goalIDString
            ) else {
                continue
            }

            let savedRecords = load(for: goalID)

            allRecords.append(contentsOf: savedRecords)
        }

        // Display activities in chronological order.
        return allRecords.sorted {
            $0.date < $1.date
        }
    }
}
