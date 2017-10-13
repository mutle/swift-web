import XCTest
@testable import web

class TestAdapter : WebAdapter {
  var server = 0

  func log(message: String) {
    print(message)
  }

  func stopServer() throws {
    self.server = 0
  }

  func runServer(responder: WebResponder, extensions: [WebServerExtension], port: Int) throws {
    self.server = port
  }
}

class WebAdapterTests: XCTestCase {
  func testServer() throws {
    let a = TestAdapter()
    let router = WebRouter()
    let s = WebServer(adapter: a, responder: router, port: 19980)
    XCTAssertEqual(0, a.server)
    try s.run()
    XCTAssertEqual(19980, a.server)
    try s.stop()
    XCTAssertEqual(0, a.server)
  }


  static var allTests = [
    ("testServer", testServer),
  ]
}
