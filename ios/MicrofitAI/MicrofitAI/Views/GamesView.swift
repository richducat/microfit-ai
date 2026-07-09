import SwiftUI
import UIKit

struct GamesView: View {
    @Environment(MicrofitAppState.self) private var state
    @State private var selectedSession: MicroSession?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                header
                whyItWorks
                sessionGrid
                officePromise
            }
            .padding(20)
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .fullScreenCover(item: $selectedSession) { session in
            MicroSessionPlayer(session: session)
                .environment(state)
        }
    }

    private var header: some View {
        PremiumCard(padding: 22) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("MICRO WORKOUTS")
                            .font(MicrofitTheme.eyebrow())
                            .tracking(1.8)
                            .foregroundStyle(MicrofitTheme.lime)
                        Text("No time is still enough time.")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    Image(systemName: "timer.circle.fill")
                        .font(.system(size: 46, weight: .black))
                        .foregroundStyle(MicrofitTheme.aqua)
                }
                Text("Pick a guided reset from three to five minutes. No equipment, no login, and no setup beyond pressing start.")
                    .font(.subheadline)
                    .foregroundStyle(MicrofitTheme.secondaryText)
            }
        }
    }

    private var whyItWorks: some View {
        LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 12) {
            PremiumCard { MetricPill(title: "Shortest", value: "3 min", icon: "bolt.fill", tint: MicrofitTheme.lime) }
            PremiumCard { MetricPill(title: "Equipment", value: "None", icon: "figure.walk", tint: MicrofitTheme.aqua) }
            PremiumCard { MetricPill(title: "Today", value: "\(microSessionsToday)", icon: "checkmark.circle.fill", tint: MicrofitTheme.gold) }
            PremiumCard { MetricPill(title: "Micro XP", value: "\(microXP)", icon: "sparkles", tint: MicrofitTheme.coral) }
        }
    }

    private var sessionGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Choose a reset", icon: "play.square.stack.fill", trailing: "GUIDED")
            ForEach(MicrofitSeedData.microSessions) { session in
                Button {
                    selectedSession = session
                } label: {
                    PremiumCard(padding: 18, interactive: true) {
                        HStack(spacing: 15) {
                            Image(systemName: session.icon)
                                .font(.title2.weight(.black))
                                .foregroundStyle(MicrofitTheme.background)
                                .frame(width: 54, height: 54)
                                .background(MicrofitTheme.accentGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(session.title)
                                    .font(.title3.weight(.black))
                                    .foregroundStyle(.white)
                                Text(session.summary)
                                    .font(.caption)
                                    .foregroundStyle(MicrofitTheme.muted)
                                    .multilineTextAlignment(.leading)
                                Text("\(session.durationMinutes) MIN • \(session.intervals.count) INTERVALS")
                                    .font(MicrofitTheme.eyebrow(MicrofitTheme.aqua))
                                    .tracking(0.8)
                                    .foregroundStyle(MicrofitTheme.aqua)
                            }
                            Spacer(minLength: 6)
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                                .foregroundStyle(MicrofitTheme.lime)
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(session.title), \(session.durationMinutes) minutes. \(session.summary)")
                .accessibilityHint("Starts guided timer")
            }
        }
    }

    private var officePromise: some View {
        PremiumCard(padding: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Label("The original MicroFit idea—rebuilt", systemImage: "arrow.trianglehead.clockwise")
                    .font(.headline.weight(.black))
                    .foregroundStyle(MicrofitTheme.lime)
                Text("The 2018 app made quick workplace exercise approachable. Version 2 keeps that promise, then connects each small session to readiness, streaks, habits, and a complete training plan.")
                    .font(.subheadline)
                    .foregroundStyle(MicrofitTheme.secondaryText)
            }
        }
    }

    private var microSessionsToday: Int {
        state.workoutLogs.filter { $0.isMicroSession && DayKey.key(for: $0.completedAt) == DayKey.today }.count
    }

    private var microXP: Int {
        state.workoutLogs.filter(\.isMicroSession).count * 35
    }
}

