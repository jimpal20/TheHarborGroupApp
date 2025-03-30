import Foundation
import Combine

class TicketViewModel: ObservableObject {
    @Published var tickets: [Ticket] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabaseManager = SupabaseManager.shared
    
    func fetchTickets() async {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            let fetchedTickets = try await supabaseManager.fetchTickets()
            
            await MainActor.run {
                self.tickets = fetchedTickets
                self.isLoading = false
                self.errorMessage = nil
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func createTicket(title: String, description: String, priority: TicketPriority, createdById: UUID) async throws {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            let newTicket = Ticket(
                id: UUID(),
                title: title,
                description: description,
                status: .open,
                priority: priority,
                assignedToId: nil,
                createdById: createdById,
                createdAt: Date(),
                updatedAt: nil
            )
            
            let createdTicket = try await supabaseManager.createTicket(newTicket)
            
            await MainActor.run {
                self.tickets.insert(createdTicket, at: 0)
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
}
