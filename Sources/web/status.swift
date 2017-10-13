public enum WebResponseStatus : Int {
case ok = 200
case created = 201
case movedPermanently = 301
case movedTemporarily = 302
case badRequest = 400
case unauthorized = 403
case notFound = 404
case internalError = 500
}

public let messages : [WebResponseStatus : String] = [
  .ok : "OK",
  .notFound : "Not Found",
  .internalError : "Internal Server Error"
]
