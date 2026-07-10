import Foundation
import Observation
import UserNotifications

#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26.0, *)
@Generable(description: "A grounded two-part Microfit coaching response")
private struct GeneratedCoachReply {
    @Guide(description: "One concise paragraph naming the exact recommended plan from context and briefly tying it to readiness. Omit labels and greetings.")
    var bestNextStep: String

    @Guide(description: "One concise paragraph naming exactly one available in-app micro-session from context. Omit labels and greetings.")
    var smallerOption: String
}
#endif

@MainActor
@Observable
final class MicrofitAppState {
    var selectedTab: MicrofitTab = .today
    var isBootstrapping = true
    var isWorking = false
    var onboardingComplete = false
    var profile = MicrofitProfile.starter
    var checkIns: [String: DailyCheckIn] = [:]
    var nutritionLogs: [String: NutritionDayLog] = [:]
    var habits = MicrofitSeedData.habits
    var workoutLogs: [WorkoutLog] = []
    var coachMessages: [CoachMessage] = [
        .init(
            text: "I’m your private Microfit coach. Tell me how you feel, what you have time for, or where you’re stuck—and we’ll choose the smallest useful next step.",
            isCoach: true
        )
    ]
    var reminderHours = [10, 12, 15, 17]
    var remindersEnabled = false
    var errorMessage: String?
    var successMessage: String?

    private let defaults: UserDefaults
    private let storageKey = "microfit.snapshot.v2"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var todayCheckIn: DailyCheckIn {
        checkIns[DayKey.today] ?? .today()
    }

    var todayNutrition: NutritionDayLog {
        nutritionLogs[DayKey.today] ?? .today()
    }

    var todayPlan: WorkoutPlan {
        MicrofitSeedData.adaptivePlan(profile: profile, checkIn: todayCheckIn)
    }

    var firstName: String {
        profile.displayName.split(separator: " ").first.map(String.init) ?? "Athlete"
    }

    var xp: Int {
        let workoutXP = workoutLogs.reduce(0) { $0 + ($1.isMicroSession ? 35 : 120 + $1.completedSets * 4) }
        let habitXP = habits.reduce(0) { $0 + $1.completedDayKeys.count * 12 }
        return workoutXP + habitXP
    }

    var level: Int { max(1, xp / 500 + 1) }
    var levelProgress: Double { Double(xp % 500) / 500.0 }
    var xpToNextLevel: Int { 500 - (xp % 500) }

    var workoutsThisWeek: [WorkoutLog] {
        workoutLogs.filter { Calendar.current.isDate($0.completedAt, equalTo: Date(), toGranularity: .weekOfYear) }
    }

    var weeklyMinutes: Int { workoutsThisWeek.reduce(0) { $0 + $1.durationMinutes } }
    var weeklySessions: Int { workoutsThisWeek.count }

    var habitCompletionCount: Int {
        habits.filter { $0.isComplete() }.count
    }

