import Foundation

/// Sample catalog used until a real backend is connected.
/// Creator handles are fictional; brand names are the brands Doji lists.
enum MockData {
    static let products: [Product] = [
        Product(id: "p01", brand: "Chloé", name: "Check Double-Breasted Jacket", price: 3290, category: .top, age: "19h"),
        Product(id: "p02", brand: "Chloé", name: "Azelan Embroidered Boots", price: 2061, category: .shoes, age: "19h"),
        Product(id: "p03", brand: "Chloé", name: "Maxime Shearling-Trim Wedges", price: 1283, category: .shoes, age: "19h"),
        Product(id: "p04", brand: "Chloé", name: "Coddington Biker Boots", price: 1150, category: .shoes, age: "19h"),
        Product(id: "p05", brand: "Alaïa", name: "Cut-Out Top", price: 615, category: .top, age: "18h"),
        Product(id: "p06", brand: "Chloé", name: "Paddington Leather Tote Bag", price: 2006, category: .bag, age: "18h"),
        Product(id: "p07", brand: "Chloé", name: "Marcie Loafers", price: 661, category: .shoes, age: "19h"),
        Product(id: "p08", brand: "Chloé", name: "Ruffled Floral-Lace Blouse", price: 3815, category: .top, age: "1d"),
        Product(id: "p09", brand: "KNWLS", name: "M60 X Knwls Corset", price: 631, category: .top, age: "2d"),
        Product(id: "p10", brand: "KNWLS", name: "Lethal Skirt", price: 533, category: .bottoms, age: "2d"),
        Product(id: "p11", brand: "Paris Texas", name: "100Mm Lace-Up Boots", price: 840, category: .shoes, age: "2d"),
        Product(id: "p12", brand: "Gucci", name: "Fine Silk Faille Jacket", price: 4200, category: .top, age: "3d"),
        Product(id: "p13", brand: "16Arlington", name: "Ivlia Tailored Trousers", price: 690, category: .bottoms, age: "3d"),
        Product(id: "p14", brand: "Le Silla", name: "Vivienne Slingback Pumps", price: 820, category: .shoes, age: "4d"),
        Product(id: "p15", brand: "Saint Laurent", name: "Checked Blouse", price: 1490, category: .top, age: "4d"),
        Product(id: "p16", brand: "Khaite", name: "Gold Oliver Peoples Edition Sunglasses", price: 610, category: .accessory, age: "5d"),
        Product(id: "p17", brand: "Saint Laurent", name: "Y Varsity Cap", price: 495, category: .hat, age: "5d"),
        Product(id: "p18", brand: "Chloé", name: "High-Neck Cropped Jacket", price: 3950, category: .top, age: "6d"),
        Product(id: "p19", brand: "Simone Rocha", name: "Lace-Trim Camisole Top", price: 795, category: .top, age: "6d"),
        Product(id: "p20", brand: "Levi's", name: "80'S Denim Jacket", price: 128, category: .top, age: "1w"),
        Product(id: "p21", brand: "Blumarine", name: "Zip-Fastening Trousers", price: 790, category: .bottoms, age: "1w"),
        Product(id: "p22", brand: "Giuseppe Di Morabito", name: "High-Waisted Wool-Blend Leggings", price: 980, category: .bottoms, age: "1w"),
        Product(id: "p23", brand: "Nude", name: "Creased Wide-Leg Jeans", price: 430, category: .bottoms, age: "1w"),
        Product(id: "p24", brand: "Nensi Avetisian", name: "Bag Smocking Big Pink", price: 490, category: .bag, age: "1w"),
        Product(id: "p25", brand: "Alaïa", name: "Oval Sunglasses", price: 540, category: .accessory, age: "2w"),
        Product(id: "p26", brand: "Almaz", name: "Barrel-Leg Trousers", price: 1899, category: .bottoms, age: "2w"),
        Product(id: "p27", brand: "Khaite", name: "Leather Shoulder Bag", price: 2800, category: .bag, age: "2w"),
        Product(id: "p28", brand: "Prada", name: "Re-Nylon Mini Bag", price: 1650, category: .bag, age: "2w"),
    ]

    static let creators: [Creator] = [
        Creator(id: "mira.k", bio: "styling for fun", looks: 628, tryOns: "2.3k"),
        Creator(id: "jules", bio: "", looks: 212, tryOns: "940"),
        Creator(id: "noor.wears", bio: "fashion photographer", looks: 341, tryOns: "1.8k"),
        Creator(id: "theo.r", bio: "textile engineer • researcher", looks: 98, tryOns: "410"),
        Creator(id: "lena_v", bio: "Professional makeup artist who also styles", looks: 120, tryOns: "620"),
        Creator(id: "ines", bio: "bored", looks: 77, tryOns: "300"),
        Creator(id: "kai", bio: "follow me on instagram", looks: 160, tryOns: "1.1k"),
        Creator(id: "sora", bio: "", looks: 54, tryOns: "210"),
        Creator(id: "ada.m", bio: "", looks: 33, tryOns: "120"),
    ]

