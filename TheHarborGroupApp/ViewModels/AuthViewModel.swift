import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    
    private let supabaseManager = SupabaseManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    func signUp(email: String, password: String, firstName: String, lastName: String) async throws {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            // Create the user first
            let user = try await supabaseManager.signUp(email: email, password: password)
            
            // Update user profile with first and last name
            // This would require an additional method in the SupabaseManager
            
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
            throw error
        }
    }
    
    func signIn(email: String, password: String) async throws {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            let user = try await supabaseManager.signIn(email: email, password: password)
            
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
            throw error
        }
    }
    
    func signOut() async throws {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            try await supabaseManager.signOut()
            
            await MainActor.run {
                self.currentUser = nil
                self.isAuthenticated = false
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
            throw error
        }
    }
    
    func checkAuthStatus() async {
        // Check if user is already logged in
        // This would require an additional method in the SupabaseManager
    }
}
