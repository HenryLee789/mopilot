import SwiftUI

struct SidebarItem: View {
    let section: AppSection
    let isSelected: Bool
    let isEnabled: Bool

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(section.shortTitle)
                    .font(.callout.weight(.semibold))
                    .lineLimit(1)

                Text(section.sidebarSubtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        } icon: {
            Image(systemName: section.systemImage)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isSelected ? MoPilotPalette.blue : .secondary)
                .frame(width: 22)
        }
        .opacity(isEnabled ? 1 : 0.42)
        .padding(.vertical, 4)
    }
}

struct ModernCard<Content: View>: View {
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 18
    var accent: Color = MoPilotPalette.blue
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
            .overlay(alignment: .top) {
                if showsAccentLine {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(accent.opacity(isHovered ? 0.34 : 0.22), lineWidth: 1)
                } else {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(.white.opacity(colorScheme == .dark ? 0.10 : 0.62), lineWidth: 1)
                }
            }
            .shadow(color: shadowColor, radius: isHovered ? 22 : 16, x: 0, y: isHovered ? 12 : 8)
            .scaleEffect(isHovered ? 1.002 : 1)
            .animation(.easeOut(duration: 0.16), value: isHovered)
            .onHover { isHovered = $0 }
    }

    private var cardBackground: some ShapeStyle {
        LinearGradient(
            colors: [
                Color(nsColor: .controlBackgroundColor).opacity(colorScheme == .dark ? 0.86 : 0.94),
                accent.opacity(colorScheme == .dark ? 0.09 : 0.06)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
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
    var accent: Color = MoPilotPalette.blue
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
    var accent: Color = MoPilotPalette.blue
    var isEnabled = true
    var action: (() -> Void)?

    var body: some View {
        Button {
            action?()
        } label: {
            ModernCard(cornerRadius: 20, padding: 18, accent: accent, showsAccentLine: true) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        IconBadge(systemImage: systemImage, accent: accent)
                        Spacer()
                        StatusTag(title: status, accent: accent)
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
                            .font(.title3.weight(.bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled || action == nil)
        .opacity(isEnabled ? 1 : 0.45)
    }
}

struct PrimaryButton: View {
    let title: String
    let systemImage: String
    var role: ButtonRole?
    var isEnabled = true
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(role: role, action: action) {
            Label(title, systemImage: systemImage)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .padding(.horizontal, 22)
                .padding(.vertical, 12)
                .frame(minWidth: 158)
                .background(buttonGradient)
                .clipShape(Capsule(style: .continuous))
                .shadow(color: shadowColor, radius: isHovered ? 18 : 12, x: 0, y: isHovered ? 9 : 6)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.45)
        .scaleEffect(isHovered && isEnabled ? 1.018 : 1)
        .animation(.easeOut(duration: 0.16), value: isHovered)
        .onHover { isHovered = $0 }
    }

    private var buttonGradient: LinearGradient {
        LinearGradient(
            colors: role == .destructive
                ? [MoPilotPalette.rose, MoPilotPalette.amber]
                : [MoPilotPalette.violet, MoPilotPalette.blue, MoPilotPalette.teal],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var shadowColor: Color {
        (role == .destructive ? MoPilotPalette.rose : MoPilotPalette.blue).opacity(0.22)
    }
}

struct ProgressCard: View {
    let title: String
    let detail: String
    let progress: Double
    let isActive: Bool
    var accent: Color = MoPilotPalette.blue

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
    var accent: Color = MoPilotPalette.blue

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
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
    var accent: Color = MoPilotPalette.blue

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
