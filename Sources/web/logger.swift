import Foundation

public class WebLoggerExtension : WebServerExtension {
  public init() {
  }

  public func handle(event: String, message: String, data: [String : Any]?) -> Bool {
    if event == "completed", let data = data, let request = data["request"] as? WebRequest, let response = data["response"] as? WebResponse {
      var extra = ""
      let query = request.queryItems
      if query.count > 0 {
        extra.append("query=\(query.map { "\($0)=\($1 ?? "")"}) ")
      }
      print("method=\(request.method.rawValue) path=\(request.path) \(extra)status=\(response.status.rawValue) t=\(request.timeElapsed)ms")
    }
    return false
  }
}
