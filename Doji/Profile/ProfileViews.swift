import SwiftUI
import StoreKit

// MARK: - My profile

struct ProfileView: View {
    enum Pane { case publicItems, privateItems }

    @Environment(AppState.self) private var app
    @Environment(Navigator.self) private var nav
    @State private var visibility: Pane = .publicItems
    @State private var editing: EditTarget?

    enum EditTarget: String, Identifiable { case profile, likeness; var id: String { rawValue } }

    private var myLooks: [Look] {
        let saved = app.savedLooks.compactMap { $0.sourceLookID }.compactMap(MockData.look)
        return saved + MockData.looks.filter { $0.creatorID == "mira.k" }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                Spacer()
                ShareLink(item: URL(string: "https://example.com/u/\(app.username)")!) {
                    Image(systemName: "square.and.arrow.up").font(.system(size: 18, weight: .light)).frame(width: 40, height: 40)
                }
                IconButton(systemName: "gearshape", size: 19) { nav.push(.settings) }
            }
            .padding(.horizontal, 8)
            .frame(height: 50)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 16) {
                        MeAvatar(size: 76)
                        VStack(alignment: .leading, spacing: 6) {
                            Text(app.username).font(.doji(24))
                            HStack(spacing: 20) {
                                Text("\(app.following.count) Following")
                                Text("\(app.savedLooks.count + 8) Try Ons")
                            }
                            .font(.doji(16))
                        }
                    }
                    .padding(.horizontal, Doji.gutter)

                    HStack(spacing: 10) {
                        Button("Edit Profile") { editing = .profile }
                            .buttonStyle(.dojiPill(.outline, height: 40, font: .doji(16)))
                        Button("Update Likeness") { editing = .likeness }
                            .buttonStyle(.dojiPill(.outline, height: 40, font: .doji(16)))
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 22)

                    HStack(spacing: 0) {
                        visibilityTab("Public", symbol: "globe", value: .publicItems)
                        visibilityTab("Private", symbol: "lock", value: .privateItems)
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 18)
                    Rectangle().fill(Doji.hairline).frame(height: 0.5)

                    if visibility == .publicItems {
                        SectionHeader(title: "Collections") { nav.push(.collection("fav")) }
                            .padding(.top, 22)
                        ScrollView(.horizontal) {
                            HStack(spacing: 12) {
                                ForEach(app.userCollections.filter { !$0.isPrivate }) { c in
                                    NavigationLink(value: Route.collection(c.id)) { UserCollectionCard(collection: c) }
                                        .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .scrollIndicators(.hidden)
                        .padding(.top, 12)

                        Text("Looks").font(.doji(20)).padding(.horizontal, Doji.gutter).padding(.top, 28).padding(.bottom, 12)
                        LookGrid(looks: myLooks, columns: 3, showsCaption: false)
                    } else {
                        SectionHeader(title: "Collections") { nav.push(.favorites) }
                            .padding(.top, 22)
                        NavigationLink(value: Route.favorites) { FavoritesCard() }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                    }
                }
                .padding(.bottom, 90)
            }
            .scrollIndicators(.hidden)
        }
        .foregroundStyle(Doji.ink)
        .fullScreenCover(item: $editing) { target in
            EditFlow(target: target).environment(app)
        }
    }

    private func visibilityTab(_ title: String, symbol: String, value: Pane) -> some View {
        let on = visibility == value
        return Button { withAnimation(.easeInOut(duration: 0.2)) { visibility = value } } label: {
            VStack(spacing: 10) {
                Label(title, systemImage: symbol)
                    .font(.doji(16))
                    .foregroundStyle(on ? Doji.ink : Doji.tertiary)
                Rectangle().fill(on ? Doji.ink : .clear).frame(height: 1.5)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// Edit Profile reuses "Set your profile pic"; Update Likeness reruns the selfie capture.
struct EditFlow: View {
    let target: ProfileView.EditTarget
    @Environment(\.dismiss) private var dismiss
    @State private var path: [OnboardingStep] = []

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                switch target {
                case .profile:
                    ProfilePicView(isEditing: true) { dismiss() }
                case .likeness:
                    // The header's back button dismisses this cover.
                    CreateLikenessIntroView { path.append(.selfies) }
                }
            }
            .dojiChrome()
            .navigationDestination(for: OnboardingStep.self) { step in
                Group {
                    switch step {
                    case .selfies: TakeSelfiesView { path.append(.camera) }
                    case .camera: SelfieCameraView { dismiss() }
                    default: EmptyView()
                    }
                }
                .dojiChrome()
            }
        }
    }
}

