import Foundation

public enum WebRouteValue {
case int
case string
}

public struct WebRoute : WebResponder {
  public let methods: [WebMethod]
  public let path: String
  public let pathComponents: [Any]?
  public let file: String?
  public let resource: WebResource?
  public let response: WebResponderAction?
  public let responder: WebResponder?
  public let action: String?

  public init(methods: [WebMethod]? = nil, path: String, resource: WebResource, action: String? = nil) {
    self.methods = methods ?? [.get, .post]
    self.path = path
    self.pathComponents = nil
    self.file = nil
    self.resource = resource
    self.response = nil
    self.responder = nil
    self.action = action
  }

  public init(methods: [WebMethod]? = nil, path: String, response: @escaping WebResponderAction) {
    self.methods = methods ?? [.get, .post]
    self.path = path
    self.pathComponents = nil
    self.file = nil
    self.resource = nil
    self.response = response
    self.responder = nil
    self.action = nil
  }

  public init(methods: [WebMethod]? = nil, path: String, file: String) {
    self.methods = methods ?? [.get, .post]
    self.path = path
    self.pathComponents = nil
    self.file = file
    self.resource = nil
    self.response = nil
    self.responder = nil
    self.action = nil
  }

  public init(methods: [WebMethod]? = nil, pathComponents: [Any], file: String) {
    self.methods = methods ?? [.get, .post]
    self.path = ""
    self.pathComponents = pathComponents
    self.file = file
    self.resource = nil
    self.response = nil
    self.responder = nil
    self.action = nil
  }

  public init(methods: [WebMethod]? = nil, path: String, responder: WebResponder? = nil) {
    self.methods = methods ?? [.get, .post]
    self.path = path
    self.pathComponents = nil
    self.file = nil
    self.resource = nil
    self.response = nil
    self.responder = responder
    self.action = nil
  }

  public init(methods: [WebMethod]? = nil, pathComponents: [Any], responder: WebResponder? = nil) {
    self.methods = methods ?? [.get, .post]
    self.pathComponents = pathComponents
    self.path = ""
    self.file = nil
    self.resource = nil
    self.response = nil
    self.responder = responder
    self.action = nil
  }

  public func matches(request: WebRequest) -> Bool {
    // print("Req \(request.method) \(request.path) Route \(methods) \(path)")
    if !methods.contains(request.method) { return false }
    if let c = self.pathComponents, c.count > 0 {
      var input = request.path
      var noMatch = false
      for comp in c {
        if var b = comp as? String {
          repeat {
            if input.count < 1 { noMatch = true; break}
            let ic = input.removeFirst()
            let bc = b.removeFirst()
            if ic != bc { noMatch = true; break }
            if b.count < 1 { break }
          } while true
        } else if let type = comp as? WebRouteValue {
          var value = ""
          repeat {
            let ic = input.removeFirst()
            if ic == "/" || input.count < 1 { break }
            value.append(ic)
          } while true
          switch type {
          case .int:
            if Int(value) == nil {
              noMatch = true
            }
            break
          case .string:
            break
          }
        }
        if noMatch { break }
      }
      if input.count == 0 && !noMatch { return true }
    }
    if request.path != path { return false }
    return true
  }

  public func respond(to request: WebRequest) throws -> WebResponse? {
    if let file = self.file {
      do {
        let body = try WebBody(file: file)
        return WebResponse(status: .ok, body: body)
      } catch {
      }
    }
    if let resource = self.resource, let res = try resource.respond(to: request, action: self.action) {
      return res
    }
    if let response = self.response {
      return try response(request)
    }
    if let responder = self.responder {
      return try responder.respond(to: request)
    }
    return WebResponse(status: .internalError)
  }
}
