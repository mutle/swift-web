import XCTest
@testable import webTests
@testable import web_swift_serverTests

XCTMain([
  testCase(WebAdapterTests.allTests),
  testCase(WebBodyTests.allTests),
  testCase(WebClientTests.allTests),
  testCase(WebRequestTests.allTests),
  testCase(WebResourceTests.allTests),
  testCase(WebResponseTests.allTests),
  testCase(WebRouterTests.allTests),
  testCase(WebServerTests.allTests),
  testCase(WebSwiftServerTest.allTests)
])
