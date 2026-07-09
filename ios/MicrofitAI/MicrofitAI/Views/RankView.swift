import SwiftUI

struct RankView: View {
    @Environment(MicrofitAppState.self) private var state

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                header
                headlineMetrics
                sevenDayActivity
                insight
                achievements
                history
            }
            .padding(20)
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
    }

    private var header: some View {
        PremiumCard(padding: 22) {
            HStack(alignment: .top, spacing: 15) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("PROGRESS")
                        .font(MicrofitTheme.eyebrow())
                        .tracking(1.8)
                        .foregroundStyle(MicrofitTheme.lime)
                    Text(progressHeadline)
                        .font(.system(size: 31, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Private, useful trends from the work you log on this device.")
                        .font(.subheadline)
                        .foregroundStyle(MicrofitTheme.secondaryText)
                }
                Spacer()
                ZStack {
                    Circle().fill(MicrofitTheme.lime.opacity(0.12)).frame(width: 76, height: 76)
                    VStack(spacing: 0) {
                        Text("\(state.currentStreak)")
                            .font(MicrofitTheme.metric(28))
                            .foregroundStyle(MicrofitTheme.lime)
                        Text("STREAK")
                            .font(.system(size: 8, weight: .black, design: .rounded))
                            .tracking(1)
                            .foregroundStyle(MicrofitTheme.muted)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Current streak \(state.currentStreak) \(state.currentStreak == 1 ? "day" : "days")")
            }
        }
    }

    private var headlineMetrics: some View {
        LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 12) {
            PremiumCard { MetricPill(title: "All sessions", value: "\(state.workoutLogs.count)", icon: "checkmark.seal.fill", tint: MicrofitTheme.lime) }
            PremiumCard { MetricPill(title: "Total minutes", value: "\(totalMinutes)", icon: "clock.fill", tint: MicrofitTheme.aqua) }
            PremiumCard { MetricPill(title: "Strength sets", value: "\(totalSets)", icon: "dumbbell.fill", tint: MicrofitTheme.blue) }
            PremiumCard { MetricPill(title: "Micro wins", value: "\(microSessionCount)", icon: "bolt.fill", tint: MicrofitTheme.gold) }
        }
    }

    private var sevenDayActivity: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Last 7 days", icon: "chart.bar.fill", trailing: "\(lastSevenDays.reduce(0) { $0 + $1.minutes }) MIN")
            PremiumCard(padding: 18) {
                HStack(alignment: .bottom, spacing: 9) {
                    ForEach(lastSevenDays, id: \.key) { day in
                        VStack(spacing: 7) {
                            Text(day.minutes == 0 ? "" : "\(day.minutes)")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(MicrofitTheme.secondaryText)
                                .frame(height: 14)
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(day.minutes > 0 ? AnyShapeStyle(MicrofitTheme.accentGradient) : AnyShapeStyle(MicrofitTheme.elevated))
                                .frame(height: max(8, CGFloat(day.minutes) / CGFloat(max(1, maxDailyMinutes)) * 118))
                            Text(day.label)
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(day.isToday ? MicrofitTheme.lime : MicrofitTheme.muted)
                        }
                        .frame(maxWidth: .infinity)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("\(day.fullLabel), \(day.minutes) minutes")
                    }
                }
                .frame(height: 160, alignment: .bottom)
            }
        }
    }

    private var insight: some View {
        PremiumCard(padding: 20) {
            VStack(alignment: .leading, spacing: 11) {
                Label("Microfit insight", systemImage: "sparkles")
                    .font(MicrofitTheme.eyebrow())
                    .tracking(1.2)
                    .foregroundStyle(MicrofitTheme.lime)
                Text(insightTitle)
                    .font(.title3.weight(.black))
                    .foregroundStyle(.white)
                Text(insightDetail)
                    .font(.subheadline)
                    .foregroundStyle(MicrofitTheme.secondaryText)
            }
        }
    }

    private var achievements: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Milestones", icon: "medal.fill", trailing: "\(achievementData.filter { $0.unlocked }.count)/\(achievementData.count)")
            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 12) {
                ForEach(Array(achievementData.enumerated()), id: \.offset) { _, item in
                    PremiumCard(padding: 15) {
                        VStack(alignment: .leading, spacing: 9) {
                            Image(systemName: item.icon)
                                .font(.title2.weight(.black))
                                .foregroundStyle(item.unlocked ? MicrofitTheme.background : MicrofitTheme.muted)
                                .frame(width: 46, height: 46)
                                .background(item.unlocked ? AnyShapeStyle(MicrofitTheme.accentGradient) : AnyShapeStyle(MicrofitTheme.elevated), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            Text(item.title)
                                .font(.headline.weight(.black))
                                .foregroundStyle(item.unlocked ? .white : MicrofitTheme.muted)
                            Text(item.detail)
                                .font(.caption)
                                .foregroundStyle(MicrofitTheme.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .opacity(item.unlocked ? 1 : 0.62)
                    .accessibilityElement(children: .combine)
                    .accessibilityValue(item.unlocked ? "Unlocked" : "Locked")
                }
            }
        }
    }

    private var history: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "History", icon: "clock.arrow.circlepath", trailing: "ON DEVICE")
            if state.recentWorkoutLogs.isEmpty {
                EmptyMicrofitState(title: "No sessions yet", detail: "Complete any plan or micro-session and it will appear here.", icon: "list.bullet.clipboard")
            } else {
                ForEach(state.recentWorkoutLogs.prefix(20)) { log in
                    PremiumCard {
                        HStack(spacing: 13) {
                            Image(systemName: log.isMicroSession ? "timer" : "dumbbell.fill")
                                .font(.headline.weight(.black))
                                .foregroundStyle(log.isMicroSession ? MicrofitTheme.aqua : MicrofitTheme.lime)
                                .frame(width: 42, height: 42)
                                .background(MicrofitTheme.elevated, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(log.title).font(.headline.weight(.bold)).foregroundStyle(.white)
                                Text(log.completedAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption).foregroundStyle(MicrofitTheme.muted)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(log.durationMinutes) min")
                                    .font(.subheadline.weight(.black)).foregroundStyle(.white)
                                Text(log.isMicroSession ? "+35 XP" : "\(log.completedSets) \(log.completedSets == 1 ? "set" : "sets")")
                                    .font(.caption2.weight(.bold)).foregroundStyle(MicrofitTheme.aqua)
                            }
                        }
                    }
                }
            }
        }
    }

    private var totalMinutes: Int { state.workoutLogs.reduce(0) { $0 + $1.durationMinutes } }
    private var totalSets: Int { state.workoutLogs.filter { !$0.isMicroSession }.reduce(0) { $0 + $1.completedSets } }
    private var microSessionCount: Int { state.workoutLogs.filter(\.isMicroSession).count }

    private var progressHeadline: String {
        if state.workoutLogs.isEmpty { return "Your first data point starts today." }
        if state.currentStreak >= 3 { return "Consistency is becoming a pattern." }
        return "Every honest session compounds."
    }

    private var insightTitle: String {
        if state.weeklySessions == 0 { return "Shrink the start" }
        if state.weeklySessions < state.profile.trainingDaysPerWeek { return "One more session moves the week" }
        if state.todayCheckIn.readinessScore < 50 { return "Protect the work with recovery" }
        return "Your planned frequency is on track"
    }

    private var insightDetail: String {
        if state.weeklySessions == 0 { return "Choose the 3-minute Desk Reset. The goal is not fitness in three minutes—it’s ending the zero." }
        if state.weeklySessions < state.profile.trainingDaysPerWeek { return "You planned \(state.profile.trainingDaysPerWeek) days and have logged \(state.weeklySessions). Today’s adaptive plan or a micro-session both count." }
        if state.todayCheckIn.readinessScore < 50 { return "You have enough work in the bank this week. Use Recovery Reset and let adaptation catch up." }
        return "You hit \(state.weeklySessions) sessions and \(state.weeklyMinutes) minutes. Keep the next session clean rather than chasing more for its own sake." 
    }

    private var achievementData: [(title: String, detail: String, icon: String, unlocked: Bool)] {
        [
            ("First rep", "Complete your first logged session.", "flag.checkered", !state.workoutLogs.isEmpty),
            ("Three-day spark", "Build a three-day activity streak.", "flame.fill", state.currentStreak >= 3),
            ("Micro master", "Complete five micro-sessions.", "bolt.fill", microSessionCount >= 5),
            ("Century", "Log 100 total training minutes.", "100.circle.fill", totalMinutes >= 100),
            ("Ten strong", "Complete ten total sessions.", "10.circle.fill", state.workoutLogs.count >= 10),
            ("Habit stack", "Complete all daily habits together.", "square.stack.3d.up.fill", state.habitCompletionCount == state.habits.count)
        ]
    }

    private var lastSevenDays: [(key: String, label: String, fullLabel: String, minutes: Int, isToday: Bool)] {
        let calendar = Calendar.current
        return (0..<7).reversed().compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { return nil }
            let key = DayKey.key(for: date)
            let minutes = state.workoutLogs
                .filter { DayKey.key(for: $0.completedAt) == key }
                .reduce(0) { $0 + $1.durationMinutes }
            return (
                key,
                date.formatted(.dateTime.weekday(.narrow)),
                date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()),
                minutes,
                calendar.isDateInToday(date)
            )
        }
    }

    private var maxDailyMinutes: Int { max(1, lastSevenDays.map { $0.minutes }.max() ?? 1) }
}
