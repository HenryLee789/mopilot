import AppKit
import SwiftUI

// Portions of the shape, theme, scan button, and scan ring ideas in this file
// are adapted from Mac Sai, licensed under the BSD 3-Clause License.
// See THIRD_PARTY_NOTICES.md for the original copyright notice and license.

extension Color {
    init(light: Color, dark: Color) {
        self = Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
                ? NSColor(dark)
                : NSColor(light)
        })
    }
}

private struct PointerHoverModifier: ViewModifier {
    let enabled: Bool
    @State private var isInside = false

    func body(content: Content) -> some View {
        content
            .onHover { inside in
                guard enabled, inside != isInside else { return }
                isInside = inside
                if inside {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
            .onDisappear {
                if isInside {
                    NSCursor.pop()
                    isInside = false
                }
            }
    }
}

extension View {
    func pointingHandOnHover(_ enabled: Bool = true) -> some View {
        modifier(PointerHoverModifier(enabled: enabled))
    }
}

enum MoPilotTheme {
    case smartScan
    case cleanup
    case files
    case applications
    case protection
    case settings

    var gradient: LinearGradient {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var buttonGradient: LinearGradient {
        LinearGradient(colors: buttonColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var colors: [Color] {
        switch self {
        case .smartScan:
            [
                Color(light: Color(red: 0.94, green: 0.91, blue: 0.99), dark: Color(red: 0.20, green: 0.12, blue: 0.50)),
                Color(light: Color(red: 0.90, green: 0.86, blue: 0.98), dark: Color(red: 0.38, green: 0.24, blue: 0.78)),
                Color(light: Color(red: 0.86, green: 0.83, blue: 0.97), dark: Color(red: 0.48, green: 0.36, blue: 0.86))
            ]
        case .cleanup:
            [
                Color(light: Color(red: 0.90, green: 0.97, blue: 0.94), dark: Color(red: 0.05, green: 0.33, blue: 0.24)),
                Color(light: Color(red: 0.85, green: 0.95, blue: 0.90), dark: Color(red: 0.10, green: 0.48, blue: 0.34)),
                Color(light: Color(red: 0.80, green: 0.93, blue: 0.86), dark: Color(red: 0.18, green: 0.62, blue: 0.42))
            ]
        case .files:
            [
                Color(light: Color(red: 0.89, green: 0.96, blue: 0.99), dark: Color(red: 0.04, green: 0.34, blue: 0.49)),
                Color(light: Color(red: 0.84, green: 0.94, blue: 0.98), dark: Color(red: 0.08, green: 0.48, blue: 0.62)),
                Color(light: Color(red: 0.79, green: 0.92, blue: 0.97), dark: Color(red: 0.16, green: 0.62, blue: 0.74))
            ]
        case .applications:
            [
                Color(light: Color(red: 0.95, green: 0.91, blue: 0.99), dark: Color(red: 0.34, green: 0.11, blue: 0.58)),
                Color(light: Color(red: 0.92, green: 0.86, blue: 0.98), dark: Color(red: 0.50, green: 0.22, blue: 0.72)),
                Color(light: Color(red: 0.88, green: 0.82, blue: 0.97), dark: Color(red: 0.63, green: 0.32, blue: 0.82))
            ]
        case .protection:
            [
                Color(light: Color(red: 0.99, green: 0.93, blue: 0.92), dark: Color(red: 0.55, green: 0.10, blue: 0.12)),
                Color(light: Color(red: 0.99, green: 0.89, blue: 0.87), dark: Color(red: 0.72, green: 0.20, blue: 0.18)),
                Color(light: Color(red: 0.98, green: 0.85, blue: 0.83), dark: Color(red: 0.86, green: 0.32, blue: 0.24))
            ]
        case .settings:
            [
                Color(light: Color(red: 0.96, green: 0.97, blue: 0.98), dark: Color(red: 0.15, green: 0.16, blue: 0.20)),
                Color(light: Color(red: 0.93, green: 0.94, blue: 0.96), dark: Color(red: 0.24, green: 0.26, blue: 0.31)),
                Color(light: Color(red: 0.90, green: 0.91, blue: 0.94), dark: Color(red: 0.34, green: 0.36, blue: 0.42))
            ]
        }
    }

    var buttonColors: [Color] {
        switch self {
        case .smartScan:
            [Color(red: 0.35, green: 0.22, blue: 0.72), Color(red: 0.52, green: 0.35, blue: 0.88)]
        case .cleanup:
            [Color(red: 0.14, green: 0.50, blue: 0.34), Color(red: 0.26, green: 0.66, blue: 0.44)]
        case .files:
            [Color(red: 0.10, green: 0.48, blue: 0.62), Color(red: 0.20, green: 0.62, blue: 0.76)]
        case .applications:
            [Color(red: 0.50, green: 0.21, blue: 0.72), Color(red: 0.66, green: 0.34, blue: 0.84)]
        case .protection:
            [Color(red: 0.74, green: 0.20, blue: 0.18), Color(red: 0.88, green: 0.35, blue: 0.25)]
        case .settings:
            [Color(red: 0.30, green: 0.32, blue: 0.38), Color(red: 0.42, green: 0.44, blue: 0.51)]
        }
    }

    var accentColor: Color {
        switch self {
        case .smartScan:
            Color(red: 0.42, green: 0.25, blue: 0.82)
        case .cleanup:
            Color(red: 0.12, green: 0.55, blue: 0.35)
        case .files:
            Color(red: 0.10, green: 0.52, blue: 0.65)
        case .applications:
            Color(red: 0.55, green: 0.25, blue: 0.78)
        case .protection:
            Color(red: 0.78, green: 0.22, blue: 0.18)
        case .settings:
            Color(red: 0.40, green: 0.42, blue: 0.49)
        }
    }
}

struct MoPilotSuperEllipse: Shape {
    let cornerRadius: CGFloat

    init(cornerRadius: CGFloat = 20) {
        self.cornerRadius = cornerRadius
    }

    func path(in rect: CGRect) -> Path {
        let minDimension = min(rect.width, rect.height)
        let radius = min(cornerRadius, minDimension / 2)
        let n: CGFloat = 4
        let centerX = rect.midX
        let centerY = rect.midY
        let a = rect.width / 2
        let b = rect.height / 2
        let steps = 360
        let blendFactor = radius / (minDimension / 2)

        var path = Path()
        for i in 0...steps {
            let angle = CGFloat(i) * .pi * 2 / CGFloat(steps)
            let cosA = cos(angle)
            let sinA = sin(angle)
            let superX = pow(abs(cosA), 2.0 / n) * a * (cosA >= 0 ? 1 : -1)
            let superY = pow(abs(sinA), 2.0 / n) * b * (sinA >= 0 ? 1 : -1)
            let ellipseX = a * cosA
            let ellipseY = b * sinA
            let x = centerX + ellipseX + (superX - ellipseX) * blendFactor
            let y = centerY + ellipseY + (superY - ellipseY) * blendFactor

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        path.closeSubpath()
        return path
    }
}

struct MoPilotSuperEllipseButtonStyle: ButtonStyle {
    let gradient: LinearGradient
    let size: CGSize

    init(gradient: LinearGradient, size: CGSize = CGSize(width: 160, height: 160)) {
        self.gradient = gradient
        self.size = size
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size.height > 60 ? 18 : 14, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size.width, height: size.height)
            .background {
                ZStack {
                    gradient
                    Color.white.opacity(0.08)
                }
            }
            .clipShape(MoPilotSuperEllipse(cornerRadius: size.width * 0.28))
            .shadow(color: .black.opacity(0.22), radius: 16, y: 8)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct SidebarItem: View {
    let section: AppSection
    let isSelected: Bool
    let isEnabled: Bool
    @State private var isHovered = false

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(section.shortTitle)
                    .font(.system(size: 13, weight: section == .dashboard ? .semibold : .regular))
                    .lineLimit(1)

                Text(section.sidebarSubtitle)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        } icon: {
            Image(systemName: section.systemImage)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isSelected || isHovered ? section.theme.accentColor : Color.secondary)
                .frame(width: 22)
                .scaleEffect(isHovered && isEnabled ? 1.08 : 1)
        }
        .opacity(isEnabled ? 1 : 0.42)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(section.theme.accentColor.opacity(isHovered && !isSelected && isEnabled ? 0.11 : 0))
        }
        .contentShape(Rectangle())
        .pointingHandOnHover(isEnabled)
        .onHover { isHovered = $0 }
        .animation(.easeOut(duration: 0.14), value: isHovered)
    }
}

struct ThemedBackground: View {
    let theme: MoPilotTheme

    var body: some View {
        ZStack {
            theme.gradient
            LinearGradient(
                colors: [Color.white.opacity(0.10), Color.clear, Color.black.opacity(0.04)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

struct ModernCard<Content: View>: View {
    var cornerRadius: CGFloat = 22
    var padding: CGFloat = 18
    var accent: Color = MoPilotTheme.smartScan.accentColor
    var showsAccentLine = false
    @ViewBuilder let content: Content
    @Environment(\.colorScheme) private var colorScheme
    @State private var isHovered = false

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(strokeColor, lineWidth: 1)
            }
            .shadow(color: shadowColor, radius: isHovered ? 22 : 15, x: 0, y: isHovered ? 12 : 8)
            .scaleEffect(isHovered ? 1.002 : 1)
            .animation(.easeOut(duration: 0.16), value: isHovered)
            .onHover { isHovered = $0 }
    }

    private var cardBackground: some ShapeStyle {
        LinearGradient(
            colors: [
                Color(nsColor: .controlBackgroundColor).opacity(colorScheme == .dark ? 0.80 : 0.88),
                Color(nsColor: .controlBackgroundColor).opacity(colorScheme == .dark ? 0.58 : 0.70),
                accent.opacity(colorScheme == .dark ? 0.10 : 0.07)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var strokeColor: Color {
        showsAccentLine
            ? accent.opacity(isHovered ? 0.32 : 0.20)
            : Color.white.opacity(colorScheme == .dark ? 0.10 : 0.55)
    }

    private var shadowColor: Color {
        colorScheme == .dark ? Color.black.opacity(0.28) : Color.black.opacity(0.08)
    }
}

struct StatusCard: View {
    let title: String
    let value: String
    let subtitle: String
    let systemImage: String
    var accent: Color = MoPilotTheme.smartScan.accentColor
    var progress: Double?

    var body: some View {
        ModernCard(cornerRadius: 18, padding: 16, accent: accent, showsAccentLine: true) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    IconBadge(systemImage: systemImage, accent: accent)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(value)
                            .font(.headline.weight(.bold))
                            .lineLimit(2)
                            .minimumScaleFactor(0.72)
                    }

                    Spacer()
                }

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                if let progress {
                    ProgressView(value: min(max(progress, 0), 1))
                        .tint(accent)
                }
            }
        }
    }
}

struct FeatureCard: View {
    let title: String
    let subtitle: String
    let estimate: String
    let status: String
    let systemImage: String
    var accent: Color = MoPilotTheme.smartScan.accentColor
    var isEnabled = true
    var action: (() -> Void)?
    @State private var isHovered = false

    var body: some View {
        Button {
            action?()
        } label: {
            ModernCard(cornerRadius: 20, padding: 18, accent: accent, showsAccentLine: true) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        IconBadge(systemImage: systemImage, accent: accent)
                            .scaleEffect(isHovered && isEnabled ? 1.08 : 1)
                        Spacer()
                        StatusTag(title: status, accent: accent)
                            .opacity(isHovered && isEnabled ? 1 : 0.86)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                            .font(.headline.weight(.semibold))
                            .lineLimit(1)
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }

                    HStack(alignment: .firstTextBaseline) {
                        Text(estimate)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.62)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(isHovered && isEnabled ? accent : Color.secondary.opacity(0.55))
                            .offset(x: isHovered && isEnabled ? 4 : 0)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled || action == nil)
        .opacity(isEnabled ? 1 : 0.45)
        .scaleEffect(isHovered && isEnabled ? 1.018 : 1)
        .offset(y: isHovered && isEnabled ? -3 : 0)
        .pointingHandOnHover(isEnabled && action != nil)
        .onHover { isHovered = $0 }
        .animation(.easeOut(duration: 0.16), value: isHovered)
    }
}

struct PrimaryButton: View {
    let title: String
    let systemImage: String
    var role: ButtonRole?
    var isEnabled = true
    var theme: MoPilotTheme = .smartScan
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(role: role, action: action) {
            Label(title, systemImage: systemImage)
                .lineLimit(1)
        }
        .buttonStyle(MoPilotSuperEllipseButtonStyle(
            gradient: role == .destructive ? destructiveGradient : theme.buttonGradient,
            size: CGSize(width: 158, height: 42)
        ))
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.45)
        .brightness(isHovered && isEnabled ? 0.045 : 0)
        .scaleEffect(isHovered && isEnabled ? 1.035 : 1)
        .offset(y: isHovered && isEnabled ? -1 : 0)
        .shadow(color: theme.accentColor.opacity(isHovered && isEnabled ? 0.26 : 0), radius: 14, y: 8)
        .pointingHandOnHover(isEnabled)
        .onHover { isHovered = $0 }
        .animation(.easeOut(duration: 0.16), value: isHovered)
    }

    private var destructiveGradient: LinearGradient {
        LinearGradient(colors: [MoPilotPalette.rose, MoPilotPalette.amber], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct ScanButton: View {
    let title: String
    let subtitle: String?
    var theme: MoPilotTheme = .smartScan
    var isScanning = false
    var progress = 0.0
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        if isScanning {
            ScanProgressRing(progress: progress, phase: title, theme: theme)
        } else {
            Button(action: action) {
                VStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 32, weight: .light))
                        .scaleEffect(isHovered ? 1.08 : 1)
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 11))
                            .opacity(0.72)
                    }
                }
            }
            .buttonStyle(MoPilotSuperEllipseButtonStyle(
                gradient: theme.buttonGradient,
                size: CGSize(width: 160, height: 160)
            ))
            .brightness(isHovered ? 0.05 : 0)
            .scaleEffect(isHovered ? 1.045 : 1)
            .offset(y: isHovered ? -3 : 0)
            .shadow(color: theme.accentColor.opacity(isHovered ? 0.32 : 0), radius: 20, y: 12)
            .pointingHandOnHover()
            .onHover { isHovered = $0 }
            .animation(.spring(response: 0.24, dampingFraction: 0.78), value: isHovered)
        }
    }
}

