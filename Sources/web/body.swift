import Foundation

public class WebBody {
  public let data: Data

  public var stringValue: String? {
    return String(data: data as Data, encoding: String.Encoding.utf8)
  }

  public var jsonValue: [String : Any]? {
    do {
      return try JSONSerialization.jsonObject(with: self.data) as? [String : Any]
    } catch {
      return nil
    }
  }

  public var raw: [UInt8] {
    let count = self.data.count / MemoryLayout<UInt8>.size
    var array = [UInt8](repeating: 0, count: count)
    self.data.copyBytes(to: &array, count: count * MemoryLayout<UInt8>.size)
    return array
  }

  public init(data: Data) {
    self.data = data
  }

  public init(raw: [UInt8]) {
    self.data = Data(bytes: raw)
  }

  public init?(string: String) {
    guard let data = string.data(using: String.Encoding.utf8) else { return nil }
    self.data = data
  }

  public init?(json: [String : Any]) {
    do {
      let data = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
      self.data = data
    } catch {
      return nil
    }
  }

  public init(file: String) throws {
    self.data = try Data(contentsOf: URL(fileURLWithPath: file))
  }
}
