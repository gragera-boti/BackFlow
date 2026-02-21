import SwiftUI

struct RedFlagsView: View {
    let onPass: () -> Void
    let onFail: () -> Void
    
    @State private var responses: [Bool] = Array(repeating: false, count: 7)
    
    let questions = [
        "New bowel or bladder control problems?",
        "Numbness in saddle area (groin/buttocks)?",
        "Severe or progressive leg weakness?",
        "Fever with severe back pain?",
        "Severe night pain or unexplained weight loss?",
        "Major trauma (fall, accident) or suspected fracture?",
        "Unable to walk normally / rapidly worsening symptoms?"
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Safety Check")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Please answer these important safety questions")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(Array(questions.enumerated()), id: \.offset) { index, question in
                        RedFlagQuestion(
                            question: question,
                            isSelected: $responses[index]
                        )
                    }
                }
                .padding()
            }
            
            Button(action: handleSubmit) {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    private func handleSubmit() {
        if responses.contains(true) {
            onFail()
        } else {
            onPass()
        }
    }
}

struct RedFlagQuestion: View {
    let question: String
    @Binding var isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(question)
                    .font(.body)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: { isSelected = false }) {
                    Text("No")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(isSelected == false ? Color.green : Color.gray.opacity(0.2))
                        .foregroundStyle(isSelected == false ? .white : .primary)
                        .cornerRadius(8)
                }
                
                Button(action: { isSelected = true }) {
                    Text("Yes")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(isSelected == true ? Color.red : Color.gray.opacity(0.2))
                        .foregroundStyle(isSelected == true ? .white : .primary)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    RedFlagsView(onPass: {}, onFail: {})
}