struct ScanProgressRing: View {
    let progress: Double
    let phase: String
    var detail: String?
    var theme: MoPilotTheme = .smartScan

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .stroke(.primary.opacity(0.12), lineWidth: 7)

                Circle()
                    .trim(from: 0, to: min(max(progress, 0), 1))
                    .stroke(.primary, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.35), value: progress)

                Text("\(Int(min(max(progress, 0), 1) * 100))%")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
            }
            .frame(width: 110, height: 110)

            VStack(spacing: 6) {
                Text(phase)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.primary)
                    .contentTransition(.interpolate)

                if let detail {
                    Text(detail)
                        .font(.system(size: 13))
                        .foregroundStyle(.primary.opacity(0.62))
                }
            }
        }
    }
}

struct ResultPill: View {
    let icon: String
    let label: String
    let value: String
    var theme: MoPilotTheme = .smartScan
    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 22))
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.primary.opacity(0.58))
            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(minWidth: 122)
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(isHovered ? theme.accentColor.opacity(0.14) : Color.primary.opacity(0.08))
        .clipShape(MoPilotSuperEllipse(cornerRadius: 18))
        .foregroundStyle(.primary)
        .scaleEffect(isHovered ? 1.025 : 1)
        .onHover { isHovered = $0 }
        .animation(.easeOut(duration: 0.15), value: isHovered)
    }
}

