import Differentiator
import RxCocoa

class HomeCellViewModel: Equatable, IdentifiableType {
    private(set) var identity: String

    private var value: String
    private var units: String?
    private var date: String

    var formattedValue: String {
        return [value, units].flatMap { $0 }.joined(separator: " ")        
    }

    var formattedDate: String {
        return "Updated: \(date)"
    }

    init(dataType: DataType) {
        value = "--"
        date = "--"
        identity = "Unknown"
        switch dataType {
        case .temperature(let entry):
            setup(with: entry)
        case .pressure(let entry):
            setup(with: entry)
        case .serial(let entry):
            setup(with: entry)
        case .location(let entry):
            setup(with: entry)
        case .voltage(let entry):
            setup(with: entry)
        case .pm1(let entry):
            setup(with: entry)
        case .unknown:
            break
        }
    }

    private func setup(with entry: DataEntry<Double>) {
        identity = entry.name
        units = entry.unit
        if let measurement = entry.measurements?.first {
            value = String(format: "%.2f", measurement.1)
            date = HomeCellViewModel.dateTimeFormatter.string(from: measurement.0)
        }
    }

    private func setup(with entry: DataEntry<String>) {
        identity = entry.name
        units = entry.unit
        if let measurement = entry.measurements?.first {
            value = measurement.1
            date = HomeCellViewModel.dateTimeFormatter.string(from: measurement.0)
        }
    }

    private func setup(with entry: DataEntry<[Double]>) {
        identity = entry.name
        units = entry.unit
        if let measurement = entry.measurements?.first {
            if let latitude = measurement.1.first,
                let longitude = measurement.1.last {
                value = "\(latitude)\n\(longitude)"
            }
            date = HomeCellViewModel.dateTimeFormatter.string(from: measurement.0)
        }
    }

    private static let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()

    static func ==(lhs: HomeCellViewModel, rhs: HomeCellViewModel) -> Bool {
        return lhs.identity == rhs.identity
    }
}
