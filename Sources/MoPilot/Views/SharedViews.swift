import SwiftUI

enum MoPilotPalette {
    static let mint = Color(red: 0.15, green: 0.78, blue: 0.55)
    static let teal = Color(red: 0.02, green: 0.66, blue: 0.78)
    static let blue = Color(red: 0.18, green: 0.46, blue: 0.95)
    static let violet = Color(red: 0.46, green: 0.34, blue: 0.96)
    static let magenta = Color(red: 0.86, green: 0.22, blue: 0.78)
    static let amber = Color(red: 0.96, green: 0.58, blue: 0.20)
    static let rose = Color(red: 0.92, green: 0.22, blue: 0.34)

    static var heroGradient: LinearGradient {
        LinearGradient(
            colors: [mint, teal, blue.opacity(0.92), violet.opacity(0.86)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var smartGradient: LinearGradient {
        LinearGradient(
            colors: [
                violet.opacity(0.88),
                blue.opacity(0.88),
                teal.opacity(0.86),
                mint.opacity(0.82)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var cardGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.18),
                mint.opacity(0.08),
                blue.opacity(0.06)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct MoPilotPage<Content: View>: View {
    var theme: MoPilotTheme = .smartScan
    var maxWidth: CGFloat = 1120
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            MoPilotBackground(theme: theme)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    content
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 28)
                .frame(maxWidth: maxWidth, alignment: .leading)
            }
        }
    }
}

struct MoPilotBackground: View {
    var theme: MoPilotTheme = .smartScan

    var body: some View {
        ZStack {
            ThemedBackground(theme: theme)

            ScanLineField()
                .opacity(0.08)
        }
    }
}

private struct ScanLineField: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let seconds = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
                let phase = CGFloat(seconds.truncatingRemainder(dividingBy: 8)) / 8
                let spacing: CGFloat = 42
                let offset = phase * spacing

                for index in 0...24 {
                    let y = CGFloat(index) * spacing - offset
                    var path = Path()
                    path.move(to: CGPoint(x: -40, y: y))
                    path.addLine(to: CGPoint(x: size.width + 80, y: y + size.width * 0.08))
                    context.stroke(
                        path,
                        with: .linearGradient(
                            Gradient(colors: [
                                MoPilotPalette.teal.opacity(0.02),
                                MoPilotPalette.teal.opacity(0.09),
                                MoPilotPalette.amber.opacity(0.04)
                            ]),
                            startPoint: CGPoint(x: 0, y: y),
                            endPoint: CGPoint(x: size.width, y: y)
                        ),
                        lineWidth: 1
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct PageHeader: View {
    let title: String
    let subtitle: String
    var systemImage: String = "wrench.and.screwdriver"

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            IconBadge(systemImage: systemImage, accent: MoPilotPalette.blue)
                .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Text(title)
                        .font(.system(size: 30, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Text("Live")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MoPilotPalette.mint)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(MoPilotPalette.mint.opacity(0.12), in: Capsule())
                }

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 4)
    }
}

struct AnimatedScanRing: View {
    let systemImage: String
    var isActive: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation) { timeline in
            let seconds = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
            let rotation = Angle.degrees(isActive ? seconds * 58 : 0)
            let pulse = isActive && !reduceMotion ? 0.5 + 0.5 * sin(seconds * 2.4) : 0.6

            ZStack {
                Circle()
                    .fill(MoPilotPalette.heroGradient)
                    .shadow(color: MoPilotPalette.teal.opacity(0.24), radius: 16, x: 0, y: 8)

                Circle()
                    .stroke(Color.white.opacity(0.28), lineWidth: 1)
                    .padding(4)

                Circle()
                    .trim(from: 0.08, to: 0.34)
                    .stroke(
                        AngularGradient(
                            colors: [.white.opacity(0.12), .white, MoPilotPalette.amber.opacity(0.95)],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .padding(6)
                    .rotationEffect(rotation)
                    .opacity(0.78 + 0.18 * pulse)

                Image(systemName: systemImage)
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundStyle(.white)
                    .symbolRenderingMode(.hierarchical)
            }
        }
    }
}

struct SmartScannerOrb: View {
    let systemImage: String
    let title: String
    let subtitle: String
    var isActive: Bool = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation) { timeline in
            let seconds = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
            let rotation = Angle.degrees(isActive ? seconds * 42 : 0)
            let counterRotation = Angle.degrees(isActive ? -seconds * 24 : 0)
            let pulse = isActive && !reduceMotion ? 0.94 + 0.04 * sin(seconds * 2.2) : 1

            ZStack {
                Circle()
                    .fill(MoPilotPalette.smartGradient)
                    .shadow(color: MoPilotPalette.blue.opacity(0.20), radius: 22, x: 0, y: 14)
                    .shadow(color: MoPilotPalette.mint.opacity(0.12), radius: 14, x: -6, y: -6)

                Circle()
                    .stroke(Color.white.opacity(0.12), lineWidth: 14)
                    .padding(18)

                Circle()
                    .trim(from: 0.02, to: 0.28)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.08), .white.opacity(0.92), MoPilotPalette.mint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .padding(12)
                    .rotationEffect(rotation)

                Circle()
                    .trim(from: 0.56, to: 0.78)
                    .stroke(
                        LinearGradient(
                            colors: [MoPilotPalette.magenta.opacity(0.15), .white.opacity(0.78)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .padding(30)
                    .rotationEffect(counterRotation)

                RadialGradient(
                    colors: [.white.opacity(0.24), .clear],
                    center: .topLeading,
                    startRadius: 4,
                    endRadius: 160
                )
                .clipShape(Circle())
                .padding(8)

                VStack(spacing: 8) {
                    Image(systemName: systemImage)
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(.white)
                        .symbolRenderingMode(.hierarchical)
                    Text(title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(subtitle)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.78))
                        .lineLimit(1)
                }
                .padding(.horizontal, 24)
            }
            .scaleEffect(pulse)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct SmartModuleTile: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let accent: Color
    var isEnabled: Bool = true
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(accent.opacity(isHovered ? 0.24 : 0.16))
                    Image(systemName: systemImage)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(accent)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.tertiary)
                    .offset(x: isHovered && isEnabled ? 3 : 0)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 70, alignment: .leading)
            .background(.regularMaterial)
            .background(accent.opacity(isHovered ? 0.12 : 0.055))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(accent.opacity(isHovered ? 0.36 : 0.16), lineWidth: 1)
            }
            .shadow(color: accent.opacity(isHovered ? 0.16 : 0.06), radius: isHovered ? 16 : 8, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.45)
        .scaleEffect(isHovered && isEnabled ? 1.012 : 1)
        .pointingHandOnHover(isEnabled)
        .animation(.easeOut(duration: 0.16), value: isHovered)
        .onHover { isHovered = $0 }
    }
}

