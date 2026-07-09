import SwiftUI
import UIKit

struct RootShellView: View {
    @Environment(MicrofitAppState.self) private var state

    var body: some View {
        ZStack(alignment: .bottom) {
            MicrofitTheme.background.ignoresSafeArea()
            BackgroundGlow()

            if state.isBootstrapping {
                LoadingView()
            } else if state.onboardingComplete {
                appTabs
            } else {
                OnboardingView()
            }

            VStack {
                StatusBanner()
                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)
            .allowsHitTesting(state.errorMessage != nil || state.successMessage != nil)
        }
        .task { await state.bootstrap() }
    }

    private var appTabs: some View {
        VStack(spacing: 0) {
            MicrofitTopBar()
            ZStack(alignment: .bottom) {
                Group {
                    switch state.selectedTab {
                    case .today: HomeView()
                    case .plan: TrainView()
                    case .move: GamesView()
                    case .coach: CoachView()
                    case .progress: RankView()
                    case .fuel: MarketView()
                    case .profile: ProfileView()
                    }
                }
                .safeAreaPadding(.bottom, 92)

                PremiumTabBar()
            }
        }
    }
}

private struct BackgroundGlow: View {
    var body: some View {
        ZStack {
            MicrofitTheme.background.ignoresSafeArea()
            Circle()
                .fill(MicrofitTheme.lime.opacity(0.10))
                .frame(width: 360, height: 360)
                .blur(radius: 120)
                .offset(x: -180, y: -300)
            Circle()
                .fill(MicrofitTheme.aqua.opacity(0.09))
                .frame(width: 340, height: 340)
                .blur(radius: 125)
                .offset(x: 190, y: 350)
        }
        .ignoresSafeArea()
    }
}

private struct MicrofitTopBar: View {
    @Environment(MicrofitAppState.self) private var state

    var body: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.snappy(duration: 0.25)) { state.selectedTab = .today }
            } label: {
                HStack(spacing: 11) {
                    BrandMark(size: 38)
                    VStack(alignment: .leading, spacing: 1) {
                        HStack(spacing: 0) {
                            Text("microfit")
                                .foregroundStyle(.white)
                            Text(".AI")
                                .foregroundStyle(MicrofitTheme.lime)
                        }
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        Text("SMALL WINS. BUILT DAILY.")
                            .font(MicrofitTheme.eyebrow(MicrofitTheme.muted))
                            .tracking(1.15)
                            .foregroundStyle(MicrofitTheme.muted)
                    }
                }
                .contentShape(Rectangle())
                .padding(.vertical, 3)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(state.todayCheckIn.readinessScore)")
                    .font(MicrofitTheme.metric(18))
                    .foregroundStyle(MicrofitTheme.aqua)
                Text("READINESS")
                    .font(MicrofitTheme.eyebrow(MicrofitTheme.muted))
                    .foregroundStyle(MicrofitTheme.muted)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Readiness \(state.todayCheckIn.readinessScore) out of 100")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background {
            if #available(iOS 26.0, *) {
                MicrofitTheme.chrome.opacity(0.86)
                    .glassEffect(.regular.tint(.black.opacity(0.18)), in: .rect)
            } else {
                MicrofitTheme.chrome.opacity(0.96)
            }
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(.white.opacity(0.07)).frame(height: 1)
        }
    }
}

private struct LoadingView: View {
    var body: some View {
        VStack(spacing: 18) {
            BrandMark(size: 76)
            ProgressView().tint(MicrofitTheme.lime).scaleEffect(1.3)
            Text("Building your next small win")
                .font(.headline.weight(.black))
                .foregroundStyle(.white)
        }
    }
}

private struct OnboardingView: View {
    @Environment(MicrofitAppState.self) private var state
    @State private var step = 0
    @State private var draft = MicrofitProfile.starter
    @State private var enableReminders = true

    private let finalStep = 3

