import SwiftUI

/// Review generated try-ons one at a time: Discard or Save (to Profile and collections).
struct NewLooksView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss
    @State private var showSave = false
    @State private var showShare = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            if let pending = app.pendingLooks.first {
                content(pending).id(pending.id).transition(.opacity)
            }
        }
        .foregroundStyle(Doji.ink)
        .onChange(of: app.pendingLooks.isEmpty) { _, empty in if empty { dismiss() } }
        .sheet(isPresented: $showSave) {
            SaveLookSheet { collections in
                showSave = false
                withAnimation { app.resolveFirstPending(save: true, into: collections) }
            }
            .presentationDetents([.height(330)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
        }
    }

    @ViewBuilder private func content(_ pending: PendingLook) -> some View {
        let products = pending.productIDs.compactMap(MockData.product)
        let brands = Array(NSOrderedSet(array: products.map(\.brand))) as? [String] ?? []

        VStack(spacing: 0) {
            ZStack {
                HStack(spacing: 6) {
                    Text("New Looks").font(.doji(17))
                    CountBadge(count: app.pendingLooks.count)
                }
                HStack {
                    IconButton(systemName: "chevron.down", size: 17, weight: .regular) { dismiss() }
                    Spacer()
                    Wordmark().padding(.trailing, 14)
                }
                .padding(.horizontal, 6)
            }
            .frame(height: 50)

            ZStack(alignment: .trailing) {
                // A real build renders the user's likeness wearing these products.
                AssetImage(name: pending.sourceLookID.map { "tryon_\($0)" } ?? "tryon_new", kind: .look)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, 8)
                VStack(spacing: 14) {
                    MeAvatar(size: 40).padding(.bottom, 6)
                    IconButton(systemName: "arrow.2.squarepath", size: 19) {}
                    IconButton(systemName: "square.and.arrow.up", size: 19) { showShare = true }
                    IconButton(systemName: "arrow.uturn.backward", size: 18, color: Doji.tertiary) {}
                    IconButton(systemName: "ellipsis", size: 17) {}
                }
                .padding(.trailing, 10)
                .offset(y: 70)
            }

            VStack(alignment: .leading, spacing: 4) {
                (Text(app.username).fontWeight(.semibold) + Text(" now").foregroundColor(Doji.secondary))
                if let styledBy = pending.styledBy {
                    (Text("Styled by ") + Text(styledBy).fontWeight(.semibold) + Text(" in \(brands.joined(separator: ", "))"))
                        .lineLimit(1)
                } else {
                    Text("In \(brands.joined(separator: ", "))").lineLimit(1)
                }
            }
            .font(.doji(15))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Doji.gutter)

            HStack(spacing: 10) {
                Button("Discard") { withAnimation { app.resolveFirstPending(save: false) } }
                    .buttonStyle(.dojiSecondary)
                Button("Save") { showSave = true }
                    .buttonStyle(.dojiPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 8)
        }
        .fullScreenCover(isPresented: $showShare) {
            if let id = pending.sourceLookID, let look = MockData.look(id) {
                ShareLookView(look: look).environment(app).toastHost()
            }
        }
    }
}

/// Choose where a look is saved: Profile plus any of the user's collections.
struct SaveLookSheet: View {
    let onSave: (Set<String>) -> Void
    @Environment(AppState.self) private var app
    @State private var toProfile = true
    @State private var selected: Set<String> = []
    @State private var newName = ""
    @State private var askingName = false

    var body: some View {
        VStack(spacing: 0) {
            row(title: "Profile", subtitle: "\(app.savedLooks.count + 9) Looks", isOn: toProfile) {
                MeAvatar(size: 44)
            } toggle: { toProfile.toggle() }
            .padding(.top, 22)

            Rectangle().fill(Doji.hairline).frame(height: 0.5).padding(.vertical, 6)

            Text("Collections").font(.doji(15)).foregroundStyle(Doji.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(app.userCollections) { c in
                        row(title: c.title, subtitle: "\(c.lookIDs.count) Looks", isOn: selected.contains(c.id)) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6).fill(Doji.fill)
                                Image(systemName: c.isPrivate ? "lock.fill" : "person.fill")
                                    .font(.system(size: 15))
                                    .foregroundStyle(c.isPrivate ? Doji.secondary : Doji.faint)
                            }
                            .frame(width: 44, height: 44)
                        } toggle: {
                            if selected.contains(c.id) { selected.remove(c.id) } else { selected.insert(c.id) }
                        }
                    }
                }
            }

            HStack(spacing: 10) {
                Button("New Collection") { askingName = true }.buttonStyle(.dojiSecondary)
                Button("Save") { onSave(selected) }.buttonStyle(.dojiPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .foregroundStyle(Doji.ink)
        .alert("New Collection", isPresented: $askingName) {
            TextField("Name", text: $newName)
            Button("Cancel", role: .cancel) { newName = "" }
            Button("Create") {
                let name = newName.trimmingCharacters(in: .whitespaces)
                guard !name.isEmpty else { return }
                let c = LookCollection(id: UUID().uuidString, title: name, subtitle: "", owner: app.username, lookIDs: [], tryOns: "0")
                app.userCollections.append(c)
                selected.insert(c.id)
                newName = ""
            }
        }
    }

    private func row<Icon: View>(title: String, subtitle: String, isOn: Bool,
                                 @ViewBuilder icon: () -> Icon, toggle: @escaping () -> Void) -> some View {
        Button(action: toggle) {
            HStack(spacing: 12) {
                icon()
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.doji(18))
                    Text(subtitle).font(.doji(14)).foregroundStyle(Doji.secondary)
                }
                Spacer()
                Image(systemName: isOn ? "checkmark.circle.fill" : "plus.circle")
                    .font(.system(size: 22, weight: .ultraLight))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(isOn ? .white : Doji.tertiary, isOn ? Doji.ink : Doji.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
