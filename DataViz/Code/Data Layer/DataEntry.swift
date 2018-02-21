import Foundation

class DataEntry<T> {
    let name: String
    let unit: String?
    let measurements: [(TimeInterval, T)]?

    init(json: JSON) throws {
        name = try json.parse("name")
        unit = json.parse("unit")
        guard let measurements: [Any] = json.parse("measurements") else {
            self.measurements = nil
            return
        }
        var measurementTouples = [(TimeInterval, T)]()
        for measurement in measurements {
            if let measurement = measurement as? [Any] {
                guard measurement.count > 1 else { continue }
                if let timestamp = measurement[0] as? TimeInterval, let value = measurement[1] as? T {
                    measurementTouples.append((timestamp, value))
                }
            }
        }
        self.measurements = measurementTouples
    }
}

