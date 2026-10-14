import SwiftUI

/// Full-screen look: action rail, "Tried on by", "In the Look" sheet and Try On.
struct LookDetailView: View {
    let lookID: String

    @Environment(AppState.self) private var app
    @Environment(Navigator.self) private var nav
    @State private var showItems = false
    @State private var showTriedOnBy = false
    @State private var showShare = false
    @State private var remixProducts: [String]?

    private var look: Look { MockData.look(lookID) ?? MockData.looks[0] }

    var body: some View {
        let look = self.look
        ZStack {
            AssetImage(name: look.image, kind: .look)
                .padding(.top, 40)
                .padding(.bottom, 90)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { showItems = true }
                .gesture(DragGesture(minimumDistance: 30).onEnded { v in
                    if v.translation.height < -40 { showItems = true }
                })

            VStack(spacing: 0) {
                HStack {
                    BackButton()
                    Spacer()
                    Wordmark().padding(.trailing, 14)
                }
                .padding(.horizontal, 6)
                .frame(height: 50)

                Spacer()

                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Button { nav.push(.creator(look.creatorID)) } label: {
                            (Text(look.creatorID).fontWeight(.semibold) + Text(" \(look.age)").foregroundStyle(Doji.secondary))
                        }
                        Text((look.styledBy.map { "Styled by \($0) in " } ?? "In ") + MockData.brandList(of: look))
                            .lineLimit(1)
                        if !look.triedOnBy.isEmpty {
                            Button { showTriedOnBy = true } label: {
                                HStack(spacing: 6) {
                                    StackedAvatars(names: look.triedOnBy, size: 18)
                                    (Text("Tried on by ") + Text(look.triedOnBy[0]).fontWeight(.semibold)
                                        + Text(look.triedOnBy.count > 1 ? " +\(look.triedOnBy.count - 1)" : ""))
                                }
                            }
                        }
                    }
                    .font(.doji(15))
                    .buttonStyle(.plain)

                    Spacer(minLength: 12)

                    Button("Try On") { app.tryOn(productIDs: look.productIDs, sourceLookID: look.id, styledBy: look.creatorID) }
                        .buttonStyle(.dojiPill(.primary, height: 46, expand: false))
                }
                .padding(.horizontal, Doji.gutter)
                .padding(.bottom, 12)
            }

            ActionRail(look: look,
                       onRemix: { remixProducts = look.productIDs },
                       onShare: { showShare = true })
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 10)
                .offset(y: 60)
        }
        .foregroundStyle(Doji.ink)
        .hidesTabBar()
        .sheet(isPresented: $showItems) {
            InTheLookSheet(look: look) {
                showItems = false
                remixProducts = look.productIDs
            }
            .presentationDetents([.height(340)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
        }
        .sheet(isPresented: $showTriedOnBy) {
            TriedOnBySheet(usernames: look.triedOnBy) { username in
                showTriedOnBy = false
                nav.push(.creator(username))
            }
            .presentationDetents([.fraction(0.85)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
        }
        .fullScreenCover(isPresented: $showShare) {
            ShareLookView(look: look).toastHost().environment(app)
        }
        .fullScreenCover(item: Binding(get: { remixProducts.map(RemixSeed.init) }, set: { remixProducts = $0?.productIDs }),
                         onDismiss: app.openNewLooksIfRequested) { seed in
            CreateLookView(initialProductIDs: seed.productIDs).toastHost().environment(app)
        }
    }
}

struct RemixSeed: Identifiable {
    let productIDs: [String]
    var id: String { productIDs.joined(separator: ",") }
}

extension MockData {
    static func brandList(of look: Look) -> String {
        var seen: [String] = []
        for p in products(of: look) where !seen.contains(p.brand) { seen.append(p.brand) }
        return seen.joined(separator: ", ")
    }
}

/// Vertical rail: creator (+follow), like, remix, share, more.
private struct ActionRail: View {
    let look: Look
    let onRemix: () -> Void
    let onShare: () -> Void

    @Environment(AppState.self) private var app
    @Environment(Navigator.self) private var nav

    var body: some View {
        let liked = app.likedLookIDs.contains(look.id)
        let following = app.following.contains(look.creatorID)
        VStack(spacing: 14) {
            Button { nav.push(.creator(look.creatorID)) } label: {
                Avatar(name: "avatar_\(look.creatorID)", size: 40)
                    .overlay(alignment: .bottom) {
                        if !following {
                            Button { withAnimation { app.toggleFollow(look.creatorID) } } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 18, height: 18)
                                    .background(Doji.ink, in: Circle())
                                    .overlay(Circle().stroke(.white, lineWidth: 1.5))
                            }
                            .offset(y: 8)
                        }
                    }
            }
            .padding(.bottom, 8)
            IconButton(systemName: liked ? "heart.fill" : "heart", size: 21,
                       color: liked ? Doji.red : Doji.ink) {
                withAnimation(.snappy) {
                    if liked { app.likedLookIDs.remove(look.id) } else { app.likedLookIDs.insert(look.id) }
                }
            }
            IconButton(systemName: "arrow.2.squarepath", size: 19, action: onRemix)
            IconButton(systemName: "square.and.arrow.up", size: 19, action: onShare)
            Menu {
                Button("View Profile") { nav.push(.creator(look.creatorID)) }
                Button(following ? "Unfollow" : "Follow") { app.toggleFollow(look.creatorID) }
            } label: {
                Image(systemName: "ellipsis").font(.system(size: 17)).frame(width: 40, height: 40)
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(Doji.ink)
    }
}

// MARK: - Sheets

/// "In the Look": products in the outfit + Remix.
struct InTheLookSheet: View {
    let look: Look
    let onRemix: () -> Void
    @Environment(AppState.self) private var app

    var body: some View {
        VStack(spacing: 0) {
            SheetTitle(title: "In the Look")
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 14) {
                    ForEach(MockData.products(of: look)) { p in
                        ProductCard(product: p) { app.toggleFavorite($0) }
                            .frame(width: 130)
                    }
                }
                .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)
            Spacer(minLength: 10)
            Button(action: onRemix) {
                Label("Remix", systemImage: "arrow.2.squarepath")
            }
            .buttonStyle(.dojiPrimary)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .foregroundStyle(Doji.ink)
    }
}

/// "Tried on by" list with Follow buttons.
struct TriedOnBySheet: View {
    let usernames: [String]
    let onOpen: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            SheetTitle(title: "Tried on by")
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(usernames, id: \.self) { name in
                        let creator = MockData.creator(name)
                        HStack(spacing: 12) {
                            Button { onOpen(name) } label: {
                                HStack(spacing: 12) {
                                    Avatar(name: creator.avatar, size: 52)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(name).font(.doji(16, .semibold))
                                        if !creator.bio.isEmpty {
                                            Text(creator.bio).font(.doji(15)).foregroundStyle(Doji.secondary).lineLimit(1)
                                        }
                                    }
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            FollowButton(username: name)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                    }
                }
            }
        }
        .foregroundStyle(Doji.ink)
    }
}
