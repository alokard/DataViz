import Foundation
@testable import DataViz

class ConfigurationMock: Configuration {
    var environmentName: String = ""
    var apiUrl: URL? = URL(string: "http://test.com")
    var appVersion: String = ""
    var appName: String = ""
    var buildVersion: String = ""

    init() { }
}

