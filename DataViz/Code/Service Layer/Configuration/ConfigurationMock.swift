import Foundation
@testable import DataViz

class ConfigurationMock: Configuration {
    var environmentName: String = ""
    var apiPath: String = ""
    var appVersion: String = ""
    var appName: String = ""
    var buildVersion: String = ""

    init() { }
}

