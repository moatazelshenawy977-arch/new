import SwiftUI
import SafariServices

/// Product page: image pager, brand/name/price, Buy ↗ / Try On, "More to Explore".
struct ProductDetailView: View {
    let productID: String

    @Environment(AppState.self) private var app
    @Environment(Navigator.self) private var nav
    @State private var page = 0
    @State private var showStore = false
    @State private var scrolled = false

    private var product: Product { MockData.product(productID) ?? MockData.products[0] }

    var body: some View {
        let product = self.product
        let fav = app.favoriteProductIDs.contains(product.id)
        VStack(spacing: 0) {
            NavHeader()
                .overlay {
                    // Collapsed product thumbnail once "More to Explore" reaches the top.
                    if scrolled {
                        AssetImage(name: product.image, kind: .product)
                            .frame(width: 30, height: 30)
                            .padding(3)
                            .background(.white, in: RoundedRectangle(cornerRadius: 6))
                            .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(Doji.hairline))
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: scrolled)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    TabView(selection: $page) {
                        ForEach(0..<5, id: \.self) { i in
                            AssetImage(name: i == 0 ? product.image : "\(product.image)_\(i + 1)", kind: i == 1 ? .look : .product)
                                .background(Doji.placeholder)
                                .padding(.horizontal, 38)
                                .tag(i)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 400)

                    HStack(spacing: 6) {
                        ForEach(0..<5, id: \.self) { i in
                            Circle().fill(i == page ? Doji.secondary : Doji.faint).frame(width: 5, height: 5)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)

                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(product.brand).font(.doji(16, .semibold))
                            Text(product.name).font(.doji(16))
                            Text(product.priceText).font(.doji(16))
                        }
                        Spacer()
                        IconButton(systemName: fav ? "heart.fill" : "heart", size: 20) {
                            app.toggleFavorite(product) { nav.push(.favorites) }
                        }
                        ShareLink(item: URL(string: "\(AppLinks.productStore)/\(product.id)")!) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 19, weight: .light))
                                .frame(width: 40, height: 40)
                        }
                    }
                    .padding(.horizontal, Doji.gutter)

                    HStack(spacing: 10) {
                        Button { showStore = true } label: {
                            HStack(spacing: 4) { Text("Buy"); Image(systemName: "arrow.up.right").font(.system(size: 13)) }
                        }
                        .buttonStyle(.dojiSecondary)
                        Button("Try On") { app.tryOn(productIDs: [product.id]) }
                            .buttonStyle(.dojiPrimary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 18)

                    Text("More to Explore")
                        .font(.doji(22))
                        .padding(.horizontal, Doji.gutter)
                        .padding(.top, 30)
                        .padding(.bottom, 14)
                        .background(GeometryReader { geo in
                            Color.clear.preference(key: ScrollOffsetKey.self, value: geo.frame(in: .named("productScroll")).minY)
                        })

                    MoreToExploreGrid(product: product)
                        .padding(.bottom, 90)
                }
            }
            .coordinateSpace(.named("productScroll"))
            .onPreferenceChange(ScrollOffsetKey.self) { y in Task { @MainActor in scrolled = y < 10 } }
            .scrollIndicators(.hidden)
        }
        .foregroundStyle(Doji.ink)
        .onAppear {
            app.recentlyViewedIDs.removeAll { $0 == product.id }
            app.recentlyViewedIDs.insert(product.id, at: 0)
        }
        .sheet(isPresented: $showStore) {
            SafariView(url: URL(string: "\(AppLinks.productStore)/\(product.id)")!).ignoresSafeArea()
        }
    }
}

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = .greatestFiniteMagnitude
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

/// Looks featuring the product next to similar products, in a staggered two-column layout.
private struct MoreToExploreGrid: View {
    let product: Product

    private var items: [Route] {
        let looks = MockData.looks.filter { $0.productIDs.contains(product.id) } + MockData.looks.prefix(3)
        let products = MockData.products.filter { $0.category == product.category && $0.id != product.id }
        var out: [Route] = []
        var seen = Set<String>()
        for (i, look) in looks.enumerated() where seen.insert(look.id).inserted {
            out.append(.look(look.id))
            if i < products.count { out.append(.product(products[i].id)) }
        }
        return out
    }

    var body: some View {
        let routes = items
        HStack(alignment: .top, spacing: 10) {
            ForEach(0..<2, id: \.self) { col in
                LazyVStack(spacing: 18) {
                    ForEach(Array(routes.enumerated()).filter { $0.offset % 2 == col }, id: \.offset) { _, route in
                        ExploreTile(route: route)
                    }
                }
            }
        }
        .padding(.horizontal, 10)
    }
}

/// A look (with creator caption) or a product (with "Brand Name" caption) tile.
struct ExploreTile: View {
    let route: Route

    var body: some View {
        NavigationLink(value: route) {
            switch route {
            case .look(let id):
                if let look = MockData.look(id) { LookCard(look: look) }
            case .product(let id):
                if let p = MockData.product(id) {
                    VStack(alignment: .leading, spacing: 8) {
                        AssetImage(name: p.image, kind: .product)
                            .aspectRatio(0.85, contentMode: .fit)
                        (Text(p.brand).fontWeight(.semibold) + Text(" \(p.name)"))
                            .font(.doji(13))
                            .lineLimit(2)
                    }
                    .foregroundStyle(Doji.ink)
                }
            default:
                EmptyView()
            }
        }
        .buttonStyle(.plain)
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController { SFSafariViewController(url: url) }
    func updateUIViewController(_ controller: SFSafariViewController, context: Context) {}
}
