import SwiftUI

struct StatsView: View {
    @EnvironmentObject var store: SessionStore

    private var week: [(day: Date, seconds: Int)] { store.lastWeek() }
    private var maxSeconds: Int { max(1, week.map { $0.seconds }.max() ?? 1) }

    var body: some View {
        ZStack {
            CB.bg.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("This week")
                        .font(.system(size: 27, weight: .bold))
                        .foregroundColor(CB.ink)
                        .padding(.top, 14)

                    Text("\(cbHuman(store.secondsThisWeek)) focused · \(store.sessionsThisWeek) sessions")
                        .font(.system(size: 13))
                        .foregroundColor(CB.muted)
                        .padding(.top, 6)

                    bars
                        .padding(.top, 18)

                    HStack(spacing: 10) {
                        card("\(store.streak) 🔥", "current streak")
                        card("\(store.bestStreak)", "best streak")
                    }
                    .padding(.top, 18)

                    if !store.secondsByTag().isEmpty {
                        Text("WHERE YOUR TIME WENT")
                            .font(.system(size: 11.5, weight: .heavy))
                            .foregroundColor(CB.muted)
                            .padding(.top, 24)
                            .padding(.bottom, 10)

                        ForEach(store.secondsByTag(), id: \.tag) { row in
                            tagRow(row.tag, row.seconds)
                        }
                    }

                    if store.sessions.isEmpty {
                        Text("No sessions yet. Your first block will show up here.")
                            .font(.system(size: 13))
                            .foregroundColor(CB.muted)
                            .padding(.top, 24)
                    }
                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var bars: some View {
        HStack(alignment: .bottom, spacing: 11) {
            ForEach(week, id: \.day) { item in
                VStack(spacing: 6) {
                    Spacer(minLength: 0)
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(item.seconds > 0 ? CB.coral : Color(red: 0.906, green: 0.878, blue: 0.847))
                        .frame(height: max(6, CGFloat(item.seconds) / CGFloat(maxSeconds) * 96))
                    Text(dayLabel(item.day))
                        .font(.system(size: 10.5, weight: .bold))
                        .foregroundColor(CB.muted)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 124)
    }

    private func dayLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEEE"
        return f.string(from: date).uppercased()
    }

    private func card(_ value: String, _ label: String) -> some View {
        VStack(spacing: 3) {
            Text(value).font(.system(size: 19, weight: .bold)).foregroundColor(CB.ink)
            Text(label).font(.system(size: 11.5)).foregroundColor(CB.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 13)
        .background(CB.field)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func tagRow(_ tag: String, _ seconds: Int) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(LinearGradient(colors: [CB.coral.opacity(0.9), Color(red: 1, green: 0.702, blue: 0.42)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 36, height: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(tag).font(.system(size: 14.5, weight: .bold)).foregroundColor(CB.ink)
                Text(cbHuman(seconds)).font(.system(size: 12)).foregroundColor(CB.muted)
            }
            Spacer()
        }
        .padding(11)
        .background(CB.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(CB.line, lineWidth: 1))
        .padding(.bottom, 8)
    }
}
