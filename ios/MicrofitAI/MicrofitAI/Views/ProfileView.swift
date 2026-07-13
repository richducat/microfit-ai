import SwiftUI

struct ProfileView: View {
    @Environment(MicrofitAppState.self) private var state
    @State private var showProfileEditor = false
    @State private var showPrivacy = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                profileHero
                preferences
                trainerNetwork
                reminders
                privacy
                about
                destructiveActions
            }
            .padding(20)
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .sheet(isPresented: $showProfileEditor) {
            ProfileEditorView(profile: state.profile) { state.updateProfile($0) }
        }
        .sheet(isPresented: $showPrivacy) {
            PrivacyDetailsView()
        }
        .alert("Delete all Microfit data?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete All Data", role: .destructive) {
                Task { await state.deleteAllData() }
            }
        } message: {
            Text("This permanently removes your local profile, check-ins, nutrition, habits, workouts, coach history, and reminders. There is no cloud copy to restore.")
        }
    }

    private var profileHero: some View {
        PremiumCard(padding: 22) {
            VStack(alignment: .leading, spacing: 17) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle().fill(MicrofitTheme.accentGradient).frame(width: 70, height: 70)
                        Text(String(state.profile.displayName.prefix(1)).uppercased())
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(MicrofitTheme.background)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(state.profile.displayName)
                            .font(.title2.weight(.black))
                            .foregroundStyle(.white)
                        Text(state.profile.goal.title)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(MicrofitTheme.aqua)
                        Text("Level \(state.level) • \(state.xp) XP")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(MicrofitTheme.muted)
                    }
                    Spacer()
                    Button {
                        showProfileEditor = true
                    } label: {
                        Image(systemName: "pencil")
                            .font(.headline.weight(.black))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(MicrofitTheme.elevated, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Edit profile")
                }

                ProgressView(value: state.levelProgress)
                    .tint(MicrofitTheme.lime)
                    .scaleEffect(y: 1.5)
            }
        }
    }

    private var preferences: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Training setup", icon: "slider.horizontal.3")
            PremiumCard {
                VStack(spacing: 13) {
                    settingRow(icon: state.profile.goal.icon, title: "Primary goal", value: state.profile.goal.title, tint: MicrofitTheme.lime)
                    Divider().overlay(MicrofitTheme.border)
                    settingRow(icon: "speedometer", title: "Experience", value: state.profile.experience.title, tint: MicrofitTheme.aqua)
                    Divider().overlay(MicrofitTheme.border)
                    settingRow(icon: "clock.fill", title: "Session time", value: "\(state.profile.sessionMinutes) minutes", tint: MicrofitTheme.gold)
                    Divider().overlay(MicrofitTheme.border)
                    settingRow(icon: "calendar", title: "Weekly plan", value: "\(state.profile.trainingDaysPerWeek) days", tint: MicrofitTheme.blue)
                    Divider().overlay(MicrofitTheme.border)
                    settingRow(icon: "dumbbell.fill", title: "Equipment", value: equipmentLabel, tint: MicrofitTheme.coral)
                }
            }
        }
    }

    private var reminders: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Movement reminders", icon: "bell.fill", trailing: state.remindersEnabled ? "ON" : "OFF")
            PremiumCard(padding: 18) {
                VStack(alignment: .leading, spacing: 15) {
                    Toggle(isOn: Binding(
                        get: { state.remindersEnabled },
                        set: { enabled in Task { await state.configureReminders(enabled: enabled) } }
                    )) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Daily Microfit nudges")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.white)
                            Text("Local notifications only. No engagement tracking.")
                                .font(.caption)
                                .foregroundStyle(MicrofitTheme.muted)
                        }
                    }
                    .tint(MicrofitTheme.lime)

                    if state.remindersEnabled {
                        Divider().overlay(MicrofitTheme.border)
                        HStack(spacing: 8) {
                            ForEach(state.reminderHours, id: \.self) { hour in
                                Text(hourLabel(hour))
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(MicrofitTheme.secondaryText)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 7)
                                    .background(MicrofitTheme.elevated, in: Capsule())
                            }
                        }
                        Text("Default reminder times can be disabled at any time. Notification delivery is controlled by iOS Settings.")
                            .font(.caption)
                            .foregroundStyle(MicrofitTheme.muted)
                    }
                }
            }
        }
    }

    private var trainerNetwork: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Trainer network", icon: "person.2.fill", trailing: "NEW")
            PremiumCard(padding: 18) {
                VStack(alignment: .leading, spacing: 13) {
                    Text("Get one-to-one help—or bring your coaching business to microfit.AI.")
                        .font(.subheadline)
                        .foregroundStyle(MicrofitTheme.secondaryText)
                    HStack(spacing: 10) {
                        Button {
                            state.coachSection = .humanTrainers
                            state.selectedTab = .coach
                        } label: {
                            Label("Find trainer", systemImage: "magnifyingglass")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        Button {
                            state.coachSection = .humanTrainers
                            state.selectedTab = .coach
                        } label: {
                            Label("Apply", systemImage: "person.badge.plus")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                    }
                    .font(.subheadline.weight(.bold))
                    .buttonStyle(.bordered)
                    .tint(MicrofitTheme.aqua)
                    Text("Applications and match requests open as drafts for you to review and send. Microfit does not upload local fitness history automatically.")
                        .font(.caption)
                        .foregroundStyle(MicrofitTheme.muted)
                }
            }
        }
    }

    private var privacy: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Privacy & data", icon: "lock.shield.fill", trailing: "LOCAL FIRST")
            Button {
                showPrivacy = true
            } label: {
                PremiumCard(padding: 18, interactive: true) {
                    HStack(spacing: 14) {
                        Image(systemName: "iphone.gen3")
                            .font(.title2.weight(.black))
                            .foregroundStyle(MicrofitTheme.lime)
                            .frame(width: 48, height: 48)
                            .background(MicrofitTheme.lime.opacity(0.10), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Your data stays on this device")
                                .font(.headline.weight(.black))
                                .foregroundStyle(.white)
                            Text("See exactly what Microfit stores and how coaching works.")
                                .font(.caption)
                                .foregroundStyle(MicrofitTheme.muted)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(MicrofitTheme.muted)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var about: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "About", icon: "info.circle.fill")
            PremiumCard {
                VStack(spacing: 13) {
                    settingRow(icon: "app.fill", title: "App", value: "microfit.AI", tint: MicrofitTheme.lime)
                    Divider().overlay(MicrofitTheme.border)
                    settingRow(icon: "number", title: "Version", value: versionLabel, tint: MicrofitTheme.aqua)
                    Divider().overlay(MicrofitTheme.border)
                    settingRow(icon: "cpu.fill", title: "Coach", value: state.coachModeLabel, tint: MicrofitTheme.gold)
                }
            }
        }
    }

    private var destructiveActions: some View {
        Button(role: .destructive) {
            showDeleteConfirmation = true
        } label: {
            Label("Delete All My Data", systemImage: "trash.fill")
                .font(.headline.weight(.black))
                .foregroundStyle(MicrofitTheme.coral)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(MicrofitTheme.coral.opacity(0.08), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(MicrofitTheme.coral.opacity(0.30), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func settingRow(icon: String, title: String, value: String, tint: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.headline.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 38, height: 38)
                .background(tint.opacity(0.10), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
            Text(title).font(.subheadline.weight(.bold)).foregroundStyle(.white)
            Spacer(minLength: 8)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MicrofitTheme.muted)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
        }
        .accessibilityElement(children: .combine)
    }

    private var equipmentLabel: String {
        state.profile.equipment.map(\.title).sorted().joined(separator: ", ")
    }

    private var versionLabel: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
        return "\(version) (\(build))"
    }

    private func hourLabel(_ hour: Int) -> String {
        let date = Calendar.current.date(from: DateComponents(hour: hour)) ?? Date()
        return date.formatted(date: .omitted, time: .shortened)
    }
}

private struct ProfileEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: MicrofitProfile
    let onSave: (MicrofitProfile) -> Void

    init(profile: MicrofitProfile, onSave: @escaping (MicrofitProfile) -> Void) {
        _draft = State(initialValue: profile)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("You") {
                    TextField("First name", text: $draft.name)
                    Picker("Primary goal", selection: $draft.goal) {
                        ForEach(FitnessGoal.allCases) { Text($0.title).tag($0) }
                    }
                    Picker("Experience", selection: $draft.experience) {
                        ForEach(ExperienceLevel.allCases) { Text($0.title).tag($0) }
                    }
                }

                Section("Plan") {
                    Stepper("\(draft.sessionMinutes) minute sessions", value: $draft.sessionMinutes, in: 10...60, step: 5)
                    Stepper("\(draft.trainingDaysPerWeek) training days", value: $draft.trainingDaysPerWeek, in: 2...6)
                }

                Section("Equipment") {
                    ForEach(EquipmentOption.allCases) { option in
                        let selected = draft.equipment.contains(option)
                        Button {
                            if selected, draft.equipment.count > 1 { draft.equipment.remove(option) }
                            else { draft.equipment.insert(option) }
                        } label: {
                            HStack {
                                Label(option.title, systemImage: option.icon)
                                Spacer()
                                if selected { Image(systemName: "checkmark").foregroundStyle(MicrofitTheme.lime) }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(draft)
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.large])
    }
}

private struct PrivacyDetailsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    privacySection(
                        title: "Stored on your device",
                        icon: "iphone.gen3",
                        text: "Your profile choices, daily readiness check-ins, nutrition totals, habits, workout logs, coach messages, and reminder preferences are stored locally in the app’s private container."
                    )
                    privacySection(
                        title: "No Microfit account",
                        icon: "person.crop.circle.badge.xmark",
                        text: "Microfit does not create an account or upload your fitness history. Contact details typed into a trainer request or application remain in that draft until you choose to send it through another app."
                    )
                    privacySection(
                        title: "Human trainer handoff",
                        icon: "person.2.fill",
                        text: "The trainer screen downloads a public curated directory without attaching your fitness data or a Microfit identifier. Match requests and applications are not sent automatically: Microfit shows a prepared message, and you must choose an app, review it, and send it. Sharing a basic training-preference summary is optional and off by default."
                    )
                    privacySection(
                        title: "Private coaching",
                        icon: "apple.intelligence",
                        text: "On eligible devices, Apple’s on-device Foundation Models framework can generate coaching responses. When it is unavailable, Microfit uses local context-aware guidance. The app does not send coach prompts to a Microfit server or third-party AI API."
                    )
                    privacySection(
                        title: "Notifications",
                        icon: "bell.fill",
                        text: "If you opt in, iOS schedules movement reminders locally. Microfit does not track whether you open or act on a reminder."
                    )
                    privacySection(
                        title: "Delete anytime",
                        icon: "trash.fill",
                        text: "Use Delete All My Data in Settings to remove all local Microfit records and pending reminders. Deleting the app also removes its local data."
                    )
                    PremiumCard(padding: 18) {
                        VStack(spacing: 12) {
                            Link(destination: URL(string: "https://richducat.github.io/microfit-ai/privacy/")!) {
                                Label("Read the full privacy policy", systemImage: "doc.text.fill")
                                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                            }
                            Divider().overlay(MicrofitTheme.border)
                            Link(destination: URL(string: "https://richducat.github.io/microfit-ai/support/")!) {
                                Label("Open microfit.AI support", systemImage: "lifepreserver.fill")
                                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                            }
                        }
                        .font(.headline.weight(.bold))
                        .foregroundStyle(MicrofitTheme.aqua)
                    }
                    Text("Microfit provides general fitness and wellness guidance. It does not diagnose conditions or replace qualified medical, physical therapy, or nutrition care.")
                        .font(.caption)
                        .foregroundStyle(MicrofitTheme.muted)
                }
                .padding(20)
            }
            .background(MicrofitTheme.background)
            .navigationTitle("Privacy")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
    }

    private func privacySection(title: String, icon: String, text: String) -> some View {
        PremiumCard(padding: 18) {
            VStack(alignment: .leading, spacing: 10) {
                Label(title, systemImage: icon)
                    .font(.headline.weight(.black))
                    .foregroundStyle(MicrofitTheme.lime)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(MicrofitTheme.secondaryText)
            }
        }
    }
}
