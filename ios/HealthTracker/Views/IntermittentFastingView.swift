import SwiftUI

struct IntermittentFastingView: View {
    @StateObject private var fastingManager = FastingManager()
    @State private var showingPlanSelection = false
    @State private var showingHistory = false
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Current fasting status
                    if let session = fastingManager.currentSession {
                        ActiveFastingCard(session: session, fastingManager: fastingManager)
                            .cardStyle()
                    } else {
                        StartFastingCard(
                            selectedPlan: fastingManager.selectedPlan,
                            onSelectPlan: { showingPlanSelection = true },
                            onStart: { fastingManager.startFasting() }
                        )
                        .cardStyle()
                    }
                    
                    // Quick stats
                    FastingStatsCard(sessionHistory: fastingManager.sessionHistory)
                        .cardStyle()
                    
                    // Fasting plans info
                    FastingPlansInfoCard()
                        .cardStyle()
                    
                    // Recent sessions
                    RecentSessionsCard(
                        sessions: Array(fastingManager.sessionHistory.prefix(5)),
                        onViewAll: { showingHistory = true }
                    )
                    .cardStyle()
                }
                .padding()
            }
            .navigationTitle("Intermittent Fasting")
            .sheet(isPresented: $showingPlanSelection) {
                FastingPlanSelectionView(fastingManager: fastingManager)
            }
            .sheet(isPresented: $showingHistory) {
                FastingHistoryView(sessions: fastingManager.sessionHistory)
            }
            .onReceive(timer) { _ in
                // Force view update for timer
            }
        }
    }
}

struct ActiveFastingCard: View {
    let session: FastingSession
    @ObservedObject var fastingManager: FastingManager
    @State private var showingEndConfirmation = false
    