struct SmartActionButton: View {
    let title: String
    let systemImage: String
    var role: ButtonRole?
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        PrimaryButton(title: title, systemImage: systemImage, role: role, action: action)
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .foregroundStyle(.secondary)
                .frame(width: 86, alignment: .leading)
            Text(value)
                .textSelection(.enabled)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer()
        }
    }
}

struct CLIUnavailableView: View {
    let message: String

    var body: some View {
        ProductCard(title: "未检测到 Mole CLI", systemImage: "exclamationmark.triangle") {
            VStack(alignment: .leading, spacing: 10) {
                Text(message)
                    .foregroundStyle(.secondary)
                Text("安装命令：brew install mole")
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
            }
        }
    }
}

struct CommandPageLayout<Controls: View>: View {
    let title: String
    let subtitle: String
    var systemImage: String = "sparkles"
    var theme: MoPilotTheme = .smartScan
    @ObservedObject var runner: CommandRunner
    @ViewBuilder let controls: Controls

    var body: some View {
        MoPilotPage(theme: theme, maxWidth: 1140) {
            PageHeader(title: title, subtitle: subtitle, systemImage: systemImage)
            controls
            CommandStatusStrip(runner: runner)
            ProductCard(title: "实时日志", systemImage: "terminal") {
                LogOutputView(text: runner.logText)
            }
        }
    }
}

struct CommandStatusStrip: View {
    @ObservedObject var runner: CommandRunner

    var body: some View {
        ModernCard(cornerRadius: 18, padding: 16, accent: MoPilotPalette.blue, showsAccentLine: true) {
            HStack(spacing: 14) {
                AnimatedStatusDot(isRunning: runner.isRunning)

                VStack(alignment: .leading, spacing: 2) {
                    Text("状态：\(runner.status.label)")
                        .font(.headline)
                    Text(statusDetail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                if let lastLogURL = runner.lastLogURL {
                    Label(lastLogURL.lastPathComponent, systemImage: "doc.text")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
            }
        }
    }

    private var statusDetail: String {
        if runner.isRunning {
            return "正在后台调用本机 mo CLI，输出会实时写入日志。"
        }
        if runner.logText.isEmpty {
            return "等待执行。危险操作会先 dry-run 预览。"
        }
        return "最近一次命令已结束，日志已保存或可复制。"
    }
}

struct AnimatedStatusDot: View {
    let isRunning: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation) { timeline in
            let seconds = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
            let scale = isRunning ? 0.88 + 0.18 * sin(seconds * 5) : 1

            ZStack {
                Circle()
                    .fill(isRunning ? MoPilotPalette.mint.opacity(0.2) : Color.secondary.opacity(0.12))
                    .frame(width: 36, height: 36)
                    .scaleEffect(scale)
                Circle()
                    .fill(isRunning ? MoPilotPalette.mint : Color.secondary.opacity(0.65))
                    .frame(width: 12, height: 12)
            }
        }
    }
}

struct MetricCard: View {
    let metric: StatusMetric

    var body: some View {
        StatusCard(
            title: metric.title,
            value: metric.value,
            subtitle: metric.detail,
            systemImage: metric.systemImage,
            accent: MoPilotPalette.teal
        )
        .frame(minHeight: 128)
    }
}

struct ProductCard<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder let content: Content
    @State private var isHovered = false

    var body: some View {
        ModernCard(cornerRadius: 20, padding: 18, accent: MoPilotPalette.teal, showsAccentLine: true) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    IconBadge(systemImage: systemImage, accent: MoPilotPalette.teal)
                        .frame(width: 34, height: 34)
                    Text(title)
                        .font(.headline.weight(.semibold))
                    Spacer()
                }
                content
            }
        }
    }
}

struct RunnerCancelButton: View {
    @ObservedObject var runner: CommandRunner

    var body: some View {
        SecondaryHoverButton(
            title: "取消",
            systemImage: "xmark.circle",
            isEnabled: runner.isRunning,
            accent: MoPilotPalette.rose
        ) {
            runner.cancel()
        }
    }
}

struct CopyLogButton: View {
    let text: String

    var body: some View {
        SecondaryHoverButton(
            title: "复制日志",
            systemImage: "doc.on.doc",
            isEnabled: !text.isEmpty,
            accent: MoPilotTheme.files.accentColor
        ) {
            Pasteboard.copy(text)
        }
    }
}
