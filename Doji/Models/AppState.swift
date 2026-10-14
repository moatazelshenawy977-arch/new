import SwiftUI
import Observation

struct Toast: Identifiable, Equatable {
    let id = UUID()
    var text: String
    var image: String? = nil
    var isLoading = false
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    static func == (lhs: Toast, rhs: Toast) -> Bool { lhs.id == rhs.id }
}

/// A try-on result waiting for the user to save or discard it ("New Looks").
struct PendingLook: Identifiable, Hashable {
    let id = UUID()
    let sourceLookID: String?
    let productIDs: [String]
    let styledBy: String?
}

enum MainTab: Hashable { case home, search, activity, profile }

@Observable
final class AppState {
    // Session
    var isOnboarded = false
    var phone = ""
    var email = ""
    var username = "samlee"
    var profileImage: UIImage?
    var selectedBrands: Set<String> = []
    var preference: ShoppingPreference = .womenswear

    // Social
    var following: Set<String> = []
    var contactsConnected = false

    // Content state
    var favoriteProductIDs: Set<String> = []
    var likedLookIDs: Set<String> = []
    var savedLooks: [PendingLook] = []
    var userCollections: [LookCollection] = [
        LookCollection(id: "fav", title: "Fav! ⭐", subtitle: "", owner: "samlee", lookIDs: ["l01"], tryOns: "3"),
        LookCollection(id: "drafts", title: "Drafts", subtitle: "", owner: "samlee", lookIDs: [], tryOns: "0", isPrivate: true),
    ]
    var featuredCollections = MockData.featuredCollections
    var recentlyViewedIDs: [String] = ["p01", "p25", "p26", "p05"]
    var activity = MockData.activity
    var pendingLooks: [PendingLook] = MockData.looks.prefix(9).map {
        PendingLook(sourceLookID: $0.id, productIDs: $0.productIDs, styledBy: $0.creatorID)
    }

    // Chrome
    var selectedTab: MainTab = .home
    var tabBarHiders = 0
    var showNewLooks = false
    var toast: Toast?

    var unreadActivity: Bool { activity.contains { $0.unread } }

    // MARK: Actions

    func showToast(_ toast: Toast, duration: Double = 2.2) {
        withAnimation(.spring(duration: 0.35)) { self.toast = toast }
        let id = toast.id
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            guard self?.toast?.id == id else { return }
            withAnimation(.easeInOut(duration: 0.25)) { self?.toast = nil }
        }
    }

    func toggleFavorite(_ product: Product, onView: (() -> Void)? = nil) {
        if favoriteProductIDs.contains(product.id) {
            favoriteProductIDs.remove(product.id)
        } else {
            favoriteProductIDs.insert(product.id)
            showToast(Toast(text: "Saved to Favorites", image: product.image, actionTitle: "View", action: onView))
        }
    }

    func toggleFollow(_ username: String) {
        if following.contains(username) { following.remove(username) } else { following.insert(username) }
    }

    /// Queues a generated try-on. A real backend would render the user's likeness wearing the products.
    func tryOn(productIDs: [String], sourceLookID: String? = nil, styledBy: String? = nil) {
        let pending = PendingLook(sourceLookID: sourceLookID, productIDs: productIDs, styledBy: styledBy)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { [weak self] in
            guard let self else { return }
            self.pendingLooks.insert(pending, at: 0)
            self.showToast(Toast(text: "New look ready", image: "look_\(sourceLookID ?? "new")", actionTitle: nil, action: { [weak self] in
                self?.showNewLooks = true
            }))
        }
    }

    func resolveFirstPending(save: Bool, into collectionIDs: Set<String> = []) {
        guard !pendingLooks.isEmpty else { return }
        let look = pendingLooks.removeFirst()
        guard save else { return }
        savedLooks.insert(look, at: 0)
        if let source = look.sourceLookID {
            for i in userCollections.indices where collectionIDs.contains(userCollections[i].id) {
                if !userCollections[i].lookIDs.contains(source) { userCollections[i].lookIDs.append(source) }
            }
        }
    }

    func logOut() {
        let fresh = AppState()
        isOnboarded = false
        phone = ""; email = ""; username = fresh.username; profileImage = nil
        selectedBrands = []; following = []; contactsConnected = false
        favoriteProductIDs = []; likedLookIDs = []; savedLooks = []
        userCollections = fresh.userCollections; pendingLooks = fresh.pendingLooks
        selectedTab = .home; tabBarHiders = 0; toast = nil
    }
}
