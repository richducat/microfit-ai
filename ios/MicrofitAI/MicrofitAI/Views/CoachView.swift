import SwiftUI

struct CoachView: View {
    @Environment(MicrofitAppState.self) private var state
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var input = ""

    private let quickPrompts = [
        "What should I do today?",
        "I only have 5 minutes",
        "Help me recover",
        "Give me a simple meal target"
    ]

    var body: some View {
        VStack(spacing: 0) {
            coachSwitcher
            switch state.coachSection {
            case .aiCoach:
                aiCoach
            case .humanTrainers:
                TrainerMarketplaceView()
            }
        }
        .frame(maxWidth: 760)
        .frame(maxWidth: .infinity)
    }

    private var coachSwitcher: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 8))
            : AnyLayout(HStackLayout(spacing: 8))

        return layout {
            ForEach(CoachSection.allCases) { section in
                let selected = state.coachSection == section
                Button {
                    withAnimation(.snappy(duration: 0.25)) { state.coachSection = section }
                } label: {
                    Label(section.title, systemImage: section.icon)
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(selected ? MicrofitTheme.background : MicrofitTheme.secondaryText)
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                        .minimumScaleFactor(0.78)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                        .padding(.vertical, dynamicTypeSize.isAccessibilitySize ? 8 : 0)
                        .background(selected ? MicrofitTheme.lime : MicrofitTheme.elevated, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(MicrofitTheme.chrome.opacity(0.96))
        .overlay(alignment: .bottom) { Rectangle().fill(MicrofitTheme.border).frame(height: 1) }
    }

    private var aiCoach: some View {
        VStack(spacing: 0) {
            coachHeader
            messages
            composer
        }
    }

    private var coachHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 13) {
                Image(systemName: "apple.intelligence")
                    .font(.title2.weight(.black))
                    .foregroundStyle(MicrofitTheme.background)
                    .frame(width: 48, height: 48)
                    .background(MicrofitTheme.accentGradient, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                VStack(alignment: .leading, spacing: 3) {
                    Text("MICROFIT COACH")
                        .font(MicrofitTheme.eyebrow())
                        .tracking(1.4)
                        .foregroundStyle(MicrofitTheme.lime)
                    Text(state.coachModeLabel)
                        .font(.title3.weight(.black))
                        .foregroundStyle(.white)
                    Label("Your fitness history stays on this device", systemImage: "lock.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MicrofitTheme.muted)
                }
                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(quickPrompts, id: \.self) { prompt in
                        Button {
                            Task { await send(prompt) }
                        } label: {
                            Text(prompt)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(MicrofitTheme.secondaryText)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 9)
                                .background(MicrofitTheme.elevated, in: Capsule())
                                .overlay(Capsule().stroke(MicrofitTheme.border, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .disabled(state.isWorking)
                    }
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .background(MicrofitTheme.background.opacity(0.94))
    }

    private var messages: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 13) {
                    ForEach(state.coachMessages) { message in
                        messageBubble(message)
                            .id(message.id)
                    }

                    if state.isWorking {
                        HStack(spacing: 9) {
                            ProgressView().tint(MicrofitTheme.lime)
                            Text("Thinking privately on this device…")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(MicrofitTheme.muted)
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                        .id("thinking")
                    }

                    Text("Microfit provides general fitness guidance, not medical diagnosis or treatment. Stop if a movement feels unsafe.")
                        .font(.caption2)
                        .foregroundStyle(MicrofitTheme.muted)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
            }
            .onChange(of: state.coachMessages.count) {
                withAnimation { proxy.scrollTo(state.coachMessages.last?.id, anchor: .bottom) }
            }
            .onChange(of: state.isWorking) {
                if state.isWorking { withAnimation { proxy.scrollTo("thinking", anchor: .bottom) } }
            }
        }
    }

    private func messageBubble(_ message: CoachMessage) -> some View {
        HStack(alignment: .bottom, spacing: 9) {
            if message.isCoach {
                BrandMark(size: 32)
            } else {
                Spacer(minLength: 54)
            }

            VStack(alignment: message.isCoach ? .leading : .trailing, spacing: 4) {
                Text(message.text)
                    .font(.subheadline)
                    .foregroundStyle(message.isCoach ? .white : MicrofitTheme.background)
                    .textSelection(.enabled)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        message.isCoach ? AnyShapeStyle(MicrofitTheme.surface) : AnyShapeStyle(MicrofitTheme.accentGradient),
                        in: RoundedRectangle(cornerRadius: 17, style: .continuous)
                    )
                    .overlay {
                        if message.isCoach {
                            RoundedRectangle(cornerRadius: 17, style: .continuous)
                                .stroke(MicrofitTheme.border, lineWidth: 1)
                        }
                    }
                Text(message.createdAt.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(MicrofitTheme.muted)
            }

            if !message.isCoach {
                Image(systemName: "person.crop.circle.fill")
                    .font(.title2)
                    .foregroundStyle(MicrofitTheme.aqua)
            } else {
                Spacer(minLength: 54)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message.isCoach ? "Microfit coach" : "You")
        .accessibilityValue(message.text)
    }

    private var composer: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField("Ask about today’s training…", text: $input, axis: .vertical)
                .lineLimit(1...4)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .foregroundStyle(.white)
                .background(MicrofitTheme.elevated, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(MicrofitTheme.border, lineWidth: 1))
                .submitLabel(.send)
                .onSubmit { Task { await send(input) } }

            Button {
                Task { await send(input) }
            } label: {
                Image(systemName: "arrow.up")
                    .font(.headline.weight(.black))
                    .foregroundStyle(MicrofitTheme.background)
                    .frame(width: 46, height: 46)
                    .background(MicrofitTheme.lime, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || state.isWorking)
            .opacity(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || state.isWorking ? 0.45 : 1)
            .accessibilityLabel("Send")
        }
        .padding(.horizontal, 18)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(MicrofitTheme.chrome.opacity(0.96))
        .overlay(alignment: .top) { Rectangle().fill(MicrofitTheme.border).frame(height: 1) }
    }

    private func send(_ text: String) async {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }
        input = ""
        await state.sendCoachMessage(cleaned)
    }
}
