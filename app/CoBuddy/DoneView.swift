import SwiftUI

struct DoneView: View {
    @EnvironmentObject var store: SessionStore

    let session: FocusSession
    let onAgain: () -> Void
    let onClose: () -> Void

    @State private var mood: String?
    @State private var note: String = ""

    private var companionName: String { Companion.by(session.companionId).name }

    var body: some View {
        ZStack {
            CB.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                Circle()
                    .fill(CB.coralSoft)
                    .frame(width: 96, height: 96)
                    .overlay(Text("✓").font(.system(size: 44, weight: .bold)).foregroundColor(CB.coral))
                    .padding(.top, 30)

                Text(session.completed ? "Session complete" : "Session saved")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(CB.ink)
                    .padding(.top, 18)

                Text(session.completed
                     ? "\(companionName) stayed the whole time. That counts."
                     : "You stopped early — recording it still keeps the habit going.")
                    .font(.system(size: 13))
                    .foregroundColor(CB.muted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 34)
                    .padding(.top, 6)

                HStack(spacing: 10) {
                    stat(cbClock(session.focusedSeconds), "focused")
                    stat("\(store.streak) 🔥", "day streak")
                    stat(cbHuman(store.secondsToday), "today")
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                Text("HOW DID IT GO?")
                    .font(.system(size: 11.5, weight: .heavy))
                    .foregroundColor(CB.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 24)

                HStack(spacing: 10) {
                    moodButton("😌", "good")
                    moodButton("💪", "strong")
                    moodButton("🥱", "tired")
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                Text("ONE LINE FOR LATER (OPTIONAL)")
                    .font(.system(size: 11.5, weight: .heavy))
                    .foregroundColor(CB.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 22)

                TextField("Hardest part was starting. Fine after 5 min.", text: $note, axis: .vertical)
                    .lineLimit(2...4)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14))
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                Spacer(minLength: 16)

                Button {
                    commit()
                    onAgain()
                } label: {
                    Text("Start another block")
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(CB.coral)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: CB.coral.opacity(0.34), radius: 10, y: 6)
                }
                .padding(.horizontal, 20)

                Button {
                    commit()
                    onClose()
                } label: {
                    Text("Back to home")
                        .font(.system(size: 13.5, weight: .semibold))
                        .foregroundColor(CB.muted)
                        .padding(.vertical, 16)
                }
                .padding(.bottom, 18)
            }
        }
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 3) {
            Text(value).font(.system(size: 19, weight: .bold)).foregroundColor(CB.ink)
            Text(label).font(.system(size: 11.5)).foregroundColor(CB.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 13)
        .background(CB.field)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func moodButton(_ emoji: String, _ value: String) -> some View {
        Button {
            mood = value
        } label: {
            Text(emoji)
                .font(.system(size: 22))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(mood == value ? CB.coralSoft : CB.field)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(mood == value ? CB.coral : CB.line, lineWidth: 1)
                )
        }
    }

    private func commit() {
        if let mood { store.updateMood(session.id, mood: mood) }
        if !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            store.updateNote(session.id, note: note.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
}
