import SwiftUI

enum MoPilotPalette {
    static let mint = Color(red: 0.15, green: 0.78, blue: 0.55)
    static let teal = Color(red: 0.02, green: 0.66, blue: 0.78)
    static let blue = Color(red: 0.18, green: 0.46, blue: 0.95)
    static let amber = Color(red: 0.96, green: 0.58, blue: 0.20)
    static let rose = Color(red: 0.92, green: 0.22, blue: 0.34)

    static var heroGradient: LinearGradient {
        LinearGradient(
            colors: [mint, teal, blue.opacity(0.92)],
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
    var maxWidth: CGFloat = 1060
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            MoPilotBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    content
                }
                .padding(24)
                .frame(maxWidth: maxWidth, alignment: .leading)
            }
        }
    }
}

struct MoPilotBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(nsColor: .windowBackgroundColor),
                    MoPilotPalette.mint.opacity(0.08),
                    MoPilotPalette.blue.opacity(0.055),
                    MoPilotPalette.amber.opacity(0.035)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            ScanLineField()
                .opacity(0.45)
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
        HStack(alignment: .center, spacing: 16) {
            AnimatedScanRing(systemImage: systemImage, isActive: true)
                .frame(width: 72, height: 72)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Text(title)
                        .font(.largeTitle.weight(.bold))
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
                    .font(.callout)
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
    @ObservedObject var runner: CommandRunner
    @ViewBuilder let controls: Controls

    var body: some View {
        MoPilotPage {
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
        .padding(14)
        .background(.ultraThinMaterial)
        .background(MoPilotPalette.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
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
        ProductCard(title: metric.title, systemImage: metric.systemImage) {
            Text(metric.value)
                .font(.title2.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(metric.detail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(minHeight: 128)
    }
}

struct ProductCard<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder let content: Content
    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 9) {
                Image(systemName: systemImage)
                    .font(.headline)
                    .foregroundStyle(MoPilotPalette.teal)
                    .frame(width: 22)
                Text(title)
                    .font(.headline)
                Spacer()
            }
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .background(MoPilotPalette.cardGradient.opacity(isHovered ? 1 : 0.72))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(isHovered ? 0.34 : 0.18),
                            MoPilotPalette.teal.opacity(isHovered ? 0.38 : 0.16),
                            Color.secondary.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .shadow(color: Color.black.opacity(isHovered ? 0.12 : 0.075), radius: isHovered ? 18 : 12, x: 0, y: isHovered ? 10 : 6)
        .scaleEffect(isHovered ? 1.004 : 1)
        .animation(.easeOut(duration: 0.18), value: isHovered)
        .onHover { isHovered = $0 }
    }
}

struct RunnerCancelButton: View {
    @ObservedObject var runner: CommandRunner

    var body: some View {
        Button {
            runner.cancel()
        } label: {
            Label("取消", systemImage: "xmark.circle")
        }
        .disabled(!runner.isRunning)
    }
}

struct CopyLogButton: View {
    let text: String

    var body: some View {
        Button {
            Pasteboard.copy(text)
        } label: {
            Label("复制日志", systemImage: "doc.on.doc")
        }
        .disabled(text.isEmpty)
    }
}
