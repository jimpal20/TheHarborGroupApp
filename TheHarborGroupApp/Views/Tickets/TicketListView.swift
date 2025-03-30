import SwiftUI
import Supabase

struct TicketListView: View {
    @ObservedObject var viewModel: TicketViewModel
    @State private var showingNewTicketSheet = false
    @State private var searchText = ""
    
    var filteredTickets: [Ticket] {
        if searchText.isEmpty {
            return viewModel.tickets
        } else {
            return viewModel.tickets.filter { ticket in
                ticket.title.localizedCaseInsensitiveContains(searchText) ||
                ticket.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading && filteredTickets.isEmpty {
                    ProgressView("Loading tickets...")
                } else if filteredTickets.isEmpty {
                    VStack {
                        Text("No tickets found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Button("Create a New Ticket") {
                            showingNewTicketSheet = true
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.top, 10)
                    }
                } else {
                    List {
                        ForEach(filteredTickets) { ticket in
                            NavigationLink(destination: TicketDetailsView(ticketId: ticket.id)) {
                                TicketRow(ticket: ticket)
                            }
                        }
                    }
                    .refreshable {
                        await viewModel.fetchTickets()
                    }
                    .searchable(text: $searchText, prompt: "Search tickets")
                }
            }
            .navigationTitle("Tickets")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewTicketSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewTicketSheet) {
                CreateTicketView(viewModel: viewModel)
            }
            .alert(item: Binding<IdentifiableError?>(
                get: { viewModel.errorMessage.map { IdentifiableError($0) } },
                set: { viewModel.errorMessage = $0?.message }
            )) { error in
                Alert(
                    title: Text("Error"),
                    message: Text(error.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

struct TicketRow: View {
    let ticket: Ticket
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(ticket.title)
                .font(.headline)
            
            Text(ticket.description)
                .font(.subheadline)
                .lineLimit(2)
                .foregroundColor(.secondary)
            
            HStack {
                PriorityBadge(priority: ticket.priority)
                StatusBadge(status: ticket.status)
                Spacer()
                Text(ticket.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct PriorityBadge: View {
    let priority: TicketPriority
    
    var color: Color {
        switch priority {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .urgent: return .red
        }
    }
    
    var body: some View {
        Text(priority.rawValue.capitalized)
            .font(.caption)
            .padding(5)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(5)
    }
}

struct StatusBadge: View {
    let status: TicketStatus
    
    var color: Color {
        switch status {
        case .open: return .blue
        case .inProgress: return .orange
        case .resolved: return .green
        case .closed: return .gray
        }
    }
    
    var body: some View {
        Text(status.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
            .font(.caption)
            .padding(5)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(5)
    }
}

// Helper to make strings identifiable for alerts
struct IdentifiableError: Identifiable {
    let id = UUID()
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
}

#Preview {
    TicketListView(viewModel: TicketViewModel())
}
