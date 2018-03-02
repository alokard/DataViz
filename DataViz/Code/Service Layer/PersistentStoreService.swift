import Foundation
import RxSwift
import CoreData

protocol PersistentStoreService {
    var viewContext: NSManagedObjectContext { get }
    func fetchedResultsController<T: NSManagedObject>() -> NSFetchedResultsController<T>

    var lastMeasurements: Observable<DataType> { get }
}

extension PersistentStoreService {
    func fetchedResultsController<T: NSManagedObject>() -> NSFetchedResultsController<T> {
        let fetchRequest = T.fetchRequest()
        fetchRequest.fetchBatchSize = 20

        let sortDescriptor = NSSortDescriptor(key: "measurementDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                   managedObjectContext: self.viewContext,
                                                                   sectionNameKeyPath: nil,
                                                                   cacheName: nil)

        return aFetchedResultsController as! NSFetchedResultsController<T>
    }
}

protocol HasPersistentStore {
    var persistentStore: PersistentStoreService { get }
}

class PersistentStoreServiceImpl: PersistentStoreService {
    private struct Const {
        static let temperatureEntity = "Temperature"
        static let pressureEntity = "Pressure"
        static let serialEntity = "Serial"
        static let locationEntity = "Location"
        static let voltageEntity = "Voltage"
        static let pm1Entity = "PM1"
    }

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
                        switch doubleEntry.name {
                        case Const.temperatureEntity:
                            result.append(.temperature(doubleEntry))
                        case Const.pressureEntity:
                            result.append(.pressure(doubleEntry))
                        case Const.pm1Entity:
                            result.append(.pm1(doubleEntry))
                        case Const.voltageEntity:
                            result.append(.voltage(doubleEntry))
                        default:
                            break
                        }
                    } else if let serial = try? DataEntry<String>(json: json) {
                        if serial.name == Const.serialEntity {
                            result.append(.serial(serial))
                        }
                    } else if let location = try? DataEntry<[Double]>(json: json) {
                        if location.name == Const.locationEntity {
                            result.append(.location(location))
                        }
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
                        let object = NSEntityDescription.insertNewObject(forEntityName: Const.temperatureEntity, into: context) as! Temperature

                        object.measurementDate = Date(timeIntervalSince1970: measurement.0)
                        object.value = measurement.1
                        object.unit = entry.unit
                    }
                case .pressure(let entry):
                    guard let measurements = entry.measurements else { break }
                    for measurement in measurements {
                        let object = NSEntityDescription.insertNewObject(forEntityName: Const.pressureEntity, into: context) as! Pressure

                        object.measurementDate = Date(timeIntervalSince1970: measurement.0)
                        object.value = measurement.1
                        object.unit = entry.unit
                    }
                case .voltage(let entry):
                    guard let measurements = entry.measurements else { break }
                    for measurement in measurements {
                        let object = NSEntityDescription.insertNewObject(forEntityName: Const.voltageEntity, into: context) as! Voltage

                        object.measurementDate = Date(timeIntervalSince1970: measurement.0)
                        object.value = measurement.1
                        object.unit = entry.unit
                    }
                case .pm1(let entry):
                    guard let measurements = entry.measurements else { break }
                    for measurement in measurements {
                        let object = NSEntityDescription.insertNewObject(forEntityName: Const.pm1Entity, into: context) as! PM1

                        object.measurementDate = Date(timeIntervalSince1970: measurement.0)
                        object.value = measurement.1
                        object.unit = entry.unit
                    }
                case .serial(let entry):
                    guard let measurements = entry.measurements else { break }
                    for measurement in measurements {
                        let object = NSEntityDescription.insertNewObject(forEntityName: Const.serialEntity, into: context) as! Serial

                        object.measurementDate = Date(timeIntervalSince1970: measurement.0)
                        object.value = measurement.1
                    }
                case .location(let entry):
                    guard let measurements = entry.measurements else { break }
                    for measurement in measurements {
                        let object = NSEntityDescription.insertNewObject(forEntityName: Const.serialEntity, into: context) as! Location

                        object.measurementDate = Date(timeIntervalSince1970: measurement.0)
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
