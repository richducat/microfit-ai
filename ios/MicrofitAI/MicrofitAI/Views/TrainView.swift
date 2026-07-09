import SwiftUI

struct TrainView: View {
    @Environment(MicrofitAppState.self) private var state
    @State private var selectedPlan: WorkoutPlan?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                header
                adaptivePlan
                planLibrary
                programmingNote
            }
            .padding(20)
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .fullScreenCover(item: $selectedPlan) { plan in
            WorkoutPlayerView(plan: plan)
                .environment(state)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("YOUR PLAN")
                .font(MicrofitTheme.eyebrow())
                .tracking(1.8)
                .foregroundStyle(MicrofitTheme.lime)
            Text("Train for today—not an imaginary perfect week.")
                .font(.system(size: 31, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
            Text("Every session includes substitutions, form cues, set tracking, rest timing, and an honest effort score.")
                .font(.subheadline)
                .foregroundStyle(MicrofitTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var adaptivePlan: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Best match", icon: "sparkles", trailing: "READINESS \(state.todayCheckIn.readinessScore)")
            planCard(state.todayPlan, emphasized: true)
        }
    }

    private var planLibrary: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Workout library", icon: "square.grid.2x2.fill", trailing: "\(MicrofitSeedData.planLibrary.count) PLANS")
            ForEach(MicrofitSeedData.planLibrary.filter { $0.id != state.todayPlan.id }) { plan in
                planCard(plan, emphasized: false)
            }
        }
    }

    private func planCard(_ plan: WorkoutPlan, emphasized: Bool) -> some View {
        Button {
            selectedPlan = plan
        } label: {
            PremiumCard(padding: 18, interactive: true) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .top, spacing: 14) {
                        Image(systemName: plan.icon)
                            .font(.title2.weight(.black))
                            .foregroundStyle(MicrofitTheme.background)
                            .frame(width: 50, height: 50)
                            .background(emphasized ? AnyShapeStyle(MicrofitTheme.accentGradient) : AnyShapeStyle(MicrofitTheme.aqua), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                        VStack(alignment: .leading, spacing: 3) {
                            Text(plan.title)
                                .font(.title3.weight(.black))
                                .foregroundStyle(.white)
                            Text(plan.focus.uppercased())
                                .font(MicrofitTheme.eyebrow(MicrofitTheme.aqua))
                                .tracking(1.1)
                                .foregroundStyle(MicrofitTheme.aqua)
                        }
                        Spacer(minLength: 8)
                        Image(systemName: "arrow.up.right")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(MicrofitTheme.muted)
                    }

                    Text(plan.summary)
                        .font(.subheadline)
                        .foregroundStyle(MicrofitTheme.secondaryText)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 14) {
                        Label("\(plan.durationMinutes) min", systemImage: "clock.fill")
                        Label("\(plan.exercises.count) moves", systemImage: "list.bullet")
                        Label(plan.difficulty.title, systemImage: "speedometer")
                    }
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MicrofitTheme.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)

                    HStack(spacing: 7) {
                        ForEach(plan.exercises.prefix(4)) { item in
                            Image(systemName: exerciseIcon(for: item.exercise.category))
                                .font(.caption.weight(.bold))
                                .foregroundStyle(emphasized ? MicrofitTheme.lime : MicrofitTheme.aqua)
                                .frame(width: 30, height: 30)
                                .background(MicrofitTheme.elevated, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                                .accessibilityLabel(item.exercise.name)
                        }
                        Spacer()
                        Text("START")
                            .font(MicrofitTheme.eyebrow(emphasized ? MicrofitTheme.lime : MicrofitTheme.aqua))
                            .tracking(1.1)
                            .foregroundStyle(emphasized ? MicrofitTheme.lime : MicrofitTheme.aqua)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(plan.title), \(plan.durationMinutes) minutes, \(plan.exercises.count) exercises")
        .accessibilityHint("Opens workout player")
    }

    private var programmingNote: some View {
        PremiumCard {
            HStack(alignment: .top, spacing: 13) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(MicrofitTheme.lime)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Adaptive, not random")
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)
                    Text("Microfit changes the recommended session when readiness is low, while keeping the plan library stable enough to measure progress.")
                        .font(.caption)
                        .foregroundStyle(MicrofitTheme.muted)
                }
            }
        }
    }

    private func exerciseIcon(for category: String) -> String {
        switch category {
        case "Lower body": "figure.strengthtraining.functional"
        case "Upper body": "dumbbell.fill"
        case "Conditioning": "flame.fill"
        case "Mobility", "Recovery": "wind"
        default: "figure.core.training"
        }
    }
}

