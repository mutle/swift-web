import Foundation

public class WebRouter : WebResponder {
  public var routes: [WebRoute]

  public init() {
    self.routes = [WebRoute]()
  }

  public func route(_ path: String, resource: WebResource, action: String? = nil, methods: [WebMethod]? = nil) {
    self.routes.append(WebRoute(methods: methods, path: path, resource: resource, action: action))
  }

  public func route(_ path: String, methods: [WebMethod]? = nil, response: @escaping WebResponderAction) {
    self.routes.append(WebRoute(methods: methods, path: path, response: response))
  }

  public func route(_ path: String, methods: [WebMethod]? = nil, responder: WebResponder) {
    self.routes.append(WebRoute(methods: methods, path: path, responder: responder))
  }

  public func route(_ path: String, methods: [WebMethod]? = nil, file: String) {
    self.routes.append(WebRoute(methods: methods, path: path, file: file))
  }

  public func route(_ path: [Any], methods: [WebMethod]? = nil, file: String) {
    self.routes.append(WebRoute(methods: methods, pathComponents: path, file: file))
  }

  public func respond(to request: WebRequest) throws -> WebResponse? {
    if let route = self.route(request: request) {
      return try route.respond(to: request)
    }
    return WebResponse(status: .notFound)
  }

  public func route(request: WebRequest) -> WebRoute? {
    for route in self.routes {
      if route.matches(request: request) {
        return route
      }
    }
    return nil
  }

  public func addStaticFiles(root: String) {
    let fm = FileManager.default
    if let en = fm.enumerator(atPath: root) {
      for file in en {
        if let file = file as? String {
          var isDir = ObjCBool(false)
          if fm.fileExists(atPath: "\(root)/\(file)", isDirectory: &isDir) {
            #if !os(Linux)
              if isDir.boolValue { continue }
            #else
              if isDir { continue }
            #endif
            var comps = file.components(separatedBy: "/")
            let fn = comps.removeLast()
            switch fn {
            case "index.html":
              let route = WebRoute(methods: [.get], path: "/\(comps.joined(separator: "/"))", file: "\(root)/\(file)")
              self.routes.append(route)
              break
            default:
              break
            }
            let route = WebRoute(methods: [.get], path: "/\(file)", file: "\(root)/\(file)")
            self.routes.append(route)
          }
        }
      }
    }
  }
}
