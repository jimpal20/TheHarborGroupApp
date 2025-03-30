import Foundation
import Combine

class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabaseManager = SupabaseManager.shared
    
    func fetchTransactions() async {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            // In a real implementation, we would get the current user's ID
            let userId = UUID()
            let fetchedTransactions = try await supabaseManager.fetchTransactions(for: userId)
            
            await MainActor.run {
                self.transactions = fetchedTransactions
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
    
    func addTransaction(amount: Double, description: String, type: TransactionType) async throws {
        await MainActor.run {
            isLoading = true
        }
        
        // In a real implementation, we would get the current user's ID
        let userId = UUID()
        
        let newTransaction = Transaction(
            id: UUID(),
            amount: amount,
            description: description,
            type: type,
            status: .pending,
            userId: userId,
            createdAt: Date(),
            updatedAt: nil
        )
        
        // In a real implementation, you would save this to Supabase
        // For demo purposes, we'll just add it to our local array
        
        do {
            // Simulate a network delay
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            await MainActor.run {
                self.transactions.insert(newTransaction, at: 0)
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
