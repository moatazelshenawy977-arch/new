import SwiftUI

// MARK: - Search home

/// Recently Viewed, Featured Collections, Top Creators, Brands For You.
struct SearchHomeView: View {
    @Environment(AppState.self) private var app
    @Environment(Navigator.self) private var nav
    @State private var query = ""
    @FocusState private var focused: Bool

    private var isSearching: Bool { focused || !query.isEmpty }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass").font(.system(size: 16, weight: .light))
                TextField("Search for people, looks, and products", text: $query)
                    .font(.doji(17))
                    .focused($focused)
                    .submitLabel(.search)
                    .autocorrectionDisabled()
                    .onSubmit { submit(query) }
                if isSearching {
                    if !query.isEmpty {
                        Button { query = "" } label: { Image(systemName: "xmark").font(.system(size: 13, weight: .light)) }
                            .buttonStyle(.plain)
                    }
                    Rectangle().fill(Doji.hairline).frame(width: 0.5, height: 22)
                    Button("Cancel") { query = ""; focused = false }.font(.doji(17)).buttonStyle(.plain)
                }
            }
            .foregroundStyle(Doji.ink)
            .padding(.horizontal, 16)
            .frame(height: 50)
            Rectangle().fill(Doji.hairline).frame(height: 0.5)

            if isSearching {
                suggestions
            } else {
                discover
            }
        }
        .foregroundStyle(Doji.ink)
    }

    private func submit(_ term: String) {
        let t = term.trimmingCharacters(in: .whitespaces)
        guard !t.isEmpty else { return }
        focused = false
        query = ""
        nav.push(.searchResults(t))
    }

    private var suggestions: some View {
        let terms = MockData.searchTerms.filter { query.isEmpty || $0.localizedCaseInsensitiveContains(query) }
        let people = MockData.creators.filter { !query.isEmpty && $0.id.localizedCaseInsensitiveContains(query) }
        return ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(people) { c in
                    Button { focused = false; nav.push(.creator(c.id)) } label: {
                        HStack(spacing: 12) {
                            Avatar(name: c.avatar, size: 38)
                            Text(c.id).font(.doji(17))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16).padding(.vertical, 6)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                ForEach(terms, id: \.self) { term in
                    Button { submit(term) } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 14, weight: .light))
                                .frame(width: 38, height: 38)
                                .overlay(Circle().strokeBorder(Doji.hairline))
                            highlighted(term)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16).padding(.vertical, 6)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 8)
        }
        .scrollDismissesKeyboard(.immediately)
    }

    /// Typed prefix in ink, completion in gray (as in "Bag|s").
    private func highlighted(_ term: String) -> Text {
        guard let r = term.range(of: query, options: [.caseInsensitive, .anchored]) else {
            return Text(term).font(.doji(17))
        }
        return (Text(term[r]) + Text(term[r.upperBound...]).foregroundColor(Doji.secondary)).font(.doji(17))
    }

    private var discover: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                SectionHeader(title: "Recently Viewed")
                    .padding(.top, 18)
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 14) {
                        ForEach(app.recentlyViewedIDs.compactMap(MockData.product)) { p in
                            NavigationLink(value: Route.product(p.id)) {
                                VStack(alignment: .leading, spacing: 2) {
                                    AssetImage(name: p.image, kind: .product).frame(width: 96, height: 110).padding(.bottom, 8)
                                    Text(p.brand).font(.doji(14))
                                    Text(p.priceText).font(.doji(14))
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, Doji.gutter)
                }
                .scrollIndicators(.hidden)
                .padding(.top, 12)

                SectionHeader(title: "Featured Collections").padding(.top, 28)
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 12) {
                        ForEach(app.featuredCollections) { c in
                            NavigationLink(value: Route.collection(c.id)) { FeaturedCollectionCard(collection: c) }
                                .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .scrollIndicators(.hidden)
                .padding(.top, 12)

                VStack(alignment: .leading, spacing: 2) {
                    SectionHeader(title: "Top Creators")
                    Text("Last 7 Days").font(.doji(14)).foregroundStyle(Doji.secondary).padding(.horizontal, Doji.gutter)
                }
                .padding(.top, 28)
                VStack(spacing: 4) {
                    ForEach(Array(MockData.creators.prefix(5).enumerated()), id: \.element.id) { i, c in
                        HStack(spacing: 12) {
                            Text("\(i + 1)").font(.doji(15)).frame(width: 14)
                            NavigationLink(value: Route.creator(c.id)) {
                                HStack(spacing: 12) {
                                    Avatar(name: c.avatar, size: 48)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(c.id).font(.doji(18))
                                        if !c.bio.isEmpty {
                                            Text(c.bio).font(.doji(14)).foregroundStyle(Doji.secondary).lineLimit(1)
                                        }
                                    }
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            let following = app.following.contains(c.id)
                            Button { withAnimation { app.toggleFollow(c.id) } } label: {
                                Image(systemName: following ? "checkmark" : "plus")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(following ? Doji.ink : .white)
                                    .frame(width: 28, height: 28)
                                    .background(following ? Doji.fill : Doji.ink, in: Circle())
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, Doji.gutter)
                    }
                }
                .padding(.top, 12)

                SectionHeader(title: "Brands For You").padding(.top, 28)
                NavigationLink(value: Route.searchResults(app.selectedBrands.sorted().first ?? "Chloé")) {
                    AssetImage(name: "brands_for_you", kind: .group)
                        .frame(height: 260)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Doji.hairline))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 90)
            }
        }
        .scrollIndicators(.hidden)
    }
}

