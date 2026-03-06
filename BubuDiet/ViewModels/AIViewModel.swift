import Foundation

@MainActor
final class AIViewModel: ObservableObject {
    private enum SuggestionRequest {
        case prompt(String)
        case calorieTarget
    }

    @Published var prompt = ""
    @Published var response: AISuggestionResponse?
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var responseSource = "Local calorie-target generator"

    let presetPrompts = [
        "Suggest a breakfast under 500 calories.",
        "Suggest a high-protein lunch under 500 calories.",
        "Replace dinner with a vegetarian option.",
        "Suggest budget-friendly meals in Canada.",
        "Suggest meals without kale, fish, or wood apple."
    ]

    private let service: AIService
    private var lastRequest: SuggestionRequest?
    private var localVariation = 0

    init(service: AIService = AIService()) {
        self.service = service
    }

    func loadPreset(_ value: String) {
        prompt = value
    }

    func fetchSuggestion(using settings: AppSettings) async {
        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPrompt.isEmpty else {
            errorMessage = "Enter a prompt or tap one of the quick ideas."
            response = nil
            return
        }

        isLoading = true
        errorMessage = nil
        responseSource = "NVIDIA Kimi"

        do {
            response = try await service.fetchSuggestion(for: trimmedPrompt, settings: settings)
            lastRequest = .prompt(trimmedPrompt)
        } catch {
            response = nil
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func generateMealsForTarget(using settings: AppSettings) {
        localVariation = 0
        buildLocalTargetPlan(using: settings)
    }

    func regenerate(using settings: AppSettings) async {
        switch lastRequest {
        case .prompt:
            await fetchSuggestion(using: settings)
        case .calorieTarget, .none:
            localVariation += 1
            buildLocalTargetPlan(using: settings)
        }
    }

    private func buildLocalTargetPlan(using settings: AppSettings) {
        errorMessage = nil
        response = service.generateTargetMealPlan(using: settings, variation: localVariation)
        responseSource = "Local calorie-target generator"
        lastRequest = .calorieTarget
    }
}
