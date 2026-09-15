import SwiftUI

/// Design tokens (iOS 16 compatible — no iOS 17+ APIs anywhere in this project).
enum CB {
    static let ink       = Color(red: 0.118, green: 0.125, blue: 0.149)
    static let muted     = Color(red: 0.541, green: 0.560, blue: 0.596)
    static let coral     = Color(red: 1.000, green: 0.478, blue: 0.349)
    static let coralSoft = Color(red: 1.000, green: 0.914, blue: 0.886)
    static let bg        = Color(red: 0.929, green: 0.906, blue: 0.878)
    static let card      = Color.white
    static let field     = Color(red: 0.965, green: 0.953, blue: 0.937)
    static let line      = Color(red: 0.937, green: 0.918, blue: 0.894)
    static let dark      = Color(red: 0.071, green: 0.078, blue: 0.102)
    static let darkCard  = Color(red: 0.110, green: 0.122, blue: 0.153)
    static let darkLine  = Color(red: 0.145, green: 0.157, blue: 0.196)
    static let darkMuted = Color(red: 0.557, green: 0.580, blue: 0.635)
    static let blue      = Color(red: 0.310, green: 0.722, blue: 1.000)
    static let mint      = Color(red: 0.482, green: 0.878, blue: 0.784)
}

extension View {
    func cbCard() -> some View {
        self.padding(14)
            .background(CB.card)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(CB.line, lineWidth: 1)
            )
    }

    func cbField() -> some View {
        self.padding(.vertical, 13).padding(.horizontal, 14)
            .background(CB.field)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(CB.line, lineWidth: 1)
            )
    }
}

/// mm:ss
func cbClock(_ seconds: Int) -> String {
    let s = max(0, seconds)
    return String(format: "%02d:%02d", s / 60, s % 60)
}

/// 1h 15m / 45m
func cbHuman(_ seconds: Int) -> String {
    let m = seconds / 60
    if m < 60 { return "\(m)m" }
    return "\(m / 60)h \(String(format: "%02d", m % 60))m"
}
