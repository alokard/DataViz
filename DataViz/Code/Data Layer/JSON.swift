import Foundation

typealias JSON = [String: Any]

protocol Parsable {
    static func parseFrom(_ object: Any) -> Self?
    static func parseFrom(_ object: Any) throws -> Self
}

enum JSONParsingError: Error {
    case noValueForKey(key: Any)
    case invalidTypeCast(from: Any.Type, to: Any.Type)
}

extension Parsable {
    static func parseFrom(_ object: Any) -> Self? {
        return object as? Self
    }

    static func parseFrom(_ object: Any) throws -> Self {
        let value: Self? = parseFrom(object)
        guard let result = value else {
            throw JSONParsingError.invalidTypeCast(from: type(of: object), to: Self.self)
        }
        return result
    }
}

extension String: Parsable {
    static func parseFrom(_ object: Any) -> String? {

        switch object {
        case let value as String:
            return value
        case let value as [String]:
            guard value.count > 0 else { return nil }
            return value[0]
        case let value as Int:
            return String(value)
        default:
            return nil
        }
    }
}

extension URL: Parsable {
    static func parseFrom(_ object: Any) -> URL? {
        return String.parseFrom(object).flatMap { URL(string: $0) }
    }
}

extension Int: Parsable {}
extension Bool: Parsable {}
extension Float: Parsable {}
extension Double: Parsable {}
extension Dictionary: Parsable {}

extension Dictionary where Value: Any {
    func parse<T: Parsable>(_ key: Key) -> T? {
        guard let object = self[key] else { return nil }
        return T.parseFrom(object)
    }

    func parse<T: Parsable>(_ key: Key) throws -> T {
        if let value = self[key] {
            return try T.parseFrom(value)
        } else {
            throw JSONParsingError.noValueForKey(key: key)
        }
    }

    func parse(_ key: Key) -> [Any]? {
        return try? parse(key)
    }

    func parse(_ key: Key) throws -> [Any] {
        if let value = self[key] {
            if let result = value as? [Any] {
                return result
            } else {
                throw JSONParsingError.invalidTypeCast(from: type(of: value), to: [Any].self)
            }
        } else {
            throw JSONParsingError.noValueForKey(key: key)
        }
    }

    func parse<T: Parsable>(_ key: Key) -> [T]? {
        return try? parse(key)
    }

    func parse<T: Parsable>(_ key: Key) throws -> [T] {
        if let value = self[key] {
            if let result = value as? [Any] {
                return try result.map {
                    return try T.parseFrom($0)
                }
            } else {
                throw JSONParsingError.invalidTypeCast(from: type(of: value), to: [Any].self)
            }
        } else {
            throw JSONParsingError.noValueForKey(key: key)
        }
    }
}
