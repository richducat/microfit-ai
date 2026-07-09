import SwiftUI

@main
struct MicrofitAIApp: App {
    @State private var state = MicrofitAppState()

    var body: some Scene {
        WindowGroup {
            RootShellView()
                .environment(state)
                .preferredColorScheme(.dark)
                .tint(MicrofitTheme.aqua)
        }
    }
}
