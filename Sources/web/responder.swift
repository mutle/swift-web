public typealias WebResponderAction = (_ request: WebRequest) throws -> WebResponse?

public protocol WebResponder {
  func respond(to request: WebRequest) throws -> WebResponse?
}

public struct WebActionResponder : WebResponder {
  public let action: WebResponderAction

  public init(action: @escaping WebResponderAction) {
    self.action = action
  }

  public func respond(to request: WebRequest) throws -> WebResponse? {
    return try action(request)
  }
}
