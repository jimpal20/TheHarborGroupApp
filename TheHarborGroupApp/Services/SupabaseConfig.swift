import Foundation

enum SupabaseConfig {
    static let supabaseUrl = "SUPABASE_URL_HERE" // Replace with your actual Supabase URL
    static let supabaseKey = "SUPABASE_KEY_HERE" // Replace with your actual Supabase key
    
    // Database table names
    static let usersTable = "users"
    static let ticketsTable = "tickets"
    static let resourcesTable = "resources"
    static let transactionsTable = "transactions"
}
