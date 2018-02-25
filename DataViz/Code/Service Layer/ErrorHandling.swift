import RxSwift
import RxCocoa

protocol ErrorHandling: class {
    var errorSubject: PublishSubject<[Error]>? { get }

    func record(error: Error, additionalInfo: [String: Any]?)
}

protocol HasErrorHandler {
    var errorHandler: ErrorHandling { get }
}

extension ErrorHandling {
    public var errorSubject: PublishSubject<[Error]>? { return nil }

    func handle(error: Error) {
        handle(errors: [error])
    }

    func handle(errors: [Error], silent: Bool = false) {
        var publish: [Error] = []
        for error in errors {
            if !silent {
                publish.append(error)
            }
        }

        if let subject = errorSubject, !publish.isEmpty {
            subject.onNext(publish)
        }
    }

    func log(error: Error) {
        let error = error as NSError
        var additionalInfo: [String: Any] = [
            "dataviz.handlerDescription": String(describing: type(of: self)),
            ]

        if type(of: error) != NSError.self {
            additionalInfo["dataviz.errorDescription"] = String(describing: error)
        }

        record(error: error, additionalInfo: additionalInfo)
    }

    func observe(errors: [ErrorHandling]) -> Disposable? {
        guard let subject = errorSubject, !errors.isEmpty else {
            return nil
        }

        let errorSubjects = errors.flatMap { $0.errorSubject }
        return Observable.from(errorSubjects).merge().bind(to: subject)
    }

    func record(error: Error, additionalInfo: [String: Any]?) {
        #if DEBUG
            print("⚠️ \(error)")
            if let info = additionalInfo {
                print("\(info)")
            }
        #else
            //TODO: Record error with some monitoring tool like Crashlytics
        #endif
    }
}
