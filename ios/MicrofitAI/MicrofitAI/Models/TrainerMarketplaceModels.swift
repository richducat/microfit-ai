import Foundation

enum TrainerFormat: String, CaseIterable, Codable, Identifiable, Sendable {
    case virtual
    case inPerson
    case hybrid

    var id: String { rawValue }

    var title: String {
        switch self {
        case .virtual: "Virtual"
        case .inPerson: "In person"
        case .hybrid: "Hybrid"
        }
    }

    var icon: String {
        switch self {
        case .virtual: "video.fill"
        case .inPerson: "person.2.fill"
        case .hybrid: "arrow.trianglehead.2.clockwise.rotate.90"
        }
    }
}

enum TrainerSpecialty: String, CaseIterable, Codable, Identifiable, Sendable {
    case beginnerFitness
    case strength
    case muscleBuilding
    case fatLoss
    case mobility
    case healthyHabits
    case activeAging
    case sportPerformance

    var id: String { rawValue }

    var title: String {
        switch self {
        case .beginnerFitness: "Beginner fitness"
        case .strength: "Strength"
        case .muscleBuilding: "Muscle building"
        case .fatLoss: "Sustainable fat loss"
        case .mobility: "Mobility"
        case .healthyHabits: "Healthy habits"
        case .activeAging: "Active aging"
        case .sportPerformance: "Sport performance"
        }
    }

    var icon: String {
        switch self {
        case .beginnerFitness: "figure.walk.motion"
        case .strength: "dumbbell.fill"
        case .muscleBuilding: "figure.strengthtraining.traditional"
        case .fatLoss: "flame.fill"
        case .mobility: "figure.flexibility"
        case .healthyHabits: "checkmark.seal.fill"
        case .activeAging: "figure.cooldown"
        case .sportPerformance: "trophy.fill"
        }
    }
}

enum TrainerBudget: String, CaseIterable, Identifiable, Sendable {
    case under75
    case from75To125
    case over125
    case discuss

    var id: String { rawValue }

    var title: String {
        switch self {
        case .under75: "Under $75 / session"
        case .from75To125: "$75–$125 / session"
        case .over125: "$125+ / session"
        case .discuss: "Help me decide"
        }
    }
}

struct TrainerProfile: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let displayName: String
    let headline: String
    let biography: String
    let credentials: [String]
    let specialties: [TrainerSpecialty]
    let formats: [TrainerFormat]
    let serviceArea: String
    let timeZone: String
    let languages: [String]
    let startingPriceUSD: Int?
    let bookingURL: String?
    let credentialsReviewedAt: String?
    let acceptsNewClients: Bool
    let featured: Bool

    var initials: String {
        let parts = displayName.split(separator: " ").prefix(2)
        return parts.compactMap(\.first).map(String.init).joined().uppercased()
    }

    var formatLabel: String {
        formats.map(\.title).joined(separator: " • ")
    }

    var rateLabel: String {
        guard let startingPriceUSD else { return "Rate discussed after match" }
        return "From $\(startingPriceUSD) / session"
    }

    var hasReviewedCredentials: Bool {
        credentialsReviewedAt != nil
    }

    var bookingLink: URL? {
        guard let bookingURL else { return nil }
        return URL(string: bookingURL)
    }

    func matches(query: String, format: TrainerFormat?) -> Bool {
        if let format, !formats.contains(format) { return false }
        let cleaned = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !cleaned.isEmpty else { return true }
        let haystack = [
            displayName,
            headline,
            biography,
            serviceArea,
            timeZone,
            credentials.joined(separator: " "),
            specialties.map(\.title).joined(separator: " "),
            formats.map(\.title).joined(separator: " "),
            languages.joined(separator: " ")
        ].joined(separator: " ").lowercased()
        return haystack.contains(cleaned)
    }
}

struct TrainerDirectoryDocument: Codable, Sendable {
    let version: Int
    let updatedAt: String
    let trainers: [TrainerProfile]
}

enum TrainerDirectoryError: LocalizedError {
    case invalidResponse
    case unsupportedVersion

    var errorDescription: String? {
        switch self {
        case .invalidResponse: "The trainer directory is temporarily unavailable."
        case .unsupportedVersion: "This trainer directory needs a newer version of microfit.AI."
        }
    }
}

enum TrainerDirectoryLoader {
    static let directoryURL = URL(string: "https://richducat.github.io/microfit-ai/data/trainers.json")!

    static func load() async throws -> TrainerDirectoryDocument {
        var request = URLRequest(url: directoryURL)
        request.cachePolicy = .reloadRevalidatingCacheData
        request.timeoutInterval = 12
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw TrainerDirectoryError.invalidResponse
        }
        let document = try JSONDecoder().decode(TrainerDirectoryDocument.self, from: data)
        guard document.version == 1 else { throw TrainerDirectoryError.unsupportedVersion }
        return document
    }
}