struct SecondaryHoverButton: View {
    let title: String
    let systemImage: String
    var isEnabled = true
    var accent: Color = MoPilotTheme.smartScan.accentColor
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isHovered && isEnabled ? accent : Color.primary.opacity(0.82))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background {
                    Capsule(style: .continuous)
                        .fill(isHovered && isEnabled ? accent.opacity(0.14) : Color.primary.opacity(0.07))
                }
                .overlay {
                    Capsule(style: .continuous)
                        .stroke(isHovered && isEnabled ? accent.opacity(0.36) : Color.primary.opacity(0.10), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.45)
        .scaleEffect(isHovered && isEnabled ? 1.025 : 1)
        .offset(y: isHovered && isEnabled ? -1 : 0)
        .pointingHandOnHover(isEnabled)
        .onHover { isHovered = $0 }
        .animation(.easeOut(duration: 0.14), value: isHovered)
    }
}

struct ProgressCard: View {
    let title: String
    let detail: String
    let progress: Double
    let isActive: Bool
    var accent: Color = MoPilotTheme.smartScan.accentColor

    var body: some View {
        ModernCard(cornerRadius: 18, padding: 16, accent: accent, showsAccentLine: true) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    if isActive {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(accent)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.headline.weight(.semibold))
                        Text(detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                    Text("\(Int(min(max(progress, 0), 1) * 100))%")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                ProgressView(value: min(max(progress, 0), 1))
                    .tint(accent)
            }
        }
    }
}

struct IconBadge: View {
    let systemImage: String
    var accent: Color = MoPilotTheme.smartScan.accentColor

    var body: some View {
        ZStack {
            MoPilotSuperEllipse(cornerRadius: 12)
                .fill(accent.opacity(0.14))
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(accent)
                .symbolRenderingMode(.hierarchical)
        }
        .frame(width: 42, height: 42)
    }
}

struct StatusTag: View {
    let title: String
    var accent: Color = MoPilotTheme.smartScan.accentColor

    var body: some View {
        Text(title)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(accent)
            .lineLimit(1)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(accent.opacity(0.12), in: Capsule(style: .continuous))
    }
}
