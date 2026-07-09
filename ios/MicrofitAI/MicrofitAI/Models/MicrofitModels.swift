import Foundation

enum FitnessGoal: String, CaseIterable, Codable, Identifiable {
    case moveMore
    case getStronger
    case buildMuscle
    case loseFat
    case feelBetter

    var id: String { rawValue }

    var title: String {
        switch self {
        case .moveMore: "Move more"
        case .getStronger: "Get stronger"
        case .buildMuscle: "Build muscle"
        case .loseFat: "Lose fat"
        case .feelBetter: "Feel better"
        }
    }

    var detail: String {
        switch self {
        case .moveMore: "Short movement wins across the day"
        case .getStronger: "Progressive strength and better movement"
        case .buildMuscle: "Focused volume with smart recovery"
        case .loseFat: "Consistent training, steps, and nutrition"
        case .feelBetter: "Energy, mobility, sleep, and resilience"
        }
    }

    var icon: String {
        switch self {
        case .moveMore: "figure.walk.motion"
        case .getStronger: "dumbbell.fill"
        case .buildMuscle: "figure.strengthtraining.traditional"
        case .loseFat: "flame.fill"
        case .feelBetter: "heart.fill"
        }
    }
}

enum ExperienceLevel: String, CaseIterable, Codable, Identifiable {
    case beginner
    case intermediate
    case advanced

    var id: String { rawValue }
    var title: String { rawValue.capitalized }

    var detail: String {
        switch self {
        case .beginner: "New or returning after time away"
        case .intermediate: "Training consistently for 6+ months"
        case .advanced: "Comfortable managing load and intensity"
        }
    }
}

enum EquipmentOption: String, CaseIterable, Codable, Identifiable {
    case bodyweight
    case dumbbells
    case bands
    case fullGym

    var id: String { rawValue }

    var title: String {
        switch self {
        case .bodyweight: "Bodyweight"
        case .dumbbells: "Dumbbells"
        case .bands: "Bands"
        case .fullGym: "Full gym"
        }
    }

    var icon: String {
        switch self {
        case .bodyweight: "figure.core.training"
        case .dumbbells: "dumbbell.fill"
        case .bands: "circle.dotted.circle.fill"
        case .fullGym: "building.2.fill"
        }
    }
}

struct MicrofitProfile: Codable, Equatable {
    var name: String
    var goal: FitnessGoal
    var experience: ExperienceLevel
    var sessionMinutes: Int
    var trainingDaysPerWeek: Int
    var equipment: Set<EquipmentOption>

    static let starter = MicrofitProfile(
        name: "",
        goal: .moveMore,
        experience: .beginner,
        sessionMinutes: 20,
        trainingDaysPerWeek: 3,
        equipment: [.bodyweight]
    )

    var displayName: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Athlete" : trimmed
    }
}

struct ExerciseDefinition: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let category: String
    let equipment: EquipmentOption
    let instructions: [String]
    let formCue: String
    let easierOption: String
    let harderOption: String
}

struct PlannedExercise: Codable, Identifiable, Hashable {
    let id: String
    let exercise: ExerciseDefinition
    let sets: Int
    let reps: Int
    let seconds: Int?
    let restSeconds: Int

    init(exercise: ExerciseDefinition, sets: Int, reps: Int, seconds: Int? = nil, restSeconds: Int = 45) {
        id = exercise.id
        self.exercise = exercise
        self.sets = sets
        self.reps = reps
        self.seconds = seconds
        self.restSeconds = restSeconds
    }

    var prescription: String {
        if let seconds { return "\(sets) × \(seconds)s" }
        return "\(sets) × \(reps)"
    }
}

struct WorkoutPlan: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let focus: String
    let summary: String
    let durationMinutes: Int
    let difficulty: ExperienceLevel
    let icon: String
    let exercises: [PlannedExercise]
}

