import Foundation

public enum ReadinessScoring {
    public static func score(energy: Int, sleep: Int, soreness: Int, stress: Int) -> Int {
        let inputs = [energy, sleep, soreness, stress].map { max(1, min(5, $0)) }
        let positive = inputs[0] + inputs[1] + (6 - inputs[2]) + (6 - inputs[3])
        return max(20, min(100, positive * 5))
    }

    public static func recommendation(score: Int, soreness: Int) -> SessionRecommendation {
        if score < 50 || soreness >= 4 { return .recovery }
        if score >= 80 { return .progress }
        return .steady
    }
}

public enum SessionRecommendation: String, Equatable, Sendable {
    case recovery
    case steady
    case progress
}

public enum StreakCalculator {
    public static func currentStreak(completedDayKeys: Set<String>, today: Date, calendar: Calendar = .current) -> Int {
        guard !completedDayKeys.isEmpty else { return 0 }

        var date = today
        if !completedDayKeys.contains(dayKey(for: date, calendar: calendar)),
           let yesterday = calendar.date(byAdding: .day, value: -1, to: date) {
            date = yesterday
        }

        var streak = 0
        while completedDayKeys.contains(dayKey(for: date, calendar: calendar)) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: date) else { break }
            date = previous
        }
        return streak
    }

    public static func dayKey(for date: Date, calendar: Calendar = .current) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }
}

public enum ProgressionRules {
    public static func nextTargetReps(current: Int, completedAllSets: Bool, effort: Int) -> Int {
        let reps = max(1, current)
        guard completedAllSets, effort <= 8 else { return reps }
        return min(30, reps + 1)
    }

    public static func shouldReduceLoad(readiness: Int, soreness: Int, previousEffort: Int) -> Bool {
        readiness < 50 || soreness >= 4 || previousEffort >= 9
    }
}

public enum NutritionProgress {
    public static func fraction(value: Int, target: Int) -> Double {
        guard target > 0 else { return 0 }
        return min(1, max(0, Double(value) / Double(target)))
    }
}

public enum TrainerLeadRules {
    public static func isValidEmail(_ value: String) -> Bool {
        let cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.contains(" "), cleaned.count <= 254 else { return false }
        let parts = cleaned.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2, !parts[0].isEmpty else { return false }
        let domain = String(parts[1])
        return domain.contains(".") && !domain.hasPrefix(".") && !domain.hasSuffix(".")
    }

    public static func matchScore(
        requestedFormat: String,
        requestedSpecialties: Set<String>,
        candidateFormats: Set<String>,
        candidateSpecialties: Set<String>,
        acceptsNewClients: Bool
    ) -> Int {
        guard acceptsNewClients else { return Int.min }
        var score = candidateFormats.contains(requestedFormat) ? 40 : 0
        score += requestedSpecialties.intersection(candidateSpecialties).count * 20
        return score
    }
}