struct FeaturedCollectionCard: View {
    let collection: LookCollection

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            AssetImage(name: collection.cover, kind: .group, contentMode: .fill)
                .frame(width: 200, height: 196)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Doji.hairline))
                .padding(.bottom, 4)
            Text(collection.title).font(.doji(17)).lineLimit(1)
            HStack(spacing: 4) {
                DojiBadge(size: 14)
                StatsLine(parts: [collection.owner, "\(collection.tryOns) Try Ons"], showsGlobe: true)
            }
        }
        .frame(width: 200, alignment: .leading)
        .foregroundStyle(Doji.ink)
    }
}

/// Tiny circular "Doji" mark used for collections curated by Doji.
struct DojiBadge: View {
    var size: CGFloat = 22
    var body: some View {
        Text("Doji")
            .font(.doji(size * 0.32))
            .frame(width: size, height: size)
            .background(.white, in: Circle())
            .overlay(Circle().strokeBorder(Doji.hairline))
    }
}

// MARK: - Results

struct SearchResultsView: View {
    let query: String

    enum Kind: String, CaseIterable { case all = "All", looks = "Looks", products = "Products" }

    @Environment(AppState.self) private var app
    @State private var kind: Kind = .all
    @State private var brands: Set<String> = []
    @State private var category: ProductCategory?
    @State private var sortNew = false
    @State private var showFilters = false

    private var products: [Product] {
        var items = MockData.products.filter { p in
            (brands.isEmpty || brands.contains(p.brand)) && (category == nil || p.category == category)
        }
        // Fall back to the filtered catalog when the mock data has no direct text match.
        let matching = items.filter { "\($0.brand) \($0.name) \($0.category.rawValue)".localizedCaseInsensitiveContains(query) }
        if !matching.isEmpty { items = matching }
        return sortNew ? items.reversed() : items
    }

    private var looks: [Look] {
        let ids = Set(products.map(\.id))
        let hits = MockData.looks.filter { !$0.productIDs.filter(ids.contains).isEmpty }
        return sortNew ? hits.reversed() : hits
    }

    private var routes: [Route] {
        switch kind {
        case .looks: return looks.map { .look($0.id) }
        case .products: return products.map { .product($0.id) }
        case .all:
            var out: [Route] = []
            let l = looks, p = products
            for i in 0..<max(l.count, p.count) {
                if i < l.count { out.append(.look(l[i].id)) }
                if i < p.count { out.append(.product(p[i].id)) }
            }
            return out
        }
    }