private struct MicroSessionPlayer: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(MicrofitAppState.self) private var state
    let session: MicroSession

    @State private var intervalIndex = 0
    @State private var remaining = 0
    @State private var isRunning = false
    @State private var isComplete = false

    private var interval: MicroInterval { session.intervals[intervalIndex] }
    private var elapsedIntervals: Int { intervalIndex }
    private var progress: Double {
        let completedSeconds = session.intervals.prefix(intervalIndex).reduce(0) { $0 + $1.seconds }
        let currentElapsed = max(0, interval.seconds - remaining)
        let total = session.intervals.reduce(0) { $0 + $1.seconds }
        return total == 0 ? 0 : Double(completedSeconds + currentElapsed) / Double(total)
    }

    var body: some View {
        ZStack {
            MicrofitTheme.background.ignoresSafeArea()
            Circle()
                .fill((interval.isRest ? MicrofitTheme.aqua : MicrofitTheme.lime).opacity(0.11))
                .frame(width: 420, height: 420)
                .blur(radius: 120)
                .offset(y: -130)

            if isComplete {
                completionView
            } else {
                player
            }
        }
        .onAppear { remaining = interval.seconds }
        .task(id: "\(intervalIndex)-\(isRunning)") {
            guard isRunning else { return }
            while isRunning && remaining > 0 {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled, isRunning else { return }
                remaining -= 1
                if remaining == 0 {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    advance()
                }
            }
        }
    }

    private var player: some View {
        VStack(spacing: 22) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(MicrofitTheme.elevated, in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close")
                Spacer()
                Text(session.title)
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }

            ProgressView(value: progress)
                .tint(interval.isRest ? MicrofitTheme.aqua : MicrofitTheme.lime)
                .scaleEffect(y: 1.6)

            Spacer()

            Text(interval.isRest ? "RESET" : "MOVE")
                .font(MicrofitTheme.eyebrow(interval.isRest ? MicrofitTheme.aqua : MicrofitTheme.lime))
                .tracking(3)
                .foregroundStyle(interval.isRest ? MicrofitTheme.aqua : MicrofitTheme.lime)

            Text(interval.title)
                .font(.system(size: 38, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            ZStack {
                Circle().stroke(MicrofitTheme.elevated, lineWidth: 14)
                Circle()
                    .trim(from: 0, to: interval.seconds == 0 ? 0 : Double(remaining) / Double(interval.seconds))
                    .stroke(interval.isRest ? MicrofitTheme.aqua : MicrofitTheme.lime, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.25), value: remaining)
                Text("\(remaining)")
                    .font(.system(size: 62, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }
            .frame(width: 210, height: 210)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(remaining) seconds remaining")

            Text(interval.cue)
                .font(.title3.weight(.semibold))
                .foregroundStyle(MicrofitTheme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 420)

            Text("INTERVAL \(elapsedIntervals + 1) OF \(session.intervals.count)")
                .font(MicrofitTheme.eyebrow(MicrofitTheme.muted))
                .tracking(1.2)
                .foregroundStyle(MicrofitTheme.muted)

            Spacer()

            HStack(spacing: 12) {
                Button {
                    goBack()
                } label: {
                    Image(systemName: "backward.end.fill")
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)
                        .frame(width: 54, height: 54)
                        .background(MicrofitTheme.elevated, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(intervalIndex == 0)
                .opacity(intervalIndex == 0 ? 0.35 : 1)
                .accessibilityLabel("Previous interval")

                MicrofitButton(
                    title: isRunning ? "Pause" : (remaining < interval.seconds ? "Resume" : "Start"),
                    icon: isRunning ? "pause.fill" : "play.fill",
                    tint: interval.isRest ? MicrofitTheme.aqua : MicrofitTheme.lime
                ) {
                    isRunning.toggle()
                }

                Button {
                    advance()
                } label: {
                    Image(systemName: "forward.end.fill")
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)
                        .frame(width: 54, height: 54)
                        .background(MicrofitTheme.elevated, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Next interval")
            }
        }
        .padding(22)
    }

    private var completionView: some View {
        VStack(spacing: 22) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 90, weight: .black))
                .foregroundStyle(MicrofitTheme.lime)
                .shadow(color: MicrofitTheme.lime.opacity(0.30), radius: 30)
            Text("Small win. Logged.")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text("\(session.durationMinutes) minutes is enough to change the direction of a day.")
                .font(.title3.weight(.semibold))
                .foregroundStyle(MicrofitTheme.secondaryText)
                .multilineTextAlignment(.center)
            Text("+35 XP")
                .font(MicrofitTheme.metric(24))
                .foregroundStyle(MicrofitTheme.aqua)
            Spacer()
            MicrofitButton(title: "Done", icon: "arrow.right", tint: MicrofitTheme.lime) { dismiss() }
        }
        .padding(28)
    }

    private func advance() {
        if intervalIndex + 1 < session.intervals.count {
            intervalIndex += 1
            remaining = session.intervals[intervalIndex].seconds
        } else {
            isRunning = false
            state.completeMicroSession(session)
            withAnimation(.snappy) { isComplete = true }
        }
    }

    private func goBack() {
        guard intervalIndex > 0 else { return }
        intervalIndex -= 1
        remaining = session.intervals[intervalIndex].seconds
        isRunning = false
    }
}
