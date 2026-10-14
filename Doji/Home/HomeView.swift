import SwiftUI

/// Home: For You · Following · Shop.
struct HomeView: View {
    enum Feed: String, CaseIterable { case forYou = "For You", following = "Following", shop = "Shop" }

    @State private var feed: Feed = .forYou
    @State private var seen: Set<Feed> = [.forYou]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 28) {
                ForEach(Feed.allCases, id: \.self) { f in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { feed = f }
                    } label: {
                        HStack(spacing: 6) {
                            Text(f.rawValue)
                                .font(.doji(19))
                                .foregroundStyle(feed == f ? Doji.ink : Doji.tertiary)
                            if f != .forYou && !seen.contains(f) { RedDot() }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(height: 50)

            TabView(selection: $feed) {
                ForYouFeed().tag(Feed.forYou)
                FollowingFeed().tag(Feed.following)
                ShopFeed().tag(Feed.shop)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .onChange(of: feed) { _, f in seen.insert(f) }
    }
}

// MARK: - Look grid

/// Two-column grid of full-length looks with "creator in Brand and Brand · age" captions.
struct LookGrid: View {
    let looks: [Look]
    var columns = 2
    var showsCaption = true
    var captionOverride: ((Look) -> String)? = nil

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: columns), spacing: 18) {
            ForEach(looks) { look in
                NavigationLink(value: Route.look(look.id)) {
                    LookCard(look: look, showsCaption: showsCaption, captionOverride: captionOverride?(look), columns: columns)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
    }
}

struct LookCard: View {
    let look: Look
    var showsCaption = true
    var captionOverride: String? = nil
    var columns = 2

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AssetImage(name: look.image, kind: .look)
                .aspectRatio(columns == 2 ? 0.42 : 0.5, contentMode: .fit)
                .frame(maxWidth: .infinity)
            if let captionOverride {
                Text(captionOverride).font(.doji(13)).frame(maxWidth: .infinity)
            } else if showsCaption {
                HStack(alignment: .top, spacing: 8) {
                    Avatar(name: "avatar_\(look.creatorID)", size: 22)
                    (Text(look.creatorID).fontWeight(.semibold)
                     + Text(" in \(MockData.brandLine(for: look)) ")
                     + Text(look.age).foregroundColor(Doji.secondary))
                        .font(.doji(13))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 6)
            }
        }
        .foregroundStyle(Doji.ink)
        .contentShape(Rectangle())
    }
}

// MARK: - Feeds

private struct ForYouFeed: View {
    var body: some View {
        ScrollView {
            LookGrid(looks: MockData.looks).padding(.top, 8).padding(.bottom, 80)
        }
        .scrollIndicators(.hidden)
    }
}

private struct FollowingFeed: View {
    @Environment(AppState.self) private var app
    @Environment(Navigator.self) private var nav

    var body: some View {
        if app.contactsConnected || !app.following.isEmpty {
            ScrollView {
                let followed = MockData.looks.filter { app.following.contains($0.creatorID) }
                LookGrid(looks: followed.isEmpty ? Array(MockData.looks.reversed()) : followed)
                    .padding(.top, 8).padding(.bottom, 80)
            }
            .scrollIndicators(.hidden)
        } else {
            VStack(spacing: 0) {
                Spacer(minLength: 20)
                AssetImage(name: "following_empty", kind: .group)
                    .frame(height: 260)
                    .mask(LinearGradient(stops: [.init(color: .black, location: 0.7), .init(color: .clear, location: 1)],
                                         startPoint: .top, endPoint: .bottom))
                Text("Find All Your Friends").font(.doji(26)).padding(.top, 10)
                Text("See what they're wearing\nand try on their looks")
                    .font(.doji(17))
                    .foregroundStyle(Doji.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 6)
                BottomCTA(title: "Connect Contacts") { nav.push(.contactsPrimer) }
                    .padding(.top, 24)
                Spacer(minLength: 80)
            }
            .foregroundStyle(Doji.ink)
        }
    }
}

private struct ShopFeed: View {
    @Environment(AppState.self) private var app
    @Environment(Navigator.self) private var nav

    var body: some View {
        ScrollView {
            ProductGrid(products: MockData.products) { product in
                app.toggleFavorite(product) { nav.push(.favorites) }
            }
            .padding(.top, 8)
            .padding(.bottom, 80)
        }
        .scrollIndicators(.hidden)
    }
}

// MARK: - Product grid

struct ProductGrid: View {
    let products: [Product]
    var onHeart: ((Product) -> Void)? = nil

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 26) {
            ForEach(products) { p in
                NavigationLink(value: Route.product(p.id)) {
                    ProductCard(product: p, onHeart: onHeart)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
    }
}

struct ProductCard: View {
    let product: Product
    var onHeart: ((Product) -> Void)? = nil
    @Environment(AppState.self) private var app

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            AssetImage(name: product.image, kind: .product)
                .aspectRatio(0.9, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 10)
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(product.brand).font(.doji(14, .semibold))
                    Text(product.name).font(.doji(14)).lineLimit(1)
                    (Text(product.priceText) + Text(" · \(product.age)").foregroundColor(Doji.secondary))
                        .font(.doji(14))
                }
                Spacer(minLength: 4)
                if let onHeart {
                    let fav = app.favoriteProductIDs.contains(product.id)
                    Button { onHeart(product) } label: {
                        Image(systemName: fav ? "heart.fill" : "heart")
                            .font(.system(size: 14, weight: .light))
                            .frame(width: 28, height: 22, alignment: .topTrailing)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .foregroundStyle(Doji.ink)
        .contentShape(Rectangle())
    }
}
