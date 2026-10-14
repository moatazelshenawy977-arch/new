import SwiftUI
import Observation

enum OnboardingStep: Hashable {
    case phone, code, email
    case likeness, selfies, camera, notifications
    case brands, username, profilePic, findFriends
    case contactsPrimer, inviteFriends
}

@Observable
final class OnboardingRouter {
    var path: [OnboardingStep] = []
    func go(_ step: OnboardingStep) { path.append(step) }
}

/// Sign-up → likeness capture → taste → profile → friends, as in Doji's onboarding.
struct OnboardingFlow: View {
    @State private var router = OnboardingRouter()
    @Environment(AppState.self) private var app

    var body: some View {
        NavigationStack(path: $router.path) {
            WelcomeView { router.go(.phone) }
                .navigationDestination(for: OnboardingStep.self) { step in
                    destination(step).dojiChrome()
                }
        }
        .environment(router)
    }

    @ViewBuilder private func destination(_ step: OnboardingStep) -> some View {
        switch step {
        case .phone: PhoneNumberView { router.go(.code) }
        case .code: VerifyCodeView { router.go(.email) }
        case .email: EmailView { router.go(.likeness) }
        case .likeness: CreateLikenessIntroView { router.go(.selfies) }
        case .selfies: TakeSelfiesView { router.go(.camera) }
        case .camera: SelfieCameraView { router.go(.notifications) }
        case .notifications: LikenessNotificationsView { router.go(.brands) }
        case .brands: SelectBrandsView(progress: 0.82) { router.go(.username) }
        case .username: CreateUsernameView { router.go(.profilePic) }
        case .profilePic: ProfilePicView { router.go(.findFriends) }
        case .findFriends:
            FindFriendsIntroView(onFind: { router.go(.contactsPrimer) }, onSkip: finish)
        case .contactsPrimer: ContactsPrimerView { router.go(.inviteFriends) }
        case .inviteFriends: InviteFriendsView(onDone: finish)
        }
    }

    private func finish() { app.isOnboarded = true }
}

/// Progress bar header used from "Create your likeness" through "Find all your friends".
struct ProgressHeader: View {
    enum Accessory { case none, help, skip(() -> Void), likenessDot }

    var progress: Double
    var showsBack = true
    var accessory: Accessory = .none

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HStack(spacing: 0) {
            Group {
                if showsBack { IconButton(systemName: "chevron.left", size: 18, weight: .regular) { dismiss() } }
                else { Color.clear }
            }
            .frame(width: 52, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Doji.faint)
                    Capsule().fill(Doji.ink).frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 2)
            .padding(.horizontal, 6)
            .animation(.easeInOut, value: progress)

            Group {
                switch accessory {
                case .none: Color.clear
                case .help:
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 19, weight: .ultraLight))
                        .foregroundStyle(Doji.secondary)
                case .skip(let action):
                    Button("Skip", action: action).font(.doji(16)).foregroundStyle(Doji.ink)
                case .likenessDot:
                    // Live thumbnail of the likeness being generated.
                    Circle().fill(Doji.ink).frame(width: 22, height: 22)
                }
            }
            .frame(width: 52, alignment: .trailing)
        }
        .padding(.horizontal, 10)
        .frame(height: 50)
    }
}

/// Dash-style page indicator from the welcome carousel and tips sheet.
struct DashPageIndicator: View {
    let count: Int
    let index: Int
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { i in
                Capsule()
                    .fill(i == index ? Doji.ink : Doji.faint)
                    .frame(width: 16, height: 2)
            }
        }
    }
}
