import SwiftUI

struct AIMealSuggestionView: View {
    var showsNavigationShell = true

    var body: some View {
        Group {
            if showsNavigationShell {
                NavigationStack {
                    ScrollView {
                        AIMealSuggestionContent()
                            .padding(.horizontal, Theme.Spacing.md)
                            .padding(.vertical, Theme.Spacing.lg)
                    }
                    .navigationTitle("AI Suggestions")
                    .navigationBarTitleDisplayMode(.large)
                }
            } else {
                AIMealSuggestionContent()
            }
        }
        .bubuScreenBackground()
    }
}

struct AIMealSuggestionContent: View {
    @EnvironmentObject private var aiViewModel: AIViewModel
    @EnvironmentObject private var settingsViewModel: SettingsViewModel

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: Theme.Spacing.xs)]

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            headerCard

            if !settingsViewModel.hasSavedAIAPIKey {
                apiKeyCard
            }

            LazyVGrid(columns: columns, spacing: Theme.Spacing.xs) {
                ForEach(aiViewModel.presetPrompts, id: \.self) { preset in
                    Button {
                        aiViewModel.loadPreset(preset)
                    } label: {
                        Text(preset)
                            .font(Theme.Typography.footnote)
                            .foregroundStyle(Theme.Palette.cocoa)
                            .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
                    }
                    .buttonStyle(BubuSecondaryButtonStyle())
                }
            }

            promptComposerCard

            if let errorMessage = aiViewModel.errorMessage {
                feedbackCard(
                    title: "Couldn’t load a suggestion",
                    message: errorMessage,
                    tint: Theme.Palette.surfaceRaised
                ) {
                    Button("Retry") {
                        Task {
                            await aiViewModel.fetchSuggestion(using: settingsViewModel.settings)
                        }
                    }
                    .buttonStyle(BubuSecondaryButtonStyle())
                }
            }

            if let response = aiViewModel.response {
                responseCard(response)
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            BubuSectionHeader(
                eyebrow: "Meal inspiration",
                title: "AI suggestions without the chaos",
                subtitle: "Use the NVIDIA-hosted model to get substitutions that still feel realistic, affordable, and aligned with the plan."
            )

            HStack(spacing: Theme.Spacing.xs) {
                BubuMetricPill(
                    title: "Model",
                    value: settingsViewModel.settings.aiConfiguration.model,
                    icon: "cpu.fill"
                )
                BubuMetricPill(
                    title: "Status",
                    value: settingsViewModel.settings.aiSuggestionsEnabled ? "Enabled" : "Disabled",
                    icon: "sparkles",
                    accent: settingsViewModel.settings.aiSuggestionsEnabled ? Theme.Palette.sage : Theme.Palette.warning
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bubuCard(tint: Theme.Palette.surface)
    }

    private var apiKeyCard: some View {
        feedbackCard(
            title: "API key needed",
            message: "Open Settings and save the NVIDIA API key there. Until then, AI suggestions stay disabled even though the rest of the planner continues to work."
        ) {
            Text("Current model: \(settingsViewModel.settings.aiConfiguration.model)")
                .font(Theme.Typography.footnote)
                .foregroundStyle(Theme.Palette.rose)
        }
    }

    private var promptComposerCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Prompt")
                .font(Theme.Typography.section)
                .foregroundStyle(Theme.Palette.cocoa)

            TextEditor(text: $aiViewModel.prompt)
                .font(UIFont.preferredFont(forTextStyle: .body).fontDescriptor.symbolicTraits.contains(.traitItalic) ? Theme.Typography.body : Theme.Typography.body)
                .frame(minHeight: 150)
                .padding(Theme.Spacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                        .fill(Theme.Palette.surfaceRaised)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                        .stroke(Theme.Palette.border, lineWidth: 1)
                )

            Button {
                Task {
                    await aiViewModel.fetchSuggestion(using: settingsViewModel.settings)
                }
            } label: {
                HStack(spacing: Theme.Spacing.xs) {
                    if aiViewModel.isLoading {
                        ProgressView()
                            .tint(Theme.Palette.onAccent)
                    }
                    Text(aiViewModel.isLoading ? "Thinking..." : "Get meal suggestion")
                }
            }
            .buttonStyle(BubuPrimaryButtonStyle())
            .disabled(aiViewModel.isLoading || !settingsViewModel.settings.aiSuggestionsEnabled)
            .opacity(aiViewModel.isLoading || !settingsViewModel.settings.aiSuggestionsEnabled ? 0.7 : 1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bubuCard(tint: Theme.Palette.surface)
    }

    private func responseCard(_ response: AISuggestionResponse) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(response.summary)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Palette.mist)

            ForEach(response.suggestions) { suggestion in
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(suggestion.title)
                        .font(Theme.Typography.section)
                        .foregroundStyle(Theme.Palette.cocoa)

                    Text(suggestion.detail)
                        .font(Theme.Typography.body)
                        .foregroundStyle(Theme.Palette.mist)

                    HStack(spacing: Theme.Spacing.xs) {
                        if let calories = suggestion.estimatedCalories {
                            BubuMetricPill(title: "Calories", value: calories.calorieText, icon: "flame.fill")
                        }
                        if let protein = suggestion.estimatedProteinGrams {
                            BubuMetricPill(title: "Protein", value: "\(protein.oneDecimalText) g", icon: "bolt.heart.fill", accent: Theme.Palette.sage)
                        }
                        if let cost = suggestion.estimatedCostCAD {
                            BubuMetricPill(title: "Cost", value: cost.asCurrencyCAD, icon: "dollarsign.circle.fill", accent: Theme.Palette.roseDeep)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .bubuCard(tint: Theme.Palette.surfaceRaised)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bubuCard(tint: Theme.Palette.surface)
    }

    private func feedbackCard<Content: View>(
        title: String,
        message: String,
        tint: Color = Theme.Palette.surface,
        @ViewBuilder footer: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(title)
                .font(Theme.Typography.section)
                .foregroundStyle(Theme.Palette.cocoa)

            Text(message)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Palette.mist)

            footer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bubuCard(tint: tint)
    }
}

#Preview {
    AIMealSuggestionView()
        .environmentObject(AIViewModel())
        .environmentObject(SettingsViewModel())
}
