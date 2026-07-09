import SwiftUI

enum MicrofitTheme {
    static let background = Color(red: 0.018, green: 0.025, blue: 0.070)
    static let chrome = Color(red: 0.020, green: 0.028, blue: 0.075)
    static let surface = Color(red: 0.055, green: 0.070, blue: 0.125)
    static let elevated = Color(red: 0.085, green: 0.105, blue: 0.170)
    static let lime = Color(red: 0.72, green: 1.00, blue: 0.04)
    static let aqua = Color(red: 0.10, green: 0.92, blue: 0.92)
    static let blue = Color(red: 0.20, green: 0.52, blue: 1.00)
    static let coral = Color(red: 1.00, green: 0.38, blue: 0.42)
    static let gold = Color(red: 1.00, green: 0.78, blue: 0.20)
    static let muted = Color(red: 0.67, green: 0.72, blue: 0.81)
    static let secondaryText = Color(red: 0.80, green: 0.84, blue: 0.90)
    static let border = Color.white.opacity(0.09)

    static let accentGradient = LinearGradient(
        colors: [lime, aqua],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let heroGradient = LinearGradient(
        colors: [lime.opacity(0.15), aqua.opacity(0.10), blue.opacity(0.06), .clear],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func eyebrow(_ color: Color = MicrofitTheme.lime) -> Font {
        .system(size: 11, weight: .black, design: .rounded)
    }

    static func sectionTitle() -> Font {
        .system(size: 24, weight: .black, design: .rounded)
    }

    static func metric(_ size: CGFloat = 18) -> Font {
        .system(size: size, weight: .black, design: .rounded)
    }
}

struct PremiumCard<Content: View>: View {
    var padding: CGFloat = 16
    var radius: CGFloat = 20
    var interactive = false
    @ViewBuilder let content: Content

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)

        Group {
            if #available(iOS 26.0, *) {
                content
                    .padding(padding)
                    .background(MicrofitTheme.surface, in: shape)
                    .glassEffect(.regular.tint(.white.opacity(0.015)).interactive(interactive), in: .rect(cornerRadius: radius))
            } else {
                content
                    .padding(padding)
                    .background(MicrofitTheme.surface, in: shape)
            }
        }
        .overlay(shape.stroke(MicrofitTheme.border, lineWidth: 1))
    }
}

struct MicrofitButton: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let title: String
    var icon: String = "arrow.right"
    var tint: Color = MicrofitTheme.aqua
    var foreground: Color = MicrofitTheme.background
    var isDisabled = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) {
                Text(title)
                    .font(.headline.weight(.black))
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                    .minimumScaleFactor(0.75)
                    .multilineTextAlignment(.center)
                Image(systemName: icon)
                    .font(.headline.weight(.black))
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 12)
            .background(tint, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: tint.opacity(isDisabled ? 0 : 0.20), radius: 14, x: 0, y: 7)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.45 : 1)
    }
}

struct MetricPill: View {
    let title: String
    let value: String
    let icon: String
    var tint: Color = MicrofitTheme.aqua

    var body: some View {
        HStack(spacing: 11) {
            Image(systemName: icon)
                .font(.headline.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 40, height: 40)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(title.uppercased())
                    .font(MicrofitTheme.eyebrow(MicrofitTheme.muted))
                    .tracking(1.1)
                    .foregroundStyle(MicrofitTheme.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
                Text(value)
                    .font(MicrofitTheme.metric(17))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    var trailing: String?

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.headline.weight(.black))
                .foregroundStyle(MicrofitTheme.lime)
            Text(title)
                .font(MicrofitTheme.sectionTitle())
                .foregroundStyle(.white)
            Spacer(minLength: 8)
            if let trailing {
                Text(trailing)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MicrofitTheme.muted)
            }
        }
    }
}

struct EmptyMicrofitState: View {
    let title: String
    let detail: String
    let icon: String

    var body: some View {
        PremiumCard {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.largeTitle.weight(.black))
                    .foregroundStyle(MicrofitTheme.accentGradient)
                Text(title)
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(MicrofitTheme.muted)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct RatingPicker: View {
    let title: String
    let lowLabel: String
    let highLabel: String
    let value: Int
    var tint: Color = MicrofitTheme.aqua
    let onChange: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                Spacer()
                Text("\(value)/5")
                    .font(MicrofitTheme.metric(14))
                    .foregroundStyle(tint)
            }

            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { rating in
                    Button {
                        onChange(rating)
                    } label: {
                        Text("\(rating)")
                            .font(.subheadline.weight(.black))
                            .foregroundStyle(rating == value ? MicrofitTheme.background : MicrofitTheme.secondaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(rating == value ? tint : MicrofitTheme.elevated, in: RoundedRectangle(cornerRadius: 11, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(title), \(rating) of 5")
                    .accessibilityAddTraits(rating == value ? .isSelected : [])
                }
            }

            HStack {
                Text(lowLabel)
                Spacer()
                Text(highLabel)
            }
            .font(.caption2.weight(.semibold))
            .foregroundStyle(MicrofitTheme.muted)
        }
    }
}

struct BrandMark: View {
    var size: CGFloat = 42

    var body: some View {
        Image(systemName: "waveform.path.ecg")
            .font(.system(size: size * 0.46, weight: .black, design: .rounded))
            .foregroundStyle(MicrofitTheme.background)
            .frame(width: size, height: size)
            .background(MicrofitTheme.accentGradient, in: RoundedRectangle(cornerRadius: size * 0.29, style: .continuous))
            .accessibilityHidden(true)
    }
}