    var body: some View {
        let routes = self.routes
        VStack(spacing: 0) {
            NavHeader(title: query)
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    FilterIconChip(active: !brands.isEmpty || category != nil || sortNew) { showFilters = true }
                    ForEach(Kind.allCases, id: \.self) { k in
                        Chip(title: k.rawValue, selected: kind == k) { kind = k }
                    }
                    Menu {
                        Button("All Categories") { category = nil }
                        ForEach(ProductCategory.allCases, id: \.self) { c in Button(c.rawValue) { category = c } }
                    } label: { ChipLabel(title: category?.rawValue ?? "Category", selected: category != nil, showsChevron: true) }
                    Button { showFilters = true } label: {
                        ChipLabel(title: brandChipTitle, selected: !brands.isEmpty, showsChevron: true)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)
            .padding(.bottom, 12)

            ScrollView {
                HStack(alignment: .top, spacing: 10) {
                    ForEach(0..<2, id: \.self) { col in
                        LazyVStack(spacing: 18) {
                            ForEach(Array(routes.enumerated()).filter { $0.offset % 2 == col }, id: \.offset) { _, r in
                                ExploreTile(route: r)
                            }
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 90)
            }
            .scrollIndicators(.hidden)
        }
        .foregroundStyle(Doji.ink)
        .sheet(isPresented: $showFilters) {
            FiltersSheet(kind: $kind, brands: $brands, sortNew: $sortNew)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
    }

    private var brandChipTitle: String {
        guard let first = brands.sorted().first else { return "Brand" }
        return brands.count > 1 ? "\(first) +\(brands.count - 1)" : first
    }
}

// MARK: - Filters

struct FiltersSheet: View {
    enum Pane: String, CaseIterable { case type = "Type", brand = "Brand", sort = "Sort", department = "Department" }

    @Binding var kind: SearchResultsView.Kind
    @Binding var brands: Set<String>
    @Binding var sortNew: Bool

    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss
    @State private var section: Pane = .brand
    @State private var query = ""

    var body: some View {
        VStack(spacing: 0) {
            SheetTitle(title: "Filters")
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").font(.system(size: 14, weight: .light)).foregroundStyle(Doji.secondary)
                TextField("Search for brands", text: $query).font(.doji(16))
            }
            .padding(.horizontal, 16)
            .frame(height: 40)

            ScrollView(.horizontal) {
                HStack(spacing: 14) {
                    ForEach(brands.sorted(), id: \.self) { b in
                        Button { brands.remove(b) } label: { Text("\(b) ×") }.buttonStyle(.plain)
                    }
                    if kind != .all {
                        Button { kind = .all } label: { Text("\(kind.rawValue) ×") }.buttonStyle(.plain)
                    }
                }
                .font(.doji(16))
                .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)
            .frame(height: 36)
            Rectangle().fill(Doji.hairline).frame(height: 0.5)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    switch section {
                    case .type:
                        Text("Show").font(.doji(20)).padding(.vertical, 12)
                        ForEach(SearchResultsView.Kind.allCases, id: \.self) { k in
                            radio(k.rawValue, on: kind == k) { kind = k }
                        }
                    case .brand:
                        check("Your Brands", on: !app.selectedBrands.isEmpty && app.selectedBrands.isSubset(of: brands), large: true) {
                            if app.selectedBrands.isSubset(of: brands) { brands.subtract(app.selectedBrands) } else { brands.formUnion(app.selectedBrands) }
                        }
                        ForEach(app.selectedBrands.sorted(), id: \.self) { b in brandRow(b) }
                        ForEach(groupedBrands, id: \.0) { letter, list in
                            Text(letter).font(.doji(20)).padding(.top, 18).padding(.bottom, 4)
                            ForEach(list, id: \.self) { b in brandRow(b) }
                        }
                    case .sort:
                        Text("Sort by").font(.doji(20)).padding(.vertical, 12)
                        radio("For You", on: !sortNew) { sortNew = false }
                        radio("New", on: sortNew) { sortNew = true }
                    case .department:
                        Text("Department").font(.doji(20)).padding(.vertical, 12)
                        ForEach(ShoppingPreference.allCases, id: \.self) { d in
                            radio(d.rawValue, on: app.preference == d) { app.preference = d }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }

            Rectangle().fill(Doji.hairline).frame(height: 0.5)
            HStack(spacing: 18) {
                ForEach(Pane.allCases, id: \.self) { s in
                    Button { section = s } label: {
                        HStack(spacing: 4) {
                            Text(s.rawValue)
                            if isActive(s) { Circle().fill(Doji.ink).frame(width: 4, height: 4) }
                        }
                        .foregroundStyle(section == s ? Doji.ink : Doji.tertiary)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .font(.doji(15))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            HStack(spacing: 10) {
                Button("Clear All") { kind = .all; brands = []; sortNew = false }.buttonStyle(.dojiSecondary)
                Button("View Results") { dismiss() }.buttonStyle(.dojiPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .foregroundStyle(Doji.ink)
    }

    private var groupedBrands: [(String, [String])] {
        let list = MockData.filterBrands.filter { query.isEmpty || $0.localizedCaseInsensitiveContains(query) }
        let groups = Dictionary(grouping: list) { String($0.prefix(1)).uppercased() }
        return groups.keys.sorted().map { ($0, groups[$0]!.sorted()) }
    }

    private func isActive(_ s: Pane) -> Bool {
        switch s {
        case .type: kind != .all
        case .brand: !brands.isEmpty
        case .sort: sortNew
        case .department: false
        }
    }

    private func brandRow(_ b: String) -> some View {
        check(b, on: brands.contains(b)) {
            if brands.contains(b) { brands.remove(b) } else { brands.insert(b) }
        }
    }

    private func check(_ title: String, on: Bool, large: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: on ? "checkmark.square.fill" : "square")
                    .font(.system(size: 20, weight: .ultraLight))
                Text(title).font(.doji(large ? 20 : 16))
                Spacer()
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func radio(_ title: String, on: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: on ? "circle.inset.filled" : "circle")
                    .font(.system(size: 20, weight: .ultraLight))
                Text(title).font(.doji(16))
                Spacer()
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
