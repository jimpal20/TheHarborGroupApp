import SwiftUI

struct HomeView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @StateObject private var ticketViewModel = TicketViewModel()
    
    var body: some View {
        TabView {
            TicketListView(viewModel: ticketViewModel)
                .tabItem {
                    Label("Tickets", systemImage: "ticket")
                }
            
            ResourceListView()
                .tabItem {
                    Label("Resources", systemImage: "folder")
                }
            
            TransactionView()
                .tabItem {
                    Label("Transactions", systemImage: "creditcard")
                }
            
            NotificationsView()
                .tabItem {
                    Label("Notifications", systemImage: "bell")
                }
            
            ProfileView(authViewModel: authViewModel)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .onAppear {
            // Load initial data
            Task {
                await ticketViewModel.fetchTickets()
            }
        }
    }
}

#Preview {
    HomeView(authViewModel: AuthViewModel())
}
