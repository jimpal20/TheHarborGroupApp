import SwiftUI
import Supabase

struct CreateTicketView: View {
    @ObservedObject var viewModel: TicketViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedPriority = TicketPriority.medium
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ticket Details")) {
                    TextField("Title", text: $title)
                    
                    ZStack(alignment: .topLeading) {
                        if description.isEmpty {
                            Text("Description")
                                .foregroundColor(Color(.placeholderText))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                    }
                }
                
                Section(header: Text("Priority")) {
                    Picker("Priority", selection: $selectedPriority) {
                        Text("Low").tag(TicketPriority.low)
                        Text("Medium").tag(TicketPriority.medium)
                        Text("High").tag(TicketPriority.high)
                        Text("Urgent").tag(TicketPriority.urgent)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section {
                    Button(action: createTicket) {
                        Text("Submit Ticket")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .listRowBackground(Color.blue)
                    .disabled(title.isEmpty || description.isEmpty || viewModel.isLoading)
                }
            }
            .navigationTitle("Create Ticket")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .disabled(viewModel.isLoading)
            .overlay(
                Group {
                    if viewModel.isLoading {
                        ProgressView("Creating ticket...")
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .shadow(radius: 2)
                    }
                }
            )
        }
    }
    
    private func createTicket() {
        // In a real app, you would get the current user's ID
        let createdById = UUID()
        
        Task {
            do {
                try await viewModel.createTicket(
                    title: title,
                    description: description,
                    priority: selectedPriority,
                    createdById: createdById
                )
                
                await MainActor.run {
                    presentationMode.wrappedValue.dismiss()
                }
            } catch {
                // Error is already handled in the ViewModel
            }
        }
    }
}

#Preview {
    CreateTicketView(viewModel: TicketViewModel())
}
