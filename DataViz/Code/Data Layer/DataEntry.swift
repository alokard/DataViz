import Foundation

enum DataType {
    case unknown
    case temperature(DataEntry<Double>)
    case pressure(DataEntry<Double>)
    case serial(DataEntry<String>)
    case location(DataEntry<[Double]>)
    case voltage(DataEntry<Double>)
    case pm1(DataEntry<Double>)

    static func dataType(from doubleEntry: DataEntry<Double>) -> DataType {
        switch doubleEntry.name {
        case PersistentStoreConst.temperatureEntity:
            return .temperature(doubleEntry)
        case PersistentStoreConst.pressureEntity:
            return .pressure(doubleEntry)
        case PersistentStoreConst.pm1Entity:
            return .pm1(doubleEntry)
        case "Batt. Voltage":
            return .voltage(doubleEntry)
        default:
            return .unknown
        }
    }

    static func dataType(from serial: DataEntry<String>) -> DataType {
        if serial.name == PersistentStoreConst.serialEntity {
            return .serial(serial)
        }
        return .unknown
    }

    static func dataType(from location: DataEntry<[Double]>) -> DataType {
        if location.name == PersistentStoreConst.locationEntity {
            return .location(location)
        }
        return .unknown
    }
}

enum DataEntryError: Error {
    case parsingError
}

class DataEntry<T> {
    let name: String
    let unit: String?
    let measurements: [(Date, T)]

    init(name: String, measurements: [(Date, T)] = [], unit: String? = nil) {
        self.name = name
        self.measurements = measurements
        self.unit = unit
    }

    init(json: JSON) throws {
        name = try json.parse("name")
        unit = json.parse("unit")
        guard let measurements: [Any] = json.parse("measurements") else {
            throw DataEntryError.parsingError
        }
        var measurementTouples = [(Date, T)]()
        for measurement in measurements {
            if let measurement = measurement as? [Any] {
                guard measurement.count > 1 else { continue }
                if let timestamp = measurement[0] as? TimeInterval, let value = measurement[1] as? T {
                    measurementTouples.append((Date(timeIntervalSince1970: timestamp), value))
                } else {
                    throw DataEntryError.parsingError
                }
            }
        }
        self.measurements = measurementTouples
    }
}

