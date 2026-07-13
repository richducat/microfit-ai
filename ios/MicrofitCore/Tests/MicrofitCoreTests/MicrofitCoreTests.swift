import Foundation
import Testing
@testable import MicrofitCore

@Test func readinessRewardsEnergySleepAndLowStrain() {
    #expect(ReadinessScoring.score(energy: 5, sleep: 5, soreness: 1, stress: 1) == 100)
    #expect(ReadinessScoring.score(energy: 1, sleep: 1, soreness: 5, stress: 5) == 20)
    #expect(ReadinessScoring.score(energy: 3, sleep: 3, soreness: 2, stress: 2) == 70)
}

@Test func recommendationFailsSafeTowardRecovery() {
    #expect(ReadinessScoring.recommendation(score: 45, soreness: 2) == .recovery)
    #expect(ReadinessScoring.recommendation(score: 75, soreness: 4) == .recovery)
    #expect(ReadinessScoring.recommendation(score: 85, soreness: 1) == .progress)
    #expect(ReadinessScoring.recommendation(score: 65, soreness: 2) == .steady)
}

@Test func streakCanStartYesterdayWithoutPunishingCurrentDay() throws {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    let today = try #require(calendar.date(from: DateComponents(year: 2026, month: 7, day: 9)))
    let keys: Set<String> = ["2026-07-08", "2026-07-07", "2026-07-06"]
    #expect(StreakCalculator.currentStreak(completedDayKeys: keys, today: today, calendar: calendar) == 3)
}

@Test func progressionAddsOnlyWhenEffortLeavesRoom() {
    #expect(ProgressionRules.nextTargetReps(current: 10, completedAllSets: true, effort: 7) == 11)
    #expect(ProgressionRules.nextTargetReps(current: 10, completedAllSets: true, effort: 9) == 10)
    #expect(ProgressionRules.nextTargetReps(current: 10, completedAllSets: false, effort: 6) == 10)
}

@Test func nutritionProgressIsClamped() {
    #expect(NutritionProgress.fraction(value: 50, target: 100) == 0.5)
    #expect(NutritionProgress.fraction(value: 150, target: 100) == 1)
    #expect(NutritionProgress.fraction(value: -10, target: 100) == 0)
}

@Test func trainerLeadEmailValidationRejectsAmbiguousAddresses() {
    #expect(TrainerLeadRules.isValidEmail("coach@example.com"))
    #expect(TrainerLeadRules.isValidEmail(" coach@example.com "))
    #expect(!TrainerLeadRules.isValidEmail("coach example.com"))
    #expect(!TrainerLeadRules.isValidEmail("coach@localhost"))
    #expect(!TrainerLeadRules.isValidEmail("@example.com"))
    #expect(!TrainerLeadRules.isValidEmail("coach@@example.com"))
}

@Test func trainerMatchingPrefersAvailableFormatAndSpecialty() {
    let strongMatch = TrainerLeadRules.matchScore(
        requestedFormat: "virtual",
        requestedSpecialties: ["strength", "beginnerFitness"],
        candidateFormats: ["virtual", "hybrid"],
        candidateSpecialties: ["strength", "beginnerFitness"],
        acceptsNewClients: true
    )
    let partialMatch = TrainerLeadRules.matchScore(
        requestedFormat: "virtual",
        requestedSpecialties: ["strength", "beginnerFitness"],
        candidateFormats: ["inPerson"],
        candidateSpecialties: ["strength"],
        acceptsNewClients: true
    )
    let unavailable = TrainerLeadRules.matchScore(
        requestedFormat: "virtual",
        requestedSpecialties: ["strength"],
        candidateFormats: ["virtual"],
        candidateSpecialties: ["strength"],
        acceptsNewClients: false
    )

    #expect(strongMatch == 80)
    #expect(partialMatch == 20)
    #expect(unavailable == Int.min)
}
