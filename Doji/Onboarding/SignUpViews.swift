import SwiftUI

// MARK: - Welcome carousel

struct WelcomeView: View {
    let onStart: () -> Void

    /// Pages captured in the reference. The middle page of Doji's 3-page carousel was not
    /// available on Mobbin, so only the first and last pages are recreated.
    private let pages: [(image: String, kind: AssetImage.Kind, text: String)] = [
        ("welcome_1", .look, "Try on clothes with your\npersonalized likeness"),
        ("welcome_3", .group, "Save your favorite looks\nto showcase your style"),
    ]
    @State private var index = 0

    var body: some View {
        VStack(spacing: 0) {
            Wordmark(size: 24).padding(.top, 14)

            TabView(selection: $index) {
                ForEach(pages.indices, id: \.self) { i in
                    AssetImage(name: pages[i].image, kind: pages[i].kind)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 24)
                        .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            DashPageIndicator(count: pages.count, index: index)
                .padding(.bottom, 14)

            Text(pages[index].text)
                .font(.doji(26))
                .multilineTextAlignment(.center)
                .frame(height: 76)
                .id(index)
                .transition(.opacity)

            BottomCTA(title: index == pages.count - 1 ? "Get Started" : "Next") {
                if index < pages.count - 1 { withAnimation { index += 1 } } else { onStart() }
            }
            .padding(.top, 22)
            .padding(.bottom, 20)
        }
        .foregroundStyle(Doji.ink)
        .background(Color.white.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Phone number

struct PhoneNumberView: View {
    let onNext: () -> Void
    @Environment(AppState.self) private var app
    @State private var digits = ""
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 0) {
            NavHeader { helpIcon }
            Spacer(minLength: 40)
            Text("What's your phone number?").font(.doji(26))
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                HStack(spacing: 2) {
                    Text("+1")
                    Image(systemName: "chevron.down").font(.system(size: 9)).foregroundStyle(Doji.secondary)
                }
                TextField("650 213 7390", text: Binding(
                    get: { Self.format(digits) },
                    set: { digits = String($0.filter(\.isNumber).prefix(10)) }
                ))
                .keyboardType(.numberPad)
                .textContentType(.telephoneNumber)
                .focused($focused)
                .fixedSize()
            }
            .font(.doji(30))
            .padding(.top, 16)
            Spacer()
            BottomCTA(title: "Request Code", enabled: digits.count == 10) {
                app.phone = Self.format(digits)
                onNext()
            }
            TermsText().padding(.top, 14).padding(.bottom, 12)
        }
        .foregroundStyle(Doji.ink)
        .onAppear { focused = true }
    }

    static func format(_ d: String) -> String {
        var out = ""
        for (i, c) in d.enumerated() {
            if i == 3 || i == 6 { out.append(" ") }
            out.append(c)
        }
        return out
    }
}

var helpIcon: some View {
    Image(systemName: "questionmark.circle")
        .font(.system(size: 19, weight: .ultraLight))
        .foregroundStyle(Doji.secondary)
        .frame(width: 40, height: 40)
}

private struct TermsText: View {
    var body: some View {
        Text(Self.copy)
            .font(.doji(12))
            .foregroundStyle(Doji.secondary)
            .tint(Doji.secondary)
            .multilineTextAlignment(.center)
    }

    private static var copy: AttributedString {
        let md = "By creating an account, you agree to our\n[Terms of Service](\(AppLinks.terms)) and [Privacy Policy](\(AppLinks.privacy))."
        return (try? AttributedString(markdown: md, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)))
            ?? AttributedString(md)
    }
}

// MARK: - Verification code

struct VerifyCodeView: View {
    let onNext: () -> Void
    @Environment(AppState.self) private var app
    @State private var code = ""
    @State private var secondsLeft = 30
    @FocusState private var focused: Bool
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            NavHeader { helpIcon }
            Spacer(minLength: 40)
            Text("Enter the code").font(.doji(26))
            TextField("000000", text: Binding(get: { code }, set: { code = String($0.filter(\.isNumber).prefix(6)) }))
                .font(.doji(30))
                .tracking(4)
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($focused)
                .padding(.top, 14)
            Group {
                if secondsLeft > 0 {
                    Text("Resend to +1 \(app.phone) in \(secondsLeft)s")
                } else {
                    Button("Resend code") { secondsLeft = 30 }
                }
            }
            .font(.doji(15))
            .foregroundStyle(Doji.secondary)
            .padding(.top, 18)
            Spacer()
            BottomCTA(title: "Verify Code", enabled: code.count == 6, action: onNext)
                .padding(.bottom, 16)
        }
        .foregroundStyle(Doji.ink)
        .onAppear { focused = true }
        .onReceive(timer) { _ in if secondsLeft > 0 { secondsLeft -= 1 } }
    }
}

// MARK: - Email

struct EmailView: View {
    let onNext: () -> Void
    @Environment(AppState.self) private var app
    @State private var email = ""
    @FocusState private var focused: Bool

    private var isValid: Bool {
        let parts = email.split(separator: "@")
        return parts.count == 2 && parts[1].contains(".") && !parts[0].isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            NavHeader { helpIcon }
            Spacer(minLength: 40)
            Text("What's your email?").font(.doji(26))
            TextField("hello@doji.com", text: $email)
                .font(.doji(28))
                .multilineTextAlignment(.center)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($focused)
                .padding(.horizontal, Doji.gutter)
                .padding(.top, 14)
            Spacer()
            BottomCTA(title: "Next", enabled: isValid) {
                app.email = email
                onNext()
            }
            .padding(.bottom, 16)
        }
        .foregroundStyle(Doji.ink)
        .onAppear { focused = true }
    }
}

// MARK: - Username

struct CreateUsernameView: View {
    let onNext: () -> Void
    @Environment(AppState.self) private var app
    @State private var name = ""
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 0) {
            ProgressHeader(progress: 0.92, accessory: .likenessDot)
            TitleBlock(title: "Create a username", subtitle: "Appears on your profile, change it anytime", titleSize: 26)
                .padding(.top, 8)
            Spacer()
            TextField("username", text: Binding(
                get: { name },
                set: { name = String($0.lowercased().filter { $0.isLetter || $0.isNumber || $0 == "_" || $0 == "." }.prefix(24)) }
            ))
            .font(.doji(28))
            .multilineTextAlignment(.center)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused($focused)
            Spacer()
            BottomCTA(title: "Next", enabled: name.count >= 2) {
                app.username = name
                onNext()
            }
            .padding(.bottom, 16)
        }
        .foregroundStyle(Doji.ink)
        .onAppear { focused = true }
    }
}

/// External pages Doji links to. The real URLs were not part of the reference; replace before release.
enum AppLinks {
    static let terms = "https://example.com/terms"
    static let privacy = "https://example.com/privacy"
    static let contact = "mailto:support@example.com"
    static let extensionHelp = "https://example.com/safari-extension"
    static let productStore = "https://example.com/product"
}