    var body: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    onboardingHeader
                    stepContent
                    navigation
                }
                .padding(20)
                .padding(.top, max(16, proxy.safeAreaInsets.top + 4))
                .padding(.bottom, 40)
                .frame(maxWidth: 680)
                .frame(maxWidth: .infinity)
                .frame(minHeight: proxy.size.height, alignment: .top)
            }
        }
    }

    private var onboardingHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                BrandMark(size: 58)
                Spacer()
                Text("\(step + 1) / \(finalStep + 1)")
                    .font(MicrofitTheme.metric(14))
                    .foregroundStyle(MicrofitTheme.muted)
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 0) {
                    Text("microfit").foregroundStyle(.white)
                    Text(".AI").foregroundStyle(MicrofitTheme.lime)
                }
                .font(.system(size: 38, weight: .black, design: .rounded))
                Text(headerTitle)
                    .font(.title2.weight(.black))
                    .foregroundStyle(.white)
                Text(headerDetail)
                    .font(.subheadline)
                    .foregroundStyle(MicrofitTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            ProgressView(value: Double(step + 1), total: Double(finalStep + 1))
                .tint(MicrofitTheme.lime)
                .scaleEffect(y: 1.4)
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case 0: identityStep
        case 1: experienceStep
        case 2: setupStep
        default: privacyStep
        }
    }

    private var identityStep: some View {
        PremiumCard(padding: 20) {
            VStack(alignment: .leading, spacing: 18) {
                TextField("First name (optional)", text: $draft.name)
                    .textContentType(.givenName)
                    .padding(14)
                    .background(MicrofitTheme.elevated, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(MicrofitTheme.border, lineWidth: 1))
                    .foregroundStyle(.white)

                Text("WHAT DO YOU WANT MOST?")
                    .font(MicrofitTheme.eyebrow())
                    .tracking(1.3)
                    .foregroundStyle(MicrofitTheme.lime)

                ForEach(FitnessGoal.allCases) { goal in
                    choiceRow(
                        title: goal.title,
                        detail: goal.detail,
                        icon: goal.icon,
                        selected: draft.goal == goal
                    ) { draft.goal = goal }
                }
            }
        }
    }

    private var experienceStep: some View {
        PremiumCard(padding: 20) {
            VStack(alignment: .leading, spacing: 18) {
                Text("TRAINING EXPERIENCE")
                    .font(MicrofitTheme.eyebrow())
                    .tracking(1.3)
                    .foregroundStyle(MicrofitTheme.lime)

                ForEach(ExperienceLevel.allCases) { level in
                    choiceRow(
                        title: level.title,
                        detail: level.detail,
                        icon: "speedometer",
                        selected: draft.experience == level
                    ) { draft.experience = level }
                }

                Divider().overlay(MicrofitTheme.border)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Typical session")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                        Spacer()
                        Text("\(draft.sessionMinutes) min")
                            .font(MicrofitTheme.metric(16))
                            .foregroundStyle(MicrofitTheme.aqua)
                    }
                    Slider(value: Binding(
                        get: { Double(draft.sessionMinutes) },
                        set: { draft.sessionMinutes = Int($0.rounded()) }
                    ), in: 10...60, step: 5)
                    .tint(MicrofitTheme.aqua)
                    Text("Microfit always keeps a shorter fallback ready.")
                        .font(.caption)
                        .foregroundStyle(MicrofitTheme.muted)
                }
            }
        }
    }

    private var setupStep: some View {
        PremiumCard(padding: 20) {
            VStack(alignment: .leading, spacing: 18) {
                Text("AVAILABLE EQUIPMENT")
                    .font(MicrofitTheme.eyebrow())
                    .tracking(1.3)
                    .foregroundStyle(MicrofitTheme.lime)

                LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 10) {
                    ForEach(EquipmentOption.allCases) { option in
                        let isSelected = draft.equipment.contains(option)
                        Button {
                            if isSelected, draft.equipment.count > 1 {
                                draft.equipment.remove(option)
                            } else {
                                draft.equipment.insert(option)
                            }
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: option.icon).font(.title2.weight(.bold))
                                Text(option.title).font(.subheadline.weight(.bold))
                            }
                            .foregroundStyle(isSelected ? MicrofitTheme.background : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isSelected ? MicrofitTheme.lime : MicrofitTheme.elevated, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(isSelected ? .isSelected : [])
                    }
                }

                Divider().overlay(MicrofitTheme.border)

                Stepper(value: $draft.trainingDaysPerWeek, in: 2...6) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(draft.trainingDaysPerWeek) training days each week")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                        Text("We’ll favor consistency over perfect weeks.")
                            .font(.caption)
                            .foregroundStyle(MicrofitTheme.muted)
                    }
                }
                .tint(MicrofitTheme.aqua)
            }
        }
    }

    private var privacyStep: some View {
        VStack(spacing: 14) {
            PremiumCard(padding: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    Label("Private by design", systemImage: "lock.shield.fill")
                        .font(.title3.weight(.black))
                        .foregroundStyle(MicrofitTheme.lime)
                    Text("Your profile, check-ins, workouts, nutrition, habits, and coach history stay on this device. Microfit has no account, analytics tracker, ad network, or shared fitness database.")
                        .font(.subheadline)
                        .foregroundStyle(MicrofitTheme.secondaryText)
                    Label("On eligible devices, coaching uses Apple’s on-device language model. A complete local coach works everywhere else.", systemImage: "apple.intelligence")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MicrofitTheme.secondaryText)
                }
            }

            PremiumCard(padding: 20) {
                Toggle(isOn: $enableReminders) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Movement reminders")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                        Text("Four quiet nudges during the day. Change or disable them anytime.")
                            .font(.caption)
                            .foregroundStyle(MicrofitTheme.muted)
                    }
                }
                .tint(MicrofitTheme.lime)
            }
        }
    }

    private var navigation: some View {
        HStack(spacing: 12) {
            if step > 0 {
                Button {
                    withAnimation(.snappy) { step -= 1 }
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)
                        .frame(width: 52, height: 52)
                        .background(MicrofitTheme.elevated, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back")
            }

            MicrofitButton(
                title: step == finalStep ? "Build My Plan" : "Continue",
                icon: step == finalStep ? "sparkles" : "arrow.right",
                tint: MicrofitTheme.lime
            ) {
                if step == finalStep {
                    Task { await state.finishOnboarding(with: draft, enableReminders: enableReminders) }
                } else {
                    withAnimation(.snappy) { step += 1 }
                }
            }
        }
    }

    private func choiceRow(title: String, detail: String, icon: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 13) {
                Image(systemName: icon)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(selected ? MicrofitTheme.background : MicrofitTheme.aqua)
                    .frame(width: 42, height: 42)
                    .background(selected ? MicrofitTheme.lime : MicrofitTheme.aqua.opacity(0.10), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.headline.weight(.bold)).foregroundStyle(.white)
                    Text(detail).font(.caption).foregroundStyle(MicrofitTheme.muted).multilineTextAlignment(.leading)
                }
                Spacer(minLength: 8)
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selected ? MicrofitTheme.lime : MicrofitTheme.muted)
            }
            .padding(12)
            .background(selected ? MicrofitTheme.lime.opacity(0.08) : MicrofitTheme.elevated.opacity(0.55), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(selected ? MicrofitTheme.lime.opacity(0.45) : MicrofitTheme.border, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private var headerTitle: String {
        switch step {
        case 0: "Start with what matters."
        case 1: "Make it fit real life."
        case 2: "Build around what you have."
        default: "Your data stays yours."
        }
    }

    private var headerDetail: String {
        switch step {
        case 0: "A useful plan begins with one honest goal."
        case 1: "Your schedule and experience shape every recommendation."
        case 2: "No equipment is always a complete option."
        default: "No login, no tracking, and no cloud account required."
        }
    }
}

private struct PremiumTabBar: View {
    @Environment(MicrofitAppState.self) private var state

    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(.white.opacity(0.09)).frame(height: 1)
            HStack(alignment: .bottom, spacing: 2) {
                ForEach([MicrofitTab.today, .plan, .move]) { tab in tabButton(tab) }
                coachButton.offset(y: -17)
                ForEach([MicrofitTab.progress, .fuel, .profile]) { tab in tabButton(tab) }
            }
            .padding(.horizontal, 7)
            .padding(.top, 8)
            .padding(.bottom, 9)
        }
        .background {
            ZStack {
                MicrofitTheme.chrome.ignoresSafeArea(.container, edges: .bottom)
                if #available(iOS 26.0, *) {
                    MicrofitTheme.chrome.opacity(0.91)
                        .glassEffect(.regular.tint(.black.opacity(0.20)), in: .rect)
                }
            }
        }
    }

    private func tabButton(_ tab: MicrofitTab) -> some View {
        Button {
            withAnimation(.snappy(duration: 0.25)) { state.selectedTab = tab }
        } label: {
            VStack(spacing: 5) {
                Image(systemName: tab.icon)
                    .font(.system(size: 19, weight: state.selectedTab == tab ? .black : .semibold))
                Text(tab.shortLabel)
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
            }
            .foregroundStyle(state.selectedTab == tab ? MicrofitTheme.lime : MicrofitTheme.muted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.label)
        .accessibilityAddTraits(state.selectedTab == tab ? .isSelected : [])
    }

    private var coachButton: some View {
        Button {
            withAnimation(.snappy(duration: 0.25)) { state.selectedTab = .coach }
        } label: {
            ZStack {
                Circle().fill(MicrofitTheme.aqua.opacity(0.22)).blur(radius: 12).frame(width: 68, height: 68)
                Circle()
                    .fill(state.selectedTab == .coach ? AnyShapeStyle(MicrofitTheme.lime) : AnyShapeStyle(MicrofitTheme.accentGradient))
                    .frame(width: 58, height: 58)
                    .overlay(Circle().stroke(MicrofitTheme.chrome, lineWidth: 4))
                Image(systemName: MicrofitTab.coach.icon)
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(MicrofitTheme.background)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Coach")
        .accessibilityAddTraits(state.selectedTab == .coach ? .isSelected : [])
    }
}

private struct StatusBanner: View {
    @Environment(MicrofitAppState.self) private var state

    var body: some View {
        Group {
            if let error = state.errorMessage {
                banner(error, tint: MicrofitTheme.coral, icon: "exclamationmark.triangle.fill") { state.errorMessage = nil }
            } else if let success = state.successMessage {
                banner(success, tint: MicrofitTheme.lime, icon: "checkmark.circle.fill") { state.successMessage = nil }
            }
        }
        .onChange(of: state.errorMessage) { _, message in
            if let message { UIAccessibility.post(notification: .announcement, argument: message) }
        }
        .onChange(of: state.successMessage) { _, message in
            if let message { UIAccessibility.post(notification: .announcement, argument: message) }
        }
    }

    private func banner(_ text: String, tint: Color, icon: String, dismiss: @escaping () -> Void) -> some View {
        Button(action: dismiss) {
            HStack(spacing: 10) {
                Image(systemName: icon).foregroundStyle(tint)
                Text(text).font(.caption.weight(.bold)).foregroundStyle(.white).lineLimit(3)
                Spacer(minLength: 0)
                Image(systemName: "xmark").font(.caption.weight(.black)).foregroundStyle(MicrofitTheme.muted)
            }
            .padding(14)
            .background(MicrofitTheme.elevated, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(tint.opacity(0.40), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
