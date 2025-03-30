import SwiftUI
import Supabase

struct ProfileView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var showingEditProfile = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    if let user = authViewModel.currentUser {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.blue)
                                .padding(.trailing, 10)
                            
                            VStack(alignment: .leading) {
                                Text("\(user.firstName ?? "") \(user.lastName ?? "")")
                                    .font(.headline)
                                
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                if let role = user.role {
                                    Text(role)
                                        .font(.caption)
                                        .padding(4)
                                        .background(Color.blue.opacity(0.2))
                                        .foregroundColor(.blue)
                                        .cornerRadius(4)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        
                        Button("Edit Profile") {
                            showingEditProfile = true
                        }
                    } else {
                        Text("Loading profile...")
                    }
                }
                
                Section(header: Text("Preferences")) {
                    Toggle("Email Notifications", isOn: .constant(true))
                    Toggle("Push Notifications", isOn: .constant(true))
                }
                
                Section(header: Text("App")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profile")
            .alert(isPresented: $showingLogoutAlert) {
                Alert(
                    title: Text("Sign Out"),
                    message: Text("Are you sure you want to sign out?"),
                    primaryButton: .destructive(Text("Sign Out")) {
                        Task {
                            try? await authViewModel.signOut()
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $showingEditProfile) {
                Text("Edit Profile View")
                // In a real app, you would implement an EditProfileView here
            }
        }
    }
}

#Preview {
    ProfileView(authViewModel: AuthViewModel())
}
