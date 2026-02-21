import SwiftUI

struct SessionExerciseInfo: View {
    let name: String
    let currentSet: Int
    let totalSets: Int
    let reps: Int?
    let holdSec: Int?
    
    var body: some View {
        VStack(spacing: 16) {
            Text(name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            Text("Set \(currentSet) of \(totalSets)")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.8))
            
            if let reps = reps {
                Text("\(reps) reps")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
            } else if let hold = holdSec {
                Text("\(hold) seconds")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(name), Set \(currentSet) of \(totalSets), \(dosageText)")
    }
    
    private var dosageText: String {
        if let reps = reps {
            return "\(reps) reps"
        } else if let hold = holdSec {
            return "\(hold) seconds"
        }
        return ""
    }
}

#Preview {
    ZStack {
        Color.black
        SessionExerciseInfo(
            name: "Cat-Cow",
            currentSet: 1,
            totalSets: 2,
            reps: 8,
            holdSec: nil
        )
    }
}
