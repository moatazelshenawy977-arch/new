import SwiftUI

// MARK: - Wordmark

struct Wordmark: View {
    var size: CGFloat = 22
    var color: Color = Doji.ink
    var body: some View {
        Text("Doji").font(.doji(size)).foregroundStyle(color)
    }
}

// MARK: - Toast

/// Floating capsule notice ("Saved to Favorites", "Look link copied", "New look ready").
struct ToastView: View {
    let toast: Toast

    var body: some View {
        HStack(spacing: 10) {
            if toast.isLoading {
                ProgressView().controlSize(.small).tint(Doji.secondary)
            } else if let image = toast.image {
                AssetImage(name: image, kind: image.hasPrefix("look") ? .look : .product)
                    .frame(width: 24, height: 28)
            }
            Text(toast.text)
                .font(.doji(16))
                .foregroundStyle(Doji.ink)
                .lineLimit(1)
            if let title = toast.actionTitle {
                Button(title) { toast.action?() }
                    .buttonStyle(.dojiPill(.primary, height: 30, font: .doji(14), expand: false))
            }
        }
        .padding(.leading, 14)
        .padding(.trailing, toast.actionTitle == nil ? 18 : 6)
        .frame(height: 44)
        .background(.white, in: Capsule())
        .shadow(color: .black.opacity(0.12), radius: 14, y: 4)
        .contentShape(Capsule())
        .onTapGesture { if toast.actionTitle == nil { toast.action?() } }
    }
}

private struct ToastHost: ViewModifier {
    @Environment(AppState.self) private var app

    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            if let toast = app.toast {
                ToastView(toast: toast)
                    .padding(.top, 44)
                    .padding(.horizontal, 24)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .id(toast.id)
            }
        }
    }
}

extension View {
    /// Shows `AppState.toast`. Applied at the root and inside every full-screen cover.
    func toastHost() -> some View { modifier(ToastHost()) }

    /// Hides the custom tab bar while this view is on screen.
    func hidesTabBar() -> some View { modifier(TabBarHider()) }

    /// Hides the system navigation bar; Doji draws its own headers.
    func dojiChrome() -> some View {
        self.toolbar(.hidden, for: .navigationBar)
            .background(Color.white.ignoresSafeArea())
    }
}

private struct TabBarHider: ViewModifier {
    @Environment(AppState.self) private var app
    func body(content: Content) -> some View {
        content
            .onAppear { app.tabBarHiders += 1 }
            .onDisappear { app.tabBarHiders = max(0, app.tabBarHiders - 1) }
    }
}

// Keep the swipe-back gesture working while the navigation bar is hidden.
extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}

// MARK: - Headers

/// Back chevron, centered title, optional trailing content.
struct NavHeader<Trailing: View>: View {
    var title: String = ""
    var subtitle: String? = nil
    var leadingIcon = "chevron.left"
    var onBack: (() -> Void)? = nil
    @ViewBuilder var trailing: () -> Trailing

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            VStack(spacing: 2) {
                Text(title).font(.doji(17)).foregroundStyle(Doji.ink)
                if let subtitle {
                    Text(subtitle).font(.doji(13)).foregroundStyle(Doji.secondary)
                }
            }
            HStack {
                IconButton(systemName: leadingIcon, size: 18, weight: .regular) {
                    if let onBack { onBack() } else { dismiss() }
                }
                Spacer()
                trailing()
            }
            .padding(.horizontal, 6)
        }
        .frame(height: 50)
    }
}

extension NavHeader where Trailing == EmptyView {
    init(title: String = "", subtitle: String? = nil, leadingIcon: String = "chevron.left", onBack: (() -> Void)? = nil) {
        self.init(title: title, subtitle: subtitle, leadingIcon: leadingIcon, onBack: onBack) { EmptyView() }
    }
}

/// Title + subtitle pair used at the top of most onboarding and sheet screens.
struct TitleBlock: View {
    let title: String
    var subtitle: String? = nil
    var titleSize: CGFloat = 28

    var body: some View {
        VStack(spacing: 8) {
            Text(title).font(.doji(titleSize))
            if let subtitle {
                Text(subtitle).font(.doji(17)).lineSpacing(2)
            }
        }
        .multilineTextAlignment(.center)
        .foregroundStyle(Doji.ink)
        .padding(.horizontal, Doji.gutter)
    }
}

