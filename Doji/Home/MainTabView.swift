import SwiftUI
import Observation

/// Per-tab navigation path so any screen can push a `Route`.
@Observable
final class Navigator {
    var path: [Route] = []
    func push(_ route: Route) { path.append(route) }
    func popToRoot() { path.removeAll() }
}

struct MainTabView: View {
    @Environment(AppState.self) private var app
    @State private var homeNav = Navigator()
    @State private var searchNav = Navigator()
    @State private var activityNav = Navigator()
    @State private var profileNav = Navigator()
    @State private var showCreate = false

    var body: some View {
        @Bindable var app = app
        VStack(spacing: 0) {
            ZStack {
                tab(.home, nav: homeNav) { HomeView() }
                tab(.search, nav: searchNav) { SearchHomeView() }
                tab(.activity, nav: activityNav) { ActivityView() }
                tab(.profile, nav: profileNav) { ProfileView() }
            }
            .overlay(alignment: .bottom) {
                if app.tabBarHiders == 0 && !app.pendingLooks.isEmpty {
                    NewLooksPill(count: app.pendingLooks.count) { app.showNewLooks = true }
                        .padding(.bottom, 12)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            if app.tabBarHiders == 0 {
                DojiTabBar(onCreate: { showCreate = true }, onReselect: reselect)
            }
        }
        .ignoresSafeArea(.keyboard)
        .onChange(of: app.selectedTab) { old, _ in
            if old == .activity { app.markActivityRead() }
        }
        .fullScreenCover(isPresented: $showCreate, onDismiss: app.openNewLooksIfRequested) {
            CreateLookView().toastHost().environment(app)
        }
        .fullScreenCover(isPresented: $app.showNewLooks) {
            NewLooksView().toastHost().environment(app)
        }
    }

    private func tab<Root: View>(_ tab: MainTab, nav: Navigator, @ViewBuilder root: () -> Root) -> some View {
        let selected = app.selectedTab == tab
        return TabStack(nav: nav, root: root())
            .opacity(selected ? 1 : 0)
            .allowsHitTesting(selected)
            .accessibilityHidden(!selected)
    }

    private func reselect(_ tab: MainTab) {
        switch tab {
        case .home: homeNav.popToRoot()
        case .search: searchNav.popToRoot()
        case .activity: activityNav.popToRoot()
        case .profile: profileNav.popToRoot()
        }
    }
}

private struct TabStack<Root: View>: View {
    @Bindable var nav: Navigator
    let root: Root

    var body: some View {
        NavigationStack(path: $nav.path) {
            root
                .dojiChrome()
                .navigationDestination(for: Route.self) { route in
                    RouteView(route: route).dojiChrome()
                }
        }
        .environment(nav)
    }
}

/// Maps every `Route` to its screen.
struct RouteView: View {
    let route: Route
    @Environment(Navigator.self) private var nav
    @Environment(AppState.self) private var app

    var body: some View {
        switch route {
        case .look(let id): LookDetailView(lookID: id)
        case .product(let id): ProductDetailView(productID: id)
        case .creator(let id): CreatorProfileView(username: id)
        case .collection(let id): CollectionDetailView(collectionID: id)
        case .favorites: FavoritesView()
        case .searchResults(let q): SearchResultsView(query: q)
        case .settings: SettingsView()
        case .shoppingPreference: ShoppingPreferenceView()
        case .yourBrands: SelectBrandsView(isEditing: true) { nav.path.removeLast() }.hidesTabBar()
        case .contactsPrimer: ContactsPrimerView { nav.push(.inviteFriends) }
        case .inviteFriends: InviteFriendsView { nav.popToRoot() }
        }
    }
}

// MARK: - Tab bar

private struct DojiTabBar: View {
    let onCreate: () -> Void
    let onReselect: (MainTab) -> Void
    @Environment(AppState.self) private var app

    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Doji.hairline).frame(height: 0.5)
            HStack(spacing: 0) {
                item(.home, symbol: "house", selectedSymbol: "house.fill")
                item(.search, symbol: "magnifyingglass", selectedSymbol: "magnifyingglass", selectedWeight: .semibold)
                Button(action: onCreate) {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .light))
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Create Look")
                item(.activity, symbol: "bell", selectedSymbol: "bell.fill")
                Button { select(.profile) } label: {
                    MeAvatar(size: 26)
                        .overlay(Circle().strokeBorder(app.selectedTab == .profile ? Doji.ink : .clear, lineWidth: 1.5).padding(-3))
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Profile")
            }
            .buttonStyle(.plain)
            .foregroundStyle(Doji.ink)
        }
        .background(Color.white.ignoresSafeArea(edges: .bottom))
    }

    private func item(_ tab: MainTab, symbol: String, selectedSymbol: String, selectedWeight: Font.Weight = .regular) -> some View {
        let selected = app.selectedTab == tab
        return Button { select(tab) } label: {
            Image(systemName: selected ? selectedSymbol : symbol)
                .font(.system(size: 20, weight: selected ? selectedWeight : .light))
                .frame(maxWidth: .infinity, minHeight: 50)
                .contentShape(Rectangle())
        }
    }

    private func select(_ tab: MainTab) {
        if app.selectedTab == tab { onReselect(tab) } else { app.selectedTab = tab }
    }
}
