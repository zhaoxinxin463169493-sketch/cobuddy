import SwiftUI

@main
struct CoBuddyApp: App {
    @StateObject private var store = SessionStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(.light)
        }
    }
}

struct SessionConfig: Identifiable, Hashable {
    var id = UUID()
    var taskName: String
    var tagName: String
    var companionId: String
    var minutes: Int
}

struct RootView: View {
    @State private var tab: Int = 0
    @State private var active: SessionConfig?

    var body: some View {
        TabView(selection: $tab) {
            HomeView(active: $active)
                .tag(0)
                .tabItem { Label("Home", systemImage: "hexagon.fill") }

            StatsView()
                .tag(1)
                .tabItem { Label("Stats", systemImage: "chart.bar.fill") }

            CompanionsView()
                .tag(2)
                .tabItem { Label("Companions", systemImage: "face.smiling") }

            SettingsView()
                .tag(3)
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(CB.coral)
        .fullScreenCover(item: $active) { config in
            SessionFlowView(config: config)
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var store: SessionStore

    var body: some View {
        NavigationStack {
            List {
                Section("Your data") {
                    LabeledContent("Sessions stored", value: "\(store.sessions.count)")
                    LabeledContent("Saved on", value: "This iPhone only")
                }
                Section("About") {
                    LabeledContent("Version", value: "1.0 (M1)")
                    Text("CoBuddy keeps you company while you work. No account, no tracking, nothing uploaded.")
                        .font(.footnote)
                        .foregroundColor(CB.muted)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
