import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    
    private var client: SupabaseClient
    
    private init() {
        guard let url = URL(string: SupabaseConfig.supabaseUrl) else {
            fatalError("Invalid Supabase URL")
        }
        
        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: SupabaseConfig.supabaseKey
        )
    }
    
    // MARK: - Authentication
    
    func signUp(email: String, password: String) async throws -> User {
        let authResponse = try await client.auth.signUp(
            email: email,
            password: password
        )
        
        guard let user = authResponse.user else {
            throw NSError(domain: "SupabaseManager", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Failed to create user"])
        }
        
        // Convert to your app's User model
        return try await fetchUserProfile(userId: user.id)
    }
    
    func signIn(email: String, password: String) async throws -> User {
        let authResponse = try await client.auth.signIn(
            email: email,
            password: password
        )
        
        guard let user = authResponse.user else {
            throw NSError(domain: "SupabaseManager", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Failed to sign in"])
        }
        
        return try await fetchUserProfile(userId: user.id)
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    // MARK: - User Management
    
    func fetchUserProfile(userId: UUID) async throws -> User {
        let response = try await client
            .database
            .from(SupabaseConfig.usersTable)
            .select()
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(User.self, from: response.data)
    }
    
    // MARK: - Tickets
    
    func fetchTickets() async throws -> [Ticket] {
        let response = try await client
            .database
            .from(SupabaseConfig.ticketsTable)
            .select()
            .order("created_at", ascending: false)
            .execute()
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode([Ticket].self, from: response.data)
    }
    
    func createTicket(_ ticket: Ticket) async throws -> Ticket {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        let data = try encoder.encode(ticket)
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        
        let response = try await client
            .database
            .from(SupabaseConfig.ticketsTable)
            .insert(values: jsonObject)
            .single()
            .execute()
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(Ticket.self, from: response.data)
    }
    
    // MARK: - Resources
    
    func fetchResources() async throws -> [Resource] {
        let response = try await client
            .database
            .from(SupabaseConfig.resourcesTable)
            .select()
            .order("created_at", ascending: false)
            .execute()
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode([Resource].self, from: response.data)
    }
    
    // MARK: - Transactions
    
    func fetchTransactions(for userId: UUID) async throws -> [Transaction] {
        let response = try await client
            .database
            .from(SupabaseConfig.transactionsTable)
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode([Transaction].self, from: response.data)
    }
}
