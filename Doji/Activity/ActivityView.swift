import SwiftUI

/// "Activity": who tried on the looks you styled.
struct ActivityView: View {
    @Environment(AppState.self) private var app

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Activity").font(.doji(19))
                HStack {
                    Spacer()
                    // Try-on queue indicator.
                    Text("\(app.pendingLooks.isEmpty ? 0 : 1)")
                        .font(.doji(11))
                        .frame(width: 22, height: 22)
                        .overlay(Circle().strokeBorder(Doji.ink, lineWidth: 1))
                        .overlay(Circle().trim(from: 0, to: 0.25).stroke(Doji.ink, lineWidth: 2).rotationEffect(.degrees(-90)))
                        .padding(.trailing, 18)
                }
            }
            .frame(height: 50)

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(app.activity) { item in
                        NavigationLink(value: Route.look(item.lookID)) { ActivityRow(item: item) }
                            .buttonStyle(.plain)
                    }
                }
                .padding(.top, 6)
                .padding(.bottom, 90)
            }
        }
        .foregroundStyle(Doji.ink)
    }
}

private struct ActivityRow: View {
    let item: ActivityItem

    private var text: Text {
        let names: Text
        switch (item.actors.count, item.othersCount) {
        case (1, _):
            names = Text(item.actors[0]).fontWeight(.semibold)
        case (_, 0):
            names = Text(item.actors[0]).fontWeight(.semibold) + Text(" and ") + Text(item.actors[1]).fontWeight(.semibold)
        default:
            names = Text("\(item.actors[0]), \(item.actors[1])").fontWeight(.semibold)
                + Text(" and \(item.othersCount) other")
        }
        return names + Text(" tried on a look you styled. ") + Text(item.age).foregroundStyle(Doji.secondary)
    }

    var body: some View {
        HStack(spacing: 10) {
            RedDot(size: 5).opacity(item.unread ? 1 : 0)
            ZStack(alignment: .bottomTrailing) {
                Avatar(name: "avatar_\(item.actors[0])", size: item.actors.count > 1 ? 34 : 46)
                    .frame(width: 46, height: 46, alignment: .topLeading)
                if item.actors.count > 1 {
                    Avatar(name: "avatar_\(item.actors[1])", size: 34)
                        .overlay(Circle().stroke(.white, lineWidth: 2))
                }
            }
            text.font(.doji(16)).frame(maxWidth: .infinity, alignment: .leading)
            AssetImage(name: "look_\(item.lookID)", kind: .look)
                .frame(width: 46, height: 46)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(Doji.hairline))
        }
        .padding(.leading, 8)
        .padding(.trailing, 16)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}