struct UserCollectionCard: View {
    let collection: LookCollection

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            AssetImage(name: collection.lookIDs.first.map { "look_\($0)" } ?? collection.cover, kind: .look)
                .padding(10)
                .frame(width: 160, height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Doji.hairline))
                .padding(.bottom, 6)
            Text(collection.title).font(.doji(17))
            Text("\(collection.lookIDs.count) Look\(collection.lookIDs.count == 1 ? "" : "s")")
                .font(.doji(14)).foregroundStyle(Doji.secondary)
        }
        .foregroundStyle(Doji.ink)
    }
}

private struct FavoritesCard: View {
    @Environment(AppState.self) private var app

    var body: some View {
        let ids = Array(app.favoriteProductIDs.sorted().prefix(3))
        VStack(alignment: .leading, spacing: 3) {
            VStack(spacing: 0) {
                cell(ids.indices.contains(0) ? ids[0] : nil).frame(height: 80)
                Rectangle().fill(Doji.hairline).frame(height: 0.5)
                HStack(spacing: 0) {
                    cell(ids.indices.contains(1) ? ids[1] : nil)
                    Rectangle().fill(Doji.hairline).frame(width: 0.5)
                    cell(ids.indices.contains(2) ? ids[2] : nil)
                }
                .frame(height: 80)
            }
            .frame(width: 160)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Doji.hairline))
            .padding(.bottom, 6)
            Text("Favorites").font(.doji(17))
            Label("\(app.favoriteProductIDs.count) Products", systemImage: "lock.fill")
                .font(.doji(14)).foregroundStyle(Doji.secondary)
        }
        .foregroundStyle(Doji.ink)
    }

    @ViewBuilder private func cell(_ id: String?) -> some View {
        if let id { AssetImage(name: "product_\(id)", kind: .product).padding(6).frame(maxWidth: .infinity) }
        else { Color.white.frame(maxWidth: .infinity) }
    }
}

// MARK: - Favorites

struct FavoritesView: View {
    @Environment(AppState.self) private var app

    var body: some View {
        VStack(spacing: 0) {
            NavHeader(title: "Favorites", subtitle: "\(app.favoriteProductIDs.count) Products")
            ScrollView {
                ProductGrid(products: MockData.products.filter { app.favoriteProductIDs.contains($0.id) }) { app.toggleFavorite($0) }
                    .padding(.top, 12)
                    .padding(.bottom, 90)
            }
        }
        .foregroundStyle(Doji.ink)
    }
}

// MARK: - Collection detail (user or featured)

struct CollectionDetailView: View {
    let collectionID: String

    @Environment(AppState.self) private var app
    @State private var showAdd = false

    private var collection: LookCollection? {
        app.userCollections.first { $0.id == collectionID } ?? app.featuredCollections.first { $0.id == collectionID }
    }

    var body: some View {
        if let c = collection {
            let looks = c.lookIDs.compactMap(MockData.look)
            VStack(spacing: 0) {
                NavHeader {
                    ShareLink(item: URL(string: "https://example.com/c/\(c.id)")!) {
                        Image(systemName: "square.and.arrow.up").font(.system(size: 18, weight: .light)).frame(width: 40, height: 40)
                    }
                }
                ScrollView {
                    VStack(spacing: 0) {
                        Text(c.title).font(.doji(28)).multilineTextAlignment(.center).padding(.horizontal, Doji.gutter)
                        if !c.subtitle.isEmpty { Text(c.subtitle).font(.doji(18)).padding(.top, 6) }
                        StatsLine(parts: ["\(looks.count) Looks", "\(c.tryOns) Try Ons"], showsGlobe: c.isFeatured)
                            .padding(.top, 8)
                        HStack(spacing: 8) {
                            if c.isFeatured { DojiBadge() } else { MeAvatar(size: 22) }
                            Text("by \(c.owner)").font(.doji(16))
                        }
                        .padding(.top, 14)

                        if c.isFeatured {
                            HStack(spacing: 10) {
                                Button(app.following.contains(c.id) ? "Following" : "Follow") { app.toggleFollow(c.id) }
                                    .buttonStyle(.dojiPill(.secondary, height: 40, font: .doji(16)))
                                Button("Add Your Look") { showAdd = true }
                                    .buttonStyle(.dojiPill(.primary, height: 40, font: .doji(16)))
                            }
                            .padding(.horizontal, 40)
                            .padding(.top, 18)
                            .padding(.bottom, 22)
                            LookGrid(looks: looks, columns: 3, captionOverride: { _ in "Editor's pick" })
                        } else {
                            LookGrid(looks: looks).padding(.top, 22)
                        }
                    }
                    .padding(.bottom, 110)
                }
                .scrollIndicators(.hidden)
            }
            .foregroundStyle(Doji.ink)
            .hidesTabBar()
            .overlay(alignment: .bottom) {
                if !c.isFeatured {
                    CollectionToolbar(onAdd: { showAdd = true }).padding(.bottom, 12)
                }
            }
            .sheet(isPresented: $showAdd) {
                AddToCollectionSheet(collectionID: c.id)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(28)
            }
        }
    }
}

