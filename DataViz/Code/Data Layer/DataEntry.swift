import Foundation

enum DataType {
    case unknown//(DataEntry<Any>)
    case temperature(DataEntry<Double>)
    case pressure(DataEntry<Double>)
    case serial(DataEntry<String>)
    case location(DataEntry<[Double]>)
    case voltage(DataEntry<Double>)
    case pm1(DataEntry<Double>)
}

class DataEntry<T> {
    let name: String
    let unit: String?
    let measurements: [(Date, T)]?

    init(name: String, measurements: [(Date, T)] = [], unit: String? = nil) {
        self.name = name
        self.measurements = measurements
        self.unit = unit
    }

    init(json: JSON) throws {
        name = try json.parse("name")
        unit = json.parse("unit")
        guard let measurements: [Any] = json.parse("measurements") else {
            self.measurements = nil
            return
        }
        var measurementTouples = [(Date, T)]()
        for measurement in measurements {
            if let measurement = measurement as? [Any] {
                guard measurement.count > 1 else { continue }
                if let timestamp = measurement[0] as? TimeInterval, let value = measurement[1] as? T {
                    measurementTouples.append((Date(timeIntervalSince1970: timestamp), value))
                }
            }
        }
        self.measurements = measurementTouples
    }
}