    var timeDisplay: String {
        let hours = Int(session.currentDuration) / 3600
        let minutes = (Int(session.currentDuration) % 3600) / 60
        let seconds = Int(session.currentDuration) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    var remainingTimeDisplay: String {
        let hours = Int(session.timeRemaining) / 3600
        let minutes = (Int(session.timeRemaining) % 3600) / 60
        return String(format: "%d hours %d minutes", hours, minutes)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Fasting type and status
            VStack(spacing: 8) {
                Text(session.fastingPlan.rawValue)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("Fasting in Progress")
                    .font(.title2.bold())
                    .foregroundColor(.mochaBrown)
            }
            
            // Timer display
            ZStack {
                // Progress ring
                Circle()
                    .stroke(Color.lightGray.opacity(0.3), lineWidth: 20)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: session.progress)
                    .stroke(
                        LinearGradient(
                            colors: [.mindfulTeal, .wellnessGreen],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear, value: session.progress)
                
                VStack(spacing: 8) {
                    Text(timeDisplay)
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                    
                    Text("Elapsed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if session.timeRemaining > 0 {
                        Text(remainingTimeDisplay)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    } else {
                        Text("Goal Reached! 🎉")
                            .font(.caption)
                            .foregroundColor(.wellnessGreen)
                            .padding(.top, 4)
                    }
                }
            }
            
            // Eating window info
            VStack(spacing: 8) {
                HStack {
                    Label("Started", systemImage: "play.circle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(session.startTime, style: .time)
                        .font(.caption)
                }
                
                HStack {
                    Label("Eating window opens", systemImage: "fork.knife.circle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(session.plannedEndTime, style: .time)
                        .font(.caption)
                }
            }
            .padding()
            .background(Color.lightGray.opacity(0.1))
            .cornerRadius(10)
            
            // Action buttons
            HStack(spacing: 16) {
                Button(action: { showingEndConfirmation = true }) {
                    Label("End Fast", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .primaryButton()
                
                Button(action: { fastingManager.cancelFasting() }) {
                    Label("Cancel", systemImage: "xmark.circle")
                        .frame(maxWidth: .infinity)
                }
                .secondaryButton()
            }
        }
        .padding()
        .alert("End Fast?", isPresented: $showingEndConfirmation) {
            Button("End Fast", role: .destructive) {
                fastingManager.endFasting()
            }
            Button("Continue Fasting", role: .cancel) {}
        } message: {
            Text("Are you ready to end your fast? You've been fasting for \(timeDisplay).")
        }
    }
}

struct StartFastingCard: View {
    let selectedPlan: FastingPlan
    let onSelectPlan: () -> Void
    let onStart: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Ready to Start Fasting?")
                    .font(.title2.bold())
                    .foregroundColor(.mochaBrown)
                
                Text("Choose your fasting plan and begin")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Selected plan
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Selected Plan")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(selectedPlan.rawValue)
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    Button("Change", action: onSelectPlan)
                        .font(.caption)
                        .foregroundColor(.mindfulTeal)
                }
                
                Text(selectedPlan.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(selectedPlan.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(Color.lightGray.opacity(0.1))
            .cornerRadius(10)
            
            Button(action: onStart) {
                Label("Start Fasting", systemImage: "play.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .primaryButton()
        }
        .padding()
    }
}

struct FastingStatsCard: View {
    let sessionHistory: [FastingSession]
    
    var totalFasts: Int {
        sessionHistory.count
    }
    
    var successfulFasts: Int {
        sessionHistory.filter { $0.currentDuration >= $0.plannedDuration }.count
    }
    
    var averageDuration: TimeInterval {
        guard !sessionHistory.isEmpty else { return 0 }
        let totalDuration = sessionHistory.reduce(0) { $0 + $1.currentDuration }
        return totalDuration / Double(sessionHistory.count)
    }
    
    var currentStreak: Int {
        var streak = 0
        let calendar = Calendar.current
        var lastDate: Date?
        
        for session in sessionHistory where session.isCompleted {
            if let last = lastDate {
                let daysBetween = calendar.dateComponents([.day], from: session.startTime, to: last).day ?? 0
                if daysBetween > 1 {
                    break
                }
            }
            streak += 1
            lastDate = session.startTime
        }
        
        return streak
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Fasting Stats")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                StatItem(
                    title: "Total Fasts",
                    value: "\(totalFasts)",
                    icon: "calendar",
                    color: .mochaBrown
                )
                
                StatItem(
                    title: "Success Rate",
                    value: totalFasts > 0 ? "\(Int(Double(successfulFasts) / Double(totalFasts) * 100))%" : "0%",
                    icon: "checkmark.circle",
                    color: .wellnessGreen
                )
                
                StatItem(
                    title: "Current Streak",
                    value: "\(currentStreak) days",
                    icon: "flame",
                    color: .orange
                )
                
                StatItem(
                    title: "Avg Duration",
                    value: formatDuration(averageDuration),
                    icon: "clock",
                    color: .mindfulTeal
                )
            }
        }
        .padding()
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}

struct FastingPlansInfoCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Popular Fasting Methods")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(FastingPlan.allCases.filter { $0 != .custom }, id: \.self) { plan in
                        FastingPlanCard(plan: plan)
                    }
                }
            }
        }
        .padding()
    }
}

struct FastingPlanCard: View {
    let plan: FastingPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(plan.rawValue)
                .font(.headline)
                .foregroundColor(.mochaBrown)
            
            Text(plan.displayName)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            if plan.fastingHours > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "moon.fill")
                        .font(.caption2)
                    Text("\(plan.fastingHours)h fast")
                        .font(.caption2)
                    
                    if plan.eatingWindowHours > 0 {
                        Image(systemName: "sun.max.fill")
                            .font(.caption2)
                            .padding(.leading, 4)
                        Text("\(plan.eatingWindowHours)h eat")
                            .font(.caption2)
                    }
                }
                .foregroundColor(.secondary)
            }
        }
        .frame(width: 140)
        .padding()
        .background(Color.lightGray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct RecentSessionsCard: View {
    let sessions: [FastingSession]
    let onViewAll: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Sessions")
                    .font(.headline)
                
                Spacer()
                
                if sessions.count > 5 {
                    Button("View All", action: onViewAll)
                        .font(.caption)
                        .foregroundColor(.mindfulTeal)
                }
            }
            
            if sessions.isEmpty {
                Text("No fasting sessions yet")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(sessions) { session in
                    FastingSessionRow(session: session)
                    
                    if session != sessions.last {
                        Divider()
                    }
                }
            }
        }
        .padding()
    }
}

