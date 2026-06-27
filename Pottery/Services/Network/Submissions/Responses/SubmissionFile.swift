
struct SubmissionFile: Decodable {

    let id: String
    let fileName: String
    let url: String
    let mimeType: String
    let size: Int
    let type: String?

    enum CodingKeys: String, CodingKey {
        case id
        case fileName
        case url
        case mimeType
        case size
        case type
    }

    init(
        id: String,
        fileName: String,
        url: String,
        mimeType: String,
        size: Int,
        type: String?
    ) {
        self.id = id
        self.fileName = fileName
        self.url = url
        self.mimeType = mimeType
        self.size = size
        self.type = type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        fileName = try container.decode(String.self, forKey: .fileName)
        url = try container.decode(String.self, forKey: .url)
        mimeType = try container.decode(String.self, forKey: .mimeType)
        size = try container.decode(Int.self, forKey: .size)

        if let value = try? container.decodeIfPresent(String.self, forKey: .type) {
            type = value
        } else if let value = try? container.decodeIfPresent(Int.self, forKey: .type) {
            type = String(value)
        } else {
            type = nil
        }
    }
}
struct AssignmentFile: Decodable, Identifiable {
    let id: String
    let fileName: String
    let url: String
    let mimeType: String
    let size: Int64
    let type: String?
}