/// Floating black "Add · Organize · Edit" bar on the user's own collections.
private struct CollectionToolbar: View {
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: 34) {
            item("Add", "plus", action: onAdd)
            // Organize and Edit screens were not part of the reference.
            item("Organize", "square.grid.2x2") {}
            item("Edit", "pencil") {}
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 30)
        .frame(height: 60)
        .background(Doji.ink, in: Capsule())
    }

    private func item(_ title: String, _ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: symbol).font(.system(size: 17, weight: .light))
                Text(title).font(.doji(12))
            }
        }
        .buttonStyle(.plain)
    }
}

/// "Add to <collection>": pick looks from Profile / Drafts / Fav!.
struct AddToCollectionSheet: View {
    let collectionID: String

    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss
    @State private var source = "profile"
    @State private var selected: Set<String> = []

    private var title: String {
        (app.userCollections + app.featuredCollections).first { $0.id == collectionID }?.title ?? ""
    }

    private var candidates: [Look] {
        switch source {
        case "profile": return MockData.looks
        default: return (app.userCollections.first { $0.id == source }?.lookIDs ?? []).compactMap(MockData.look)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            SheetTitle(title: "Add to \(title)")
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    Chip(title: "Profile", selected: source == "profile") { source = "profile" }
                    ForEach(app.userCollections.filter { $0.id != collectionID }) { c in
                        Chip(title: c.title, selected: source == c.id) { source = c.id }
                    }
                }
                .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)
            .padding(.bottom, 12)
            Rectangle().fill(Doji.hairline).frame(height: 0.5)

            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3), spacing: 8) {
                    ForEach(candidates) { look in
                        Button {
                            if selected.contains(look.id) { selected.remove(look.id) } else { selected.insert(look.id) }
                        } label: {
                            AssetImage(name: look.image, kind: .look)
                                .aspectRatio(0.5, contentMode: .fit)
                                .opacity(selected.isEmpty || selected.contains(look.id) ? 1 : 0.4)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(8)
            }

            Button("Add \(selected.count) Look\(selected.count == 1 ? "" : "s")") { add() }
                .buttonStyle(.dojiPrimary)
                .disabled(selected.isEmpty)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
        }
        .foregroundStyle(Doji.ink)
    }

    private func add() {
        let ids = Array(selected)
        if let i = app.userCollections.firstIndex(where: { $0.id == collectionID }) {
            app.userCollections[i].lookIDs.append(contentsOf: ids.filter { !app.userCollections[i].lookIDs.contains($0) })
        } else if let i = app.featuredCollections.firstIndex(where: { $0.id == collectionID }) {
            app.featuredCollections[i].lookIDs.append(contentsOf: ids.filter { !app.featuredCollections[i].lookIDs.contains($0) })
        }
        let count = ids.count
        dismiss()
        app.showToast(Toast(text: "Added \(count) look\(count == 1 ? "" : "s") to \(title)", image: ids.first.map { "look_\($0)" }))
    }
}

// MARK: - Another creator's profile

struct CreatorProfileView: View {
    let username: String
    @Environment(AppState.self) private var app