    var currentStreak: Int {
        let completedDays = Set(workoutLogs.map { DayKey.key(for: $0.completedAt) })
        guard !completedDays.isEmpty else { return 0 }

        let calendar = Calendar.current
        var date = Date()
        if !completedDays.contains(DayKey.key(for: date)), let yesterday = calendar.date(byAdding: .day, value: -1, to: date) {
            date = yesterday
        }

        var streak = 0
        while completedDays.contains(DayKey.key(for: date)) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: date) else { break }
            date = previous
        }
        return streak
    }

    var coachModeLabel: String {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *), SystemLanguageModel.default.isAvailable {
            return "Private on-device AI"
        }
        #endif
        return "Private adaptive coach"
    }

    var recentWorkoutLogs: [WorkoutLog] {
        workoutLogs.sorted { $0.completedAt > $1.completedAt }
    }

    func bootstrap() async {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--microfit-demo") {
            applyDemoSeed()
            let arguments = ProcessInfo.processInfo.arguments
            if arguments.contains("--microfit-plan") { selectedTab = .plan }
            else if arguments.contains("--microfit-move") { selectedTab = .move }
            else if arguments.contains("--microfit-coach") { selectedTab = .coach }
            else if arguments.contains("--microfit-progress") { selectedTab = .progress }
            else if arguments.contains("--microfit-fuel") { selectedTab = .fuel }
            else if arguments.contains("--microfit-me") { selectedTab = .profile }
            isBootstrapping = false
            return
        }
        #endif
        loadSnapshot()
        ensureTodayRecords()
        isBootstrapping = false
    }

    func finishOnboarding(with newProfile: MicrofitProfile, enableReminders: Bool) async {
        profile = newProfile
        onboardingComplete = true
        ensureTodayRecords()
        saveSnapshot()
        if enableReminders {
            await configureReminders(enabled: true)
        }
        successMessage = "Your adaptive plan is ready."
    }

    func updateProfile(_ updatedProfile: MicrofitProfile) {
        profile = updatedProfile
        saveSnapshot()
        successMessage = "Profile updated."
    }

    func updateCheckIn(energy: Int? = nil, sleep: Int? = nil, soreness: Int? = nil, stress: Int? = nil) {
        var entry = todayCheckIn
        if let energy { entry.energy = clampedRating(energy) }
        if let sleep { entry.sleep = clampedRating(sleep) }
        if let soreness { entry.soreness = clampedRating(soreness) }
        if let stress { entry.stress = clampedRating(stress) }
        checkIns[DayKey.today] = entry
        saveSnapshot()
    }

    func addNutrition(protein: Int = 0, fiber: Int = 0, water: Int = 0, plants: Int = 0) {
        var entry = todayNutrition
        entry.proteinGrams = max(0, entry.proteinGrams + protein)
        entry.fiberGrams = max(0, entry.fiberGrams + fiber)
        entry.waterCups = max(0, entry.waterCups + water)
        entry.plants = max(0, entry.plants + plants)
        nutritionLogs[DayKey.today] = entry

        if entry.waterCups >= 8 { markHabitComplete("water") }
        if entry.proteinGrams >= 90 { markHabitComplete("protein") }
        saveSnapshot()
    }

    func toggleHabit(_ habitId: String) {
        guard let index = habits.firstIndex(where: { $0.id == habitId }) else { return }
        if habits[index].completedDayKeys.contains(DayKey.today) {
            habits[index].completedDayKeys.remove(DayKey.today)
        } else {
            habits[index].completedDayKeys.insert(DayKey.today)
        }
        saveSnapshot()
    }

    func completeWorkout(plan: WorkoutPlan, sets: [LoggedSet], durationMinutes: Int, effort: Int) {
        let completed = sets.filter(\.completed)
        let totalReps = completed.reduce(0) { $0 + $1.reps }
        let volume = completed.reduce(0.0) { $0 + Double($1.reps) * max(1, $1.weight) }
        let log = WorkoutLog(
            id: UUID(),
            planId: plan.id,
            title: plan.title,
            completedAt: Date(),
            durationMinutes: max(1, durationMinutes),
            completedSets: completed.count,
            totalReps: totalReps,
            trainingVolume: volume,
            effort: clampedEffort(effort),
            isMicroSession: false
        )
        workoutLogs.append(log)
        markHabitComplete("move")
        saveSnapshot()
        successMessage = "\(plan.title) complete. +\(120 + completed.count * 4) XP"
    }

    func completeMicroSession(_ session: MicroSession) {
        let log = WorkoutLog(
            id: UUID(),
            planId: session.id,
            title: session.title,
            completedAt: Date(),
            durationMinutes: session.durationMinutes,
            completedSets: session.intervals.filter { !$0.isRest }.count,
            totalReps: 0,
            trainingVolume: 0,
            effort: 4,
            isMicroSession: true
        )
        workoutLogs.append(log)
        markHabitComplete("move")
        saveSnapshot()
        successMessage = "Small win logged. +35 XP"
    }

    func sendCoachMessage(_ text: String) async {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty, !isWorking else { return }

        coachMessages.append(.init(text: cleaned, isCoach: false))
        isWorking = true
        defer {
            isWorking = false
            saveSnapshot()
        }

        let context = coachContext(for: cleaned)

        if isSafetyQuestion(cleaned) {
            coachMessages.append(.init(text: fallbackCoachReply(to: cleaned), isCoach: true))
            return
        }

        #if canImport(FoundationModels)
        if #available(iOS 26.0, *), SystemLanguageModel.default.isAvailable {
            do {
                let reply = try await onDeviceReply(prompt: context)
                coachMessages.append(.init(text: reply, isCoach: true))
                return
            } catch {
                // The complete local fallback below keeps coaching available on every supported device.
            }
        }
        #endif

        coachMessages.append(.init(text: fallbackCoachReply(to: cleaned), isCoach: true))
    }

    func configureReminders(enabled: Bool, hours: [Int]? = nil) async {
        if let hours {
            reminderHours = Array(Set(hours.map { max(6, min(21, $0)) })).sorted()
        }

        let center = UNUserNotificationCenter.current()
        let identifiers = (0..<8).map { "microfit-move-\($0)" }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)

        guard enabled else {
            remindersEnabled = false
            saveSnapshot()
            return
        }

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound])
            guard granted else {
                remindersEnabled = false
                errorMessage = "Movement reminders are off. You can enable notifications in Settings."
                saveSnapshot()
                return
            }

            for (index, hour) in reminderHours.prefix(8).enumerated() {
                let content = UNMutableNotificationContent()
                content.title = "A Microfit minute"
                content.body = index.isMultiple(of: 2)
                    ? "Stand up, breathe, and give your body one small win."
                    : "Three minutes now can change how the rest of your day feels."
                content.sound = .default
                let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: hour), repeats: true)
                let request = UNNotificationRequest(identifier: "microfit-move-\(index)", content: content, trigger: trigger)
                try await center.add(request)
            }

            remindersEnabled = true
            successMessage = "Movement reminders scheduled."
        } catch {
            remindersEnabled = false
            errorMessage = "Microfit couldn’t schedule reminders: \(error.localizedDescription)"
        }
        saveSnapshot()
    }

    func deleteAllData() async {
        defaults.removeObject(forKey: storageKey)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: (0..<8).map { "microfit-move-\($0)" })
        selectedTab = .today
        onboardingComplete = false
        profile = .starter
        checkIns = [:]
        nutritionLogs = [:]
        habits = MicrofitSeedData.habits
        workoutLogs = []
        coachMessages = [.init(text: "Your local data is cleared. Start fresh whenever you’re ready.", isCoach: true)]
        reminderHours = [10, 12, 15, 17]
        remindersEnabled = false
        successMessage = nil
        errorMessage = nil
    }

    private func ensureTodayRecords() {
        if checkIns[DayKey.today] == nil { checkIns[DayKey.today] = .today() }
        if nutritionLogs[DayKey.today] == nil { nutritionLogs[DayKey.today] = .today() }
        if habits.isEmpty { habits = MicrofitSeedData.habits }
        saveSnapshot()
    }

    private func markHabitComplete(_ habitId: String) {
        guard let index = habits.firstIndex(where: { $0.id == habitId }) else { return }
        habits[index].completedDayKeys.insert(DayKey.today)
    }

    private func saveSnapshot() {
        let snapshot = MicrofitSnapshot(
            onboardingComplete: onboardingComplete,
            profile: profile,
            checkIns: checkIns,
            nutritionLogs: nutritionLogs,
            habits: habits,
            workoutLogs: workoutLogs,
            coachMessages: Array(coachMessages.suffix(30)),
            reminderHours: reminderHours,
            remindersEnabled: remindersEnabled
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(snapshot) {
            defaults.set(data, forKey: storageKey)
        }
    }

    private func loadSnapshot() {
        guard let data = defaults.data(forKey: storageKey) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let snapshot = try? decoder.decode(MicrofitSnapshot.self, from: data) else { return }
        onboardingComplete = snapshot.onboardingComplete
        profile = snapshot.profile
        checkIns = snapshot.checkIns
        nutritionLogs = snapshot.nutritionLogs
        habits = snapshot.habits
        workoutLogs = snapshot.workoutLogs
        coachMessages = snapshot.coachMessages.isEmpty
            ? [.init(text: "What would make today feel like a win?", isCoach: true)]
            : snapshot.coachMessages
        reminderHours = snapshot.reminderHours.isEmpty ? [10, 12, 15, 17] : snapshot.reminderHours
        remindersEnabled = snapshot.remindersEnabled
    }

    private func coachContext(for question: String) -> String {
        """
        Athlete name: \(profile.displayName)
        Primary goal: \(profile.goal.title)
        Experience: \(profile.experience.title)
        Available session time: \(profile.sessionMinutes) minutes
        Readiness: \(todayCheckIn.readinessScore)/100 (energy \(todayCheckIn.energy)/5, sleep \(todayCheckIn.sleep)/5, soreness \(todayCheckIn.soreness)/5, stress \(todayCheckIn.stress)/5)
        Today's recommended plan: \(todayPlan.title), \(todayPlan.durationMinutes) minutes
        Available smaller in-app options: Desk Reset (3 minutes), Calm Down (4 minutes), Energy Boost (5 minutes)
        Workouts this week: \(weeklySessions); minutes this week: \(weeklyMinutes); current streak: \(currentStreak)
        Nutrition today: \(todayNutrition.proteinGrams)g protein, \(todayNutrition.fiberGrams)g fiber, \(todayNutrition.waterCups) cups water, \(todayNutrition.plants) plant servings
        User question: \(question)
        """
    }

    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private func onDeviceReply(prompt: String) async throws -> String {
        let session = LanguageModelSession(instructions: """
            You are Microfit, a concise and encouraging fitness coach. Use only facts explicitly present in the supplied readiness, training, nutrition, and question context. Never invent history, feelings, motivation problems, prior behavior, symptoms, or observations. Never say or imply that you have seen the person struggle. Start directly—no greeting, letter format, signature, or signoff. For normal fitness questions, return exactly two short paragraphs labeled "Best next step:" and "Smaller option:". The best step should prefer the exact recommended plan named in context; the smaller option should name one available in-app micro-session. Explain the readiness reason briefly. Do not diagnose, treat, or claim medical expertise. If the person describes sharp pain, chest pain, faintness, severe shortness of breath, or an injury, tell them to stop and seek appropriate professional care. Avoid shame, absolutes, unsafe intensity, and medicalized claims. Keep the entire response under 100 words.
            """)
        let generated = try await session.respond(to: prompt, generating: GeneratedCoachReply.self).content
        var best = cleanCoachSection(generated.bestNextStep, label: "Best next step")
        if !best.localizedCaseInsensitiveContains(todayPlan.title) {
            best = "\(todayPlan.title), \(todayPlan.durationMinutes) minutes."
        }
        if !best.localizedCaseInsensitiveContains("readiness") {
            best = "Readiness is \(todayCheckIn.readinessScore)/100. \(best)"
        }

        var smaller = cleanCoachSection(generated.smallerOption, label: "Smaller option")
        let namesAnAvailableSession = MicrofitSeedData.microSessions.contains {
            smaller.localizedCaseInsensitiveContains($0.title)
        }
        if !namesAnAvailableSession {
            smaller = "Desk Reset, 3 minutes. Small useful work still counts."
        }
        return "Best next step: \(best)\n\nSmaller option: \(smaller)"
    }
    #endif

    private func fallbackCoachReply(to question: String) -> String {
        let lower = question.lowercased()
        if isSafetyQuestion(lower) {
            return "Stop the session if you have sharp pain, chest pain, faintness, severe shortness of breath, or symptoms that feel unsafe. Microfit can’t diagnose an injury. Choose gentle breathing only if that feels comfortable, and contact an appropriate medical professional before resuming training."
        }
        if lower.contains("sore") || lower.contains("recover") || todayCheckIn.readinessScore < 50 {
            return "Best next step: Do the 12-minute Recovery Reset at an easy pace because today’s readiness favors recovery.\n\nSmaller option: Choose the 4-minute Calm Down micro-session and finish feeling like you could have done more."
        }
        if lower.contains("eat") || lower.contains("protein") || lower.contains("nutrition") || lower.contains("food") {
            let remaining = max(0, 100 - todayNutrition.proteinGrams)
            return "Best next step: Build the next meal around a palm-sized protein, one high-fiber plant, and water. You’re about \(remaining)g from the app’s baseline protein target.\n\nSmaller option: Log one protein serving and one cup of water now."
        }
        if lower.contains("motivat") || lower.contains("skip") || lower.contains("tired") {
            return "Best next step: Start only the first exercise in \(todayPlan.title), then reassess. Consistency is the win; intensity is optional.\n\nSmaller option: Complete the 3-minute Desk Reset and end the zero."
        }
        if lower.contains("plan") || lower.contains("workout") || lower.contains("today") {
            return "Best next step: Do \(todayPlan.title), \(todayPlan.durationMinutes) minutes focused on \(todayPlan.focus.lowercased()). Start at a conversational effort and adjust from there.\n\nSmaller option: Complete the 3-minute Desk Reset and log the honest work."
        }
        return "Best next step: At \(todayCheckIn.readinessScore)/100 readiness, choose \(todayPlan.title) and keep effort around 6 out of 10. Focus on clean reps and finish with energy left.\n\nSmaller option: Do the 3-minute Desk Reset—small useful work still counts."
    }

    private func isSafetyQuestion(_ question: String) -> Bool {
        let lower = question.lowercased()
        return ["pain", "injur", "dizzy", "faint", "chest", "shortness of breath"].contains { lower.contains($0) }
    }

    private func cleanCoachSection(_ text: String, label: String) -> String {
        var cleaned = text.split(whereSeparator: \Character.isWhitespace).joined(separator: " ")
        if cleaned.lowercased().hasPrefix(label.lowercased()) {
            cleaned = String(cleaned.dropFirst(label.count))
                .trimmingCharacters(in: CharacterSet(charactersIn: ":–—- "))
        }
        return cleaned
    }

    private func clampedRating(_ value: Int) -> Int { max(1, min(5, value)) }
    private func clampedEffort(_ value: Int) -> Int { max(1, min(10, value)) }

    #if DEBUG
    private func applyDemoSeed() {
        let calendar = Calendar.current
        func date(daysAgo: Int, hour: Int) -> Date {
            let base = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
            return calendar.date(bySettingHour: hour, minute: 0, second: 0, of: base) ?? base
        }

        onboardingComplete = true
        profile = .init(
            name: "Alex",
            goal: .getStronger,
            experience: .intermediate,
            sessionMinutes: 30,
            trainingDaysPerWeek: 4,
            equipment: [.bodyweight, .dumbbells]
        )
        checkIns = [DayKey.today: .init(dayKey: DayKey.today, energy: 4, sleep: 4, soreness: 2, stress: 2)]
        nutritionLogs = [DayKey.today: .init(dayKey: DayKey.today, proteinGrams: 80, fiberGrams: 19, waterCups: 6, plants: 4)]
        habits = MicrofitSeedData.habits
        for index in habits.indices where habits[index].id != "reset" {
            habits[index].completedDayKeys.insert(DayKey.today)
        }
        workoutLogs = [
            .init(id: UUID(), planId: "strength-foundation", title: "Strength Foundation", completedAt: date(daysAgo: 0, hour: 7), durationMinutes: 32, completedSets: 15, totalReps: 138, trainingVolume: 4_820, effort: 7, isMicroSession: false),
            .init(id: UUID(), planId: "desk-reset", title: "Desk Reset", completedAt: date(daysAgo: 1, hour: 14), durationMinutes: 3, completedSets: 4, totalReps: 0, trainingVolume: 0, effort: 4, isMicroSession: true),
            .init(id: UUID(), planId: "engine-builder", title: "Engine Builder", completedAt: date(daysAgo: 2, hour: 18), durationMinutes: 18, completedSets: 15, totalReps: 108, trainingVolume: 1_540, effort: 8, isMicroSession: false),
            .init(id: UUID(), planId: "calm-down", title: "Calm Down", completedAt: date(daysAgo: 3, hour: 16), durationMinutes: 4, completedSets: 4, totalReps: 0, trainingVolume: 0, effort: 3, isMicroSession: true),
            .init(id: UUID(), planId: "build-and-balance", title: "Build & Balance", completedAt: date(daysAgo: 5, hour: 8), durationMinutes: 38, completedSets: 19, totalReps: 196, trainingVolume: 6_240, effort: 7, isMicroSession: false)
        ]
        coachMessages = [
            .init(text: "Your readiness is 80 today. Strength Foundation is the best match; Desk Reset is there if your schedule collapses.", isCoach: true)
        ]
        reminderHours = [10, 12, 15, 17]
        remindersEnabled = false
        errorMessage = nil
        successMessage = nil
    }
    #endif
}

enum MicrofitTab: String, CaseIterable, Identifiable {
    case today
    case plan
    case move
    case coach
    case progress
    case fuel
    case profile

    var id: String { rawValue }

    var label: String {
        switch self {
        case .today: "Today"
        case .plan: "Plan"
        case .move: "Move"
        case .coach: "Coach"
        case .progress: "Progress"
        case .fuel: "Fuel"
        case .profile: "Me"
        }
    }

    var shortLabel: String {
        switch self {
        case .progress: "Wins"
        default: label
        }
    }

    var icon: String {
        switch self {
        case .today: "sparkles"
        case .plan: "list.bullet.clipboard.fill"
        case .move: "figure.run"
        case .coach: "bubble.left.and.bubble.right.fill"
        case .progress: "chart.line.uptrend.xyaxis"
        case .fuel: "fork.knife"
        case .profile: "person.fill"
        }
    }
}
