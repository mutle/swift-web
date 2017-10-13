import XCTest
@testable import web

class WebBodyTests: XCTestCase {
  func testString() {
    let body = WebBody(string: "test")
    XCTAssertNotNil(body)
    if let body = body {
      XCTAssertEqual("test", body.stringValue)
    }
  }

  func testJSON() {
    let body = WebBody(json: ["test" : "foo"])
    XCTAssertNotNil(body)
    if let body = body {
      #if !os(Linux)
        XCTAssertEqual("{\n  \"test\" : \"foo\"\n}", body.stringValue)
      #else
        XCTAssertEqual("{\n  \"test\": \"foo\"\n}", body.stringValue)
      #endif
      let json = body.jsonValue
      XCTAssertNotNil(json)
      if let json = json {
        XCTAssertEqual("foo", json["test"] as? String)
      }
    }
  }


  static var allTests = [
    ("testString", testString),
    ("testJSON", testJSON)
  ]
}
