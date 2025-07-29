import SwiftUI
import CoreData

struct USDAImportView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isImporting = false
    @State private var importProgress: Float = 0
    @State private var importMessage = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var importComplete = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(red: 127/255, green: 176/255, blue: 105/255))
                    
                    Text("USDA Food Database")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Import comprehensive nutrition data from the USDA FoodData Central database")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                // Info Cards
                VStack(spacing: 16) {
                    InfoCard(
                        icon: "folder.fill",
                        title: "Database Size",
                        description: "Over 300,000 foods with detailed nutrition information"
                    )
                    
                    InfoCard(
                        icon: "clock.fill",
                        title: "Import Time",
                        description: "This process may take 5-10 minutes"
                    )
                    
                    InfoCard(
                        icon: "exclamationmark.triangle.fill",
                        title: "Storage Required",
                        description: "Approximately 500MB of device storage"
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Progress Section
                if isImporting {
                    VStack(spacing: 16) {
                        ProgressView(value: importProgress)
                            .progressViewStyle(LinearProgressViewStyle())
                            .scaleEffect(x: 1, y: 2)
                        
                        Text(importMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if importProgress > 0 {
                            Text("\(Int(importProgress * 100))% Complete")
                                .font(.headline)
                                .foregroundColor(Color(red: 127/255, green: 176/255, blue: 105/255))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 30)
                } else if importComplete {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Import Successful!")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("The USDA database has been imported successfully")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
                
                // Action Buttons
                VStack(spacing: 16) {
                    if !isImporting && !importComplete {
                        Button(action: startImport) {
                            HStack {
                                Image(systemName: "arrow.down.circle.fill")
                                Text("Start Import")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 127/255, green: 176/255, blue: 105/255))
                            .cornerRadius(12)
                        }
                    }
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(importComplete ? "Done" : "Cancel")
                            .font(.headline)
                            .foregroundColor(importComplete ? .white : Color(red: 127/255, green: 176/255, blue: 105/255))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(importComplete ? Color(red: 127/255, green: 176/255, blue: 105/255) : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 127/255, green: 176/255, blue: 105/255), lineWidth: importComplete ? 0 : 2)
                            )
                            .cornerRadius(12)
                    }
                    .disabled(isImporting)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .navigationBarTitle("Import USDA Database", displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert("Import Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func startImport() {
        isImporting = true
        importProgress = 0
        importMessage = "Preparing import..."
        
        // Create a background context for import
        let importContext = PersistenceController.shared.container.newBackgroundContext()
        
        Task {
            do {
                // For now, show an alert that USDA import is not available on device
                throw NSError(domain: "USDAImport", code: 1, userInfo: [NSLocalizedDescriptionKey: "USDA database import is currently only available when running from Xcode. Please use the built-in food database."])
                
                // The following code is unreachable but left for future implementation
                /*
                let basePath = "/Users/mocha/HealthTracker/Resources/Databases/FoodData_Central_csv_2023-10-26"
                try await USDACSVImporter.importUSDADatabase(
                    from: basePath,
                    context: importContext,
                    progress: { progress, message in
                        DispatchQueue.main.async {
                            withAnimation {
                                self.importProgress = progress
                                self.importMessage = message
                            }
                        }
                    }
                )
                
                DispatchQueue.main.async {
                    withAnimation {
                        self.isImporting = false
                        self.importComplete = true
                    }
                }
                */
            } catch {
                DispatchQueue.main.async {
                    self.isImporting = false
                    self.errorMessage = error.localizedDescription
                    self.showingError = true
                }
            }
        }
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color(red: 127/255, green: 176/255, blue: 105/255))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

#Preview {
    USDAImportView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}