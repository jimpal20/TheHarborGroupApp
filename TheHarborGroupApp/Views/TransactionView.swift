import SwiftUI
import Supabase

struct TransactionView: View {
    @StateObject private var viewModel = TransactionViewModel()
    @State private var showingAddTransactionSheet = false
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading && viewModel.transactions.isEmpty {
                    ProgressView("Loading transactions...")
                } else if viewModel.transactions.isEmpty {
                    VStack {
                        Text("No transactions found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Button("Add Transaction") {
                            showingAddTransactionSheet = true
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.top, 10)
                    }
                } else {
                    List {
                        ForEach(viewModel.transactions) { transaction in
                            TransactionRow(transaction: transaction)
                        }
                    }
                    .refreshable {
                        await viewModel.fetchTransactions()
                    }
                }
            }
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTransactionSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTransactionSheet) {
                AddTransactionView(viewModel: viewModel)
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
        .onAppear {
            Task {
                await viewModel.fetchTransactions()
            }
        }
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            transactionTypeIcon
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(transactionTypeColor.opacity(0.2))
                .foregroundColor(transactionTypeColor)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description)
                    .font(.headline)
                
                Text(transaction.status.rawValue.capitalized)
                    .font(.caption)
                    .padding(4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(4)
                
                Text(transaction.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("$\(String(format: "%.2f", transaction.amount))")
                .font(.headline)
                .foregroundColor(amountColor)
        }
        .padding(.vertical, 4)
    }
    
    var transactionTypeIcon: Image {
        switch transaction.type {
        case .payment:
            return Image(systemName: "creditcard")
        case .refund:
            return Image(systemName: "arrow.left.arrow.right")
        case .deposit:
            return Image(systemName: "arrow.down")
        case .withdrawal:
            return Image(systemName: "arrow.up")
        }
    }
    
    var transactionTypeColor: Color {
        switch transaction.type {
        case .payment:
            return .blue
        case .refund:
            return .orange
        case .deposit:
            return .green
        case .withdrawal:
            return .red
        }
    }
    
    var statusColor: Color {
        switch transaction.status {
        case .pending:
            return .orange
        case .completed:
            return .green
        case .failed:
            return .red
        case .cancelled:
            return .gray
        }
    }
    
    var amountColor: Color {
        switch transaction.type {
        case .payment, .withdrawal:
            return .red
        case .refund, .deposit:
            return .green
        }
    }
}

#Preview {
    TransactionView()
}