    static let looks: [Look] = [
        Look(id: "l01", creatorID: "mira.k", productIDs: ["p09", "p10", "p11"], age: "1d", triedOnBy: ["jules", "noor.wears", "theo.r", "lena_v", "ines", "kai", "sora", "ada.m"]),
        Look(id: "l02", creatorID: "jules", productIDs: ["p12", "p13"], age: "2d", triedOnBy: ["mira.k", "kai"]),
        Look(id: "l03", creatorID: "noor.wears", productIDs: ["p05", "p23", "p07"], age: "6w", triedOnBy: ["sora"]),
        Look(id: "l04", creatorID: "theo.r", productIDs: ["p18", "p21", "p02"], age: "6w", triedOnBy: ["ines", "ada.m"]),
        Look(id: "l05", creatorID: "lena_v", productIDs: ["p19", "p10", "p14"], age: "22h", triedOnBy: ["mira.k"]),
        Look(id: "l06", creatorID: "kai", productIDs: ["p20", "p23", "p04"], age: "1h", triedOnBy: ["jules", "theo.r"]),
        Look(id: "l07", creatorID: "ines", productIDs: ["p08", "p26", "p27"], age: "3d", triedOnBy: []),
        Look(id: "l08", creatorID: "sora", productIDs: ["p15", "p22", "p28"], age: "5d", triedOnBy: ["kai"]),
        Look(id: "l09", creatorID: "mira.k", productIDs: ["p01", "p13", "p06"], age: "1w", triedOnBy: ["noor.wears"]),
        Look(id: "l10", creatorID: "ada.m", productIDs: ["p12", "p22", "p14", "p16", "p17"], age: "2w", triedOnBy: []),
        Look(id: "l11", creatorID: "mira.k", productIDs: ["p05", "p21", "p11"], age: "2w", triedOnBy: ["lena_v"]),
        Look(id: "l12", creatorID: "noor.wears", productIDs: ["p18", "p10", "p02"], age: "3w", triedOnBy: []),
    ]

    static let featuredCollections: [LookCollection] = [
        LookCollection(id: "made-in-korea", title: "Made in Korea", subtitle: "Seoul designers we can't stop wearing", owner: "Doji", lookIDs: ["l03", "l05", "l06", "l07", "l08", "l11"], tryOns: "1.7k", isFeatured: true),
        LookCollection(id: "alt-wedding", title: "Alt Wedding Guest", subtitle: "In another life, we'd all be invited", owner: "Doji", lookIDs: ["l01", "l04", "l09", "l10", "l12", "l02"], tryOns: "2.1k", isFeatured: true),
        LookCollection(id: "music-fashion", title: "Music, Fashion, Friends", subtitle: "Front row energy", owner: "Doji", lookIDs: ["l02", "l06", "l08", "l11"], tryOns: "3.0k", isFeatured: true),
    ]

    static let activity: [ActivityItem] = [
        ActivityItem(id: "a1", actors: ["kai", "sora"], othersCount: 0, lookID: "l02", age: "4h"),
        ActivityItem(id: "a2", actors: ["ines", "ada.m"], othersCount: 1, lookID: "l05", age: "1d"),
        ActivityItem(id: "a3", actors: ["theo.r", "lena_v"], othersCount: 0, lookID: "l07", age: "6d"),
        ActivityItem(id: "a4", actors: ["jules"], othersCount: 0, lookID: "l10", age: "6d"),
    ]

    /// Brand chips offered during onboarding, in Doji's order.
    static let brands: [String] = [
        "Rick Owens", "Alaïa", "Balenciaga", "Maison Margiela", "Bottega Veneta", "Acne Studios",
        "Miu Miu", "Prada", "The Row", "Ganni", "Khaite", "Jacquemus", "Chloé", "Toteme",
        "Jil Sander", "Coperni", "Courrèges", "Moschino", "Jean Paul Gaultier", "Lemaire",
        "Vivienne Westwood", "Loewe", "Entire Studios", "Simone Rocha", "Yohji Yamamoto",
        "Paloma Wool", "Dries Van Noten", "Our Legacy", "KNWLS", "Marni", "JW Anderson",
        "Saint Laurent", "Givenchy", "Isabel Marant", "Ulla Johnson", "Zimmermann", "Alemais",
        "LoveShackFancy", "Faithfull the Brand", "Dodo Bar Or", "See by Chloé",
    ]

    /// Brands listed in the search filter sheet.
    static let filterBrands: [String] = [
        "A.P.C.", "Acne Studios", "adidas Originals", "Aeyde", "Alaïa", "Balenciaga", "Balenciaga Eyewear",
        "Blumarine", "Chloé", "Gucci", "Khaite", "KNWLS", "Le Silla", "Paris Texas", "Prada", "Saint Laurent", "Simone Rocha",
    ]

    static let searchTerms: [String] = [
        "Bag", "Bags", "Shoulder Bags", "Boots", "Blazer", "Corset", "Denim", "Dress", "Jacket", "Jeans",
        "Loafers", "Skirt", "Sunglasses", "Tote", "Trousers",
    ]

    static func product(_ id: String) -> Product? { products.first { $0.id == id } }
    static func look(_ id: String) -> Look? { looks.first { $0.id == id } }
    static func creator(_ id: String) -> Creator {
        creators.first { $0.id == id } ?? Creator(id: id, bio: "", looks: 0, tryOns: "0")
    }
    static func products(of look: Look) -> [Product] { look.productIDs.compactMap(product) }

    /// "In KNWLS and Paris Texas" / "In Gucci, Khaite, Le Silla and more"
    static func brandLine(for look: Look, limit: Int = 2) -> String {
        var seen: [String] = []
        for p in products(of: look) where !seen.contains(p.brand) { seen.append(p.brand) }
        if seen.count <= limit { return seen.joined(separator: " and ") }
        return seen.prefix(limit).joined(separator: ", ") + " and more"
    }
}
