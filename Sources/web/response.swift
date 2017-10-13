import Foundation

public class WebResponse {
  public let status : WebResponseStatus
  public let headers : [String : Any]
  public var cookies : [String : String]
  public let body : WebBody?

  public init(status: WebResponseStatus, headers: [String : Any] = [:], body: WebBody? = nil) {
    self.status = status
    self.headers = headers
    self.body = body
    self.cookies = [:]
  }

  public class func redirect(to location: String) -> WebResponse {
    return WebResponse(status: .movedTemporarily, headers: ["Location" : location], body: WebBody(string: ""))
  }
}
