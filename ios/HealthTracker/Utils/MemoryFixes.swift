import Foundation
import CoreData
import SwiftUI

// MARK: - Memory Management Fixes

/// Limit fetch requests to prevent memory overload
struct FetchRequestOptimizer {
    static func optimize<T: NSManagedObject>(_ request: NSFetchRequest<T>) {
        request.fetchBatchSize = 20
        request.fetchLimit = 100
        request.returnsObjectsAsFaults = true
        request.includesPropertyValues = false
    }
}

/// Wrapper for memory-safe fetch requests
struct MemorySafeFetchRequest<T: NSManagedObject>: View {
    let entity: T.Type
    let sortDescriptors: [NSSortDescriptor]
    let predicate: NSPredicate?
    let limit: Int

    @State private var items: [T] = []
    @Environment(\.managedObjectContext) private var viewContext

    init(
        entity: T.Type,
        sortDescriptors: [NSSortDescriptor] = [],
        predicate: NSPredicate? = nil,
        limit: Int = 50
    ) {
        self.entity = entity
        self.sortDescriptors = sortDescriptors
        self.predicate = predicate
        self.limit = limit
    }

    var body: some View {
        EmptyView()
            .onAppear {
                loadData()
            }
    }

    private func loadData() {
        let request = NSFetchRequest<T>(entityName: String(describing: entity))
        request.sortDescriptors = sortDescriptors
        request.predicate = predicate
        request.fetchLimit = limit
        request.fetchBatchSize = min(20, limit)
        request.returnsObjectsAsFaults = true

        do {
            items = try viewContext.fetch(request)
        } catch {
            print("Fetch error: \(error)")
            items = []
        }
    }
}

/// Memory-safe image cache
class ImageMemoryCache {
    static let shared = ImageMemoryCache()
    private var cache = NSCache<NSString, UIImage>()

    init() {
        cache.countLimit = 20  // Maximum 20 images
        cache.totalCostLimit = 50 * 1024 * 1024  // 50MB maximum
    }

    func image(for key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }

    func store(_ image: UIImage, for key: String) {
        let cost = image.jpegData(compressionQuality: 1.0)?.count ?? 0
        cache.setObject(image, forKey: key as NSString, cost: cost)
    }

    func clearCache() {
        cache.removeAllObjects()
    }
}

/// Prevent memory leaks in closures
class WeakProxy<T: AnyObject> {
    weak var value: T?

    init(_ value: T) {
        self.value = value
    }
}

/// Safe AsyncImage wrapper with memory management
struct MemorySafeAsyncImage: View {
    let url: URL?
    let maxWidth: CGFloat

    @State private var image: UIImage?
    @State private var isLoading = false

    init(url: URL?, maxWidth: CGFloat = 200) {
        self.url = url
        self.maxWidth = maxWidth
    }

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: maxWidth)
            } else if isLoading {
                ProgressView()
                    .frame(width: maxWidth, height: maxWidth)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: maxWidth, height: maxWidth)
            }
        }
        .onAppear {
            loadImage()
        }
        .onDisappear {
            // Cancel any pending loads
            isLoading = false
        }
    }

    private func loadImage() {
        guard let url = url, !isLoading else { return }

        // Check cache first
        if let cachedImage = ImageMemoryCache.shared.image(for: url.absoluteString) {
            self.image = cachedImage
            return
        }

        isLoading = true

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }

            // Resize image if needed
            let resized = image.resize(toWidth: maxWidth * UIScreen.main.scale)

            DispatchQueue.main.async {
                self.image = resized
                ImageMemoryCache.shared.store(resized, for: url.absoluteString)
                self.isLoading = false
            }
        }.resume()
    }
}

extension UIImage {
    func resize(toWidth width: CGFloat) -> UIImage {
        let scale = width / self.size.width
        let newHeight = self.size.height * scale
        let size = CGSize(width: width, height: newHeight)

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? self
    }
}