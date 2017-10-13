import Foundation

public protocol WebServerExtension {
  func handle(event: String, message: String, data: [String : Any]?) -> Bool
}
