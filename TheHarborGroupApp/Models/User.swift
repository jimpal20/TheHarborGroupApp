import Foundation

struct User: Identifiable, Codable {
    var id: UUID
    var email: String
    var firstName: String?
    var lastName: String?
    var role: String?
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case role
        case createdAt = "created_at"
    }
}
