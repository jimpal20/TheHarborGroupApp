import Foundation
import Supabase

class TicketDetailsViewModel: ObservableObject {
    @Published var ticket: Ticket?
    @Published var assignedUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var comments: [Comment] = []
    
    private let supabaseManager = SupabaseManager.shared
    
    func fetchTicket(id: UUID) async {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            // This would require a method in SupabaseManager to fetch a single ticket
            // For now, let's assume we have such a method
            let fetchedTickets = try await supabaseManager.fetchTickets()
            let foundTicket = fetchedTickets.first(where: { $0.id == id })
            
            await MainActor.run {
                self.ticket = foundTicket
                self.isLoading = false
            }
            
            // If ticket is assigned, fetch the assigned user
            if let assignedToId = foundTicket?.assignedToId {
                await fetchAssignedUser(id: assignedToId)
            }
            
            // Fetch comments for this ticket (if we implemented that feature)
            // await fetchComments(for: id)
            
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func fetchAssignedUser(id: UUID) async {
        do {
            let user = try await supabaseManager.fetchUserProfile(userId: id)
            
            await MainActor.run {
                self.assignedUser = user
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load assigned user: \(error.localizedDescription)"
            }
        }
    }
    
    func updateTicketStatus(_ newStatus: TicketStatus) async {
        guard var updatedTicket = ticket else { return }
        
        await MainActor.run {
            isLoading = true
        }
        
        updatedTicket.status = newStatus
        updatedTicket.updatedAt = Date()
        
        do {
            // This would require an update method in SupabaseManager
            // For demo purposes, just update the local state
            await MainActor.run {
                self.ticket = updatedTicket
                self.isLoading = false
            }
            
            // In a real implementation, you would save to Supabase:
            // try await supabaseManager.updateTicket(updatedTicket)
            
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func saveTicket() async {
        // Save the current state of the ticket to the database
        guard let updatedTicket = ticket else { return }
        
        await MainActor.run {
            isLoading = true
        }
        
        do {
            // This would require an update method in SupabaseManager
            // For demo purposes, just update the local state
            await MainActor.run {
                self.isLoading = false
            }
            
            // In a real implementation, you would save to Supabase:
            // try await supabaseManager.updateTicket(updatedTicket)
            
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

// This would be defined in its own file in a real app
struct Comment: Identifiable, Codable {
    var id: UUID
    var content: String
    var ticketId: UUID
    var userId: UUID
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case ticketId = "ticket_id"
        case userId = "user_id"
        case createdAt = "created_at"
    }
}