struct TrainerMatchRequestDraft {
    var name = ""
    var email = ""
    var goal: FitnessGoal = .feelBetter
    var format: TrainerFormat = .virtual
    var budget: TrainerBudget = .discuss
    var availability = ""
    var notes = ""
    var shareProfileSummary = false
    var confirmsAdultOrGuardian = false
    var consentsToContact = false

    var canPrepare: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && TrainerLeadValidation.isValidEmail(email)
            && !availability.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && confirmsAdultOrGuardian
            && consentsToContact
    }

    func emailBody(profile: MicrofitProfile, preferredTrainer: TrainerProfile?) -> String {
        var sections = [
            "MICROFIT TRAINER MATCH REQUEST",
            "",
            "Name: \(name.trimmed)",
            "Email: \(email.trimmed)",
            "Preferred trainer: \(preferredTrainer?.displayName ?? "Best available match")",
            "Primary goal: \(goal.title)",
            "Training format: \(format.title)",
            "Budget: \(budget.title)",
            "Availability / time zone: \(availability.trimmed)",
            "",
            "What I want help with:",
            notes.trimmed.isEmpty ? "Not provided" : notes.trimmed
        ]

        if shareProfileSummary {
            sections.append(contentsOf: [
                "",
                "MICROFIT PROFILE SUMMARY I CHOSE TO SHARE",
                "Goal: \(profile.goal.title)",
                "Experience: \(profile.experience.title)",
                "Preferred session length: \(profile.sessionMinutes) minutes",
                "Training days: \(profile.trainingDaysPerWeek) per week",
                "Equipment: \(profile.equipment.map(\.title).sorted().joined(separator: ", "))",
                "",
                "No readiness check-ins, workout history, nutrition logs, or coach messages are included."
            ])
        }

        sections.append(contentsOf: [
            "",
            "I confirm I am 18 or older, or a parent/guardian is submitting this request.",
            "I consent to Microfit contacting me at the email above about this request.",
            "I understand this email starts a matching conversation and does not create a booking or charge."
        ])
        return sections.joined(separator: "\n")
    }
}

struct TrainerApplicationDraft {
    var name = ""
    var email = ""
    var locationAndTimeZone = ""
    var certification = ""
    var credentialReference = ""
    var yearsExperience = 1
    var formats: Set<TrainerFormat> = [.virtual]
    var specialties: Set<TrainerSpecialty> = [.beginnerFitness]
    var startingRate = ""
    var website = ""
    var biography = ""
    var confirmsAdult = false
    var confirmsAccuracy = false
    var consentsToPublicListing = false

    var canPrepare: Bool {
        !name.trimmed.isEmpty
            && TrainerLeadValidation.isValidEmail(email)
            && !locationAndTimeZone.trimmed.isEmpty
            && !certification.trimmed.isEmpty
            && !formats.isEmpty
            && !specialties.isEmpty
            && biography.trimmed.count >= 40
            && confirmsAdult
            && confirmsAccuracy
            && consentsToPublicListing
    }

    var emailBody: String {
        [
            "MICROFIT TRAINER APPLICATION",
            "",
            "Name: \(name.trimmed)",
            "Business email: \(email.trimmed)",
            "Location / time zone: \(locationAndTimeZone.trimmed)",
            "Certification: \(certification.trimmed)",
            "Credential reference or verification URL: \(credentialReference.trimmed.isEmpty ? "Not provided" : credentialReference.trimmed)",
            "Experience: \(yearsExperience) \(yearsExperience == 1 ? "year" : "years")",
            "Training formats: \(formats.map(\.title).sorted().joined(separator: ", "))",
            "Specialties: \(specialties.map(\.title).sorted().joined(separator: ", "))",
            "Starting rate: \(startingRate.trimmed.isEmpty ? "Discuss during review" : startingRate.trimmed)",
            "Website / professional profile: \(website.trimmed.isEmpty ? "Not provided" : website.trimmed)",
            "",
            "BIOGRAPHY",
            biography.trimmed,
            "",
            "ATTESTATIONS",
            "I confirm I am 18 years of age or older.",
            "I confirm the information above is accurate and that Microfit may request evidence before approval.",
            "If accepted, I consent to Microfit publishing the approved profile fields and contact/booking link we agree on.",
            "I understand applications are reviewed by a person and are not published automatically."
        ].joined(separator: "\n")
    }
}

enum TrainerLeadValidation {
    static func isValidEmail(_ value: String) -> Bool {
        let cleaned = value.trimmed
        guard !cleaned.contains(" "), cleaned.count <= 254 else { return false }
        let parts = cleaned.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2, !parts[0].isEmpty else { return false }
        let domain = String(parts[1])
        return domain.contains(".") && !domain.hasPrefix(".") && !domain.hasSuffix(".")
    }
}

struct MicrofitMailDraft: Sendable {
    let recipient: String
    let subject: String
    let body: String

    var url: URL? {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = recipient
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body)
        ]
        return components.url
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