// MARK: - Small pieces

struct RedDot: View {
    var size: CGFloat = 6
    var body: some View { Circle().fill(Doji.red).frame(width: size, height: size) }
}

struct CountBadge: View {
    let count: Int
    var body: some View {
        Text("\(count)")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.white)
            .frame(minWidth: 18, minHeight: 18)
            .background(Doji.red, in: Circle())
    }
}

/// Black floating "New Looks ⑨" pill.
struct NewLooksPill: View {
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text("New Looks").font(.doji(17))
                CountBadge(count: count)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .frame(height: 46)
            .background(Doji.ink, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

/// Rounded search field ("Search for brands", "Search contacts").
struct SearchField: View {
    let prompt: String
    @Binding var text: String
    var filled = true

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(Doji.secondary)
            TextField(prompt, text: $text)
                .font(.doji(16))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
        .padding(.horizontal, 16)
        .frame(height: 46)
        .background(filled ? Doji.fill : .white, in: Capsule())
        .overlay(Capsule().strokeBorder(Doji.hairline, lineWidth: filled ? 0.5 : 1))
    }
}

/// Outlined filter chip; filled black when selected.
struct Chip: View {
    let title: String
    var selected = false
    var showsChevron = false
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            ChipLabel(title: title, selected: selected, showsChevron: showsChevron)
        }
        .buttonStyle(.plain)
    }
}

/// Chip appearance without a button, for use as a `Menu` label.
struct ChipLabel: View {
    let title: String
    var selected = false
    var showsChevron = false

    var body: some View {
        HStack(spacing: 4) {
            Text(title)
            if showsChevron { Image(systemName: "chevron.down").font(.system(size: 10, weight: .medium)) }
        }
        .font(.doji(15))
        .foregroundStyle(selected ? .white : Doji.ink)
        .padding(.horizontal, 14)
        .frame(height: 34)
        .background(selected ? Doji.ink : .white, in: Capsule())
        .overlay(Capsule().strokeBorder(selected ? .clear : Doji.faint, lineWidth: 1))
    }
}

/// Small circular filter (sliders) button that sits at the start of chip rows.
struct FilterIconChip: View {
    var active = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(active ? .white : Doji.ink)
                .frame(width: 34, height: 34)
                .background(active ? Doji.ink : .white, in: Circle())
                .overlay(Circle().strokeBorder(active ? .clear : Doji.faint, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

/// Section title with optional count and chevron ("Collections >", "Tops 40 >").
struct SectionHeader: View {
    let title: String
    var count: Int? = nil
    var chevronInline = true
    var action: (() -> Void)? = nil

    var body: some View {
        Button { action?() } label: {
            HStack(spacing: 6) {
                Text(title).font(.doji(20))
                if chevronInline, action != nil {
                    Image(systemName: "chevron.right").font(.system(size: 13, weight: .regular))
                }
                Spacer()
                if let count { Text("\(count)").font(.doji(14)).foregroundStyle(Doji.secondary) }
            }
            .foregroundStyle(Doji.ink)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
        .padding(.horizontal, Doji.gutter)
    }
}

/// Wrap-around layout for brand chips.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 10

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, lineHeight: CGFloat = 0, maxX: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 {
                x = 0; y += lineHeight + lineSpacing; lineHeight = 0
            }
            x += size.width + spacing
            maxX = max(maxX, x - spacing)
            lineHeight = max(lineHeight, size.height)
        }
        return CGSize(width: proposal.width ?? maxX, height: y + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, lineHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX; y += lineHeight + lineSpacing; lineHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

/// Grabber + centered title used at the top of Doji's bottom sheets.
struct SheetTitle: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.doji(19))
            .frame(maxWidth: .infinity)
            .padding(.top, 26)
            .padding(.bottom, 14)
    }
}

/// Stat line like "215 Looks · 2.1k Try Ons · 🌐".
struct StatsLine: View {
    let parts: [String]
    var showsGlobe = false
    var body: some View {
        HStack(spacing: 4) {
            Text(parts.joined(separator: " · ") + (showsGlobe ? " ·" : ""))
            if showsGlobe { Image(systemName: "globe").font(.system(size: 12, weight: .light)) }
        }
        .font(.doji(15))
        .foregroundStyle(Doji.secondary)
    }
}
