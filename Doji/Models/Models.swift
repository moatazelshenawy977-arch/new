import SwiftUI

enum ProductCategory: String, CaseIterable, Hashable {
    case top = "Top"
    case bottoms = "Bottoms"
    case shoes = "Shoes"
    case bag = "Bag"
    case accessory = "Accessory"
    case hat = "Hat"

    var symbol: String {
        switch self {
        case .top: "tshirt"
        case .bottoms: "rectangle.portrait"
        case .shoes: "shoe"
        case .bag: "handbag"
        case .accessory: "eyeglasses"
        case .hat: "tag"
        }
    }
}

struct Product: Identifiable, Hashable {
    let id: String
    let brand: String
    let name: String
    let price: Int
    let category: ProductCategory
    let age: String
    /// Asset catalog name. Drop an image with this name into Assets.xcassets to replace the placeholder.
    var image: String { "product_\(id)" }

    var priceText: String { Self.format(price) }

    static func format(_ value: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        return "$" + (f.string(from: NSNumber(value: value)) ?? "\(value)")
    }
}

struct Creator: Identifiable, Hashable {
    let id: String          // username
    let bio: String
    let looks: Int
    let tryOns: String
    var username: String { id }
    var avatar: String { "avatar_\(id)" }
}

struct Look: Identifiable, Hashable {
    let id: String
    let creatorID: String
    let productIDs: [String]
    let age: String
    var triedOnBy: [String] = []
    var styledBy: String? = nil
    var isEditorsPick = false
    var image: String { "look_\(id)" }
}

struct LookCollection: Identifiable, Hashable {
    let id: String
    var title: String
    var subtitle: String
    var owner: String          // "Doji" for featured collections
    var lookIDs: [String]
    var tryOns: String
    var isPrivate = false
    var isFeatured = false
    var cover: String { "collection_\(id)" }
}

struct ActivityItem: Identifiable, Hashable {
    let id: String
    let actors: [String]
    let othersCount: Int
    let lookID: String
    let age: String
    var unread = true
}

enum ShoppingPreference: String, CaseIterable {
    case menswear = "Menswear"
    case womenswear = "Womenswear"
}

/// Destinations reachable from any tab's navigation stack.
enum Route: Hashable {
    case look(String)
    case product(String)
    case creator(String)
    case collection(String)
    case favorites
    case searchResults(String)
    case settings
    case shoppingPreference
    case yourBrands
    case contactsPrimer
    case inviteFriends
}
