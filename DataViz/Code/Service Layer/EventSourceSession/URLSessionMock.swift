import Foundation
@testable import DataViz

class URLSessionMock: URLSessionProtocol {
    let dataTaskMock = URLSessionDataTaskMock()

    var dataTaskInvoked: Bool = false
    var dataTaskUrl: URL?
    var invalidateAndCancelInvoked: Bool = false

    private(set) var delegate: URLSessionDelegate? //Mimic URLSession behevior
    init(delegate: URLSessionDelegate?) {
        self.delegate = delegate
    }

    func dataTask(with url: URL) -> URLSessionDataTaskProtocol {
        dataTaskInvoked = true
        dataTaskUrl = url
        return dataTaskMock
    }

    func invalidateAndCancel() {
        delegate = nil
        invalidateAndCancelInvoked = true
    }
}

class URLSessionDataTaskMock: URLSessionDataTaskProtocol {
    var resumeInvoked: Bool = false
    func resume() {
        resumeInvoked = true
    }
}
