import Foundation

struct Ticket: Identifiable, Codable {
    var id: UUID
    var title: String
    var description: String
    var status: TicketStatus
    var priority: TicketPriority
    var assignedToId: UUID?
    var createdById: UUID
    var createdAt: Date
    var updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case status
        case priority
        case assignedToId = "assigned_to_id"
        case createdById = "created_by_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum TicketStatus: String, Codable {
    case open = "open"
    case inProgress = "in_progress"
    case resolved = "resolved"
    case closed = "closed"
}

enum TicketPriority: String, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case urgent = "urgent"
}
