import SwiftUI

/// Capsule buttons used across Doji: solid black, soft gray, outlined and white (on dark).
struct PillButtonStyle: ButtonStyle {
    enum Kind { case primary, secondary, outline, light }

    var kind: Kind = .primary
    var height: CGFloat = 50
    var font: Font = .doji(17)
    var expand = true
    var minWidth: CGFloat? = nil

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(font)
            .lineLimit(1)
            .padding(.horizontal, 22)
            .frame(minWidth: minWidth, maxWidth: expand ? .infinity : nil)
            .frame(height: height)
            .foregroundStyle(foreground)
            .background(background, in: Capsule())
            .overlay {
                if kind == .outline { Capsule().strokeBorder(Doji.faint, lineWidth: 1) }
            }
            .opacity(configuration.isPressed ? 0.75 : 1)
            .contentShape(Capsule())
    }

    private var foreground: Color {
        guard isEnabled else { return Doji.tertiary }
        switch kind {
        case .primary: return .white
        case .secondary, .outline, .light: return Doji.ink
        }
    }

    private var background: Color {
        guard isEnabled else { return Doji.fill }
        switch kind {
        case .primary: return Doji.ink
        case .secondary: return Doji.fill
        case .outline: return .white
        case .light: return .white
        }
    }
}

extension ButtonStyle where Self == PillButtonStyle {
    static var dojiPrimary: PillButtonStyle { PillButtonStyle(kind: .primary) }
    static var dojiSecondary: PillButtonStyle { PillButtonStyle(kind: .secondary) }
    static var dojiOutline: PillButtonStyle { PillButtonStyle(kind: .outline) }
    static func dojiPill(_ kind: PillButtonStyle.Kind, height: CGFloat = 50, font: Font = .doji(17), expand: Bool = true) -> PillButtonStyle {
        PillButtonStyle(kind: kind, height: height, font: font, expand: expand)
    }
}

/// The centered call-to-action used at the bottom of onboarding screens (≈ 200pt wide).
struct BottomCTA: View {
    let title: String
    var enabled = true
    let action: () -> Void

    var body: some View {
        Button(title, action: action)
            .buttonStyle(PillButtonStyle(kind: .primary, expand: false, minWidth: 160))
            .disabled(!enabled)
    }
}

/// Small black "Follow" / outlined "Following" toggle.
struct FollowButton: View {
    let username: String
    var compact = true
    @Environment(AppState.self) private var app

    var body: some View {
        let isFollowing = app.following.contains(username)
        Button(isFollowing ? "Following" : "Follow") {
            withAnimation(.snappy) { app.toggleFollow(username) }
        }
        .buttonStyle(.dojiPill(isFollowing ? .outline : .primary, height: compact ? 32 : 44,
                               font: .doji(compact ? 14 : 17), expand: !compact))
    }
}

/// Plain icon button with a generous hit area.
struct IconButton: View {
    let systemName: String
    var size: CGFloat = 19
    var weight: Font.Weight = .light
    var color: Color = Doji.ink
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size, weight: weight))
                .foregroundStyle(color)
                .frame(width: 40, height: 40)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct BackButton: View {
    var color: Color = Doji.ink
    var systemName = "chevron.left"
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        IconButton(systemName: systemName, size: 18, weight: .regular, color: color) { dismiss() }
    }
}
