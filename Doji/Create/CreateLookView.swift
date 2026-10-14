import SwiftUI

/// Outfit builder: pick items per slot, "Style Me" fills the rest, "Try on" generates a new look.
struct CreateLookView: View {
    var initialProductIDs: [String] = []

    struct Slot: Identifiable, Hashable {
        let id: Int
        let category: ProductCategory?   // nil = "Add Product" (paste a link)
        let label: String
        var productID: String?
        var locked = false
    }

    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss
    @State private var slots: [Slot] = CreateLookView.emptySlots
    @State private var path: [Int] = []
    @State private var styling = false
    @State private var tryingOn = false
    @State private var didSeed = false

    static let emptySlots: [Slot] = [
        Slot(id: 0, category: .top, label: "Select a Top"),
        Slot(id: 1, category: .bottoms, label: "Select Bottoms"),
        Slot(id: 2, category: .shoes, label: "Select Shoes"),
        Slot(id: 3, category: .top, label: "Add Another Top"),
        Slot(id: 4, category: .accessory, label: "Add Accessories"),
        Slot(id: 5, category: .bag, label: "Add a Bag"),
        Slot(id: 6, category: .hat, label: "Add a Hat"),
        Slot(id: 7, category: nil, label: "Add Product"),
    ]

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                ZStack {
                    Text("Create Look").font(.doji(19))
                    HStack {
                        IconButton(systemName: "chevron.down", size: 17, weight: .regular) { dismiss() }
                        Spacer()
                        IconButton(systemName: "magnifyingglass", size: 18) {
                            if let empty = slots.first(where: { $0.productID == nil && $0.category != nil }) { path.append(empty.id) }
                        }
                    }
                    .padding(.horizontal, 6)
                }
                .frame(height: 50)
                .overlay(alignment: .top) {
                    if tryingOn {
                        ToastView(toast: Toast(text: "Trying on your look", isLoading: true))
                            .offset(y: 46)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .zIndex(1)

                Rectangle().fill(Doji.hairline).frame(height: 0.5)

                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)], spacing: 0) {
                        ForEach($slots) { $slot in
                            SlotCell(slot: $slot, loading: styling && !slot.locked && slot.category != nil) {
                                if slot.category != nil { path.append(slot.id) }
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
                .scrollIndicators(.hidden)

                HStack(spacing: 10) {
                    Button(action: styleMe) {
                        Label("Style Me", systemImage: "sparkles")
                    }
                    .buttonStyle(.dojiSecondary)
                    Button("Try on", action: tryOn)
                        .buttonStyle(.dojiPrimary)
                        .disabled(slots.allSatisfy { $0.productID == nil } || tryingOn)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 8)
            }
            .foregroundStyle(Doji.ink)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Int.self) { index in
                ProductPickerView(slots: $slots, slotIndex: index) { productID in
                    slots[index].productID = productID
                    slots[index].locked = true
                    path.removeLast()
                }
                .toolbar(.hidden, for: .navigationBar)
            }
        }
        .onAppear(perform: seed)
    }

    private func seed() {
        guard !didSeed else { return }
        didSeed = true
        for id in initialProductIDs {
            guard let p = MockData.product(id),
                  let i = slots.firstIndex(where: { $0.category == p.category && $0.productID == nil }) else { continue }
            slots[i].productID = id
            slots[i].locked = true
        }
    }

    private func styleMe() {
        withAnimation { styling = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            var used = Set(slots.compactMap(\.productID))
            for i in slots.indices where !slots[i].locked {
                guard let category = slots[i].category else { continue }
                let options = MockData.products.filter { $0.category == category && !used.contains($0.id) }
                if let pick = options.randomElement() {
                    slots[i].productID = pick.id
                    used.insert(pick.id)
                }
            }
            withAnimation { styling = false }
        }
    }

    private func tryOn() {
        let ids = slots.compactMap(\.productID)
        withAnimation { tryingOn = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            app.pendingLooks.insert(PendingLook(sourceLookID: nil, productIDs: ids, styledBy: nil), at: 0)
            tryingOn = false
            app.openNewLooksAfterDismiss = true
            dismiss()
        }
    }
}

