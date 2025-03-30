import SwiftUI
import Supabase

struct ResourceListView: View {
    @StateObject private var viewModel = ResourceViewModel()
    @State private var showingAddResourceSheet = false
    @State private var searchText = ""
    
    var filteredResources: [Resource] {
        if searchText.isEmpty {
            return viewModel.resources
        } else {
            return viewModel.resources.filter { resource in
                resource.title.localizedCaseInsensitiveContains(searchText) ||
                resource.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading && filteredResources.isEmpty {
                    ProgressView("Loading resources...")
                } else if filteredResources.isEmpty {
                    VStack {
                        Text("No resources found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Button("Add Resource") {
                            showingAddResourceSheet = true
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.top, 10)
                    }
                } else {
                    List {
                        ForEach(filteredResources) { resource in
                            ResourceRow(resource: resource)
                        }
                    }
                    .refreshable {
                        await viewModel.fetchResources()
                    }
                    .searchable(text: $searchText, prompt: "Search resources")
                }
            }
            .navigationTitle("Resources")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddResourceSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddResourceSheet) {
                Text("Add Resource View")
                // In a real app, you would implement an AddResourceView here
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
                await viewModel.fetchResources()
            }
        }
    }
}

struct ResourceRow: View {
    let resource: Resource
    
    var body: some View {
        HStack {
            resourceTypeIcon
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(resourceTypeColor.opacity(0.2))
                .foregroundColor(resourceTypeColor)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(resource.title)
                    .font(.headline)
                
                Text(resource.description)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundColor(.secondary)
                
                Text("Added \(resource.createdAt, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if resource.fileUrl != nil {
                Button(action: {
                    // Handle file download/view
                }) {
                    Image(systemName: "arrow.down.circle")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    var resourceTypeIcon: Image {
        switch resource.type {
        case .document:
            return Image(systemName: "doc.text")
        case .image:
            return Image(systemName: "photo")
        case .video:
            return Image(systemName: "video")
        case .link:
            return Image(systemName: "link")
        case .other:
            return Image(systemName: "folder")
        }
    }
    
    var resourceTypeColor: Color {
        switch resource.type {
        case .document:
            return .blue
        case .image:
            return .green
        case .video:
            return .red
        case .link:
            return .purple
        case .other:
            return .gray
        }
    }
}

#Preview {
    ResourceListView()
}