struct LoggedSet: Codable, Identifiable, Hashable {
    let id: UUID
    let exerciseId: String
    let setNumber: Int
    var reps: Int
    var weight: Double
    var completed: Bool

    init(exerciseId: String, setNumber: Int, reps: Int, weight: Double = 0, completed: Bool = false) {
        id = UUID()
        self.exerciseId = exerciseId
        self.setNumber = setNumber
        self.reps = reps
        self.weight = weight
        self.completed = completed
    }
}

struct WorkoutLog: Codable, Identifiable, Hashable {
    let id: UUID
    let planId: String
    let title: String
    let completedAt: Date
    let durationMinutes: Int
    let completedSets: Int
    let totalReps: Int
    let trainingVolume: Double
    let effort: Int
    let isMicroSession: Bool
}

struct DailyCheckIn: Codable, Identifiable, Equatable {
    let dayKey: String
    var energy: Int
    var sleep: Int
    var soreness: Int
    var stress: Int

    var id: String { dayKey }

    static func today() -> DailyCheckIn {
        .init(dayKey: DayKey.today, energy: 3, sleep: 3, soreness: 2, stress: 2)
    }

    var readinessScore: Int {
        let positive = energy + sleep + (6 - soreness) + (6 - stress)
        return max(20, min(100, positive * 5))
    }

    var readinessLabel: String {
        switch readinessScore {
        case 80...: "Ready to push"
        case 60..<80: "Build steadily"
        case 45..<60: "Keep it light"
        default: "Recovery first"
        }
    }
}

struct HabitRecord: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let detail: String
    let icon: String
    var completedDayKeys: Set<String>

    func isComplete(on dayKey: String = DayKey.today) -> Bool {
        completedDayKeys.contains(dayKey)
    }
}

struct NutritionDayLog: Codable, Identifiable, Equatable {
    let dayKey: String
    var proteinGrams: Int
    var fiberGrams: Int
    var waterCups: Int
    var plants: Int

    var id: String { dayKey }

    static func today() -> NutritionDayLog {
        .init(dayKey: DayKey.today, proteinGrams: 0, fiberGrams: 0, waterCups: 0, plants: 0)
    }
}

struct CoachMessage: Codable, Identifiable, Hashable {
    let id: UUID
    let text: String
    let isCoach: Bool
    let createdAt: Date

    init(text: String, isCoach: Bool) {
        id = UUID()
        self.text = text
        self.isCoach = isCoach
        createdAt = Date()
    }
}

struct MicroInterval: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let seconds: Int
    let cue: String
    let isRest: Bool
}

struct MicroSession: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let summary: String
    let durationMinutes: Int
    let icon: String
    let intervals: [MicroInterval]
}

struct MicrofitSnapshot: Codable {
    var onboardingComplete: Bool
    var profile: MicrofitProfile
    var checkIns: [String: DailyCheckIn]
    var nutritionLogs: [String: NutritionDayLog]
    var habits: [HabitRecord]
    var workoutLogs: [WorkoutLog]
    var coachMessages: [CoachMessage]
    var reminderHours: [Int]
    var remindersEnabled: Bool
}

enum DayKey {
    static var today: String { key(for: Date()) }

    static func key(for date: Date) -> String {
        let parts = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }
}

