import Foundation

@MainActor
final class AIViewModel: ObservableObject {
    @Published var prompt = ""
    @Published var response: AISuggestionResponse?
    @Published var errorMessage: String?
    @Published var isLoading = false

    let presetPrompts = [
        "Suggest a breakfast under 500 calories.",
        "Suggest a high-protein lunch under 500 calories.",
        "Replace dinner with a vegetarian option.",
        "Suggest budget-friendly meals in Canada.",
        "Suggest meals without kale, fish, or wood apple."
    ]

    private let service: AIService

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

        do {
            response = try await service.fetchSuggestion(for: trimmedPrompt, settings: settings)
        } catch {
            response = nil
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
