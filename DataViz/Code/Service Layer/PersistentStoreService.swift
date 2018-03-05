import Foundation
import RxSwift
import RxCocoa
import CoreData

struct PersistentStoreConst {
    static let temperatureEntity = "Temperature"
    static let pressureEntity = "Pressure"
    static let serialEntity = "Serial"
    static let locationEntity = "Location"
    static let voltageEntity = "Voltage"
    static let pm1Entity = "PM1"

    static let measurementDate = "measurementDate"
}

protocol PersistentStoreService {
    var viewContext: NSManagedObjectContext { get }
    func fetchedResultsController<T: NSManagedObject>() -> NSFetchedResultsController<T>

    var lastMeasurements: Observable<DataType> { get }
}

extension PersistentStoreService {
    func fetchedResultsController<T: NSManagedObject>() -> NSFetchedResultsController<T> {
        let fetchRequest = T.fetchRequest()
        fetchRequest.fetchBatchSize = 20

        let sortDescriptor = NSSortDescriptor(key: PersistentStoreConst.measurementDate, ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                   managedObjectContext: self.viewContext,
                                                                   sectionNameKeyPath: nil,
                                                                   cacheName: nil)

        return aFetchedResultsController as! NSFetchedResultsController<T>
    }
}

extension PersistentStoreService {
    var temperatureMeasurements: Driver<DataType?> {
        let fetchRequest: NSFetchRequest<Temperature> = Temperature.fetchRequest()
        fetchRequest.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: PersistentStoreConst.measurementDate, ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        var startValue: DataType?
        if let result = (try? viewContext.fetch(fetchRequest))?.first,
            let date = result.measurementDate {
            let measurement: [(Date, Double)] = [(date, result.value)]
            let entry = DataEntry<Double>(name: PersistentStoreConst.temperatureEntity, measurements: measurement, unit: result.unit)
            startValue = DataType.dataType(from: entry)
        }

        return lastMeasurements
            .map { data -> DataEntry<Double>? in
                switch data {
                case .temperature(let value): return value
                default: return nil
                }
            }
            .filter { $0 != nil }
            .map { $0! }
            .map { DataType.dataType(from: $0) }
            .asDriver(onErrorJustReturn: nil)
            .startWith(startValue)
    }
    var pressureMeasurements: Driver<DataType?> {
        let fetchRequest: NSFetchRequest<Pressure> = Pressure.fetchRequest()
        fetchRequest.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: PersistentStoreConst.measurementDate, ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        var startValue: DataType?
        if let result = (try? viewContext.fetch(fetchRequest))?.first,
            let date = result.measurementDate {
            let measurement: [(Date, Double)] = [(date, result.value)]
            let entry = DataEntry<Double>(name: PersistentStoreConst.pressureEntity, measurements: measurement, unit: result.unit)
            startValue = DataType.dataType(from: entry)
        }
        return lastMeasurements
            .map { data -> DataEntry<Double>? in
                switch data {
                case .pressure(let value): return value
                default: return nil
                }
            }
            .filter { $0 != nil }
            .map { $0! }
            .map { DataType.dataType(from: $0) }
            .asDriver(onErrorJustReturn: nil)
            .startWith(startValue)
    }
    var serialMeasurements: Driver<DataType?> {
        let fetchRequest: NSFetchRequest<Serial> = Serial.fetchRequest()
        fetchRequest.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: PersistentStoreConst.measurementDate, ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        var startValue: DataType?
        if let result = (try? viewContext.fetch(fetchRequest))?.first,
            let date = result.measurementDate,
            let value = result.value {
            let measurement: [(Date, String)] = [(date, value)]
            let entry = DataEntry<String>(name: PersistentStoreConst.serialEntity, measurements: measurement)
            startValue = DataType.dataType(from: entry)
        }
        return lastMeasurements
            .map { data -> DataEntry<String>? in
                switch data {
                case .serial(let value): return value
                default: return nil
                }
            }
            .filter { $0 != nil }
            .map { $0! }
            .map { DataType.dataType(from: $0) }
            .asDriver(onErrorJustReturn: nil)
            .startWith(startValue)
    }
    var locationMeasurements: Driver<DataType?> {
        let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
        fetchRequest.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: PersistentStoreConst.measurementDate, ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        var startValue: DataType?
        if let result = (try? viewContext.fetch(fetchRequest))?.first,
            let date = result.measurementDate {
            let measurement: [(Date, [Double])] = [(date, [result.latitude, result.longitude])]
            let entry = DataEntry<[Double]>(name: PersistentStoreConst.locationEntity, measurements: measurement)
            startValue = DataType.dataType(from: entry)
        }
        return lastMeasurements
            .map { data -> DataEntry<[Double]>? in
                switch data {
                case .location(let value): return value
                default: return nil
                }
            }
            .filter { $0 != nil }
            .map { $0! }
            .map { DataType.dataType(from: $0) }
            .asDriver(onErrorJustReturn: nil)
            .startWith(startValue)
    }
    var voltageMeasurements: Driver<DataType?> {
        let fetchRequest: NSFetchRequest<Voltage> = Voltage.fetchRequest()
        fetchRequest.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: PersistentStoreConst.measurementDate, ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        var startValue: DataType?
        if let result = (try? viewContext.fetch(fetchRequest))?.first,
            let date = result.measurementDate {
            let measurement: [(Date, Double)] = [(date, result.value)]
            let entry = DataEntry<Double>(name: PersistentStoreConst.voltageEntity, measurements: measurement, unit: result.unit)
            startValue = DataType.dataType(from: entry)
        }
        return lastMeasurements
            .map { data -> DataEntry<Double>? in
                switch data {
                case .voltage(let value): return value
                default: return nil
                }
            }
            .filter { $0 != nil }
            .map { $0! }
            .map { DataType.dataType(from: $0) }
            .asDriver(onErrorJustReturn: nil)
            .startWith(startValue)
    }
    var pm1Measurements: Driver<DataType?> {
        let fetchRequest: NSFetchRequest<PM1> = PM1.fetchRequest()
        fetchRequest.fetchLimit = 1
        let sortDescriptor = NSSortDescriptor(key: PersistentStoreConst.measurementDate, ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        var startValue: DataType?
        if let result = (try? viewContext.fetch(fetchRequest))?.first,
            let date = result.measurementDate {
            let measurement: [(Date, Double)] = [(date, result.value)]
            let entry = DataEntry<Double>(name: PersistentStoreConst.pm1Entity, measurements: measurement, unit: result.unit)
            startValue = DataType.dataType(from: entry)
        }
        return lastMeasurements
            .map { data -> DataEntry<Double>? in
                switch data {
                case .pm1(let value): return value
                default: return nil
                }
            }
            .filter { $0 != nil }
            .map { $0! }
            .map { DataType.dataType(from: $0) }
            .asDriver(onErrorJustReturn: nil)
            .startWith(startValue)
    }
}

protocol HasPersistentStore {
    var persistentStore: PersistentStoreService { get }
}

class PersistentStoreServiceImpl: PersistentStoreService {
    let lastMeasurements: Observable<DataType>
    var viewContext: NSManagedObjectContext { return coreDataService.viewContext }

