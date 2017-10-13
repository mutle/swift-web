import XCTest
@testable import web

class TestResource : WebResource {
  public override func actions() -> [String : WebResponderAction]? {
    return [
      "test" : testAction
    ]
  }

  func testAction(_ request: WebRequest) throws -> WebResponse? {
    return WebResponse(status: .ok)
  }
}

class WebResourceTests: XCTestCase {
  func testResourceActions() throws {
    let res = TestResource()
    let request = WebRequest(method: .get, path: "/")

    let rr1 = try res.respond(to: request)
    guard let r1 = rr1 else { return }
    XCTAssertEqual(.notFound, r1.status)

    let rr2 = try res.respond(to: request, action: "test")
    XCTAssertNotNil(rr2)
    guard let r2 = rr2 else { return }
    XCTAssertEqual(.ok, r2.status)
  }


  static var allTests = [
    ("testResourceActions", testResourceActions),
  ]
}
