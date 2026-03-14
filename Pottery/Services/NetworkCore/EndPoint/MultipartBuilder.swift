import Foundation

enum MultipartBuilder {

    static func buildBody(
        parts: [MultipartFormData],
        boundary: String
    ) -> Data {

        var body = Data()

        for part in parts {

            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(part.name)\"; filename=\"\(part.filename)\"\r\n")
            body.append("Content-Type: \(part.mimeType)\r\n\r\n")
            body.append(part.data)
            body.append("\r\n")
        }

        body.append("--\(boundary)--\r\n")

        return body
    }
}

extension Data {

    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }

}