enum MicrofitSeedData {
    static let exercises: [ExerciseDefinition] = [
        .init(id: "squat", name: "Tempo Squat", category: "Lower body", equipment: .bodyweight, instructions: ["Stand with feet just outside hip width.", "Lower for three seconds while keeping your whole foot grounded.", "Drive the floor away and stand tall."], formCue: "Knees track over toes; ribs stay stacked.", easierOption: "Sit to a chair and stand.", harderOption: "Hold a dumbbell at your chest."),
        .init(id: "pushup", name: "Push-Up", category: "Upper body", equipment: .bodyweight, instructions: ["Set hands just wider than shoulders.", "Brace from shoulders through heels.", "Lower with elbows about 45 degrees, then press."], formCue: "Move as one strong line.", easierOption: "Use a wall or elevated surface.", harderOption: "Pause one second at the bottom."),
        .init(id: "hinge", name: "Hip Hinge", category: "Posterior chain", equipment: .bodyweight, instructions: ["Soften the knees.", "Push hips back while keeping a long spine.", "Squeeze glutes to stand."], formCue: "Feel hamstrings, not your low back.", easierOption: "Shorten the range.", harderOption: "Hold dumbbells or a loaded backpack."),
        .init(id: "row", name: "Supported Row", category: "Upper body", equipment: .dumbbells, instructions: ["Support one hand on a stable surface.", "Pull the weight toward your back pocket.", "Lower with control."], formCue: "Keep shoulder away from your ear.", easierOption: "Use a light band or towel isometric.", harderOption: "Add a two-second squeeze."),
        .init(id: "split-squat", name: "Split Squat", category: "Lower body", equipment: .bodyweight, instructions: ["Take a comfortable staggered stance.", "Drop the back knee toward the floor.", "Press through the front foot to rise."], formCue: "Stay tall and own the front foot.", easierOption: "Hold a wall for balance.", harderOption: "Add dumbbells."),
        .init(id: "dead-bug", name: "Dead Bug", category: "Core", equipment: .bodyweight, instructions: ["Lie on your back with hips and knees at 90 degrees.", "Exhale and lower opposite arm and leg.", "Return without arching your back."], formCue: "Keep your low back gently heavy.", easierOption: "Move only the arms.", harderOption: "Slow each rep to five seconds."),
        .init(id: "glute-bridge", name: "Glute Bridge", category: "Posterior chain", equipment: .bodyweight, instructions: ["Plant feet near your hips.", "Exhale and lift the hips.", "Pause, squeeze, and lower slowly."], formCue: "Finish with glutes, not your low back.", easierOption: "Use a smaller range.", harderOption: "Use one leg or add load."),
        .init(id: "march", name: "Power March", category: "Conditioning", equipment: .bodyweight, instructions: ["Stand tall and brace lightly.", "Drive opposite arm and knee.", "Stay quick and quiet through the feet."], formCue: "Own the rhythm before adding speed.", easierOption: "Slow the pace.", harderOption: "Turn it into high knees."),
        .init(id: "mountain-climber", name: "Mountain Climber", category: "Conditioning", equipment: .bodyweight, instructions: ["Start in a strong plank.", "Drive one knee forward at a time.", "Keep shoulders stacked over hands."], formCue: "Hips stay quiet while legs move.", easierOption: "Use an elevated surface.", harderOption: "Increase pace without bouncing."),
        .init(id: "world-stretch", name: "World's Greatest Stretch", category: "Mobility", equipment: .bodyweight, instructions: ["Step into a long lunge.", "Place one hand down and rotate the other arm up.", "Breathe, switch, and repeat."], formCue: "Move slowly through a pain-free range.", easierOption: "Place the lower hand on a block or chair.", harderOption: "Add a hamstring rock-back."),
        .init(id: "wall-slide", name: "Wall Slide", category: "Mobility", equipment: .bodyweight, instructions: ["Stand with back near a wall.", "Slide arms upward without shrugging.", "Return slowly while breathing out."], formCue: "Keep ribs relaxed and neck long.", easierOption: "Work in a smaller range.", harderOption: "Lift hands gently away from the wall."),
        .init(id: "calf-raise", name: "Calf Raise", category: "Lower body", equipment: .bodyweight, instructions: ["Stand tall with even pressure through the forefoot.", "Rise onto the balls of your feet.", "Pause, then lower slowly."], formCue: "Travel straight up, not outward.", easierOption: "Use both hands for support.", harderOption: "Use one leg."),
        .init(id: "breathing", name: "90/90 Breathing", category: "Recovery", equipment: .bodyweight, instructions: ["Lie down with feet supported and knees bent.", "Breathe in quietly through your nose.", "Exhale slowly until ribs soften."], formCue: "Make the exhale longer than the inhale.", easierOption: "Sit comfortably instead.", harderOption: "Add a three-second pause after exhaling.")
    ]

