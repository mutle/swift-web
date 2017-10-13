import XCTest
@testable import web

class WebRouterTestResource : WebResource {
  public override func respond(to request: WebRequest, action: String?) throws -> WebResponse? {
    return WebResponse(status: .ok, body: WebBody(string: "Hello, \(action ?? "world")!"))
  }
}

class WebRouterTests: XCTestCase {
  func testRouter() throws {
    let router = WebRouter()
    let resource = WebRouterTestResource()
    router.route("/test", resource: resource)
    router.route("/test/post", resource: resource, action: "post", methods: [.post])

    let r1 = router.route(request: WebRequest(method: .get, path: "/"))
    XCTAssertNil(r1)

    let r2 = router.route(request: WebRequest(method: .get, path: "/test"))
    XCTAssertNotNil(r2)

    let r3 = router.route(request: WebRequest(method: .get, path: "/test/post"))
    XCTAssertNil(r3)

    let req4 = WebRequest(method: .post, path: "/test/post")
    let r4 = router.route(request: req4)
    XCTAssertNotNil(r4)
  }

  func testRouterResponse() throws {
    let router = WebRouter()
    let resource = WebRouterTestResource()
    router.route("/test", resource: resource)

    let req = WebRequest(method: .get, path: "/test")
    let rr = router.route(request: req)
    XCTAssertNotNil(rr)
    guard let r = rr else { return }
    let rres = try r.respond(to: req)
    XCTAssertNotNil(rres)
    guard let res = rres else { return }
    XCTAssertEqual(WebResponseStatus.ok, res.status)
    XCTAssertNotNil(res.body)
    guard let b = res.body else { return }
    XCTAssertEqual("Hello, world!", b.stringValue)
  }

  func testRouterResponseAction() throws {
    let router = WebRouter()
    let resource = WebRouterTestResource()
    router.route("/test/post", resource: resource, action: "post", methods: [.post])

    let req = WebRequest(method: .post, path: "/test/post")
    let rr = router.route(request: req)
    XCTAssertNotNil(rr)
    guard let r = rr else { return }
    let rres = try r.respond(to: req)
    XCTAssertNotNil(rres)
    guard let res = rres else { return }
    XCTAssertEqual(WebResponseStatus.ok, res.status)
    XCTAssertNotNil(res.body)
    guard let b = res.body else { return }
    XCTAssertEqual("Hello, post!", b.stringValue)
  }

  func testStaticFiles() throws {
    let router = WebRouter()
    router.addStaticFiles(root: "Fixtures/public")
    let resource = WebRouterTestResource()
    router.route("/test", resource: resource)

    let req = WebRequest(method: .get, path: "/test")
    let rr = router.route(request: req)
    XCTAssertNotNil(rr)
    guard let r = rr else { return }
    let rres = try r.respond(to: req)
    XCTAssertNotNil(rres)
    guard let res = rres else { return }
    XCTAssertEqual(WebResponseStatus.ok, res.status)
    XCTAssertNotNil(res.body)
    guard let b = res.body else { return }
    XCTAssertEqual("Test\n", b.stringValue)
  }


  static var allTests = [
    ("testRouter", testRouter),
    ("testRouterResponse", testRouterResponse),
    ("testRouterResponseAction", testRouterResponseAction),
    ("testStaticFiles", testStaticFiles)
  ]
}
