import Foundation

protocol ViewModel {
    associatedtype Context
    associatedtype Input
    associatedtype Data
    associatedtype Handlers

    init(context: Context, input: Input, data: Data, handlers: Handlers)
}

extension ViewModel {
    typealias CreateHandler = (Input) -> Self
    static func create(context: Context, data: Data, handlers: Handlers) -> CreateHandler {
        return { input in
            return Self(context: context, input: input, data: data, handlers: handlers)
        }
    }
}

