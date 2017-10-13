import Foundation
import Dispatch
import HTTP
import web

public class WebSwiftServerAdapter : WebAdapter {
  var server: HTTPServer? = nil
  var responder: WebResponder? = nil
  var extensions: [WebServerExtension]? = nil

  public init() {
  }

  public func log(message: String) {
    print(message)
  }

  func handler(request: HTTPRequest, response: HTTPResponseWriter) -> HTTPBodyProcessing {
    var bodyData = Data()
    return .processBody(handler:  { (chunk: HTTPBodyChunk, done: inout Bool) in
      switch chunk {
      case .chunk(let data, let finishedProcessing):
        let d = [UInt8](data)
        bodyData.append(contentsOf: d)
        finishedProcessing()
        return
      case .end:
        break
      default:
        return
      }
      do {
        if let responder = self.responder,
          let wreq = try self.request(request: request, data: bodyData) {
          let _ = self.handle(event: "started", message: "start", data: [
            "request" : wreq
          ])
          if let wres = try responder.respond(to: wreq) {
            let _ = self.handle(event: "response", message: "done", data: [
              "request" : wreq,
              "response" : wres
            ])
            let status = self.response(status: wres.status)
            let headers = self.responseHeaders(response: wres, request: wreq)
            response.writeHeader(status: status, headers: headers)
            if let body = wres.body {
              response.writeBody(body.data)
            }
            response.done()
            let _ = self.handle(event: "completed", message: "done", data: [
              "request" : wreq,
              "response" : wres
            ])
            return
          }
        }
      } catch {
        print("\(error)")
      }
      response.writeHeader(status: .notFound)
      response.writeBody("Not found")
      response.done()
    })
  }

  public func runServer(responder: WebResponder, extensions: [WebServerExtension] = [], port: Int) throws {
    let server = HTTPServer()
    try! server.start(port: port, handler: self.handler)
    self.responder = responder
    self.extensions = extensions
    self.server = server
    // CFRunLoopRun()
    RunLoop.current.run()
  }

  public func stopServer() throws {
    if let server = self.server {
      server.stop()
      self.server = nil
    }
  }

  func request(request: HTTPRequest, data: Data) throws -> WebRequest? {
    if let method = WebMethod(rawValue: request.method.method) {
      var headers = [String : String]()
      for header in request.headers {
        headers[header.name.description] = header.value
      }
      var target = request.target.components(separatedBy: "?")
      let path = target.removeFirst()
      let query = target.count > 0 ? target.joined(separator: "?") : ""
      return WebRequest(method: method, path: path, query: query, headers: headers, body: WebBody(data: data))
    }
    return nil
  }

  func response(status: WebResponseStatus) -> HTTPResponseStatus {
    return HTTPResponseStatus(code: status.rawValue)
  }

  func responseHeaders(response: WebResponse, request: WebRequest) -> HTTPHeaders {
    var headers = HTTPHeaders()
    for (name,value) in response.headers {
      if let sval = value as? String {
        let n = HTTPHeaders.Name(name)
        headers[n] = sval
      }
    }
    let setcookies = response.cookies.count > 0 ? response.cookies : request.storage["Set-Cookie"] as? [String : String] ?? [:]
    if setcookies.count > 0 {
      var cookies = [String]()
      for (name,value) in setcookies {
        cookies.append("\(name)=\(value)")
      }
      headers["Set-Cookie"] = cookies.joined(separator: "&")
    }
    return headers
  }

  func handle(event: String, message: String, data: [String : Any]?) -> Bool {
    if let extensions = self.extensions {
      for ext in extensions {
        if ext.handle(event: event, message: message, data: data) {
          return true
        }
      }
    }
    return false
  }
}
