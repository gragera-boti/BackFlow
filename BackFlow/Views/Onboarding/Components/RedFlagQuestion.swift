import SwiftUI

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
                .accessibilityLabel("No to: \(question)")
                
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
                .accessibilityLabel("Yes to: \(question)")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    @Previewable @State var response = false
    RedFlagQuestion(
        question: "New bowel or bladder control problems?",
        isSelected: $response
    )
    .padding()
}
