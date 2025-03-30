import Foundation

struct Resource: Identifiable, Codable {
    var id: UUID
    var title: String
    var description: String
    var fileUrl: String?
    var type: ResourceType
    var createdById: UUID
    var createdAt: Date
    var updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case fileUrl = "file_url"
        case type
        case createdById = "created_by_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum ResourceType: String, Codable {
    case document = "document"
    case image = "image"
    case video = "video"
    case link = "link"
    case other = "other"
}
