import SwiftUI

/// "Share Look": swipeable share cards + Stories / Share / Link / Save.
struct ShareLookView: View {
    let look: Look
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss
    @State private var page = 0

    private var link: URL { URL(string: "https://example.com/look/\(look.id)")! }

    var body: some View {
        VStack(spacing: 0) {
            NavHeader(title: "Share Look", leadingIcon: "chevron.down")

            TabView(selection: $page) {
                ForEach(0..<4, id: \.self) { i in
                    ShareCard(look: look, style: i).padding(.horizontal, 26).tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            HStack(spacing: 6) {
                ForEach(0..<4, id: \.self) { i in
                    Circle().fill(i == page ? Doji.ink : Doji.faint).frame(width: 5, height: 5)
                }
            }
            .padding(.vertical, 14)

            HStack(spacing: 22) {
                ShareLink(item: link) {
                    action("Stories") {
                        Image(systemName: "camera")
                            .font(.system(size: 22))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(LinearGradient(colors: [.purple, .pink, .orange], startPoint: .topTrailing, endPoint: .bottomLeading), in: Circle())
                    }
                }
                ShareLink(item: link) { action("Share") { round("square.and.arrow.up") } }
                Button {
                    UIPasteboard.general.url = link
                    app.showToast(Toast(text: "Look link copied"))
                } label: { action("Link") { round("link") } }
                Button {
                    if let image = ImageRenderer(content: ShareCard(look: look, style: page).frame(width: 330, height: 520)).uiImage {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        app.showToast(Toast(text: "Saved to Photos"))
                    }
                } label: { action("Save") { round("arrow.down.to.line") } }
            }
            .buttonStyle(.plain)
            .padding(.bottom, 16)
        }
        .foregroundStyle(Doji.ink)
        .background(Color.white.ignoresSafeArea())
    }

    private func action<Icon: View>(_ title: String, @ViewBuilder icon: () -> Icon) -> some View {
        VStack(spacing: 8) {
            icon()
            Text(title).font(.doji(14))
        }
    }

    private func round(_ symbol: String) -> some View {
        Image(systemName: symbol)
            .font(.system(size: 20, weight: .light))
            .frame(width: 56, height: 56)
            .background(Doji.fill, in: Circle())
    }
}

/// Bordered card with item labels, creator name, the look and the Doji wordmark.
private struct ShareCard: View {
    let look: Look
    let style: Int

    var body: some View {
        let products = MockData.products(of: look)
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                ForEach(products.prefix(2)) { p in
                    VStack(alignment: .leading, spacing: 1) {
                        Text(p.category.rawValue.uppercased()).font(.system(size: 8, weight: .medium))
                        Text(p.brand).font(.doji(12))
                    }
                    if p.id != products.prefix(2).last?.id { Spacer() }
                }
            }
            Text(look.creatorID).font(.doji(20, .semibold))
            AssetImage(name: look.image, kind: .look)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .bottomTrailing) { Wordmark(size: 18) }
        }
        .padding(12)
        .background(style % 2 == 0 ? Color.white : Doji.placeholder)
        .overlay(Rectangle().strokeBorder(Doji.hairline, lineWidth: 1))
        .foregroundStyle(Doji.ink)
    }
}
