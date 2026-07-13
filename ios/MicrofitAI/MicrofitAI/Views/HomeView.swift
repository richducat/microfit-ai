import SwiftUI

struct HomeView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(MicrofitAppState.self) private var state

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                hero
                quickMetrics
                checkIn
                todayPlan
                habits
                recentWin
                privateCoach
            }
            .padding(20)
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
    }

    private var hero: some View {
        PremiumCard(padding: 22) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("TODAY’S SIGNAL")
                            .font(MicrofitTheme.eyebrow())
                            .tracking(1.8)
                            .foregroundStyle(MicrofitTheme.lime)
                        Text("Hey, \(state.firstName).")
                            .font(.system(size: 35, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text(heroMessage)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(MicrofitTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                    readinessRing
                }

                HStack(spacing: 12) {
                    MicrofitButton(title: dynamicTypeSize.isAccessibilitySize ? "Start Plan" : "Start Today’s Plan", icon: "play.fill", tint: MicrofitTheme.lime) {
                        state.selectedTab = .plan
                    }
                    Button {
                        state.selectedTab = .move
                    } label: {
                        Image(systemName: "timer")
                            .font(.headline.weight(.black))
                            .foregroundStyle(MicrofitTheme.aqua)
                            .frame(width: 52, height: 52)
                            .background(MicrofitTheme.aqua.opacity(0.10), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(MicrofitTheme.aqua.opacity(0.25), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Choose a micro workout")
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("LEVEL \(state.level)")
                            .font(MicrofitTheme.eyebrow(MicrofitTheme.muted))
                            .foregroundStyle(MicrofitTheme.muted)
                        Spacer()
                        Text("\(state.xpToNextLevel) XP TO NEXT")
                            .font(MicrofitTheme.eyebrow(MicrofitTheme.muted))
                            .foregroundStyle(MicrofitTheme.muted)
                    }
                    ProgressView(value: state.levelProgress)
                        .tint(MicrofitTheme.aqua)
                        .scaleEffect(y: 1.5)
                }
            }
        }
    }

    private var readinessRing: some View {
        ZStack {
            Circle().stroke(MicrofitTheme.elevated, lineWidth: 9)
            Circle()
                .trim(from: 0, to: Double(state.todayCheckIn.readinessScore) / 100)
                .stroke(MicrofitTheme.accentGradient, style: StrokeStyle(lineWidth: 9, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 0) {
                Text("\(state.todayCheckIn.readinessScore)")
                    .font(MicrofitTheme.metric(24))
                    .foregroundStyle(.white)
                Text("READY")
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .tracking(1)
                    .foregroundStyle(MicrofitTheme.muted)
            }
        }
        .frame(width: 86, height: 86)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Readiness \(state.todayCheckIn.readinessScore) out of 100, \(state.todayCheckIn.readinessLabel)")
    }

    private var quickMetrics: some View {
        LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 12) {
            PremiumCard { MetricPill(title: "This week", value: "\(state.weeklySessions) sessions", icon: "checkmark.circle.fill", tint: MicrofitTheme.lime) }
            PremiumCard { MetricPill(title: "Minutes", value: "\(state.weeklyMinutes)", icon: "clock.fill", tint: MicrofitTheme.aqua) }
            PremiumCard { MetricPill(title: "Streak", value: "\(state.currentStreak) \(state.currentStreak == 1 ? "day" : "days")", icon: "flame.fill", tint: MicrofitTheme.coral) }
            PremiumCard { MetricPill(title: "Daily habits", value: "\(state.habitCompletionCount)/\(state.habits.count)", icon: "circle.hexagongrid.fill", tint: MicrofitTheme.gold) }
        }
    }

    private var checkIn: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Check in", icon: "waveform.path.ecg", trailing: state.todayCheckIn.readinessLabel)
            PremiumCard(padding: 18) {
                VStack(spacing: 20) {
                    RatingPicker(title: "Energy", lowLabel: "Drained", highLabel: "Charged", value: state.todayCheckIn.energy, tint: MicrofitTheme.lime) {
                        state.updateCheckIn(energy: $0)
                    }
                    Divider().overlay(MicrofitTheme.border)
                    RatingPicker(title: "Sleep", lowLabel: "Rough", highLabel: "Restored", value: state.todayCheckIn.sleep, tint: MicrofitTheme.aqua) {
                        state.updateCheckIn(sleep: $0)
                    }
                    Divider().overlay(MicrofitTheme.border)
                    RatingPicker(title: "Soreness", lowLabel: "None", highLabel: "Very sore", value: state.todayCheckIn.soreness, tint: MicrofitTheme.gold) {
                        state.updateCheckIn(soreness: $0)
                    }
                    Divider().overlay(MicrofitTheme.border)
                    RatingPicker(title: "Stress", lowLabel: "Calm", highLabel: "Maxed", value: state.todayCheckIn.stress, tint: MicrofitTheme.coral) {
                        state.updateCheckIn(stress: $0)
                    }
                }
            }
        }
    }

    private var todayPlan: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Adaptive plan", icon: "sparkles", trailing: "\(state.todayPlan.durationMinutes) MIN")
            PremiumCard(padding: 20, interactive: true) {
                VStack(alignment: .leading, spacing: 15) {
                    HStack(alignment: .top, spacing: 14) {
                        Image(systemName: state.todayPlan.icon)
                            .font(.title2.weight(.black))
                            .foregroundStyle(MicrofitTheme.background)
                            .frame(width: 48, height: 48)
                            .background(MicrofitTheme.accentGradient, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        VStack(alignment: .leading, spacing: 3) {
                            Text(state.todayPlan.title)
                                .font(.title3.weight(.black))
                                .foregroundStyle(.white)
                            Text(state.todayPlan.focus.uppercased())
                                .font(MicrofitTheme.eyebrow(MicrofitTheme.aqua))
                                .tracking(1.1)
                                .foregroundStyle(MicrofitTheme.aqua)
                        }
                        Spacer()
                    }
                    Text(state.todayPlan.summary)
                        .font(.subheadline)
                        .foregroundStyle(MicrofitTheme.secondaryText)
                    HStack(spacing: 8) {
                        ForEach(state.todayPlan.exercises.prefix(3)) { item in
                            Text(item.exercise.name)
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(MicrofitTheme.muted)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 6)
                                .background(MicrofitTheme.elevated, in: Capsule())
                                .lineLimit(1)
                        }
                    }
                    MicrofitButton(title: "Open Workout", icon: "arrow.right", tint: MicrofitTheme.aqua) {
                        state.selectedTab = .plan
                    }
                }
            }
        }
    }

    private var habits: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Small wins", icon: "checkmark.seal.fill", trailing: "\(state.habitCompletionCount)/\(state.habits.count)")
            VStack(spacing: 10) {
                ForEach(state.habits) { habit in
                    let complete = habit.isComplete()
                    Button {
                        withAnimation(.snappy) { state.toggleHabit(habit.id) }
                    } label: {
                        HStack(spacing: 13) {
                            Image(systemName: habit.icon)
                                .font(.headline.weight(.bold))
                                .foregroundStyle(complete ? MicrofitTheme.background : MicrofitTheme.aqua)
                                .frame(width: 42, height: 42)
                                .background(complete ? MicrofitTheme.lime : MicrofitTheme.aqua.opacity(0.10), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(habit.title).font(.headline.weight(.bold)).foregroundStyle(.white)
                                Text(habit.detail).font(.caption).foregroundStyle(MicrofitTheme.muted)
                            }
                            Spacer(minLength: 8)
                            Image(systemName: complete ? "checkmark.circle.fill" : "circle")
                                .font(.title3)
                                .foregroundStyle(complete ? MicrofitTheme.lime : MicrofitTheme.muted)
                        }
                        .padding(13)
                        .background(MicrofitTheme.surface, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).stroke(complete ? MicrofitTheme.lime.opacity(0.32) : MicrofitTheme.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(complete ? .isSelected : [])
                }
            }
        }
    }

    @ViewBuilder
    private var recentWin: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Latest win", icon: "trophy.fill")
            if let log = state.recentWorkoutLogs.first {
                PremiumCard {
                    HStack(spacing: 14) {
                        Image(systemName: log.isMicroSession ? "timer" : "dumbbell.fill")
                            .font(.title2.weight(.black))
                            .foregroundStyle(log.isMicroSession ? MicrofitTheme.aqua : MicrofitTheme.lime)
                            .frame(width: 48, height: 48)
                            .background(MicrofitTheme.elevated, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        VStack(alignment: .leading, spacing: 3) {
                            Text(log.title).font(.headline.weight(.black)).foregroundStyle(.white)
                            Text(log.completedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption).foregroundStyle(MicrofitTheme.muted)
                        }
                        Spacer()
                        Text("\(log.durationMinutes) MIN")
                            .font(MicrofitTheme.eyebrow(MicrofitTheme.aqua))
                            .foregroundStyle(MicrofitTheme.aqua)
                    }
                }
            } else {
                EmptyMicrofitState(title: "Your first win is ready", detail: "Start the adaptive plan or choose a three-minute movement break.", icon: "flag.checkered")
            }
        }
    }

    private var privateCoach: some View {
        PremiumCard(padding: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Label(state.coachModeLabel, systemImage: "lock.shield.fill")
                    .font(MicrofitTheme.eyebrow(MicrofitTheme.lime))
                    .tracking(1.2)
                    .foregroundStyle(MicrofitTheme.lime)
                Text("Need a smaller plan?")
                    .font(.title3.weight(.black))
                    .foregroundStyle(.white)
                Text("Your coach can use today’s readiness and activity—without sending your fitness history to a Microfit server.")
                    .font(.subheadline)
                    .foregroundStyle(MicrofitTheme.secondaryText)
                MicrofitButton(title: "Ask My Coach", icon: "bubble.left.and.bubble.right.fill", tint: MicrofitTheme.lime) {
                    state.coachSection = .aiCoach
                    state.selectedTab = .coach
                }
                Button {
                    state.coachSection = .humanTrainers
                    state.selectedTab = .coach
                } label: {
                    Label("Find a human trainer", systemImage: "person.2.fill")
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(MicrofitTheme.aqua)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var heroMessage: String {
        switch state.todayCheckIn.readinessScore {
        case 80...: "You have room to push—but clean reps still win."
        case 60..<80: "A steady session fits the signal today."
        case 45..<60: "Keep the work useful and leave some in the tank."
        default: "Recovery is training when your body asks for it."
        }
    }
}