    private let disposeBag = DisposeBag()
    private let coreDataService: CoreDataService

    init(dataInput: Observable<String>, coreDataService: CoreDataService) {
        self.coreDataService = coreDataService
        
        lastMeasurements = dataInput.map { jsonString -> [DataType] in
                var result = [DataType]()
                guard let data = jsonString.data(using: .utf8) else { return result }
                guard let jsons = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [JSON] else { return result }
                for json in jsons {
                    if let doubleEntry = try? DataEntry<Double>(json: json) {
                        result.append(DataType.dataType(from: doubleEntry))
                    } else if let serial = try? DataEntry<String>(json: json) {
                        result.append(DataType.dataType(from: serial))
                    } else if let location = try? DataEntry<[Double]>(json: json) {
                        result.append(DataType.dataType(from: location))
                    }
                }
                return result
            }.flatMap { entries -> Observable<DataType> in
                return Observable.from(entries)
            }


        lastMeasurements
            .subscribe(onNext: { [weak coreDataService] dataType in
                guard let context = coreDataService?.backgroundContext else { return }
                switch dataType {
                case .unknown: break
                case .temperature(let entry):
                    guard let measurements = entry.measurements else { break }
                    for measurement in measurements {
                        let object = NSEntityDescription.insertNewObject(forEntityName: PersistentStoreConst.temperatureEntity,
                                                                         into: context) as! Temperature

                        object.measurementDate = measurement.0
                        object.value = measurement.1
                        object.unit = entry.unit
                    }
                case .pressure(let entry):
                    guard let measurements = entry.measurements else { break }
                    for measurement in measurements {
                        let object = NSEntityDescription.insertNewObject(forEntityName: PersistentStoreConst.pressureEntity,
                                                                         into: context) as! Pressure

                        object.measurementDate = measurement.0
                        object.value = measurement.1
                        object.unit = entry.unit
                    }
                case .voltage(let entry):
                    guard let measurements = entry.measurements else { break }
                    for measurement in measurements {
                        let object = NSEntityDescription.insertNewObject(forEntityName: PersistentStoreConst.voltageEntity,
                                                                         into: context) as! Voltage

                        object.measurementDate = measurement.0
                        object.value = measurement.1
                        object.unit = entry.unit
                    }
                case .pm1(let entry):
                    guard let measurements = entry.measurements else { break }
                    for measurement in measurements {
                        let object = NSEntityDescription.insertNewObject(forEntityName: PersistentStoreConst.pm1Entity,
                                                                         into: context) as! PM1

                        object.measurementDate = measurement.0
                        object.value = measurement.1
                        object.unit = entry.unit
                    }
                case .serial(let entry):
                    guard let measurements = entry.measurements else { break }
                    for measurement in measurements {
                        let object = NSEntityDescription.insertNewObject(forEntityName: PersistentStoreConst.serialEntity,
                                                                         into: context) as! Serial

                        object.measurementDate = measurement.0
                        object.value = measurement.1
                    }
                case .location(let entry):
                    guard let measurements = entry.measurements else { break }
                    for measurement in measurements {
                        let object = NSEntityDescription.insertNewObject(forEntityName: PersistentStoreConst.serialEntity,
                                                                         into: context) as! Location

                        object.measurementDate = measurement.0
                        object.latitude = measurement.1.first ?? 0
                        object.longitude = measurement.1.last ?? 0
                    }
                }

                do {
                    try context.save()
                } catch { }
            }).disposed(by: disposeBag)
    }
}
