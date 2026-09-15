import SwiftUI

struct CompanionsView: View {
    @EnvironmentObject var store: SessionStore

    var body: some View {
        ZStack {
            CB.bg.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Companions")
                        .font(.system(size: 27, weight: .bold))
                        .foregroundColor(CB.ink)
                        .padding(.top, 14)

                    Text("Different people need different company. Pick who shows up.")
                        .font(.system(size: 13))
                        .foregroundColor(CB.muted)
                        .padding(.top, 6)
                        .padding(.bottom, 18)

                    ForEach(Companion.all) { c in
                        row(c)
                    }

                    Text("\(Companion.all.count) companions · more coming")
                        .font(.system(size: 12))
                        .foregroundColor(CB.muted)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 14)
                        .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func row(_ c: Companion) -> some View {
        let active = store.companionId == c.id
        return Button {
            store.companionId = c.id
        } label: {
            HStack(spacing: 12) {
                Circle()
                    .fill(LinearGradient(colors: c.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 46, height: 46)
                VStack(alignment: .leading, spacing: 2) {
                    Text(c.name)
                        .font(.system(size: 14.5, weight: .bold))
                        .foregroundColor(CB.ink)
                    Text(c.tagline)
                        .font(.system(size: 12))
                        .foregroundColor(CB.muted)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                if active {
                    Text("ACTIVE")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundColor(Color(red: 0.851, green: 0.314, blue: 0.180))
                        .padding(.horizontal, 9).padding(.vertical, 5)
                        .background(CB.coralSoft)
                        .clipShape(Capsule())
                }
            }
            .cbCard()
            .padding(.bottom, 10)
        }
        .buttonStyle(.plain)
    }
}
