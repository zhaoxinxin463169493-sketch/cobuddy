import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: SessionStore
    @Binding var active: SessionConfig?

    @State private var taskName: String = ""

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        if h < 12 { return "☀️ Good morning" }
        if h < 18 { return "☀️ Good afternoon" }
        return "🌙 Good evening"
    }

    var body: some View {
        ZStack {
            CB.bg.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(greeting)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(red: 0.851, green: 0.314, blue: 0.180))
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(CB.coralSoft)
                            .clipShape(Capsule())

                        Text("What are you\nworking on?")
                            .font(.system(size: 27, weight: .bold))
                            .foregroundColor(CB.ink)
                            .lineSpacing(2)
                            .padding(.top, 14)

                        Text("Name the task and pick a block. Someone will stay with you.")
                            .font(.system(size: 13))
                            .foregroundColor(CB.muted)
                            .padding(.top, 6)

                        TextField("e.g. Finish the report draft", text: $taskName)
                            .textFieldStyle(.plain)
                            .font(.system(size: 14))
                            .cbField()
                            .padding(.top, 16)

                        FlowChips(tagName: $store.tagName)
                            .padding(.top, 12)

                        sectionLabel("Focus block")
                        HStack(spacing: 8) {
                            ForEach(cbDurations, id: \.self) { m in
                                Button {
                                    store.durationMinutes = m
                                } label: {
                                    Text("\(m)")
                                        .font(.system(size: 14, weight: .bold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 11)
                                }
                                .foregroundColor(store.durationMinutes == m ? .white : CB.ink)
                                .background(store.durationMinutes == m ? CB.coral : CB.field)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(store.durationMinutes == m ? CB.coral : CB.line, lineWidth: 1)
                                )
                            }
                        }

                        sectionLabel("Companion")
                        companionRow

                        Text("No sign-up. Nothing is shared.\nSessions stay on your phone.")
                            .font(.system(size: 12))
                            .foregroundColor(CB.muted)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 18)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                }

                Button {
                    start()
                } label: {
                    Text("Start session")
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(CB.coral)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: CB.coral.opacity(0.34), radius: 10, y: 6)
                }
                .padding(.horizontal, 20)

                Text(footerText)
                    .font(.system(size: 12))
                    .foregroundColor(CB.muted)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                    .padding(.bottom, 6)
            }
        }
    }

    private var footerText: String {
        let n = store.sessionsThisWeek
        let s = store.streak
        if n == 0 { return "No sessions yet — the first one is the hardest" }
        return s > 1 ? "\(n) sessions this week · \(s)-day streak" : "\(n) sessions this week"
    }

    private var companionRow: some View {
        let c = Companion.by(store.companionId)
        return HStack(spacing: 12) {
            Circle()
                .fill(LinearGradient(colors: c.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 46, height: 46)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(c.name) · \(c.style == .quiet ? "quiet company" : c.style.rawValue)")
                    .font(.system(size: 14.5, weight: .bold))
                    .foregroundColor(CB.ink)
                Text(c.tagline)
                    .font(.system(size: 12))
                    .foregroundColor(CB.muted)
            }
            Spacer()
            Menu {
                ForEach(Companion.all) { item in
                    Button(item.name) { store.companionId = item.id }
                }
            } label: {
                Text("CHANGE")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(Color(red: 0.851, green: 0.314, blue: 0.180))
                    .padding(.horizontal, 9).padding(.vertical, 5)
                    .background(CB.coralSoft)
                    .clipShape(Capsule())
            }
        }
        .cbCard()
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 11.5, weight: .heavy))
            .foregroundColor(CB.muted)
            .padding(.top, 22)
            .padding(.bottom, 10)
    }

    private func start() {
        let trimmed = taskName.trimmingCharacters(in: .whitespacesAndNewlines)
        active = SessionConfig(
            taskName: trimmed.isEmpty ? "Just focus" : trimmed,
            tagName: store.tagName,
            companionId: store.companionId,
            minutes: store.durationMinutes
        )
    }
}

/// Simple wrapping chip row for tags.
struct FlowChips: View {
    @Binding var tagName: String

    var body: some View {
        HStack(spacing: 8) {
            ForEach(TaskTag.allCases.prefix(3)) { tag in
                chip(tag)
            }
        }
    }

    private func chip(_ tag: TaskTag) -> some View {
        let on = tagName == tag.rawValue
        return Button {
            tagName = tag.rawValue
        } label: {
            Text("\(tag.emoji) \(tag.rawValue)")
                .font(.system(size: 12.5, weight: .semibold))
                .lineLimit(1)
                .padding(.horizontal, 13).padding(.vertical, 8)
        }
        .foregroundColor(on ? .white : CB.ink)
        .background(on ? CB.ink : CB.field)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(on ? CB.ink : CB.line, lineWidth: 1))
    }
}
