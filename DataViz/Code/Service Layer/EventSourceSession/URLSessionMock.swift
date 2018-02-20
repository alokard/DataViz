import Foundation
@testable import DataViz

class URLSessionMock: URLSessionProtocol {
    let dataTaskMock = URLSessionDataTaskMock()

    private(set) var dataTaskInvoked: Bool = false
    private(set) var dataTaskUrl: URL?
    private(set) var invalidateAndCancelInvoked: Bool = false

    func dataTask(with url: URL) -> URLSessionDataTaskProtocol {
        dataTaskInvoked = true
        dataTaskUrl = url
        return dataTaskMock
    }

    func invalidateAndCancel() {
        invalidateAndCancelInvoked = true
    }
}

class URLSessionDataTaskMock: URLSessionDataTaskProtocol {
    private(set) var resumeInvoked: Bool = false
    func resume() {
        resumeInvoked = true
    }
}
