import SwiftUI
import Supabase

struct NotificationsView: View {
    @State private var notifications: [Notification] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading && notifications.isEmpty {
                    ProgressView("Loading notifications...")
                } else if notifications.isEmpty {
                    VStack {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .padding()
                        
                        Text("No notifications")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("You're all caught up!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                } else {
                    List {
                        ForEach(notifications) { notification in
                            NotificationRow(notification: notification)
                        }
                    }
                    .refreshable {
                        await loadNotifications()
                    }
                }
            }
            .navigationTitle("Notifications")
        }
        .onAppear {
            Task {
                await loadNotifications()
            }
        }
    }
    
    func loadNotifications() async {
        isLoading = true
        
        // Simulate loading notifications
        // In a real app, you would fetch this from Supabase
        
        // Create some sample notifications for the preview
        await Task.sleep(1_000_000_000) // 1 second delay
        
        let sampleNotifications = [
            Notification(
                id: UUID(),
                title: "Ticket Updated",
                message: "Your ticket #1234 has been updated to 'In Progress'",
                type: .ticket,
                isRead: false,
                createdAt: Date().addingTimeInterval(-3600) // 1 hour ago
            ),
            Notification(
                id: UUID(),
                title: "New Resource Available",
                message: "A new document has been added to resources",
                type: .resource,
                isRead: true,
                createdAt: Date().addingTimeInterval(-86400) // 1 day ago
            ),
            Notification(
                id: UUID(),
                title: "Payment Processed",
                message: "Your payment of $250.00 has been processed",
                type: .transaction,
                isRead: true,
                createdAt: Date().addingTimeInterval(-172800) // 2 days ago
            )
        ]
        
        notifications = sampleNotifications
        isLoading = false
    }
}

struct NotificationRow: View {
    let notification: Notification
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            notificationIcon
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(notificationColor.opacity(0.2))
                .foregroundColor(notificationColor)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.headline)
                    .fontWeight(notification.isRead ? .regular : .bold)
                
                Text(notification.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(notification.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if !notification.isRead {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.vertical, 4)
    }
    
    var notificationIcon: Image {
        switch notification.type {
        case .ticket:
            return Image(systemName: "ticket")
        case .resource:
            return Image(systemName: "folder")
        case .transaction:
            return Image(systemName: "creditcard")
        case .system:
            return Image(systemName: "gear")
        }
    }
    
    var notificationColor: Color {
        switch notification.type {
        case .ticket:
            return .blue
        case .resource:
            return .green
        case .transaction:
            return .purple
        case .system:
            return .gray
        }
    }
}

// This would be defined in its own file in a real app
struct Notification: Identifiable {
    let id: UUID
    let title: String
    let message: String
    let type: NotificationType
    var isRead: Bool
    let createdAt: Date
}

enum NotificationType {
    case ticket
    case resource
    case transaction
    case system
}

#Preview {
    NotificationsView()
}