private struct WorkoutPlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(MicrofitAppState.self) private var state
    let plan: WorkoutPlan

    @State private var setLogs: [LoggedSet]
    @State private var effort = 6.0
    @State private var startedAt = Date()
    @State private var restEndsAt: Date?
    @State private var showFinishConfirmation = false

    init(plan: WorkoutPlan) {
        self.plan = plan
        let logs = plan.exercises.flatMap { item in
            (1...item.sets).map { LoggedSet(exerciseId: item.id, setNumber: $0, reps: item.reps) }
        }
        _setLogs = State(initialValue: logs)
    }

    private var completedSets: Int { setLogs.filter(\.completed).count }
    private var totalSets: Int { setLogs.count }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                MicrofitTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        workoutHeader
                        ForEach(plan.exercises) { item in
                            exerciseCard(item)
                        }
                        effortCard
                        Color.clear.frame(height: 100)
                    }
                    .padding(18)
                    .frame(maxWidth: 760)
                    .frame(maxWidth: .infinity)
                }

                finishBar
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close", systemImage: "xmark") { dismiss() }
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .principal) {
                    Text(plan.title).font(.headline.weight(.black)).foregroundStyle(.white)
                }
            }
            .toolbarBackground(MicrofitTheme.chrome, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .alert("Finish this workout?", isPresented: $showFinishConfirmation) {
                Button("Keep Training", role: .cancel) { }
                Button("Finish") { finishWorkout() }
            } message: {
                Text("You completed \(completedSets) of \(totalSets) sets. Honest work still counts.")
            }
        }
    }

    private var workoutHeader: some View {
        PremiumCard(padding: 20) {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plan.focus.uppercased())
                            .font(MicrofitTheme.eyebrow())
                            .tracking(1.3)
                            .foregroundStyle(MicrofitTheme.lime)
                        Text("Own the next set.")
                            .font(.title2.weight(.black))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        Text(elapsedString(at: context.date))
                            .font(MicrofitTheme.metric(19))
                            .foregroundStyle(MicrofitTheme.aqua)
                            .monospacedDigit()
                    }
                }

                ProgressView(value: Double(completedSets), total: Double(max(1, totalSets)))
                    .tint(MicrofitTheme.lime)
                    .scaleEffect(y: 1.6)

                HStack {
                    Text("\(completedSets) / \(totalSets) SETS")
                        .font(MicrofitTheme.eyebrow(MicrofitTheme.muted))
                        .foregroundStyle(MicrofitTheme.muted)
                    Spacer()
                    if let restEndsAt {
                        TimelineView(.periodic(from: .now, by: 1)) { context in
                            let remaining = max(0, Int(restEndsAt.timeIntervalSince(context.date).rounded(.up)))
                            if remaining > 0 {
                                Label("REST \(remaining)s", systemImage: "timer")
                                    .font(MicrofitTheme.eyebrow(MicrofitTheme.gold))
                                    .foregroundStyle(MicrofitTheme.gold)
                                    .monospacedDigit()
                            }
                        }
                    }
                }
            }
        }
    }

    private func exerciseCard(_ item: PlannedExercise) -> some View {
        let indices = setLogs.indices.filter { setLogs[$0].exerciseId == item.id }

        return PremiumCard(padding: 18) {
            VStack(alignment: .leading, spacing: 15) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "figure.strengthtraining.functional")
                        .font(.title3.weight(.black))
                        .foregroundStyle(MicrofitTheme.aqua)
                        .frame(width: 42, height: 42)
                        .background(MicrofitTheme.aqua.opacity(0.10), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.exercise.name).font(.title3.weight(.black)).foregroundStyle(.white)
                        Text("\(item.prescription) • \(item.restSeconds)s rest")
                            .font(.caption.weight(.bold)).foregroundStyle(MicrofitTheme.muted)
                    }
                    Spacer()
                }

                Text(item.exercise.formCue)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MicrofitTheme.secondaryText)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(MicrofitTheme.elevated, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(spacing: 8) {
                    ForEach(indices, id: \.self) { index in
                        setRow(index: index, exerciseName: item.exercise.name, restSeconds: item.restSeconds)
                    }
                }

                DisclosureGroup("Form & substitutions") {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(item.exercise.instructions, id: \.self) { instruction in
                            Label(instruction, systemImage: "checkmark")
                        }
                        Divider().overlay(MicrofitTheme.border)
                        Label("Easier: \(item.exercise.easierOption)", systemImage: "arrow.down.right")
                        Label("Harder: \(item.exercise.harderOption)", systemImage: "arrow.up.right")
                    }
                    .font(.caption)
                    .foregroundStyle(MicrofitTheme.secondaryText)
                    .padding(.top, 10)
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(MicrofitTheme.aqua)
                .tint(MicrofitTheme.aqua)
            }
        }
    }

    private func setRow(index: Int, exerciseName: String, restSeconds: Int) -> some View {
        HStack(spacing: 10) {
            Button {
                setLogs[index].completed.toggle()
                if setLogs[index].completed, restSeconds > 0 {
                    restEndsAt = Date().addingTimeInterval(TimeInterval(restSeconds))
                }
            } label: {
                Image(systemName: setLogs[index].completed ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(setLogs[index].completed ? MicrofitTheme.lime : MicrofitTheme.muted)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(exerciseName), set \(setLogs[index].setNumber)")
            .accessibilityValue(setLogs[index].completed ? "Complete" : "Not complete")

            Text("SET \(setLogs[index].setNumber)")
                .font(MicrofitTheme.eyebrow(MicrofitTheme.muted))
                .foregroundStyle(MicrofitTheme.muted)
                .frame(width: 42, alignment: .leading)

            HStack(spacing: 0) {
                Button {
                    setLogs[index].reps = max(0, setLogs[index].reps - 1)
                } label: {
                    Image(systemName: "minus")
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Decrease \(exerciseName) set \(setLogs[index].setNumber) reps")

                VStack(spacing: 0) {
                    Text("\(setLogs[index].reps)")
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(.white)
                    Text("REPS")
                        .font(.system(size: 7, weight: .black, design: .rounded))
                        .foregroundStyle(MicrofitTheme.muted)
                }
                .frame(width: 40)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(exerciseName) set \(setLogs[index].setNumber), \(setLogs[index].reps) reps")

                Button {
                    setLogs[index].reps = min(100, setLogs[index].reps + 1)
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Increase \(exerciseName) set \(setLogs[index].setNumber) reps")
            }
            .font(.subheadline.weight(.black))
            .foregroundStyle(.white)
            .background(MicrofitTheme.elevated, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            HStack(spacing: 3) {
                TextField("0", value: $setLogs[index].weight, format: .number.precision(.fractionLength(0...1)))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(minWidth: 30)
                Text("LB")
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .foregroundStyle(MicrofitTheme.muted)
            }
                .frame(width: 58, height: 44)
                .padding(.horizontal, 5)
                .background(MicrofitTheme.elevated, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .accessibilityLabel("\(exerciseName) set \(setLogs[index].setNumber) weight in pounds")
        }
        .padding(.vertical, 4)
        .opacity(setLogs[index].completed ? 0.72 : 1)
    }

    private var effortCard: some View {
        PremiumCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("SESSION EFFORT")
                            .font(MicrofitTheme.eyebrow())
                            .tracking(1.2)
                            .foregroundStyle(MicrofitTheme.lime)
                        Text(effortLabel)
                            .font(.headline.weight(.black))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    Text("\(Int(effort))/10")
                        .font(MicrofitTheme.metric(20))
                        .foregroundStyle(MicrofitTheme.aqua)
                }
                Slider(value: $effort, in: 1...10, step: 1).tint(MicrofitTheme.aqua)
                Text("Use the whole scale. Most productive sessions should finish around 6–8, not 10.")
                    .font(.caption)
                    .foregroundStyle(MicrofitTheme.muted)
            }
        }
    }

    private var finishBar: some View {
        VStack(spacing: 8) {
            MicrofitButton(
                title: finishButtonTitle,
                icon: "checkmark.circle.fill",
                tint: MicrofitTheme.lime,
                isDisabled: completedSets == 0
            ) {
                showFinishConfirmation = completedSets < totalSets
                if completedSets == totalSets { finishWorkout() }
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .background(MicrofitTheme.chrome.opacity(0.97).ignoresSafeArea())
        .overlay(alignment: .top) { Rectangle().fill(MicrofitTheme.border).frame(height: 1) }
    }

    private var finishButtonTitle: String {
        if completedSets == totalSets {
            return dynamicTypeSize.isAccessibilitySize ? "Complete" : "Complete Workout"
        }
        return dynamicTypeSize.isAccessibilitySize ? "Log \(completedSets) Sets" : "Finish & Log \(completedSets) Sets"
    }

    private func finishWorkout() {
        let minutes = max(1, Int(Date().timeIntervalSince(startedAt) / 60))
        state.completeWorkout(plan: plan, sets: setLogs, durationMinutes: minutes, effort: Int(effort))
        dismiss()
    }

    private func elapsedString(at date: Date) -> String {
        let seconds = max(0, Int(date.timeIntervalSince(startedAt)))
        return String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    private var effortLabel: String {
        switch Int(effort) {
        case 1...3: "Very easy"
        case 4...5: "Comfortable"
        case 6...7: "Productive"
        case 8...9: "Hard"
        default: "Maximum"
        }
    }
}
