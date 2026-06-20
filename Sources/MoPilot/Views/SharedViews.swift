import SwiftUI

struct PageHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.linearGradient(
                        colors: [Color.teal.opacity(0.9), Color.green.opacity(0.72), Color.primary.opacity(0.82)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                Image(systemName: "wrench.and.screwdriver")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.largeTitle.weight(.semibold))
                Text(subtitle)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
            Spacer()
        }
    }
}

struct CLIUnavailableView: View {
    let message: String

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Label("未检测到 Mole CLI", systemImage: "exclamationmark.triangle")
                    .font(.headline)
                Text(message)
                    .foregroundStyle(.secondary)
                Text("安装命令：brew install mole")
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
        }
    }
}

struct CommandPageLayout<Controls: View>: View {
    let title: String
    let subtitle: String
    @ObservedObject var runner: CommandRunner
    @ViewBuilder let controls: Controls

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                PageHeader(title: title, subtitle: subtitle)

                GroupBox("操作") {
                    VStack(alignment: .leading, spacing: 12) {
                        controls
                        HStack {
                            Text("状态：\(runner.status.label)")
                                .foregroundStyle(runner.isRunning ? .primary : .secondary)
                            Spacer()
                            if let lastLogURL = runner.lastLogURL {
                                Text(lastLogURL.lastPathComponent)
                                    .foregroundStyle(.secondary)
                                    .textSelection(.enabled)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
                }

                GroupBox("日志输出") {
                    LogOutputView(text: runner.logText)
                }
            }
            .padding(24)
            .frame(maxWidth: 960, alignment: .leading)
        }
    }
}

struct MetricCard: View {
    let metric: StatusMetric

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: metric.systemImage)
                    .font(.title3)
                    .foregroundStyle(.teal)
                Spacer()
            }

            Text(metric.title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(metric.value)
                .font(.title2.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(metric.detail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 128, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.quaternary, lineWidth: 1)
        }
    }
}

struct ProductCard<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .foregroundStyle(.teal)
                Text(title)
                    .font(.headline)
            }
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.quaternary, lineWidth: 1)
        }
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