private struct SlotCell: View {
    @Binding var slot: CreateLookView.Slot
    let loading: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            ZStack {
                if loading {
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 10).fill(Doji.fill).frame(height: 120).padding(.horizontal, 18)
                        RoundedRectangle(cornerRadius: 3).fill(Doji.fill).frame(width: 60, height: 8).padding(.horizontal, 18)
                        RoundedRectangle(cornerRadius: 3).fill(Doji.fill).frame(width: 110, height: 8).padding(.horizontal, 18)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else if let id = slot.productID, let p = MockData.product(id) {
                    VStack(alignment: .leading, spacing: 2) {
                        AssetImage(name: p.image, kind: .product)
                            .frame(height: 130)
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 10)
                        Text(p.brand).font(.doji(14))
                        Text(p.name.lowercased()).font(.doji(14)).lineLimit(1)
                    }
                    .padding(.horizontal, 14)
                } else {
                    VStack(spacing: 14) {
                        Image(systemName: slot.category?.symbol ?? "link.badge.plus")
                            .font(.system(size: 64, weight: .ultraLight))
                            .foregroundStyle(Doji.faint)
                            .frame(height: 130)
                        HStack(spacing: 4) {
                            Text(slot.label)
                            Image(systemName: "chevron.right").font(.system(size: 10, weight: .semibold))
                        }
                        .font(.doji(15))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 210)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .top) {
            if slot.productID != nil && !loading {
                HStack {
                    Button { slot.locked.toggle() } label: {
                        Image(systemName: slot.locked ? "lock.fill" : "lock.open")
                            .font(.system(size: 12))
                            .foregroundStyle(Doji.tertiary)
                            .frame(width: 34, height: 34)
                    }
                    Spacer()
                    Button { slot.productID = nil; slot.locked = false } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .light))
                            .foregroundStyle(Doji.secondary)
                            .frame(width: 34, height: 34)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .overlay(alignment: .trailing) { Rectangle().fill(Doji.hairline).frame(width: 0.5) }
        .overlay(alignment: .bottom) { Rectangle().fill(Doji.hairline).frame(height: 0.5) }
    }
}

// MARK: - Product picker

/// "Select a Top" / "Select Bottoms": slot strip, filter chips, product grid.
struct ProductPickerView: View {
    @Binding var slots: [CreateLookView.Slot]
    let slotIndex: Int
    let onPick: (String) -> Void

    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss
    @State private var favoritesOnly = false
    @State private var brand: String?
    @State private var query = ""
    @State private var searching = false

    private var slot: CreateLookView.Slot { slots[slotIndex] }

    private var products: [Product] {
        MockData.products.filter { p in
            p.category == slot.category
            && (!favoritesOnly || app.favoriteProductIDs.contains(p.id))
            && (brand == nil || p.brand == brand)
            && (query.isEmpty || "\(p.brand) \(p.name)".localizedCaseInsensitiveContains(query))
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            NavHeader(title: slot.label.replacingOccurrences(of: "Add Another", with: "Select a")) {
                IconButton(systemName: "magnifyingglass", size: 18) { withAnimation { searching.toggle() } }
            }

            if searching {
                SearchField(prompt: "Search products", text: $query).padding(.horizontal, 16).padding(.bottom, 8)
            }

            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(slots.filter { $0.category != nil }) { s in
                        Group {
                            if let id = s.productID {
                                AssetImage(name: "product_\(id)", kind: .product)
                            } else {
                                Image(systemName: s.category?.symbol ?? "tag")
                                    .font(.system(size: 22, weight: .ultraLight))
                                    .foregroundStyle(Doji.faint)
                            }
                        }
                        .frame(width: 44, height: 50)
                        .padding(2)
                        .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(s.id == slotIndex ? Doji.ink : .clear, lineWidth: 1.5))
                    }
                }
                .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)
            .padding(.bottom, 10)

            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    FilterIconChip(active: favoritesOnly || brand != nil) { favoritesOnly = false; brand = nil }
                    Chip(title: "Favorites", selected: favoritesOnly) { favoritesOnly.toggle() }
                    Menu {
                        ForEach(ProductCategory.allCases, id: \.self) { c in Text(c.rawValue) }
                    } label: { ChipLabel(title: "Category", showsChevron: true) }
                    Menu {
                        Button("All Brands") { brand = nil }
                        ForEach(Array(Set(MockData.products.map(\.brand))).sorted(), id: \.self) { b in
                            Button(b) { brand = b }
                        }
                    } label: { ChipLabel(title: brand ?? "Brand", selected: brand != nil, showsChevron: true) }
                    Menu {
                        Text("Color data not available")
                    } label: { ChipLabel(title: "Color", showsChevron: true) }
                }
                .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)

            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 22) {
                    ForEach(products) { p in
                        Button { onPick(p.id) } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                AssetImage(name: p.image, kind: .product).aspectRatio(0.9, contentMode: .fit)
                                (Text(p.brand).fontWeight(.semibold) + Text(" \(p.name)"))
                                    .font(.doji(14))
                                    .lineLimit(2)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .scrollIndicators(.hidden)
        }
        .foregroundStyle(Doji.ink)
        .background(Color.white.ignoresSafeArea())
    }
}
