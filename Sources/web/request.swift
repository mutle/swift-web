import Foundation

public class WebRequest {
  public let method : WebMethod
  public let path : String
  public let query : String?
  public let headers : [String : String]
  public var storage : [String : Any]
  public let body : WebBody?
  public let host: String?
  public let port: Int?

  public init(method: WebMethod, path: String, host: String? = nil, query: String? = nil, port: Int? = nil, headers: [String : String] = [:], body: WebBody? = nil) {
    self.method = method
    self.path = path
    self.query = query
    self.host = host
    self.port = port
    self.headers = headers
    self.storage = ["start-time" : Date() as Any]
    self.body = body
  }

  public convenience init?(method: WebMethod, uri: String, headers: [String : String] = [:], body: WebBody? = nil) {
    guard let url = URL(string: uri) else { return nil }
    self.init(method: method, path: url.path, host: url.host, port: url.port, headers: headers, body: body)
  }

  public var uri: String? {
    let port = self.port != nil ? ":\(self.port!)" : ""
    if let host = host {
      return "http://\(host)\(port)\(self.path)"
    }
    return nil
  }

  public var queryItems: [(String, String?)] {
    if let query = self.query, let comps = URLComponents(string: "http://localhost?\(query)"), let items = comps.queryItems {
      return items.map { ($0.name, $0.value) }
    }
    return []
  }

  public var cookies : [String : String] {
    if var cookies = headers["Cookie"] {
      let index = cookies.index(of: ";") ?? cookies.endIndex
      cookies = String(cookies[..<index])
      if let comps = URLComponents(string: "http://localhost?\(cookies)"), let items = comps.queryItems {
      var res = [String : String]()
      for item in items {
        res[item.name] = item.value
      }
      return res
    }
    }
    return [:]
  }

  public var timeElapsed : Int {
    if let start = self.storage["start-time"] as? Date {
      return Int(-start.timeIntervalSinceNow * 1000)
    }
    return 0
  }
}
