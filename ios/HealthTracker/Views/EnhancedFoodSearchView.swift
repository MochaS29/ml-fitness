import SwiftUI

struct EnhancedFoodSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: FoodCategory? = nil
    @State private var searchResults: [FoodItem] = []
    @State private var isSearching = false
    @State private var selectedSort: SortOption = .relevance
    @State private var showingFilters = false
    
    private let foodDatabase = FoodDatabase.shared
    let onSelect: (FoodItem) -> Void
    
    enum SortOption: String, CaseIterable {
        case relevance = "Relevance"
        case caloriesAsc = "Calories (Low to High)"
        case caloriesDesc = "Calories (High to Low)"
        case proteinDesc = "Protein (High to Low)"
        
        var displayName: String { rawValue }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search foods...", text: $searchText)
                            .textFieldStyle(.plain)
                            .onSubmit {
                                performSearch()
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                searchResults = []
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    Button(action: {
                        showingFilters.toggle()
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.wellnessGreen)
                    }
                }
                .padding()
                
                // Filter Bar
                if showingFilters {
                    VStack(spacing: 10) {
                        // Sort Options
                        Menu {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button(action: { selectedSort = option }) {
                                    Label(option.displayName, systemImage: selectedSort == option ? "checkmark" : "")
                                }
                            }
                        } label: {
                            HStack {
                                Text("Sort: \(selectedSort.displayName)")
                                Image(systemName: "chevron.down")
                            }
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        }
                        
                        // Category Filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                SearchCategoryChip(
                                    title: "All",
                                    isSelected: selectedCategory == nil,
                                    action: {
                                        selectedCategory = nil
                                        performSearch()
                                    }
                                )
                                
                                ForEach(FoodCategory.allCases, id: \.self) { category in
                                    SearchCategoryChip(
                                        title: category.rawValue,
                                        isSelected: selectedCategory == category,
                                        action: {
                                            selectedCategory = category
                                            performSearch()
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                Divider()
                
                // Results
                if isSearching {
                    ProgressView("Searching...")
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if searchResults.isEmpty && !searchText.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No results found")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Try adjusting your search or filters")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if searchResults.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("Search for foods")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Find nutritional information for thousands of foods")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // Quick Search Suggestions
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Popular Searches:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            SearchFlowLayout(spacing: 8) {
                                ForEach(["Chicken Breast", "Banana", "Greek Yogurt", "Avocado", "Eggs"], id: \.self) { suggestion in
                                    Button(action: {
                                        searchText = suggestion
                                        performSearch()
                                    }) {
                                        Text(suggestion)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.wellnessGreen.opacity(0.2))
                                            .foregroundColor(.wellnessGreen)
                                            .cornerRadius(15)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(sortedResults) { food in
                                VStack(spacing: 0) {
                                    EnhancedFoodSearchRow(food: food) {
                                        onSelect(food)
                                        dismiss()
                                    }
                                    
                                    Divider()
                                        .padding(.leading, 16)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Food Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .animation(.easeInOut(duration: 0.2), value: showingFilters)
        }
        .onAppear {
            if searchText.isEmpty && searchResults.isEmpty {
                // Load popular foods
                searchResults = Array(foodDatabase.foods.prefix(20))
            }
        }
    }
    
    private var sortedResults: [FoodItem] {
        switch selectedSort {
        case .relevance:
            return searchResults
        case .caloriesAsc:
            return searchResults.sorted { $0.calories < $1.calories }
        case .caloriesDesc:
            return searchResults.sorted { $0.calories > $1.calories }
        case .proteinDesc:
            return searchResults.sorted { $0.protein > $1.protein }
        }
    }
    
    private func performSearch() {
        isSearching = true
        
        // Simulate search delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if searchText.isEmpty {
                searchResults = Array(foodDatabase.foods.prefix(20))
            } else {
                searchResults = foodDatabase.searchFoods(searchText).filter { food in
                    selectedCategory == nil || food.category == selectedCategory
                }
            }
            isSearching = false
        }
    }
}

// Flow Layout for suggestions
struct SearchFlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(at: CGPoint(x: frame.origin.x + bounds.origin.x,
                                               y: frame.origin.y + bounds.origin.y),
                                  proposal: ProposedViewSize(frame.size))
        }
    }
    
    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            var maxX: CGFloat = 0
            
            for subview in subviews {
                let viewSize = subview.sizeThatFits(.unspecified)
                
                if currentX + viewSize.width > maxWidth, currentX > 0 {
                    currentY += lineHeight + spacing
                    currentX = 0
                    lineHeight = 0
                }
                
                frames.append(CGRect(origin: CGPoint(x: currentX, y: currentY), size: viewSize))
                
                currentX += viewSize.width + spacing
                maxX = max(maxX, currentX)
                lineHeight = max(lineHeight, viewSize.height)
            }
            
            size = CGSize(width: maxX - spacing, height: currentY + lineHeight)
        }
    }
}

struct EnhancedFoodSearchRow: View {
    let food: FoodItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(food.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let brand = food.brand {
                        Text(brand)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("\(food.servingSize) \(food.servingUnit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(food.calories)) cal")
                        .font(.headline)
                        .foregroundColor(.wellnessGreen)
                    
                    HStack(spacing: 10) {
                        MacroLabel(value: food.protein, label: "P", color: .blue)
                        MacroLabel(value: food.carbs, label: "C", color: .orange)
                        MacroLabel(value: food.fat, label: "F", color: .purple)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

struct SearchCategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.wellnessGreen : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct MacroLabel: View {
    let value: Double
    let label: String
    let color: Color
    
    var body: some View {
        Text("\(Int(value))\(label)")
            .font(.caption2)
            .foregroundColor(color)
    }
}