    var body: some View {
        let creator = MockData.creator(username)
        let looks = MockData.looks.filter { $0.creatorID == username }
        VStack(spacing: 0) {
            NavHeader {
                Menu {
                    ShareLink(item: URL(string: "https://example.com/u/\(username)")!)
                } label: {
                    Image(systemName: "ellipsis").font(.system(size: 17)).frame(width: 40, height: 40)
                }
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 16) {
                        Avatar(name: creator.avatar, size: 76)
                        VStack(alignment: .leading, spacing: 6) {
                            Text(username).font(.doji(24))
                            HStack(spacing: 18) {
                                Text("\(creator.looks) Looks")
                                Text("\(creator.tryOns) Try Ons")
                            }
                            .font(.doji(16))
                        }
                    }
                    .padding(.horizontal, Doji.gutter)

                    FollowButton(username: username, compact: false)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)

                    LookGrid(looks: looks.isEmpty ? MockData.looks : looks, columns: 3, showsCaption: false)
                }
                .padding(.bottom, 90)
            }
            .scrollIndicators(.hidden)
        }
        .foregroundStyle(Doji.ink)
    }
}

// MARK: - Settings

struct SettingsView: View {
    @Environment(AppState.self) private var app
    @Environment(Navigator.self) private var nav
    @Environment(\.openURL) private var openURL
    @Environment(\.requestReview) private var requestReview
    @State private var editing: ProfileView.EditTarget?

    var body: some View {
        VStack(spacing: 0) {
            NavHeader(title: "Settings")
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Button { openURL(URL(string: AppLinks.extensionHelp)!) } label: {
                        HStack(spacing: 14) {
                            Image(systemName: "safari")
                                .font(.system(size: 30, weight: .light))
                                .foregroundStyle(.white)
                                .frame(width: 50, height: 50)
                                .background(LinearGradient(colors: [Color(red: 0.2, green: 0.7, blue: 1), Color(red: 0.1, green: 0.4, blue: 0.95)],
                                                           startPoint: .top, endPoint: .bottom),
                                            in: RoundedRectangle(cornerRadius: 12))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Install the Doji Extension").font(.doji(18))
                                Text("Try on anything directly in Safari").font(.doji(15)).foregroundStyle(Doji.secondary)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Doji.hairline))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 24)

                    row("Update Likeness") { editing = .likeness }
                    row("Edit Profile") { editing = .profile }
                    row("Your Brands") { nav.push(.yourBrands) }
                    row("Shopping Preference") { nav.push(.shoppingPreference) }
                    // The Account screen was not part of the reference.
                    row("Account") {}

                    Text("Support").font(.doji(14)).foregroundStyle(Doji.secondary)
                        .padding(.horizontal, Doji.gutter).padding(.top, 30).padding(.bottom, 4)
                    row("Review Doji", external: true) { requestReview() }
                    row("Contact Us", external: true) { openURL(URL(string: AppLinks.contact)!) }
                    row("Privacy Policy", external: true) { openURL(URL(string: AppLinks.privacy)!) }
                    row("Terms & Conditions", external: true) { openURL(URL(string: AppLinks.terms)!) }

                    Button("Log Out") { app.logOut() }
                        .font(.doji(18))
                        .buttonStyle(.plain)
                        .padding(.horizontal, Doji.gutter)
                        .padding(.top, 40)
                }
                .padding(.bottom, 40)
            }
        }
        .foregroundStyle(Doji.ink)
        .hidesTabBar()
        .fullScreenCover(item: $editing) { target in
            EditFlow(target: target).environment(app)
        }
    }

    private func row(_ title: String, external: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title).font(.doji(18))
                Spacer()
                Image(systemName: external ? "arrow.up.right" : "chevron.right")
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(Doji.tertiary)
            }
            .padding(.horizontal, Doji.gutter)
            .frame(height: 50)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Shopping preference

struct ShoppingPreferenceView: View {
    @Environment(AppState.self) private var app

    var body: some View {
        VStack(spacing: 0) {
            NavHeader(title: "Shopping Preference")
            Spacer()
            Text("What do you wear?").font(.doji(26))
            VStack(spacing: 8) {
                ForEach(ShoppingPreference.allCases, id: \.self) { p in
                    Button(p.rawValue) { withAnimation(.easeInOut(duration: 0.2)) { app.preference = p } }
                        .font(.doji(38))
                        .foregroundStyle(app.preference == p ? Doji.ink : Doji.faint)
                        .buttonStyle(.plain)
                }
            }
            .padding(.top, 20)
            Spacer()
            Spacer()
        }
        .foregroundStyle(Doji.ink)
        .hidesTabBar()
    }
}
