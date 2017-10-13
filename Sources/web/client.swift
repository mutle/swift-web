import Foundation
import Dispatch

public class WebClient {
  public let adapter : WebAdapter

  public init(adapter: WebAdapter) {
    self.adapter = adapter
  }

  public func fetch(request: WebRequest) throws -> WebResponse? {
    if let uri = request.uri, let url = URL(string: uri) {
      let semaphore = DispatchSemaphore(value: 0)
      var res: WebResponse? = nil
      let task = URLSession(configuration: URLSessionConfiguration.default).dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
        if let r = response as? HTTPURLResponse, let status = WebResponseStatus(rawValue: r.statusCode) {
          var headers = [String : String]()
          for (name, value) in r.allHeaderFields {
            if let n = name as? String, let v = value as? String {
              headers[n] = v
            }
          }
          if let data = data {
            res = WebResponse(status: status, headers: headers, body: WebBody(data: data))
          } else {
            res = WebResponse(status: status, headers: headers)
          }
        }
        semaphore.signal()
      }
      task.resume()
      semaphore.wait()
      return res
    }
    return nil
  }
}
