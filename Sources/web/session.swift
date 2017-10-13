import Foundation

public protocol WebSession {
  static func session(apiKey: String) -> WebSession?
  static func session(uuid: String) -> WebSession?
}

open class WebSessionExtension<Session : WebSession> : WebServerExtension {
  public init() {
  }

  open func cookieName() -> String {
    return "web-session"
  }

  public func handle(event: String, message: String, data: [String : Any]?) -> Bool {
    if event == "started", let data = data, let request = data["request"] as? WebRequest, data["response"] == nil {
      if let item = request.queryItems.first(where: { $0.0 == "apiKey" }), let apiKey = item.1 {
        if let session = Session.session(apiKey: apiKey) {
          request.storage["session"] = session as Any
        }
      } else {
        let (cookie, createdCookie) = self.getOrCreateCookie(request: request)
        if let session = Session.session(uuid: cookie) {
          request.storage["session"] = session as Any
          if createdCookie {
            request.storage["Set-Cookie"] = [self.cookieName() : cookie]
          }
        }
      }
    }
    return false
  }

  private func getOrCreateCookie(request: WebRequest) -> (String, Bool) {
    if let requestCookie = request.cookies[self.cookieName()] {
      return (requestCookie, false)
    }
    return (UUID().uuidString, true)
  }
}
