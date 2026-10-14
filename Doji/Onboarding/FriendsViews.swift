import SwiftUI
import Contacts

// MARK: - Contacts primer

/// Explains the iOS contacts prompt before it appears ("Share All Contacts").
struct ContactsPrimerView: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            NavHeader()
            Text("Find all your friends").font(.doji(26))
            (Text("Share All Contacts").foregroundColor(Doji.link)
             + Text(" to find your friends on\nDoji and try on what they're wearing"))
                .font(.doji(17))
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            PhoneMock().padding(.horizontal, 40).padding(.top, 22)

            Spacer(minLength: 16)
            BottomCTA(title: "Next") {
                Task {
                    _ = try? await CNContactStore().requestAccess(for: .contacts)
                    await MainActor.run { onNext() }
                }
            }
            .padding(.bottom, 16)
        }
        .foregroundStyle(Doji.ink)
    }
}

/// Illustration of the iOS contact-sharing sheet.
private struct PhoneMock: View {
    private let initials = ["KK", "", "H", "", "JT", "JB", "QB", "TA", "MT", "", "SC", "C", "", "CC",
                            "CK", "CM", "MB", "", "J", "KB", "CK", "AK", "I", "", "S", "", "NF",
                            "ML", "DB", "", "KS", "AH", "", "TH", "LS", "ZA", "JS", "", "MP", "", "KS"]

    var body: some View {
        VStack(spacing: 14) {
            Capsule().fill(Doji.ink).frame(width: 90, height: 24).padding(.top, 10)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                ForEach(initials.indices, id: \.self) { i in
                    ZStack {
                        Circle().fill(initials[i].isEmpty ? Doji.faint : Color(red: 0.62, green: 0.66, blue: 0.84))
                        Text(initials[i]).font(.system(size: 9, weight: .semibold)).foregroundStyle(.white)
                    }
                    .aspectRatio(1, contentMode: .fit)
                }
            }
            .padding(.horizontal, 12)
            Text("How do you want\nto share contacts?")
                .font(.system(size: 20, weight: .bold))
                .multilineTextAlignment(.center)
            VStack(spacing: 8) {
                Text("Select Contacts").foregroundStyle(Doji.secondary)
                    .frame(maxWidth: .infinity).frame(height: 32).background(Doji.fill, in: Capsule())
                Text("Share All Contacts").foregroundStyle(Doji.link)
                    .frame(maxWidth: .infinity).frame(height: 32).background(.white, in: Capsule())
                    .overlay(Capsule().strokeBorder(Doji.hairline))
            }
            .font(.system(size: 12, weight: .medium))
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(.white, in: RoundedRectangle(cornerRadius: 34))
        .overlay(RoundedRectangle(cornerRadius: 34).strokeBorder(Doji.ink, lineWidth: 7))
        .overlay(alignment: .bottomTrailing) {
            Image(systemName: "hand.point.up.left.fill")
                .font(.system(size: 54))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.6), radius: 0.5)
                .offset(x: 24, y: -10)
        }
    }
}

// MARK: - Invite friends

struct ContactEntry: Identifiable, Hashable {
    let id: String
    let name: String
    let phone: String

    var initials: String {
        let parts = name.split(separator: " ")
        let first = parts.first?.first.map(String.init) ?? "?"
        let last = parts.dropFirst().first?.first.map(String.init) ?? "-"
        return first + last
    }
}

struct InviteFriendsView: View {
    let onDone: () -> Void

    @Environment(AppState.self) private var app
    @State private var contacts: [ContactEntry] = []
    @State private var query = ""
    @State private var invitee: ContactEntry?
    @State private var loaded = false

    private var filtered: [ContactEntry] {
        query.isEmpty ? contacts : contacts.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        VStack(spacing: 0) {
            NavHeader()
            TitleBlock(title: "Invite your friends", subtitle: "Doji's more fun with people you know", titleSize: 26)
            SearchField(prompt: "Search contacts", text: $query)
                .padding(.horizontal, 16)
                .padding(.top, 18)
            Divider().overlay(Doji.hairline).padding(.top, 14)

            ScrollView {
                LazyVStack(spacing: 0) {
                    if loaded && contacts.isEmpty {
                        Text("Allow access to Contacts in Settings to invite friends.")
                            .font(.doji(15))
                            .foregroundStyle(Doji.secondary)
                            .multilineTextAlignment(.center)
                            .padding(40)
                    }
                    ForEach(filtered) { contact in
                        HStack(spacing: 12) {
                            Text(contact.initials)
                                .font(.doji(14))
                                .foregroundStyle(Doji.secondary)
                                .frame(width: 40, height: 40)
                                .background(Doji.fill, in: Circle())
                            VStack(alignment: .leading, spacing: 2) {
                                Text(contact.name).font(.doji(16))
                                Text(contact.phone).font(.doji(14)).foregroundStyle(Doji.secondary)
                            }
                            Spacer()
                            Button("Invite") { invitee = contact }
                                .buttonStyle(.dojiPill(.primary, height: 30, font: .doji(14), expand: false))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)

            BottomCTA(title: "Done") {
                app.contactsConnected = true
                onDone()
            }
            .padding(.bottom, 16)
        }
        .foregroundStyle(Doji.ink)
        .task { await load() }
        .sheet(item: $invitee) { contact in
            InviteWithSheet(contact: contact)
                .presentationDetents([.height(250)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
    }

    private func load() async {
        let entries: [ContactEntry] = await Task.detached(priority: .userInitiated) {
            guard CNContactStore.authorizationStatus(for: .contacts) == .authorized else { return [] }
            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
            let request = CNContactFetchRequest(keysToFetch: keys)
            request.sortOrder = .givenName
            var out: [ContactEntry] = []
            try? CNContactStore().enumerateContacts(with: request) { c, _ in
                guard let phone = c.phoneNumbers.first?.value.stringValue else { return }
                let name = [c.givenName, c.familyName].filter { !$0.isEmpty }.joined(separator: " ")
                out.append(ContactEntry(id: c.identifier, name: name.isEmpty ? phone : name, phone: phone))
            }
            return out
        }.value
        contacts = entries
        loaded = true
    }
}

private struct InviteWithSheet: View {
    let contact: ContactEntry
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss

    private var message: String { "Join me on Doji and try on my looks!" }
    private var digits: String { contact.phone.filter(\.isNumber) }

    var body: some View {
        VStack(spacing: 0) {
            SheetTitle(title: "Invite With")
            HStack(alignment: .top, spacing: 22) {
                option(title: "Messages", symbol: "message.fill") {
                    let body = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    if let url = URL(string: "sms:\(digits)&body=\(body)") { openURL(url) }
                }
                Text("or").font(.doji(15)).foregroundStyle(Doji.secondary).padding(.top, 20)
                option(title: "WhatsApp", symbol: "phone.bubble.fill") {
                    let text = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    if let url = URL(string: "https://wa.me/\(digits)?text=\(text)") { openURL(url) }
                }
            }
            Spacer()
        }
        .foregroundStyle(Doji.ink)
    }

    private func option(title: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
            dismiss()
        } label: {
            VStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.system(size: 26))
                    .foregroundStyle(.white)
                    .frame(width: 60, height: 60)
                    .background(Color(red: 0.25, green: 0.78, blue: 0.35), in: Circle())
                Text(title).font(.doji(14))
            }
        }
        .buttonStyle(.plain)
    }
}