    private static func exercise(_ id: String) -> ExerciseDefinition {
        exercises.first(where: { $0.id == id })!
    }

    static let strength = WorkoutPlan(
        id: "strength-foundation",
        title: "Strength Foundation",
        focus: "Full body strength",
        summary: "A balanced session that builds the movement patterns behind everyday strength.",
        durationMinutes: 35,
        difficulty: .beginner,
        icon: "dumbbell.fill",
        exercises: [
            .init(exercise: exercise("squat"), sets: 3, reps: 10, restSeconds: 60),
            .init(exercise: exercise("pushup"), sets: 3, reps: 8, restSeconds: 60),
            .init(exercise: exercise("hinge"), sets: 3, reps: 12, restSeconds: 60),
            .init(exercise: exercise("row"), sets: 3, reps: 10, restSeconds: 60),
            .init(exercise: exercise("dead-bug"), sets: 3, reps: 8, restSeconds: 45)
        ]
    )

    static let muscle = WorkoutPlan(
        id: "build-and-balance",
        title: "Build & Balance",
        focus: "Muscle and control",
        summary: "Moderate volume, deliberate tempo, and unilateral work for durable muscle.",
        durationMinutes: 40,
        difficulty: .intermediate,
        icon: "figure.strengthtraining.traditional",
        exercises: [
            .init(exercise: exercise("split-squat"), sets: 4, reps: 10, restSeconds: 75),
            .init(exercise: exercise("pushup"), sets: 4, reps: 10, restSeconds: 75),
            .init(exercise: exercise("row"), sets: 4, reps: 12, restSeconds: 75),
            .init(exercise: exercise("glute-bridge"), sets: 4, reps: 15, restSeconds: 60),
            .init(exercise: exercise("dead-bug"), sets: 3, reps: 10, restSeconds: 45)
        ]
    )

    static let conditioning = WorkoutPlan(
        id: "engine-builder",
        title: "Engine Builder",
        focus: "Conditioning",
        summary: "Low-space intervals that raise your heart rate without complicated equipment.",
        durationMinutes: 18,
        difficulty: .intermediate,
        icon: "flame.fill",
        exercises: [
            .init(exercise: exercise("march"), sets: 4, reps: 0, seconds: 40, restSeconds: 20),
            .init(exercise: exercise("squat"), sets: 4, reps: 12, restSeconds: 25),
            .init(exercise: exercise("mountain-climber"), sets: 4, reps: 0, seconds: 30, restSeconds: 30),
            .init(exercise: exercise("glute-bridge"), sets: 3, reps: 15, restSeconds: 30)
        ]
    )

    static let recovery = WorkoutPlan(
        id: "recovery-reset",
        title: "Recovery Reset",
        focus: "Mobility and downshift",
        summary: "Restore range, reduce stiffness, and finish with calmer breathing.",
        durationMinutes: 12,
        difficulty: .beginner,
        icon: "wind",
        exercises: [
            .init(exercise: exercise("world-stretch"), sets: 2, reps: 5, restSeconds: 20),
            .init(exercise: exercise("wall-slide"), sets: 2, reps: 8, restSeconds: 20),
            .init(exercise: exercise("glute-bridge"), sets: 2, reps: 10, restSeconds: 20),
            .init(exercise: exercise("breathing"), sets: 1, reps: 0, seconds: 120, restSeconds: 0)
        ]
    )

    static var planLibrary: [WorkoutPlan] { [strength, muscle, conditioning, recovery] }

