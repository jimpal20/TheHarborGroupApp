import SwiftUI
import Supabase

struct AddTransactionView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var amount = ""
    @State private var description = ""
    @State private var selectedType: TransactionType = .payment
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Transaction Details")) {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    TextField("Description", text: $description)
                }
                
                Section(header: Text("Type")) {
                    Picker("Transaction Type", selection: $selectedType) {
                        Text("Payment").tag(TransactionType.payment)
                        Text("Refund").tag(TransactionType.refund)
                        Text("Deposit").tag(TransactionType.deposit)
                        Text("Withdrawal").tag(TransactionType.withdrawal)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section {
                    Button(action: addTransaction) {
                        Text("Add Transaction")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .listRowBackground(Color.blue)
                    .disabled(amount.isEmpty || description.isEmpty || viewModel.isLoading || !isValidAmount)
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .disabled(viewModel.isLoading)
            .overlay(
                Group {
                    if viewModel.isLoading {
                        ProgressView("Adding transaction...")
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .shadow(radius: 2)
                    }
                }
            )
        }
    }
    
    private var isValidAmount: Bool {
        guard let amountDouble = Double(amount) else {
            return false
        }
        return amountDouble > 0
    }
    
    private func addTransaction() {
        guard let amountDouble = Double(amount) else { return }
        
        Task {
            do {
                try await viewModel.addTransaction(
                    amount: amountDouble,
                    description: description,
                    type: selectedType
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
    AddTransactionView(viewModel: TransactionViewModel())
}
