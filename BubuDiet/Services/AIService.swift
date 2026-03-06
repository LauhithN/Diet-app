import Foundation

enum AIServiceError: LocalizedError {
    case disabled
    case missingConfiguration
    case invalidResponse
    case requestFailed(String)

    var errorDescription: String? {
        switch self {
        case .disabled:
            "AI suggestions are turned off in Settings."
        case .missingConfiguration:
            "Config.plist is missing or still contains the placeholder Kimi API key."
        case .invalidResponse:
            "The Kimi response could not be parsed into a suggestion."
        case .requestFailed(let message):
            message
        }
    }
}

struct AIService {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchSuggestion(for prompt: String, settings: AppSettings) async throws -> AISuggestionResponse {
        guard settings.aiSuggestionsEnabled else {
            throw AIServiceError.disabled
        }

        let config = try loadConfiguration()
        let requestBody = ChatCompletionRequest(
            model: config.model,
            messages: [
                .init(role: "system", content: systemPrompt(targetCalories: settings.dailyCalorieTarget, name: settings.displayName)),
                .init(role: "user", content: prompt)
            ],
            temperature: 0.7
        )

        guard let url = URL(string: config.baseURL) else {
            throw AIServiceError.missingConfiguration
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown server error."
            throw AIServiceError.requestFailed("Kimi API error (\(httpResponse.statusCode)): \(message)")
        }

        let chatResponse = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        guard let content = chatResponse.choices.first?.message.content else {
            throw AIServiceError.invalidResponse
        }

        return try parseSuggestion(prompt: prompt, from: content)
    }

    private func systemPrompt(targetCalories: Int, name: String) -> String {
        """
        You are creating meal suggestions for \(name), a woman following a \(targetCalories)-calorie day.
        Requirements:
        - No kale
        - No fish
        - No wood apple
        - Simple, realistic, affordable meals in Canada
        - High protein
        - Beginner friendly
        Return strict JSON using this shape:
        {
          "summary": "one short paragraph",
          "suggestions": [
            {
              "title": "meal title",
              "detail": "why it fits and quick prep steps",
              "estimatedCalories": 0,
              "estimatedProteinGrams": 0,
              "estimatedCostCAD": 0
            }
          ]
        }
        """
    }

    private func loadConfiguration() throws -> KimiConfiguration {
        let bundle = Bundle.main
        let resourceName = bundle.url(forResource: "Config", withExtension: "plist") != nil ? "Config" : "Config.example"

        guard
            let url = bundle.url(forResource: resourceName, withExtension: "plist"),
            let dictionary = NSDictionary(contentsOf: url) as? [String: Any]
        else {
            throw AIServiceError.missingConfiguration
        }

        let apiKey = dictionary["KIMI_API_KEY"] as? String ?? ""
        let baseURL = dictionary["KIMI_BASE_URL"] as? String ?? AppConstants.kimiEndpoint
        let model = dictionary["KIMI_MODEL"] as? String ?? AppConstants.kimiDefaultModel

        guard !apiKey.isEmpty, !apiKey.contains("PASTE_YOUR") else {
            throw AIServiceError.missingConfiguration
        }

        return KimiConfiguration(apiKey: apiKey, baseURL: baseURL, model: model)
    }

    private func parseSuggestion(prompt: String, from content: String) throws -> AISuggestionResponse {
        let sanitized = content
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let data = sanitized.data(using: .utf8),
           let payload = try? JSONDecoder().decode(AIJSONPayload.self, from: data) {
            let suggestions = payload.suggestions.map {
                AISuggestedMeal(
                    title: $0.title,
                    detail: $0.detail,
                    estimatedCalories: $0.estimatedCalories,
                    estimatedProteinGrams: $0.estimatedProteinGrams,
                    estimatedCostCAD: $0.estimatedCostCAD
                )
            }

            return AISuggestionResponse(prompt: prompt, summary: payload.summary, suggestions: suggestions)
        }

        let paragraphs = sanitized
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard let first = paragraphs.first else {
            throw AIServiceError.invalidResponse
        }

        let suggestions = paragraphs.dropFirst().enumerated().map { index, paragraph in
            AISuggestedMeal(title: "Suggestion \(index + 1)", detail: paragraph)
        }

        return AISuggestionResponse(
            prompt: prompt,
            summary: first,
            suggestions: suggestions.isEmpty ? [AISuggestedMeal(title: "Suggestion", detail: sanitized)] : suggestions
        )
    }
}

private struct KimiConfiguration {
    let apiKey: String
    let baseURL: String
    let model: String
}

private struct ChatCompletionRequest: Encodable {
    struct Message: Encodable {
        let role: String
        let content: String
    }

    let model: String
    let messages: [Message]
    let temperature: Double
}

private struct ChatCompletionResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            let content: String
        }

        let message: Message
    }

    let choices: [Choice]
}

private struct AIJSONPayload: Decodable {
    struct Suggestion: Decodable {
        let title: String
        let detail: String
        let estimatedCalories: Int?
        let estimatedProteinGrams: Double?
        let estimatedCostCAD: Double?
    }

    let summary: String
    let suggestions: [Suggestion]
}
