import Foundation
import Combine

class ResourceViewModel: ObservableObject {
    @Published var resources: [Resource] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabaseManager = SupabaseManager.shared
    
    func fetchResources() async {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            let fetchedResources = try await supabaseManager.fetchResources()
            
            await MainActor.run {
                self.resources = fetchedResources
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
    
    // Additional methods for resource management would be added here
}
