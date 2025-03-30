import Foundation

struct Transaction: Identifiable, Codable {
    var id: UUID
    var amount: Double
    var description: String
    var type: TransactionType
    var status: TransactionStatus
    var userId: UUID
    var createdAt: Date
    var updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case amount
        case description
        case type
        case status
        case userId = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum TransactionType: String, Codable {
    case payment = "payment"
    case refund = "refund"
    case deposit = "deposit"
    case withdrawal = "withdrawal"
}

enum TransactionStatus: String, Codable {
    case pending = "pending"
    case completed = "completed"
    case failed = "failed"
    case cancelled = "cancelled"
}