    static func adaptivePlan(profile: MicrofitProfile, checkIn: DailyCheckIn) -> WorkoutPlan {
        if checkIn.readinessScore < 50 || checkIn.soreness >= 4 { return recovery }
        switch profile.goal {
        case .getStronger: return strength
        case .buildMuscle: return muscle
        case .loseFat: return conditioning
        case .moveMore: return profile.sessionMinutes <= 15 ? recovery : conditioning
        case .feelBetter: return checkIn.readinessScore >= 75 ? strength : recovery
        }
    }

    static let habits: [HabitRecord] = [
        .init(id: "move", title: "Move with intent", detail: "Complete any workout or micro-session", icon: "figure.walk.motion", completedDayKeys: []),
        .init(id: "protein", title: "Protein anchor", detail: "Include protein in three meals", icon: "fork.knife", completedDayKeys: []),
        .init(id: "water", title: "Hydrate", detail: "Reach eight cups of water", icon: "drop.fill", completedDayKeys: []),
        .init(id: "reset", title: "Two-minute reset", detail: "Breathe, stretch, or walk without a screen", icon: "leaf.fill", completedDayKeys: [])
    ]

    static let microSessions: [MicroSession] = [
        .init(id: "desk-reset", title: "Desk Reset", summary: "Undo sitting with mobility and light strength.", durationMinutes: 3, icon: "chair.lounge.fill", intervals: [
            .init(id: "desk-1", title: "Power March", seconds: 40, cue: "Tall posture, quick quiet feet.", isRest: false),
            .init(id: "desk-2", title: "Breathe", seconds: 15, cue: "Slow exhale and reset.", isRest: true),
            .init(id: "desk-3", title: "Tempo Squat", seconds: 45, cue: "Three seconds down, stand with intent.", isRest: false),
            .init(id: "desk-4", title: "Breathe", seconds: 15, cue: "Relax shoulders.", isRest: true),
            .init(id: "desk-5", title: "Wall Slide", seconds: 45, cue: "Ribs soft, neck long.", isRest: false),
            .init(id: "desk-6", title: "Calf Raise", seconds: 20, cue: "Pause at the top.", isRest: false)
        ]),
        .init(id: "energy-boost", title: "Energy Boost", summary: "A fast pulse of low-space conditioning.", durationMinutes: 5, icon: "bolt.fill", intervals: [
            .init(id: "energy-1", title: "Power March", seconds: 45, cue: "Build rhythm and breathe.", isRest: false),
            .init(id: "energy-2", title: "Rest", seconds: 15, cue: "Shake out your arms.", isRest: true),
            .init(id: "energy-3", title: "Squat", seconds: 45, cue: "Smooth reps, whole foot grounded.", isRest: false),
            .init(id: "energy-4", title: "Rest", seconds: 15, cue: "One long exhale.", isRest: true),
            .init(id: "energy-5", title: "Incline Push-Up", seconds: 45, cue: "Use a desk or wall if needed.", isRest: false),
            .init(id: "energy-6", title: "Rest", seconds: 15, cue: "Stay loose.", isRest: true),
            .init(id: "energy-7", title: "Mountain Climber", seconds: 45, cue: "Elevate hands for a lighter option.", isRest: false),
            .init(id: "energy-8", title: "Breathe", seconds: 30, cue: "Finish under control.", isRest: true)
        ]),
        .init(id: "calm-down", title: "Calm Down", summary: "Mobility and breathing for a cleaner reset.", durationMinutes: 4, icon: "wind", intervals: [
            .init(id: "calm-1", title: "World's Greatest Stretch", seconds: 60, cue: "Move slowly and switch sides halfway.", isRest: false),
            .init(id: "calm-2", title: "Wall Slide", seconds: 45, cue: "Keep ribs relaxed.", isRest: false),
            .init(id: "calm-3", title: "Hip Hinge", seconds: 45, cue: "Reach hips back and stand tall.", isRest: false),
            .init(id: "calm-4", title: "90/90 Breathing", seconds: 90, cue: "Long, quiet exhales.", isRest: false)
        ])
    ]
}
