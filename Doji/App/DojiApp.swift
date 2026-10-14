import SwiftUI

@main
struct DojiApp: App {
    @State private var app = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(app)
                .preferredColorScheme(.light)
                .tint(Doji.ink)
        }
    }
}

struct RootView: View {
    @Environment(AppState.self) private var app

    var body: some View {
        Group {
            if app.isOnboarded {
                MainTabView()
            } else {
                OnboardingFlow()
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: app.isOnboarded)
        .toastHost()
    }
}
