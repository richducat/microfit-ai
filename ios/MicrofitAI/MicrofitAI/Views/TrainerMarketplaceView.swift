import SwiftUI

struct TrainerMarketplaceView: View {
    @Environment(MicrofitAppState.self) private var state
    @State private var trainers: [TrainerProfile] = []
    @State private var query = ""
    @State private var selectedFormat: TrainerFormat?
    @State private var selectedTrainer: TrainerProfile?
    @State private var isLoading = true
    @State private var loadError: String?
    @State private var showMatchRequest = false
    @State private var showApplication = false

    private var filteredTrainers: [TrainerProfile] {
        trainers
            .filter { $0.acceptsNewClients && $0.matches(query: query, format: selectedFormat) }
            .sorted {
                if $0.featured != $1.featured { return $0.featured }
                return $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
            }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                hero
                paths
                directory
                safetyNote
            }
            .padding(20)
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .refreshable { await loadDirectory() }
        .task { await loadDirectory() }
        .sheet(isPresented: $showMatchRequest) {
            TrainerMatchRequestView(preferredTrainer: nil)
        }
        .sheet(isPresented: $showApplication) {
            TrainerApplicationView()
        }
        .sheet(item: $selectedTrainer) { trainer in
            TrainerProfileDetailView(trainer: trainer)
        }
    }

    private var hero: some View {
        PremiumCard(padding: 22) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("HUMAN COACHING")
                            .font(MicrofitTheme.eyebrow())
                            .tracking(1.8)
                            .foregroundStyle(MicrofitTheme.lime)
                        Text("Find the right trainer, not just the closest one.")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 4)
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 42, weight: .black))
                        .foregroundStyle(MicrofitTheme.aqua)
                        .accessibilityHidden(true)
                }
                Text("Tell us your goal, schedule, format, and budget. Microfit will route your request to an owner-reviewed trainer—or help with a manual match while the network grows.")
                    .font(.subheadline)
                    .foregroundStyle(MicrofitTheme.secondaryText)
                MicrofitButton(title: "Request a Trainer Match", icon: "arrow.right", tint: MicrofitTheme.lime) {
                    showMatchRequest = true
                }
            }
        }
    }

    private var paths: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 245), spacing: 12)], spacing: 12) {
            pathCard(
                eyebrow: "FOR ATHLETES",
                title: "Hire a trainer",
                detail: "Start a one-to-one consultation request. Nothing is booked or charged until you agree directly with a trainer.",
                icon: "figure.strengthtraining.traditional",
                tint: MicrofitTheme.aqua,
                buttonTitle: "Start Request"
            ) {
                showMatchRequest = true
            }

            pathCard(
                eyebrow: "FOR PROFESSIONALS",
                title: "Become a trainer",
                detail: "Apply to join the curated directory. Credentials and listing details are reviewed before anything becomes public.",
                icon: "person.crop.circle.badge.checkmark",
                tint: MicrofitTheme.gold,
                buttonTitle: "Apply to Join"
            ) {
                showApplication = true
            }
        }
    }

    private func pathCard(
        eyebrow: String,
        title: String,
        detail: String,
        icon: String,
        tint: Color,
        buttonTitle: String,
        action: @escaping () -> Void
    ) -> some View {
        PremiumCard(padding: 18) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.title2.weight(.black))
                    .foregroundStyle(tint)
                    .frame(width: 48, height: 48)
                    .background(tint.opacity(0.11), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                Text(eyebrow)
                    .font(MicrofitTheme.eyebrow(tint))
                    .tracking(1.2)
                    .foregroundStyle(tint)
                Text(title)
                    .font(.title3.weight(.black))
                    .foregroundStyle(.white)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(MicrofitTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                Button(action: action) {
                    HStack {
                        Text(buttonTitle).font(.subheadline.weight(.black))
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                    .foregroundStyle(tint)
                    .frame(minHeight: 44)
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var directory: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Trainer directory", icon: "person.3.fill", trailing: directoryCountLabel)

            if !trainers.isEmpty {
                filters
            }

            if isLoading && trainers.isEmpty {
                PremiumCard {
                    HStack(spacing: 12) {
                        ProgressView().tint(MicrofitTheme.lime)
                        Text("Checking for available trainers…")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(MicrofitTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity, minHeight: 64)
                }
            } else if trainers.isEmpty {
                foundingNetworkState
            } else if filteredTrainers.isEmpty {
                EmptyMicrofitState(
                    title: "No exact match yet",
                    detail: "Clear a filter or send a match request. We can look beyond the published directory.",
                    icon: "magnifyingglass"
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(filteredTrainers) { trainer in
                        trainerCard(trainer)
                    }
                }
            }

            if let loadError, !trainers.isEmpty {
                Label(loadError, systemImage: "wifi.exclamationmark")
                    .font(.caption)
                    .foregroundStyle(MicrofitTheme.gold)
            }
        }
    }

    private var filters: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(MicrofitTheme.muted)
                TextField("Search specialty, location, or name", text: $query)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 13)
            .frame(minHeight: 48)
            .background(MicrofitTheme.elevated, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(MicrofitTheme.border, lineWidth: 1))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterButton(title: "All formats", icon: "person.2.fill", format: nil)
                    ForEach(TrainerFormat.allCases) { format in
                        filterButton(title: format.title, icon: format.icon, format: format)
                    }
                }
            }
        }
    }

    private func filterButton(title: String, icon: String, format: TrainerFormat?) -> some View {
        let selected = selectedFormat == format
        return Button {
            withAnimation(.snappy) { selectedFormat = format }
        } label: {
            Label(title, systemImage: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(selected ? MicrofitTheme.background : MicrofitTheme.secondaryText)
                .padding(.horizontal, 12)
                .frame(minHeight: 40)
                .background(selected ? MicrofitTheme.lime : MicrofitTheme.elevated, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private var foundingNetworkState: some View {
        PremiumCard(padding: 20) {
            VStack(alignment: .leading, spacing: 13) {
                Label("Founding trainer network", systemImage: "sparkles")
                    .font(.title3.weight(.black))
                    .foregroundStyle(MicrofitTheme.lime)
                Text("Published profiles are empty until real trainers apply and their credentials are reviewed. You can still request a manual match today.")
                    .font(.subheadline)
                    .foregroundStyle(MicrofitTheme.secondaryText)
                if let loadError {
                    Label(loadError, systemImage: "wifi.exclamationmark")
                        .font(.caption)
                        .foregroundStyle(MicrofitTheme.gold)
                }
                HStack(spacing: 10) {
                    Button("Request match") { showMatchRequest = true }
                    Button("Apply as trainer") { showApplication = true }
                }
                .font(.subheadline.weight(.bold))
                .buttonStyle(.bordered)
                .tint(MicrofitTheme.aqua)
            }
        }
    }

    private func trainerCard(_ trainer: TrainerProfile) -> some View {
        Button {
            selectedTrainer = trainer
        } label: {
            PremiumCard(padding: 18, interactive: true) {
                VStack(alignment: .leading, spacing: 13) {
                    HStack(alignment: .top, spacing: 13) {
                        Text(trainer.initials)
                            .font(.title3.weight(.black))
                            .foregroundStyle(MicrofitTheme.background)
                            .frame(width: 54, height: 54)
                            .background(MicrofitTheme.accentGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        VStack(alignment: .leading, spacing: 3) {
                            Text(trainer.displayName)
                                .font(.headline.weight(.black))
                                .foregroundStyle(.white)
                            Text(trainer.headline)
                                .font(.caption)
                                .foregroundStyle(MicrofitTheme.secondaryText)
                                .multilineTextAlignment(.leading)
                            if trainer.hasReviewedCredentials {
                                Label("Credentials reviewed", systemImage: "checkmark.seal.fill")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(MicrofitTheme.lime)
                            }
                        }
                        Spacer(minLength: 6)
                        Image(systemName: "chevron.right")
                            .foregroundStyle(MicrofitTheme.muted)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 7) {
                            ForEach(trainer.specialties.prefix(4)) { specialty in
                                Text(specialty.title)
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(MicrofitTheme.aqua)
                                    .padding(.horizontal, 9)
                                    .padding(.vertical, 6)
                                    .background(MicrofitTheme.aqua.opacity(0.09), in: Capsule())
                            }
                        }
                    }

                    HStack {
                        Label(trainer.formatLabel, systemImage: "video.fill")
                        Spacer()
                        Text(trainer.rateLabel)
                    }
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MicrofitTheme.muted)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(trainer.displayName), \(trainer.headline), \(trainer.rateLabel)")
        .accessibilityHint("Open trainer profile")
    }

    private var safetyNote: some View {
        Label(
            "Microfit reviews submitted credentials before publishing a profile, but does not provide medical referrals or guarantee outcomes. Confirm fit, scope, pricing, and cancellation terms directly with the trainer.",
            systemImage: "shield.checkered"
        )
        .font(.caption)
        .foregroundStyle(MicrofitTheme.muted)
        .padding(.horizontal, 4)
    }

    private var directoryCountLabel: String {
        if isLoading && trainers.isEmpty { return "UPDATING" }
        return "\(filteredTrainers.count) AVAILABLE"
    }

    @MainActor
    private func loadDirectory() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let document = try await TrainerDirectoryLoader.load()
            trainers = document.trainers
            loadError = nil
        } catch {
            loadError = "Live listings could not refresh. Match requests are still available."
        }
    }
}

private struct TrainerProfileDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(MicrofitAppState.self) private var state
    @State private var showRequest = false

    let trainer: TrainerProfile

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    profileHero
                    detailSection(title: "About", icon: "person.text.rectangle.fill") {
                        Text(trainer.biography)
                    }
                    detailSection(title: "Credentials", icon: "checkmark.seal.fill") {
                        ForEach(trainer.credentials, id: \.self) { credential in
                            Label(credential, systemImage: "checkmark.circle.fill")
                        }
                    }
                    detailSection(title: "Specialties", icon: "scope") {
                        ForEach(trainer.specialties) { specialty in
                            Label(specialty.title, systemImage: specialty.icon)
                        }
                    }
                    detailSection(title: "Working together", icon: "calendar.badge.clock") {
                        Label(trainer.formatLabel, systemImage: "video.fill")
                        Label(trainer.serviceArea, systemImage: "mappin.and.ellipse")
                        Label(trainer.timeZone, systemImage: "clock.fill")
                        Label(trainer.languages.joined(separator: ", "), systemImage: "character.bubble.fill")
                        Label(trainer.rateLabel, systemImage: "dollarsign.circle.fill")
                    }

                    MicrofitButton(title: "Request a Consultation", icon: "arrow.right", tint: MicrofitTheme.lime) {
                        showRequest = true
                    }

                    if let bookingLink = trainer.bookingLink {
                        Button {
                            openURL(bookingLink)
                        } label: {
                            Label("Open trainer booking page", systemImage: "safari.fill")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(MicrofitTheme.aqua)
                                .frame(maxWidth: .infinity, minHeight: 48)
                        }
                        .buttonStyle(.bordered)
                        .tint(MicrofitTheme.elevated)
                    }

                    Button {
                        reportListing()
                    } label: {
                        Label("Report this listing", systemImage: "flag.fill")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(MicrofitTheme.coral)
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(.plain)

                    Text("A reviewed credential means Microfit checked the submitted credential reference before publication. It is not a background check, medical referral, or guarantee of service quality.")
                        .font(.caption)
                        .foregroundStyle(MicrofitTheme.muted)
                }
                .padding(20)
                .frame(maxWidth: 700)
                .frame(maxWidth: .infinity)
            }
            .background(MicrofitTheme.background)
            .navigationTitle("Trainer Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showRequest) {
            TrainerMatchRequestView(preferredTrainer: trainer)
        }
    }

    private var profileHero: some View {
        PremiumCard(padding: 22) {
            VStack(alignment: .leading, spacing: 13) {
                HStack(spacing: 14) {
                    Text(trainer.initials)
                        .font(.title.weight(.black))
                        .foregroundStyle(MicrofitTheme.background)
                        .frame(width: 72, height: 72)
                        .background(MicrofitTheme.accentGradient, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(trainer.displayName)
                            .font(.title2.weight(.black))
                            .foregroundStyle(.white)
                        Text(trainer.headline)
                            .font(.subheadline)
                            .foregroundStyle(MicrofitTheme.secondaryText)
                        Label(
                            trainer.acceptsNewClients ? "Accepting new clients" : "Waitlist",
                            systemImage: trainer.acceptsNewClients ? "checkmark.circle.fill" : "clock.fill"
                        )
                        .font(.caption.weight(.bold))
                        .foregroundStyle(trainer.acceptsNewClients ? MicrofitTheme.lime : MicrofitTheme.gold)
                    }
                }
                if trainer.hasReviewedCredentials {
                    Label("Credentials reviewed before publication", systemImage: "checkmark.seal.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(MicrofitTheme.lime)
                }
            }
        }
    }

    private func detailSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        PremiumCard(padding: 18) {
            VStack(alignment: .leading, spacing: 11) {
                Label(title, systemImage: icon)
                    .font(.headline.weight(.black))
                    .foregroundStyle(MicrofitTheme.lime)
                content()
                    .font(.subheadline)
                    .foregroundStyle(MicrofitTheme.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func reportListing() {
        let draft = MicrofitMailDraft(
            recipient: "richducat@gmail.com",
            subject: "microfit.AI trainer listing report: \(trainer.id)",
            body: "Trainer: \(trainer.displayName)\nListing ID: \(trainer.id)\n\nWhat should we review?\n"
        )
        guard let url = draft.url else { return }
        openURL(url) { accepted in
            if accepted {
                state.successMessage = "Report email opened. Send it so the listing can be reviewed."
            } else {
                state.errorMessage = "No mail app could open the report. Email richducat@gmail.com with listing ID \(trainer.id)."
            }
        }
    }
}

struct TrainerMatchRequestView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(MicrofitAppState.self) private var state
    @State private var draft: TrainerMatchRequestDraft

    let preferredTrainer: TrainerProfile?

    init(preferredTrainer: TrainerProfile?) {
        self.preferredTrainer = preferredTrainer
        _draft = State(initialValue: TrainerMatchRequestDraft())
    }

    var body: some View {
        NavigationStack {
            Form {
                if let preferredTrainer {
                    Section("Preferred trainer") {
                        Label(preferredTrainer.displayName, systemImage: "person.crop.circle.badge.checkmark")
                        Text("If this trainer is unavailable, Microfit can suggest another fit.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("How to reach you") {
                    TextField("Name", text: $draft.name)
                        .textContentType(.name)
                    TextField("Email", text: $draft.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    if !draft.email.isEmpty && !TrainerLeadValidation.isValidEmail(draft.email) {
                        Label("Enter a valid email address.", systemImage: "exclamationmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                Section("Your match") {
                    Picker("Primary goal", selection: $draft.goal) {
                        ForEach(FitnessGoal.allCases) { goal in
                            Text(goal.title).tag(goal)
                        }
                    }
                    Picker("Format", selection: $draft.format) {
                        ForEach(TrainerFormat.allCases) { format in
                            Text(format.title).tag(format)
                        }
                    }
                    Picker("Budget", selection: $draft.budget) {
                        ForEach(TrainerBudget.allCases) { budget in
                            Text(budget.title).tag(budget)
                        }
                    }
                    TextField("Availability and time zone", text: $draft.availability, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("What would make this work?") {
                    TextEditor(text: $draft.notes)
                        .frame(minHeight: 100)
                    Text("Avoid including medical records or sensitive health details. Discuss appropriate scope directly with the trainer.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Optional Microfit summary") {
                    Toggle("Include my basic training preferences", isOn: $draft.shareProfileSummary)
                    Text(draft.shareProfileSummary ? sharedSummary : "Off by default. Your Microfit profile, check-ins, history, nutrition, and coach messages stay on this device.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Consent") {
                    Toggle("I am 18 or older, or a parent/guardian is submitting this request", isOn: $draft.confirmsAdultOrGuardian)
                    Toggle("Microfit may contact me about this request", isOn: $draft.consentsToContact)
                }

                Section("Send request") {
                    Button {
                        prepareEmail()
                    } label: {
                        Label("Open Email Request", systemImage: "envelope.fill")
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .disabled(!draft.canPrepare)

                    ShareLink(
                        item: requestBody,
                        subject: Text(requestSubject)
                    ) {
                        Label("Share Request Another Way", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .disabled(!draft.canPrepare)

                    Text("Microfit prepares a draft in an app you choose. You must review and send it to complete the request. No booking or payment happens here.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Hire a Trainer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var requestSubject: String {
        if let preferredTrainer {
            return "microfit.AI consultation request for \(preferredTrainer.displayName)"
        }
        return "microfit.AI trainer match request"
    }

    private var requestBody: String {
        draft.emailBody(profile: state.profile, preferredTrainer: preferredTrainer)
    }

    private var sharedSummary: String {
        "Shares only: \(state.profile.goal.title), \(state.profile.experience.title), \(state.profile.sessionMinutes)-minute sessions, \(state.profile.trainingDaysPerWeek) days per week, and selected equipment."
    }

    private func prepareEmail() {
        let mail = MicrofitMailDraft(
            recipient: "richducat@gmail.com",
            subject: requestSubject,
            body: requestBody
        )
        guard let url = mail.url else {
            state.errorMessage = "Microfit couldn’t prepare the request. Use the share option instead."
            return
        }
        openURL(url) { accepted in
            if accepted {
                state.successMessage = "Email draft opened. Review and send it to complete your trainer request."
                dismiss()
            } else {
                state.errorMessage = "No mail app accepted the request. Use Share Request Another Way."
            }
        }
    }
}

struct TrainerApplicationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(MicrofitAppState.self) private var state
    @State private var draft = TrainerApplicationDraft()

    var body: some View {
        NavigationStack {
            Form {
                Section("Professional contact") {
                    TextField("Full name", text: $draft.name)
                        .textContentType(.name)
                    TextField("Business email", text: $draft.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("Location and time zone", text: $draft.locationAndTimeZone)
                    TextField("Website or professional profile (optional)", text: $draft.website)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section("Credentials") {
                    TextField("Certification and issuing organization", text: $draft.certification, axis: .vertical)
                        .lineLimit(2...4)
                    TextField("Credential ID or verification URL (optional)", text: $draft.credentialReference)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Stepper("\(draft.yearsExperience) \(draft.yearsExperience == 1 ? "year" : "years") experience", value: $draft.yearsExperience, in: 0...50)
                    Text("Applications are reviewed by a person. A credential reference may be requested before publication.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("How you train") {
                    ForEach(TrainerFormat.allCases) { format in
                        Toggle(format.title, isOn: setBinding(format, in: $draft.formats))
                    }
                    TextField("Starting rate (optional)", text: $draft.startingRate)
                        .keyboardType(.numbersAndPunctuation)
                }

                Section("Specialties") {
                    ForEach(TrainerSpecialty.allCases) { specialty in
                        Toggle(specialty.title, isOn: setBinding(specialty, in: $draft.specialties))
                    }
                }

                Section("Public profile biography") {
                    TextEditor(text: $draft.biography)
                        .frame(minHeight: 120)
                    Text("\(draft.biography.trimmingCharacters(in: .whitespacesAndNewlines).count)/40 minimum characters")
                        .font(.caption)
                        .foregroundStyle(
                            draft.biography.trimmingCharacters(in: .whitespacesAndNewlines).count >= 40
                                ? MicrofitTheme.muted
                                : MicrofitTheme.coral
                        )
                }

                Section("Review and consent") {
                    Toggle("I am 18 years of age or older", isOn: $draft.confirmsAdult)
                    Toggle("I confirm this information is accurate", isOn: $draft.confirmsAccuracy)
                    Toggle("If accepted, I consent to publishing the approved profile and contact/booking fields we agree on", isOn: $draft.consentsToPublicListing)
                    Text("Applying does not publish a profile automatically. Microfit will contact you before an approved listing goes live, and you can request removal at any time.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Apply") {
                    Button {
                        prepareEmail()
                    } label: {
                        Label("Open Email Application", systemImage: "envelope.fill")
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .disabled(!draft.canPrepare)

                    ShareLink(
                        item: draft.emailBody,
                        subject: Text(applicationSubject)
                    ) {
                        Label("Share Application Another Way", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .disabled(!draft.canPrepare)

                    Text("Microfit opens a draft; you must review and send it to apply. Do not include government IDs, payment information, or sensitive client data.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Become a Trainer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var applicationSubject: String {
        "microfit.AI trainer application — \(draft.name.trimmingCharacters(in: .whitespacesAndNewlines))"
    }

    private func prepareEmail() {
        let mail = MicrofitMailDraft(
            recipient: "richducat@gmail.com",
            subject: applicationSubject,
            body: draft.emailBody
        )
        guard let url = mail.url else {
            state.errorMessage = "Microfit couldn’t prepare the application. Use the share option instead."
            return
        }
        openURL(url) { accepted in
            if accepted {
                state.successMessage = "Application email opened. Review and send it to apply."
                dismiss()
            } else {
                state.errorMessage = "No mail app accepted the application. Use Share Application Another Way."
            }
        }
    }

    private func setBinding<Element: Hashable>(_ element: Element, in set: Binding<Set<Element>>) -> Binding<Bool> {
        Binding(
            get: { set.wrappedValue.contains(element) },
            set: { isOn in
                var updated = set.wrappedValue
                if isOn {
                    updated.insert(element)
                } else {
                    updated.remove(element)
                }
                set.wrappedValue = updated
            }
        )
    }
}
