import SwiftUI

/// Running session -> completion recap, in one full-screen flow.
struct SessionFlowView: View {
    @EnvironmentObject var store: SessionStore
    @Environment(\.dismiss) private var dismiss

    let config: SessionConfig

    @State private var finished: FocusSession?

    var body: some View {
        Group {
            if let session = finished {
                DoneView(session: session, onAgain: {
                    finished = nil
                    restartKey = UUID()
                }, onClose: { dismiss() })
            } else {
                SessionView(config: config) { session in
                    store.add(session)
                    finished = session
                }
            }
        }
        .id(restartKey)
    }

    @State private var restartKey = UUID()
}

struct SessionView: View {
    @Environment(\.dismiss) private var dismiss

    let config: SessionConfig
    let onFinish: (FocusSession) -> Void

    @State private var remaining: Int
    @State private var running: Bool = true
    @State private var startedAt: Date = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(config: SessionConfig, onFinish: @escaping (FocusSession) -> Void) {
        self.config = config
        self.onFinish = onFinish
        _remaining = State(initialValue: config.minutes * 60)
    }

    private var companion: Companion { Companion.by(config.companionId) }
    private var total: Int { config.minutes * 60 }
    private var progress: Double { total == 0 ? 0 : Double(total - remaining) / Double(total) }

    var body: some View {
        ZStack {
            CB.dark.ignoresSafeArea()
            VStack(spacing: 0) {
                Text("● In session")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(CB.mint)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(CB.darkCard)
                    .clipShape(Capsule())
                    .padding(.top, 14)

                ring
                    .padding(.top, 10)

                Circle()
                    .fill(LinearGradient(colors: companion.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 58, height: 58)
                    .shadow(color: companion.colors[0].opacity(0.35), radius: 22)
                    .padding(.top, 4)

                Text("\(companion.name) is here with you")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.929, green: 0.937, blue: 0.953))
                    .padding(.top, 10)

                Text(companion.style == .quiet ? "quiet company · no notifications" : companion.style.rawValue)
                    .font(.system(size: 12))
                    .foregroundColor(CB.darkMuted)
                    .padding(.top, 3)

                Text("Working on · \(config.taskName)")
                    .font(.system(size: 12))
                    .foregroundColor(CB.darkMuted)
                    .padding(.top, 18)

                Text("\(companion.ambient)\nJust stay \(max(0, remaining / 60)) more minute\(remaining / 60 == 1 ? "" : "s").")
                    .font(.system(size: 13.5))
                    .foregroundColor(Color(red: 0.776, green: 0.796, blue: 0.839))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 34)
                    .padding(.top, 16)

                Spacer(minLength: 12)

                HStack(spacing: 10) {
                    Button {
                        running.toggle()
                    } label: {
                        Text(running ? "Pause" : "Resume")
                            .font(.system(size: 14.5, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(CB.darkLine, lineWidth: 1))
                    }
                    .foregroundColor(Color(red: 0.843, green: 0.859, blue: 0.890))

                    Button {
                        end(completed: false)
                    } label: {
                        Text("End early")
                            .font(.system(size: 14.5, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                    }
                    .foregroundColor(Color(red: 0.482, green: 0.514, blue: 0.576))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .onReceive(timer) { _ in
            guard running, remaining > 0 else { return }
            remaining -= 1
            if remaining == 0 { end(completed: true) }
        }
    }

    private var ring: some View {
        ZStack {
            Circle()
                .stroke(CB.darkLine, lineWidth: 14)
            Circle()
                .trim(from: 0, to: max(0.001, progress))
                .stroke(CB.blue, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 4) {
                Text(cbClock(remaining))
                    .font(.system(size: 46, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .monospacedDigit()
                Text(running ? "remaining" : "paused")
                    .font(.system(size: 12))
                    .foregroundColor(CB.darkMuted)
            }
        }
        .frame(width: 250, height: 250)
        .animation(.linear(duration: 0.25), value: progress)
    }

    private func end(completed: Bool) {
        let session = FocusSession(
            taskName: config.taskName,
            tagName: config.tagName,
            companionId: config.companionId,
            plannedMinutes: config.minutes,
            focusedSeconds: total - remaining,
            startedAt: startedAt,
            endedAt: Date(),
            mood: nil,
            note: nil,
            completed: completed
        )
        running = false
        onFinish(session)
    }
}
