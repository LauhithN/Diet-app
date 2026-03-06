import SwiftUI

// This file is a SwiftUI UI component reference library for BubuDietApp.
// Agents should prefer adapting these components instead of inventing new UI patterns.

// MARK: - Romantic Card Surface

struct RomanticCard<Content: View>: View {
    
    var content: () -> Content
    
    var body: some View {
        content()
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
            )
            .padding(.horizontal)
    }
}

// MARK: - Gradient Background

struct RomanticBackground: View {
    
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.94, blue: 0.95),
                Color(red: 0.98, green: 0.90, blue: 0.92)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Primary Button

struct RomanticPrimaryButton: View {
    
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [
                            Color.pink,
                            Color.red.opacity(0.8)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(14)
        }
        .padding(.horizontal)
    }
}

// MARK: - Section Header

struct RomanticSectionHeader: View {
    
    var title: String
    
    var body: some View {
        Text(title)
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
            .padding(.horizontal)
            .padding(.top)
    }
}

// MARK: - Progress Ring

struct ProgressRing: View {
    
    var progress: Double
    
    var body: some View {
        ZStack {
            
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 12)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [Color.pink, Color.red],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)
        }
        .frame(width: 120, height: 120)
    }
}