struct FastingSessionRow: View {
    let session: FastingSession
    
    var durationText: String {
        let hours = Int(session.currentDuration) / 3600
        let minutes = (Int(session.currentDuration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
    var statusIcon: String {
        if session.currentDuration >= session.plannedDuration {
            return "checkmark.circle.fill"
        } else {
            return "xmark.circle"
        }
    }
    
    var statusColor: Color {
        if session.currentDuration >= session.plannedDuration {
            return .wellnessGreen
        } else {
            return .red.opacity(0.6)
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(session.fastingPlan.rawValue)
                        .font(.subheadline.bold())
                    
                    Image(systemName: statusIcon)
                        .foregroundColor(statusColor)
                        .font(.caption)
                }
                
                Text("\(session.startTime, style: .date) at \(session.startTime, style: .time)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Duration: \(durationText)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(Int(session.progress * 100))%")
                .font(.headline)
                .foregroundColor(session.progress >= 1 ? .wellnessGreen : .secondary)
        }
        .padding(.vertical, 4)
    }
}

struct FastingPlanSelectionView: View {
    @ObservedObject var fastingManager: FastingManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedPlan: FastingPlan
    @State private var customHours: Int
    
    init(fastingManager: FastingManager) {
        self.fastingManager = fastingManager
        self._selectedPlan = State(initialValue: fastingManager.selectedPlan)
        self._customHours = State(initialValue: fastingManager.customFastingHours)
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(FastingPlan.allCases, id: \.self) { plan in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(plan.rawValue)
                                    .font(.headline)
                                Text(plan.displayName)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedPlan == plan {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.mindfulTeal)
                            }
                        }
                        
                        Text(plan.description)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        if plan == .custom && selectedPlan == .custom {
                            HStack {
                                Text("Fasting Hours:")
                                    .font(.caption)
                                Stepper("\(customHours) hours", value: $customHours, in: 1...48)
                                    .font(.caption)
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedPlan = plan
                    }
                }
            }
            .navigationTitle("Choose Fasting Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        fastingManager.selectedPlan = selectedPlan
                        if selectedPlan == .custom {
                            fastingManager.customFastingHours = customHours
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct FastingHistoryView: View {
    let sessions: [FastingSession]
    @Environment(\.presentationMode) var presentationMode
    @State private var filterOption: FilterOption = .all
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case completed = "Completed"
        case incomplete = "Incomplete"
    }
    
    var filteredSessions: [FastingSession] {
        switch filterOption {
        case .all:
            return sessions
        case .completed:
            return sessions.filter { $0.currentDuration >= $0.plannedDuration }
        case .incomplete:
            return sessions.filter { $0.currentDuration < $0.plannedDuration }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Filter", selection: $filterOption) {
                    ForEach(FilterOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                List(filteredSessions) { session in
                    FastingSessionDetailRow(session: session)
                }
            }
            .navigationTitle("Fasting History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct FastingSessionDetailRow: View {
    let session: FastingSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.fastingPlan.rawValue)
                        .font(.headline)
                    Text("\(session.startTime, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if session.currentDuration >= session.plannedDuration {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.wellnessGreen)
                        .font(.title2)
                } else {
                    Text("\(Int(session.progress * 100))%")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Started")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(session.startTime, style: .time)
                        .font(.caption)
                }
                
                if let endTime = session.actualEndTime {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Ended")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(endTime, style: .time)
                            .font(.caption)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Duration")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(formatDuration(session.currentDuration))
                        .font(.caption)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Goal")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(formatDuration(session.plannedDuration))
                        .font(.caption)
                }
            }
            
            if let notes = session.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}