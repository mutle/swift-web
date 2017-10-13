import Foundation

open class WebResource : WebResponder {
  public init() {
  }

  open func actions() -> [String : WebResponderAction]? {
    return nil
  }

  open func respond(to request: WebRequest) throws -> WebResponse? {
    return try self.respond(to: request, action: nil)
  }

  open func respond(to request: WebRequest, action: String?) throws -> WebResponse? {
    if let actions = self.actions() {
      let action = action ?? "default"
      if let a = actions[action] {
        return try a(request)
      }
    }
    return WebResponse(status: .notFound)
  }
}
