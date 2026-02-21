import SwiftUI
import SwiftData

struct PlanView: View {
    @Query private var plans: [ProgramPlan]
    @Query private var sessions: [Session]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if let plan = plans.first {
                    VStack(alignment: .leading, spacing: 24) {
                        // Plan Overview
                        PlanOverviewSection(plan: plan)
                        
                        // Current Phase
                        CurrentPhaseSection(plan: plan)
                        
                        // Upcoming Sessions
                        UpcomingSessionsSection(plan: plan, sessions: sessions)
                        
                        // Activity Ladder
                        ActivityLadderSection(plan: plan)
                    }
                    .padding()
                } else {
                    ContentUnavailableView(
                        "No Active Plan",
                        systemImage: "list.clipboard",
                        description: Text("Complete onboarding to create your rehab plan")
                    )
                }
            }
            .navigationTitle("Plan")
        }
    }
}

struct PlanOverviewSection: View {
    let plan: ProgramPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Plan")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Week \(plan.currentWeek)")
                        .font(.headline)
                    Text("\(plan.currentPhaseId.capitalized)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if plan.isPaused {
                    Label("Paused", systemImage: "pause.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct CurrentPhaseSection: View {
    let plan: ProgramPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Phase")
                .font(.headline)
            
            Text("Focus: Building capacity with controlled progression")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // TODO: Load exercises from template
            VStack(alignment: .leading, spacing: 8) {
                PhaseExerciseRow(name: "Cat-Cow", sets: 2, reps: 8)
                PhaseExerciseRow(name: "Bird Dog", sets: 2, reps: "6/side")
                PhaseExerciseRow(name: "Dead Bug", sets: 2, reps: 8)
                PhaseExerciseRow(name: "Glute Bridge", sets: 2, reps: 10)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

struct PhaseExerciseRow: View {
    let name: String
    let sets: Int
    let reps: CustomStringConvertible
    
    var body: some View {
        HStack {
            Text(name)
                .font(.body)
            Spacer()
            Text("\(sets) × \(reps)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

struct UpcomingSessionsSection: View {
    let plan: ProgramPlan
    let sessions: [Session]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Sessions")
                .font(.headline)
            
            ForEach(getUpcomingDates(), id: \.self) { date in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(date, style: .date)
                            .font(.body)
                        Text(weekdayString(from: date))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "calendar")
                        .foregroundStyle(.blue)
                }
                .padding()
                .background(Color.blue.opacity(0.05))
                .cornerRadius(8)
            }
        }
    }
    
    private func getUpcomingDates() -> [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        
        for weekday in plan.weekdays.sorted() {
            if let date = calendar.nextDate(
                after: Date(),
                matching: DateComponents(weekday: weekday + 1),
                matchingPolicy: .nextTime
            ) {
                dates.append(date)
            }
        }
        
        return Array(dates.prefix(5))
    }
    
    private func weekdayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
}

struct ActivityLadderSection: View {
    let plan: ProgramPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Walking Progression")
                .font(.headline)
            
            Text("Level \(plan.activityLadderLevel + 1) of 5")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            ProgressView(value: Double(plan.activityLadderLevel + 1), total: 5)
                .tint(.green)
            
            Text("Current target: 90 minutes per week")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    PlanView()
        .modelContainer(for: [ProgramPlan.self, Session.self], inMemory: true)
}
