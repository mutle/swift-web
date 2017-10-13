import Foundation

public class WebServer {
  public let adapter : WebAdapter
  public let responder : WebResponder
  public let port : Int?
  public let extensions : [WebServerExtension]

  public init(adapter: WebAdapter, responder: WebResponder, extensions: [WebServerExtension] = [], port: Int? = nil) {
    self.adapter = adapter
    self.responder = responder
    self.extensions = extensions
    self.port = port
  }

  public func run() throws {
    try self.adapter.runServer(responder: self.responder, extensions: self.extensions, port: self.port ?? 8080)
  }

  public func stop() throws {
    try self.adapter.stopServer()
  }
}
