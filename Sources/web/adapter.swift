public protocol WebAdapter {
  func log(message: String)
  func runServer(responder: WebResponder, extensions: [WebServerExtension], port: Int) throws
  func stopServer() throws
}
