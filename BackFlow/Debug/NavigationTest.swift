import SwiftUI

// Simple test to verify navigation pattern works
struct NavigationTestView: View {
    @State private var currentStep = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Current Step: \(currentStep)")
                .font(.largeTitle)
            
            switch currentStep {
            case 0:
                StepView(
                    stepNumber: 0,
                    onContinue: {
                        print("Step 0 calling onContinue")
                        currentStep = 1
                        print("currentStep updated to: \(currentStep)")
                    }
                )
            case 1:
                StepView(
                    stepNumber: 1,
                    onContinue: {
                        print("Step 1 calling onContinue")
                        currentStep = 2
                        print("currentStep updated to: \(currentStep)")
                    }
                )
            default:
                Text("Completed!")
                    .font(.title)
                Button("Reset") {
                    currentStep = 0
                }
            }
        }
        .padding()
    }
}

struct StepView: View {
    let stepNumber: Int
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Step \(stepNumber)")
                .font(.title)
            
            Button("Continue") {
                print("Button tapped in step \(stepNumber)")
                onContinue()
            }
            .buttonStyle(.borderedProminent)
            
            // Test with async
            Button("Continue (Async)") {
                print("Async button tapped in step \(stepNumber)")
                Task { @MainActor in
                    onContinue()
                }
            }
            .buttonStyle(.bordered)
            
            // Test with delay
            Button("Continue (Delayed)") {
                print("Delayed button tapped in step \(stepNumber)")
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 100_000_000)
                    onContinue()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    NavigationTestView()
}