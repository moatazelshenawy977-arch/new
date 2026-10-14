import SwiftUI
import PhotosUI

// MARK: - Select brands

/// "Select 3+ brands you like". Also reused for Settings → Your Brands.
struct SelectBrandsView: View {
    var progress: Double? = nil
    var isEditing = false
    let onContinue: () -> Void

    @Environment(AppState.self) private var app
    @State private var query = ""

    private var brands: [String] {
        let q = query.trimmingCharacters(in: .whitespaces)
        return q.isEmpty ? MockData.brands : MockData.brands.filter { $0.localizedCaseInsensitiveContains(q) }
    }

    var body: some View {
        VStack(spacing: 0) {
            if let progress {
                ProgressHeader(progress: progress, showsBack: false, accessory: .likenessDot)
            } else {
                NavHeader(title: "Your Brands")
            }

            ScrollView {
                VStack(spacing: 0) {
                    TitleBlock(title: "Select 3+ brands you like", subtitle: "This teaches Doji your taste", titleSize: 26)
                        .padding(.top, 8)
                    SearchField(prompt: "Search for brands", text: $query)
                        .padding(.horizontal, 16)
                        .padding(.top, 22)
                    FlowLayout(spacing: 8, lineSpacing: 10) {
                        ForEach(brands, id: \.self) { brand in
                            BrandChip(title: brand, selected: app.selectedBrands.contains(brand)) {
                                withAnimation(.snappy(duration: 0.2)) {
                                    if app.selectedBrands.contains(brand) { app.selectedBrands.remove(brand) }
                                    else { app.selectedBrands.insert(brand) }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 18)
                    .padding(.bottom, 110)
                }
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.immediately)
        }
        .overlay(alignment: .bottom) {
            if app.selectedBrands.count >= 3 {
                BottomCTA(title: isEditing ? "Save" : "Continue", action: onContinue)
                    .padding(.bottom, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.snappy, value: app.selectedBrands.count >= 3)
        .foregroundStyle(Doji.ink)
    }
}

private struct BrandChip: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.doji(17))
                .foregroundStyle(selected ? .white : Doji.ink)
                .padding(.horizontal, 13)
                .frame(height: 40)
                .background(selected ? Doji.ink : .white, in: Capsule())
                .overlay(Capsule().strokeBorder(selected ? .clear : Doji.faint, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Profile picture

struct ProfilePicView: View {
    var isEditing = false
    let onNext: () -> Void

    @Environment(AppState.self) private var app
    @State private var item: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 0) {
            if isEditing {
                NavHeader(title: "Edit Profile")
            } else {
                ProgressHeader(progress: 1.0, accessory: .likenessDot)
            }
            TitleBlock(title: "Set your profile pic", subtitle: "Appears on your profile, change it anytime", titleSize: 26)
                .padding(.top, 8)

            Group {
                if let image = app.profileImage {
                    Image(uiImage: image).resizable().scaledToFill()
                } else {
                    EmptyAvatarArt()
                }
            }
            .frame(width: 200, height: 200)
            .clipShape(Circle())
            .overlay(Circle().strokeBorder(Doji.hairline, lineWidth: 1.5))
            .padding(.top, 54)

            Text(app.username).font(.doji(20)).padding(.top, 16)

            PhotosPicker(selection: $item, matching: .images) {
                Text(app.profileImage == nil ? "Upload photo" : "Change Photo")
            }
            .buttonStyle(.dojiPill(app.profileImage == nil ? .primary : .secondary, height: 40, font: .doji(16), expand: false))
            .padding(.top, 22)

            Spacer()

            if app.profileImage == nil && !isEditing {
                Button("Skip", action: onNext).font(.doji(17)).padding(.bottom, 26)
            } else {
                BottomCTA(title: isEditing ? "Done" : "Next", action: onNext).padding(.bottom, 16)
            }
        }
        .foregroundStyle(Doji.ink)
        .onChange(of: item) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                    await MainActor.run { app.profileImage = image }
                }
            }
        }
    }
}

/// Light-gray head-and-shoulders silhouette shown before a photo is uploaded.
struct EmptyAvatarArt: View {
    var body: some View {
        GeometryReader { geo in
            let s = geo.size.width
            ZStack {
                Doji.fill
                Circle().fill(.white).frame(width: s * 0.38).position(x: s / 2, y: s * 0.38)
                Ellipse().fill(.white).frame(width: s * 0.8, height: s * 0.5).position(x: s / 2, y: s * 0.98)
            }
        }
    }
}

// MARK: - Find friends (onboarding)

struct FindFriendsIntroView: View {
    let onFind: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ProgressHeader(progress: 1.0, accessory: .likenessDot)
            TitleBlock(title: "Find all your friends", subtitle: "Keep up with their style and try on their\nlooks", titleSize: 26)
                .padding(.top, 8)

            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { i in AssetImage(name: "friends_\(i + 1)", kind: .look) }
                }
                HStack(spacing: 6) {
                    ForEach(3..<6, id: \.self) { i in AssetImage(name: "friends_\(i + 1)", kind: .look) }
                }
                .frame(maxHeight: 120, alignment: .top)
                .clipped()
                .mask(LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom))
            }
            .padding(.horizontal, 16)
            .padding(.top, 18)

            Spacer(minLength: 12)
            BottomCTA(title: "Find Your Friends", action: onFind)
            Button("Continue Without Friends", action: onSkip)
                .font(.doji(17))
                .padding(.vertical, 18)
        }
        .foregroundStyle(Doji.ink)
    }
}
