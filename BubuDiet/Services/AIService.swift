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
            "Add your NVIDIA Kimi API key in Settings or Config.plist before requesting suggestions."
        case .invalidResponse:
            "The Kimi response could not be parsed into a suggestion."
        case .requestFailed(let message):
            message
        }
    }
}

struct AIService {
    private let session: URLSession
    private let keychain: KeychainService

    init(
        session: URLSession = .shared,
        keychain: KeychainService = .shared
    ) {
        self.session = session
        self.keychain = keychain
    }

    func fetchSuggestion(for prompt: String, settings: AppSettings) async throws -> AISuggestionResponse {
        guard settings.aiSuggestionsEnabled else {
            throw AIServiceError.disabled
        }

        let config = try loadConfiguration(using: settings)
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
            throw AIServiceError.requestFailed("NVIDIA Kimi API error (\(httpResponse.statusCode)): \(message)")
        }

        let chatResponse = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        guard let content = chatResponse.choices.first?.message.content else {
            throw AIServiceError.invalidResponse
        }

        return try parseSuggestion(prompt: prompt, from: content)
    }

    func generateTargetMealPlan(using settings: AppSettings, variation: Int) -> AISuggestionResponse {
        let meals = buildTargetMeals(targetCalories: settings.dailyCalorieTarget, variation: variation)
        let totalCalories = meals.reduce(0) { $0 + $1.adjustedCalories }
        let totalProtein = meals.reduce(0) { $0 + $1.adjustedProteinGrams }
        let totalCost = meals.reduce(0) { $0 + $1.adjustedCostCAD }

        let suggestions = meals.map { meal in
            AISuggestedMeal(
                title: "\(meal.type.rawValue) • \(meal.name)",
                detail: "\(meal.ingredients.count) simple ingredients. Portioned to around \(meal.adjustedCalories.calorieText) with \(meal.adjustedProteinGrams.oneDecimalText) g protein.",
                estimatedCalories: meal.adjustedCalories,
                estimatedProteinGrams: meal.adjustedProteinGrams,
                estimatedCostCAD: meal.adjustedCostCAD
            )
        }

        return AISuggestionResponse(
            prompt: "Build a \(settings.dailyCalorieTarget)-calorie day for \(settings.displayName)",
            summary: "This locally generated day lands around \(totalCalories.calorieText), \(totalProtein.oneDecimalText) g protein, and \(totalCost.asCurrencyCAD). Tap regenerate for another balanced combination.",
            suggestions: suggestions
        )
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

    private func loadConfiguration(using settings: AppSettings) throws -> KimiConfiguration {
        let bundledConfiguration = loadBundledConfiguration()
        let storedAPIKey = normalizedValue(keychain.loadString(for: SecureStorageKeys.kimiAPIKey))
        let bundledAPIKey = normalizedValue(bundledConfiguration?.apiKey)
        let apiKey = storedAPIKey ?? bundledAPIKey

        guard let apiKey else {
            throw AIServiceError.missingConfiguration
        }

        let settingsBaseURL = normalizedValue(settings.aiConfiguration.baseURL)
        let settingsModel = normalizedValue(settings.aiConfiguration.model)

        let baseURL = settingsBaseURL
            ?? normalizedValue(bundledConfiguration?.baseURL)
            ?? AppConstants.kimiEndpoint
        let model = settingsModel
            ?? normalizedValue(bundledConfiguration?.model)
            ?? AppConstants.kimiDefaultModel

        return KimiConfiguration(apiKey: apiKey, baseURL: baseURL, model: model)
    }

    private func loadBundledConfiguration() -> BundledKimiConfiguration? {
        let bundle = Bundle.main
        let resourceName = bundle.url(forResource: "Config", withExtension: "plist") != nil ? "Config" : "Config.example"

        guard
            let url = bundle.url(forResource: resourceName, withExtension: "plist"),
            let dictionary = NSDictionary(contentsOf: url) as? [String: Any]
        else {
            return nil
        }

        let apiKey = normalizedValue(dictionary["KIMI_API_KEY"] as? String)
        let baseURL = normalizedValue(dictionary["KIMI_BASE_URL"] as? String) ?? AppConstants.kimiEndpoint
        let model = normalizedValue(dictionary["KIMI_MODEL"] as? String) ?? AppConstants.kimiDefaultModel

        return BundledKimiConfiguration(apiKey: apiKey, baseURL: baseURL, model: model)
    }

    private func normalizedValue(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmed.isEmpty,
              !trimmed.contains("PASTE_YOUR")
        else {
            return nil
        }

        return trimmed
    }

    private func buildTargetMeals(targetCalories: Int, variation: Int) -> [Meal] {
        let allocations: [(MealType, Double)] = [
            (.breakfast, 0.28),
            (.lunch, 0.34),
            (.dinner, 0.38)
        ]

        return allocations.enumerated().map { index, allocation in
            let idealCalories = Int((Double(targetCalories) * allocation.1).rounded())
            let pool = candidateMeals(for: allocation.0)
                .sorted {
                    abs($0.baseCalories - idealCalories) < abs($1.baseCalories - idealCalories)
                }

            let candidateIndex = (variation + index) % max(pool.count, 1)
            return adjustedMeal(pool[candidateIndex], toward: idealCalories)
        }
    }

    private func candidateMeals(for type: MealType) -> [Meal] {
        switch type {
        case .breakfast:
            SampleData.breakfastMeals()
        case .lunch:
            SampleData.lunchMeals()
        case .dinner:
            SampleData.dinnerMeals()
        }
    }

    private func adjustedMeal(_ meal: Meal, toward targetCalories: Int) -> Meal {
        let rawMultiplier = Double(targetCalories) / Double(max(meal.baseCalories, 1))
        let roundedMultiplier = (rawMultiplier * 4).rounded() / 4
        let clampedMultiplier = min(max(roundedMultiplier, 0.75), 1.4)

        return Meal(
            id: UUID(),
            type: meal.type,
            name: meal.name,
            ingredients: meal.ingredients,
            baseCalories: meal.baseCalories,
            estimatedCostCAD: meal.estimatedCostCAD,
            proteinGrams: meal.proteinGrams,
            portionMultiplier: clampedMultiplier
        )
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

private struct BundledKimiConfiguration {
    let apiKey: String?
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
