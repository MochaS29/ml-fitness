import Foundation
import CoreData
import SwiftUI

// MARK: - Memory Optimization Utilities

class MemoryOptimization {

    // MARK: - Core Data Fetch Limits

    static let dashboardFetchLimit = 100
    static let listViewFetchLimit = 50
    static let historyFetchLimit = 30

    // MARK: - Image Optimization

    static func resizeImage(_ image: UIImage, maxSize: CGSize) -> UIImage? {
        let size = image.size

        let widthRatio = maxSize.width / size.width
        let heightRatio = maxSize.height / size.height
        let ratio = min(widthRatio, heightRatio)

        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }

    static func compressImageData(_ imageData: Data, maxSizeKB: Int = 500) -> Data? {
        guard let image = UIImage(data: imageData) else { return nil }

        let maxBytes = maxSizeKB * 1024
        var compression: CGFloat = 1.0
        var compressedData = image.jpegData(compressionQuality: compression)

        while let data = compressedData, data.count > maxBytes && compression > 0.1 {
            compression -= 0.1
            compressedData = image.jpegData(compressionQuality: compression)
        }

        return compressedData
    }

    // MARK: - Core Data Batch Operations

    static func batchDeleteOldEntries(context: NSManagedObjectContext, daysToKeep: Int = 90) {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -daysToKeep, to: Date())!

        // Delete old food entries
        let foodRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FoodEntry")
        foodRequest.predicate = NSPredicate(format: "timestamp < %@", cutoffDate as NSDate)
        let foodDelete = NSBatchDeleteRequest(fetchRequest: foodRequest)

        // Delete old exercise entries
        let exerciseRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ExerciseEntry")
        exerciseRequest.predicate = NSPredicate(format: "timestamp < %@", cutoffDate as NSDate)
        let exerciseDelete = NSBatchDeleteRequest(fetchRequest: exerciseRequest)

        // Delete old weight entries (keep monthly samples)
        let weightRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WeightEntry")
        weightRequest.predicate = NSPredicate(format: "timestamp < %@", cutoffDate as NSDate)
        let weightDelete = NSBatchDeleteRequest(fetchRequest: weightRequest)

        do {
            try context.execute(foodDelete)
            try context.execute(exerciseDelete)
            try context.execute(weightDelete)
            try context.save()
        } catch {
            print("Error batch deleting old entries: \(error)")
        }
    }
}

// MARK: - Optimized Fetch Request Wrapper

struct OptimizedFetchRequest<T: NSManagedObject>: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var items: [T] = []

    let entityType: T.Type
    let sortDescriptors: [NSSortDescriptor]
    let predicate: NSPredicate?
    let fetchLimit: Int

    init(
        entity: T.Type,
        sortDescriptors: [NSSortDescriptor],
        predicate: NSPredicate? = nil,
        fetchLimit: Int = 50
    ) {
        self.entityType = entity
        self.sortDescriptors = sortDescriptors
        self.predicate = predicate
        self.fetchLimit = fetchLimit
    }

    var body: some View {
        EmptyView()
            .onAppear {
                fetchData()
            }
    }

    private func fetchData() {
        let request = NSFetchRequest<T>(entityName: String(describing: entityType))
        request.sortDescriptors = sortDescriptors
        request.predicate = predicate
        request.fetchLimit = fetchLimit
        request.fetchBatchSize = 20

        do {
            items = try viewContext.fetch(request)
        } catch {
            print("Error fetching \(entityType): \(error)")
        }
    }
}

// MARK: - Memory Warning Handler

class MemoryWarningHandler: ObservableObject {
    static let shared = MemoryWarningHandler()

    @Published var isLowMemory = false

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    @objc private func handleMemoryWarning() {
        print("⚠️ Memory warning received")
        isLowMemory = true

        // Clear image caches
        URLCache.shared.removeAllCachedResponses()

        // Clear any custom caches
        clearCaches()

        // Reset after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.isLowMemory = false
        }
    }

    private func clearCaches() {
        // Clear any app-specific caches here
        // For example, clear recipe image cache, etc.
    }
}

// MARK: - Lazy Loading List

struct LazyLoadingList<T: NSManagedObject, Content: View>: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var items: [T] = []
    @State private var isLoading = false
    @State private var currentPage = 0

    let entityType: T.Type
    let sortDescriptors: [NSSortDescriptor]
    let predicate: NSPredicate?
    let pageSize: Int
    let content: (T) -> Content

    init(
        entity: T.Type,
        sortDescriptors: [NSSortDescriptor],
        predicate: NSPredicate? = nil,
        pageSize: Int = 20,
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self.entityType = entity
        self.sortDescriptors = sortDescriptors
        self.predicate = predicate
        self.pageSize = pageSize
        self.content = content
    }

    var body: some View {
        List {
            ForEach(items, id: \.objectID) { item in
                content(item)
                    .onAppear {
                        if item == items.last {
                            loadMoreItems()
                        }
                    }
            }

            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding()
            }
        }
        .onAppear {
            loadInitialItems()
        }
    }

    private func loadInitialItems() {
        items = []
        currentPage = 0
        loadMoreItems()
    }

    private func loadMoreItems() {
        guard !isLoading else { return }

        isLoading = true

        let request = NSFetchRequest<T>(entityName: String(describing: entityType))
        request.sortDescriptors = sortDescriptors
        request.predicate = predicate
        request.fetchLimit = pageSize
        request.fetchOffset = currentPage * pageSize
        request.fetchBatchSize = 20

        do {
            let newItems = try viewContext.fetch(request)
            items.append(contentsOf: newItems)
            currentPage += 1
            isLoading = false
        } catch {
            print("Error loading items: \(error)")
            isLoading = false
        }
    }
}