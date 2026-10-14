import SwiftUI

/// Shows the image named `name` from the asset catalog, or a neutral placeholder when the
/// asset has not been supplied yet. No reference screenshots are bundled with the app.
struct AssetImage: View {
    enum Kind { case look, product, avatar, face, collection, group }

    let name: String
    var kind: Kind = .product
    var contentMode: ContentMode = .fit

    var body: some View {
        if let ui = UIImage(named: name) {
            Image(uiImage: ui)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } else {
            Placeholder(kind: kind, seed: name)
        }
    }
}

private struct Placeholder: View {
    let kind: AssetImage.Kind
    let seed: String

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            ZStack {
                background
                switch kind {
                case .look, .face:
                    Image(systemName: kind == .look ? "figure.stand" : "person.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(tint.opacity(0.55))
                        .padding(.vertical, geo.size.height * (kind == .look ? 0.06 : 0.18))
                case .group:
                    HStack(alignment: .bottom, spacing: -side * 0.08) {
                        ForEach(0..<3) { _ in
                            Image(systemName: "figure.stand").resizable().scaledToFit()
                        }
                    }
                    .foregroundStyle(tint.opacity(0.5))
                    .padding(geo.size.height * 0.08)
                case .avatar:
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(side * 0.24)
                        .offset(y: side * 0.08)
                case .collection:
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: side * 0.2, weight: .ultraLight))
                        .foregroundStyle(tint.opacity(0.5))
                case .product:
                    Image(systemName: symbol)
                        .font(.system(size: side * 0.34, weight: .ultraLight))
                        .foregroundStyle(tint.opacity(0.55))
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder private var background: some View {
        switch kind {
        case .avatar: hue.opacity(0.9)
        case .product: Color.white
        default: LinearGradient(colors: [Doji.placeholder, hue.opacity(0.35)], startPoint: .top, endPoint: .bottom)
        }
    }

    /// Product placeholders pick a symbol from the asset name's category hint.
    private var symbol: String {
        if let id = seed.split(separator: "_").last, let p = MockData.product(String(id)) { return p.category.symbol }
        return "tag"
    }

    private var tint: Color { Color(white: 0.55) }

    /// Stable, soft neutral tint per asset so neighbouring placeholders are distinguishable.
    private var hue: Color {
        let palette: [Color] = [
            Color(red: 0.83, green: 0.81, blue: 0.80), Color(red: 0.80, green: 0.81, blue: 0.83),
            Color(red: 0.84, green: 0.82, blue: 0.84), Color(red: 0.81, green: 0.83, blue: 0.81),
            Color(red: 0.86, green: 0.84, blue: 0.81),
        ]
        let sum = seed.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return palette[sum % palette.count]
    }
}

/// Circular avatar; uses the signed-in user's picked photo when `image` is provided.
struct Avatar: View {
    let name: String
    var size: CGFloat = 28
    var image: UIImage? = nil

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image).resizable().scaledToFill()
            } else {
                AssetImage(name: name, kind: .avatar, contentMode: .fill)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

/// Avatar of the signed-in user.
struct MeAvatar: View {
    var size: CGFloat = 28
    @Environment(AppState.self) private var app

    var body: some View {
        Avatar(name: "avatar_me", size: size, image: app.profileImage)
    }
}

/// Two overlapping avatars used for "tried on by" and activity rows.
struct StackedAvatars: View {
    let names: [String]
    var size: CGFloat = 18

    var body: some View {
        HStack(spacing: -size * 0.35) {
            ForEach(Array(names.prefix(2).enumerated()), id: \.offset) { _, n in
                Avatar(name: "avatar_\(n)", size: size)
                    .overlay(Circle().stroke(.white, lineWidth: 1.5))
            }
        }
    }
}
