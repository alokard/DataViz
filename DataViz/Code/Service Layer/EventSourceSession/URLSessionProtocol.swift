import Foundation

protocol URLSessionProtocol: class {
    func dataTask(with url: URL) -> URLSessionDataTaskProtocol
    func invalidateAndCancel()
}

extension URLSession: URLSessionProtocol {
    func dataTask(with url: URL) -> URLSessionDataTaskProtocol {
        return (dataTask(with: url) as URLSessionDataTask) as URLSessionDataTaskProtocol
    }
}

protocol URLSessionDataTaskProtocol {
    func resume()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol { }
