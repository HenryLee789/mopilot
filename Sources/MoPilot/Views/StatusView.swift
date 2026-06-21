import SwiftUI

struct StatusView: View {
    @EnvironmentObject private var appState: MoleAppState
    @StateObject private var runner = CommandRunner()
    @State private var lastAttemptUsedJSON = false
    @State private var didFallbackFromJSON = false

    private var parsedStatus: (metrics: [StatusMetric], processes: [ProcessMetric])? {
        MoleJSONParsers.statusMetrics(from: runner.stdoutText)
    }

    var body: some View {
        CommandPageLayout(
            title: "System Status",
            subtitle: "优先使用 JSON 输出构建状态卡片；当前 CLI 不支持或解析失败时自动回退原始日志。",
            systemImage: "waveform.path.ecg",
            runner: runner
        ) {
            if let moPath = appState.cliStatus.path {
                ModernCard(cornerRadius: 24, padding: 24, accent: MoPilotPalette.violet, showsAccentLine: true) {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack(alignment: .top, spacing: 16) {
                            IconBadge(systemImage: "waveform.path.ecg", accent: MoPilotPalette.violet)
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Live system snapshot")
                                    .font(.system(size: 26, weight: .bold))
                                Text(appState.capabilities.statusModeDescription)
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            StatusTag(title: parsedStatus?.metrics.isEmpty == false ? "Cards" : "Raw Log", accent: MoPilotPalette.violet)
                        }

                        if runner.isRunning {
                            ProgressCard(title: "Refreshing status", detail: "后台调用 mo status。", progress: 0.62, isActive: true, accent: MoPilotPalette.violet)
                        }

                        HStack(spacing: 12) {
                            PrimaryButton(title: "Refresh Status", systemImage: "arrow.clockwise", isEnabled: !runner.isRunning) {
                                runStatus(moPath: moPath)
                            }

                            RunnerCancelButton(runner: runner)
                            CopyLogButton(text: runner.logText)
                        }
                    }
                }

                if let parsedStatus, !parsedStatus.metrics.isEmpty {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 12)], spacing: 12) {
                        ForEach(parsedStatus.metrics) { metric in
                            MetricCard(metric: metric)
                        }
                    }

                    if !parsedStatus.processes.isEmpty {
                        ProductCard(title: "高占用进程", systemImage: "cpu") {
                            Table(parsedStatus.processes) {
                                TableColumn("进程", value: \.name)
                                TableColumn("CPU", value: \.cpu)
                                    .width(min: 70, ideal: 80, max: 100)
                                TableColumn("内存", value: \.memory)
                                    .width(min: 70, ideal: 80, max: 100)
                            }
                            .frame(minHeight: 150, maxHeight: 220)
                        }
                    }
                }
            } else {
                CLIUnavailableView(message: missingMessage)
            }
        }
        .onChange(of: runner.status) { status in
            guard let moPath = appState.cliStatus.path else { return }
            handleFallbackIfNeeded(status: status, moPath: moPath)
        }
    }

    private var missingMessage: String {
        if case .missing(let message) = appState.cliStatus {
            return message
        }
        return "未检测到 Mole CLI，请先安装：brew install mole"
    }

    private func runStatus(moPath: String) {
        didFallbackFromJSON = false
        if let jsonFlag = appState.capabilities.statusJSONFlag {
            lastAttemptUsedJSON = true
            runner.run(.status, moPath: moPath, arguments: ["status", jsonFlag])
        } else {
            lastAttemptUsedJSON = false
            runner.run(.status, moPath: moPath)
        }
    }

    private func handleFallbackIfNeeded(status: CommandRunStatus, moPath: String) {
        guard lastAttemptUsedJSON, !didFallbackFromJSON else { return }

        switch status {
        case .failed, .launchFailed:
            didFallbackFromJSON = true
            lastAttemptUsedJSON = false
            runner.run(.status, moPath: moPath)
        case .succeeded:
            if MoleJSONParsers.statusMetrics(from: runner.stdoutText) == nil {
                didFallbackFromJSON = true
                lastAttemptUsedJSON = false
                runner.run(.status, moPath: moPath)
            }
        default:
            break
        }
    }
}
