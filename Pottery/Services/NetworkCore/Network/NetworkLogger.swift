import Foundation

enum NetworkLogger {
    static var isEnabled: Bool = true

    static func log(_ message: String) {
        guard isEnabled else { return }
        print(message)
    }

    static func maskToken(_ value: String?) -> String {
        guard let value, !value.isEmpty else { return "nil" }
        if value.count <= 10 { return "***" }
        let prefix = value.prefix(6)
        let suffix = value.suffix(4)
        return "\(prefix)…\(suffix)"
    }

    static func prettyJSON(_ data: Data) -> String? {
        guard
            let object = try? JSONSerialization.jsonObject(with: data),
            let prettyData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let prettyString = String(data: prettyData, encoding: .utf8)
        else { return nil }
        return prettyString
    }

    static func clip(_ string: String?, limit: Int = 1500) -> String {
        guard let string else { return "" }
        if string.count <= limit { return string }
        let idx = string.index(string.startIndex, offsetBy: limit)
        return String(string[..<idx]) + "\n…(clipped)"
    }
}
