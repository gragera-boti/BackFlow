import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var plans: [ProgramPlan]
    @Query private var sessions: [Session]
    @Query private var walkingLogs: [WalkingLog]
    @Query private var educationCards: [EducationCard]
    
    @State private var showSettings = false
    @State private var showQuickLog = false
    @State private var showSessionPlayer = false
    
    var todaySession: Session? {
        sessions.first(where: { Calendar.current.isDateInToday($0.date) && !$0.completed })
    }
    
    var todayWalkingTotal: Int {
        walkingLogs
            .filter { Calendar.current.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.durationMinutes }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Today's Session Card
                    if let plan = plans.first {
                        TodaySessionCard(
                            plan: plan,
                            session: todaySession,
                            onStartSession: { showSessionPlayer = true }
                        )
                    }
                    
                    // Walking Target Card
                    WalkingTargetCard(
                        todayMinutes: todayWalkingTotal,
                        targetMinutes: 30,
                        onLogWalk: { /* Show log sheet */ }
                    )
                    
                    // Quick Log Card
                    QuickLogCard(onTap: { showQuickLog = true })
                    
                    // Education Bite
                    if let card = educationCards.randomElement() {
                        EducationBiteCard(card: card)
                    }
                }
                .padding()
            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showQuickLog) {
                QuickLogSheet()
            }
            .fullScreenCover(isPresented: $showSessionPlayer) {
                if let session = todaySession {
                    SessionPlayerView(session: session)
                }
            }
        }
    }
}

struct TodaySessionCard: View {
    let plan: ProgramPlan
    let session: Session?
    let onStartSession: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Session")
                        .font(.headline)
                    Text("Phase \(plan.currentPhaseId.suffix(1)) • Week \(plan.currentWeek)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.largeTitle)
                    .foregroundStyle(.blue)
            }
            
            if plan.isPaused {
                Text("Plan paused: \(plan.pausedReason ?? "Unknown")")
                    .font(.subheadline)
                    .foregroundStyle(.orange)
            } else if session != nil {
                Button(action: onStartSession) {
                    Text("Start Session")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("✓ Session completed")
                        .font(.subheadline)
                        .foregroundStyle(.green)
                    
                    if let nextDate = plan.nextSessionDate {
                        Text("Next session: \(nextDate, style: .date)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(16)
    }
}

struct WalkingTargetCard: View {
    let todayMinutes: Int
    let targetMinutes: Int
    let onLogWalk: () -> Void
    
    var progress: Double {
        min(Double(todayMinutes) / Double(targetMinutes), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Walking Target")
                        .font(.headline)
                    Text("\(todayMinutes) / \(targetMinutes) min")
                        .font(.title3)
                        .fontWeight(.medium)
                }
                Spacer()
                Image(systemName: "figure.walk")
                    .font(.largeTitle)
                    .foregroundStyle(.green)
            }
            
            ProgressView(value: progress)
                .tint(.green)
            
            Button(action: onLogWalk) {
                Text("Log Walk")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.green.opacity(0.2))
                    .foregroundStyle(.green)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(16)
    }
}

struct QuickLogCard: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quick Log")
                        .font(.headline)
                    Text("Track symptoms anytime")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "note.text.badge.plus")
                    .font(.largeTitle)
                    .foregroundStyle(.orange)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

struct EducationBiteCard: View {
    let card: EducationCard
    
    var body: some View {
        NavigationLink(destination: EducationDetailView(card: card)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("💡 Learn")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Text(card.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Text(card.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .padding()
            .background(Color.purple.opacity(0.1))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TodayView()
        .modelContainer(for: [ProgramPlan.self, Session.self], inMemory: true)
}
