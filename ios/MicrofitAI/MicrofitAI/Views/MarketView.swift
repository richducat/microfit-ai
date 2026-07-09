import SwiftUI

struct MarketView: View {
    @Environment(MicrofitAppState.self) private var state

    private let proteinTarget = 100
    private let fiberTarget = 28
    private let waterTarget = 8
    private let plantTarget = 5

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                header
                dailyTargets
                quickLog
                fineTune
                nextMeal
                scopeNote
            }
            .padding(20)
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
    }

    private var header: some View {
        PremiumCard(padding: 22) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("FUEL")
                            .font(MicrofitTheme.eyebrow())
                            .tracking(1.8)
                            .foregroundStyle(MicrofitTheme.lime)
                        Text("Track what changes the next decision.")
                            .font(.system(size: 31, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 46, weight: .black))
                        .foregroundStyle(MicrofitTheme.aqua)
                }
                Text("A lightweight daily scorecard for protein, fiber, plants, and water—without turning every meal into accounting.")
                    .font(.subheadline)
                    .foregroundStyle(MicrofitTheme.secondaryText)
            }
        }
    }

    private var dailyTargets: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Today’s anchors", icon: "target", trailing: completionLabel)
            PremiumCard(padding: 18) {
                VStack(spacing: 18) {
                    nutrientProgress(
                        title: "Protein",
                        value: state.todayNutrition.proteinGrams,
                        target: proteinTarget,
                        unit: "g",
                        icon: "figure.strengthtraining.traditional",
                        tint: MicrofitTheme.lime
                    )
                    nutrientProgress(
                        title: "Fiber",
                        value: state.todayNutrition.fiberGrams,
                        target: fiberTarget,
                        unit: "g",
                        icon: "leaf.fill",
                        tint: MicrofitTheme.aqua
                    )
                    nutrientProgress(
                        title: "Water",
                        value: state.todayNutrition.waterCups,
                        target: waterTarget,
                        unit: " cups",
                        icon: "drop.fill",
                        tint: MicrofitTheme.blue
                    )
                    nutrientProgress(
                        title: "Plants",
                        value: state.todayNutrition.plants,
                        target: plantTarget,
                        unit: " servings",
                        icon: "carrot.fill",
                        tint: MicrofitTheme.gold
                    )
                }
            }
        }
    }

    private func nutrientProgress(title: String, value: Int, target: Int, unit: String, icon: String, tint: Color) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(tint)
                    .frame(width: 36, height: 36)
                    .background(tint.opacity(0.11), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                VStack(alignment: .leading, spacing: 1) {
                    Text(title).font(.subheadline.weight(.bold)).foregroundStyle(.white)
                    Text(value >= target ? "Target reached" : "\(formattedAmount(target - value, unit: unit)) to baseline")
                        .font(.caption).foregroundStyle(MicrofitTheme.muted)
                }
                Spacer()
                Text(formattedAmount(value, unit: unit))
                    .font(MicrofitTheme.metric(16))
                    .foregroundStyle(value >= target ? MicrofitTheme.lime : .white)
            }
            ProgressView(value: Double(min(value, target)), total: Double(target))
                .tint(tint)
                .scaleEffect(y: 1.35)
        }
        .accessibilityElement(children: .combine)
    }

    private var quickLog: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Quick log", icon: "plus.circle.fill")
            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 12) {
                quickButton(title: "Protein meal", detail: "+30g protein", icon: "fork.knife", tint: MicrofitTheme.lime) {
                    state.addNutrition(protein: 30, fiber: 4, plants: 1)
                }
                quickButton(title: "Protein snack", detail: "+20g protein", icon: "takeoutbag.and.cup.and.straw.fill", tint: MicrofitTheme.aqua) {
                    state.addNutrition(protein: 20, fiber: 2)
                }
                quickButton(title: "Plant-rich meal", detail: "+10g fiber", icon: "leaf.fill", tint: MicrofitTheme.gold) {
                    state.addNutrition(protein: 10, fiber: 10, plants: 3)
                }
                quickButton(title: "Water", detail: "+1 cup", icon: "drop.fill", tint: MicrofitTheme.blue) {
                    state.addNutrition(water: 1)
                }
            }
        }
    }

    private func quickButton(title: String, detail: String, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            PremiumCard(padding: 15, interactive: true) {
                VStack(alignment: .leading, spacing: 9) {
                    Image(systemName: icon)
                        .font(.title3.weight(.black))
                        .foregroundStyle(tint)
                    Text(title)
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                    Text(detail)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(MicrofitTheme.muted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }

    private var fineTune: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Fine tune", icon: "slider.horizontal.3")
            PremiumCard {
                VStack(spacing: 12) {
                    adjuster(title: "Protein", value: state.todayNutrition.proteinGrams, step: 5, unit: "g", tint: MicrofitTheme.lime) {
                        state.addNutrition(protein: $0)
                    }
                    Divider().overlay(MicrofitTheme.border)
                    adjuster(title: "Fiber", value: state.todayNutrition.fiberGrams, step: 2, unit: "g", tint: MicrofitTheme.aqua) {
                        state.addNutrition(fiber: $0)
                    }
                    Divider().overlay(MicrofitTheme.border)
                    adjuster(title: "Water", value: state.todayNutrition.waterCups, step: 1, unit: " cups", tint: MicrofitTheme.blue) {
                        state.addNutrition(water: $0)
                    }
                    Divider().overlay(MicrofitTheme.border)
                    adjuster(title: "Plants", value: state.todayNutrition.plants, step: 1, unit: " servings", tint: MicrofitTheme.gold) {
                        state.addNutrition(plants: $0)
                    }
                }
            }
        }
    }

    private func adjuster(title: String, value: Int, step: Int, unit: String, tint: Color, change: @escaping (Int) -> Void) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline.weight(.bold)).foregroundStyle(.white)
                Text(formattedAmount(value, unit: unit)).font(.caption.weight(.bold)).foregroundStyle(tint)
            }
            Spacer()
            Button { change(-step) } label: {
                Image(systemName: "minus").frame(width: 44, height: 44)
            }
            .disabled(value == 0)
            .opacity(value == 0 ? 0.35 : 1)
            .accessibilityLabel("Subtract \(step) from \(title)")
            Button { change(step) } label: {
                Image(systemName: "plus").frame(width: 44, height: 44)
            }
            .accessibilityLabel("Add \(step) to \(title)")
        }
        .font(.headline.weight(.black))
        .foregroundStyle(.white)
        .buttonStyle(.bordered)
        .tint(MicrofitTheme.elevated)
    }

    private var nextMeal: some View {
        PremiumCard(padding: 20) {
            VStack(alignment: .leading, spacing: 11) {
                Text("NEXT MEAL")
                    .font(MicrofitTheme.eyebrow())
                    .tracking(1.2)
                    .foregroundStyle(MicrofitTheme.lime)
                Text(nextMealTitle)
                    .font(.title3.weight(.black))
                    .foregroundStyle(.white)
                Text(nextMealDetail)
                    .font(.subheadline)
                    .foregroundStyle(MicrofitTheme.secondaryText)
                MicrofitButton(title: "Ask Coach for an Option", icon: "bubble.left.fill", tint: MicrofitTheme.aqua) {
                    state.selectedTab = .coach
                }
            }
        }
    }

    private var scopeNote: some View {
        Label("Targets are general wellness baselines, not medical or dietetic prescriptions. Adjust with a qualified professional when needed.", systemImage: "info.circle.fill")
            .font(.caption)
            .foregroundStyle(MicrofitTheme.muted)
            .padding(.horizontal, 4)
    }

    private var completionLabel: String {
        let completed = [
            state.todayNutrition.proteinGrams >= proteinTarget,
            state.todayNutrition.fiberGrams >= fiberTarget,
            state.todayNutrition.waterCups >= waterTarget,
            state.todayNutrition.plants >= plantTarget
        ].filter { $0 }.count
        return "\(completed)/4 COMPLETE"
    }

    private func formattedAmount(_ value: Int, unit: String) -> String {
        switch unit {
        case " cups": return "\(value) \(value == 1 ? "cup" : "cups")"
        case " servings": return "\(value) \(value == 1 ? "serving" : "servings")"
        default: return "\(value)\(unit)"
        }
    }

    private var nextMealTitle: String {
        if state.todayNutrition.proteinGrams < 60 { return "Lead with protein" }
        if state.todayNutrition.fiberGrams < 15 { return "Add color and crunch" }
        if state.todayNutrition.waterCups < 5 { return "Drink before deciding" }
        return "Keep the pattern simple"
    }

    private var nextMealDetail: String {
        if state.todayNutrition.proteinGrams < 60 { return "Choose one palm-sized protein, one high-fiber plant, and water. That covers the anchors without perfection." }
        if state.todayNutrition.fiberGrams < 15 { return "Add beans, berries, vegetables, or a whole grain to the next meal." }
        if state.todayNutrition.waterCups < 5 { return "Have one or two cups of water now, then build the meal around hunger—not thirst." }
        return "Repeat a meal that worked: protein, a plant, a satisfying carb, and enough food to support training."
    }
}
