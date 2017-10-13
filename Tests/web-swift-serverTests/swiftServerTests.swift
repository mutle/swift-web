import XCTest
import Foundation
import Dispatch
import web
@testable import web_swift_server

let testPort = 19921

class WebSwiftServerTest: XCTestCase {
  func testClientAndServer() throws {
    let adapter = WebSwiftServerAdapter()
    let responder = WebActionResponder() { request in
      return WebResponse(status: .ok, body: WebBody(string: "test"))
    }
    let server = WebServer(adapter: adapter, responder: responder, port: testPort)
    let semaphore = DispatchSemaphore(value: 0)
    DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
      do {
        semaphore.signal()
        try server.run()
      } catch {
        print("Server run error \(error)")
      }
    }
    semaphore.wait()
    do {
      let c = WebClient(adapter: adapter)
      let res = try c.fetch(request: WebRequest(method: .get, path: "/", host: "localhost", port: testPort))
      if let r = res, let body = r.body {
        XCTAssertEqual("test", body.stringValue)
      } else {
        XCTFail("Missing body")
      }
    } catch {
      print("Client error \(error)")
    }
    do {
      try server.stop()
    } catch {
      print("Server stop error \(error)")
    }
  }


  static var allTests = [
    ("testClientAndServer", testClientAndServer),
  ]
}
