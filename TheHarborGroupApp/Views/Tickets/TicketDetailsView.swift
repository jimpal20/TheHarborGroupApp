import SwiftUI
import Supabase

struct TicketDetailsView: View {
    let ticketId: UUID
    @StateObject private var viewModel = TicketDetailsViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var isEditing = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if viewModel.isLoading {
                    ProgressView("Loading ticket details...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                } else if let ticket = viewModel.ticket {
                    Group {
                        // Ticket header section
                        VStack(alignment: .leading, spacing: 8) {
                            Text(ticket.title)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            HStack {
                                PriorityBadge(priority: ticket.priority)
                                StatusBadge(status: ticket.status)
                            }
                            
                            Text("Created: \(ticket.createdAt, style: .date)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if let updatedAt = ticket.updatedAt {
                                Text("Updated: \(updatedAt, style: .date)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        
                        // Description section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                            
                            Text(ticket.description)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        // Assignment section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Assignment")
                                .font(.headline)
                            
                            if let assignedUser = viewModel.assignedUser {
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.blue)
                                    Text("\(assignedUser.firstName ?? "") \(assignedUser.lastName ?? "")")
                                    Spacer()
                                    Button("Reassign") {
                                        // Show reassignment UI
                                    }
                                    .foregroundColor(.blue)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            } else {
                                Button(action: {
                                    // Show assignment UI
                                }) {
                                    HStack {
                                        Image(systemName: "person.badge.plus")
                                        Text("Assign Ticket")
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Status update section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Update Status")
                                .font(.headline)
                            
                            HStack {
                                ForEach([TicketStatus.open, .inProgress, .resolved, .closed], id: \.self) { status in
                                    Button(action: {
                                        Task {
                                            await viewModel.updateTicketStatus(status)
                                        }
                                    }) {
                                        Text(status.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(status == ticket.status ? Color.blue : Color(.systemGray5))
                                            .foregroundColor(status == ticket.status ? .white : .primary)
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                } else {
                    Text("Ticket not found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                }
            }
            .padding(.bottom)
        }
        .navigationTitle("Ticket Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Save" : "Edit") {
                    if isEditing {
                        // Save changes
                        Task {
                            await viewModel.saveTicket()
                        }
                    }
                    isEditing.toggle()
                }
            }
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
        .onAppear {
            Task {
                await viewModel.fetchTicket(id: ticketId)
            }
        }
    }
}

#Preview {
    NavigationView {
        TicketDetailsView(ticketId: UUID())
    }
}
