import Foundation


enum ConfigurationError: Error {
    case missedItem(String)
    case wrongItemType(String)
    case notInitialized
}

protocol Configuration {
    var environmentName: String { get }

    var appName: String { get }
    var appVersion: String { get }
    var buildVersion: String { get }
    var apiPath: String { get }
}

protocol HasConfiguration {
    var configuration: Configuration { get }
}

protocol Environment {
    var bundle: Bundle { get }
    var configUrl: URL? { get }
}

struct AppEnvironment: Environment {
    private let configKey = "AppConfigName"
    var bundle: Bundle { return Bundle.main }
    var configUrl: URL? {
        let configName = bundle.object(forInfoDictionaryKey: configKey) as? String
        return bundle.url(forResource: configName, withExtension: "plist")
    }
}

class ConfigurationImpl {
    private let store: [String : Any]
    private let dataLock = NSLock()
    
    private let environment: Environment
    
    public init(environment: Environment) {
        self.environment = environment
        guard let configUrl = environment.configUrl else {
            store = [:]
            return
        }
        store = NSDictionary(contentsOf: configUrl) as? [String : Any] ?? [:]
    }

    private func getValueForKey<T>(_ key: String, get: (String) throws -> T, default: T) -> T {
        do {
            return try get(key)
        } catch {
            if let handler = self as? ErrorHandling {
                handler.handle(error: error)
            }
            return `default`
        }
    }
    
    private func getValueForKey<T>(_ key: String, default: T) -> T {
        return getValueForKey(key, get: { try getValueForKey($0) }, default: `default`)
    }
    
    private func getValueForKey<T>(_ key: String) throws -> T {
        dataLock.lock()
        defer { dataLock.unlock() }
        
        if store.isEmpty {
            throw ConfigurationError.notInitialized
        }
        
        let data = store[key]
        switch data {
        case let value as T:
            return value
        case let value where value == nil:
            throw ConfigurationError.missedItem(key)
        default:
            throw ConfigurationError.wrongItemType(key)
        }
    }
}

extension ConfigurationImpl: Configuration {
    public var environmentName: String {
        return getValueForKey("environment", default: "")
    }

    public var appVersion: String {
        let info = environment.bundle.infoDictionary!
        return info["CFBundleShortVersionString"] as! String
    }
    
    public var buildVersion: String {
        let info = environment.bundle.infoDictionary!
        return info[kCFBundleVersionKey as String] as! String
    }
    
    public var appName: String {
        let info = environment.bundle.infoDictionary!
        return info[kCFBundleNameKey as String] as! String
    }

    public var apiPath: String {
        return getValueForKey("apiUrl", default: appName)
    }
}

