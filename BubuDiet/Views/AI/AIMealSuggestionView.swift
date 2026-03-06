import SwiftUI

struct AIMealSuggestionView: View {
    @EnvironmentObject private var aiViewModel: AIViewModel
    @EnvironmentObject private var settingsViewModel: SettingsViewModel

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("AI meal ideas")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Theme.cocoa)
                        Text("Use Kimi to suggest replacements that stay simple, affordable, high-protein, and tailored to Bubu’s rules.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .bubuCard()

                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(aiViewModel.presetPrompts, id: \.self) { preset in
                            Button {
                                aiViewModel.loadPreset(preset)
                            } label: {
                                Text(preset)
                                    .font(.footnote.weight(.medium))
                                    .foregroundStyle(Theme.cocoa)
                                    .frame(maxWidth: .infinity, minHeight: 72)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .fill(Color.white.opacity(0.9))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Prompt")
                            .font(.headline)
                            .foregroundStyle(Theme.cocoa)
                        TextEditor(text: $aiViewModel.prompt)
                            .frame(minHeight: 130)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Theme.cream)
                            )

                        Button {
                            Task {
                                await aiViewModel.fetchSuggestion(using: settingsViewModel.settings)
                            }
                        } label: {
                            HStack {
                                if aiViewModel.isLoading {
                                    SwiftUI.ProgressView()
                                        .tint(.white)
                                }
                                Text(aiViewModel.isLoading ? "Thinking..." : "Get meal suggestion")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Theme.rose)
                        .disabled(aiViewModel.isLoading || !settingsViewModel.settings.aiSuggestionsEnabled)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .bubuCard()

                    if let errorMessage = aiViewModel.errorMessage {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Couldn’t load a suggestion")
                                .font(.headline)
                                .foregroundStyle(Theme.cocoa)
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Button("Retry") {
                                Task {
                                    await aiViewModel.fetchSuggestion(using: settingsViewModel.settings)
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .bubuCard()
                    }

                    if let response = aiViewModel.response {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(response.summary)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            ForEach(response.suggestions) { suggestion in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(suggestion.title)
                                        .font(.headline)
                                        .foregroundStyle(Theme.cocoa)
                                    Text(suggestion.detail)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)

                                    HStack {
                                        if let calories = suggestion.estimatedCalories {
                                            Label("\(calories) cal", systemImage: "flame")
                                        }
                                        if let protein = suggestion.estimatedProteinGrams {
                                            Label("\(protein.oneDecimalText) g", systemImage: "bolt.heart")
                                        }
                                        if let cost = suggestion.estimatedCostCAD {
                                            Label(cost.asCurrencyCAD, systemImage: "dollarsign.circle")
                                        }
                                    }
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(Theme.rose)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(Theme.cream)
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .bubuCard()
                    }
                }
                .padding()
            }
            .background(Theme.cream.ignoresSafeArea())
            .navigationTitle("AI Suggestions")
        }
    }
}

#Preview {
    AIMealSuggestionView()
        .environmentObject(AIViewModel())
        .environmentObject(SettingsViewModel())
}
