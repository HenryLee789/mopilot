import SwiftUI

struct AnalyzeView: View {
    @EnvironmentObject private var appState: MoleAppState
    @StateObject private var runner = CommandRunner()
    @State private var lastAttemptUsedJSON = false
    @State private var didFallbackFromJSON = false

    private var parsedItems: [AnalyzeItem] {
        if let jsonItems = MoleJSONParsers.analyzeItems(from: runner.stdoutText) {
            return jsonItems
        }
        return AnalyzeParser.parse(runner.stdoutText)
    }

    var body: some View {
        CommandPageLayout(
            title: "大文件",
            subtitle: "调用 mo analyze 分析空间占用。支持 JSON 时展示表格，否则自动回退原始日志。",
            systemImage: "folder",
            theme: .files,
            runner: runner
        ) {
            if let moPath = appState.cliStatus.path {
                ModernCard(cornerRadius: 28, padding: 24, accent: MoPilotTheme.files.accentColor, showsAccentLine: true) {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack(alignment: .top, spacing: 16) {
                            IconBadge(systemImage: "folder", accent: MoPilotTheme.files.accentColor)
                            VStack(alignment: .leading, spacing: 6) {
                                Text("查找占用空间较大的项目")
                                    .font(.system(size: 26, weight: .bold))
                                Text(appState.capabilities.analyzeModeDescription)
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            StatusTag(title: parsedItems.isEmpty ? "原始日志" : "\(parsedItems.count) 项", accent: MoPilotTheme.files.accentColor)
                        }

                        if runner.isRunning {
                            ProgressCard(title: "正在分析磁盘占用", detail: "mo analyze 正在后台执行。", progress: 0.58, isActive: true, accent: MoPilotTheme.files.accentColor)
                        }

                        HStack(spacing: 12) {
                            PrimaryButton(title: "开始分析", systemImage: "chart.pie", isEnabled: !runner.isRunning, theme: .files) {
                                runAnalyze(moPath: moPath)
                            }

                            RunnerCancelButton(runner: runner)
                            CopyLogButton(text: runner.logText)
                        }
                    }
                }

                if !parsedItems.isEmpty {
                    ProductCard(title: "分析结果", systemImage: "list.bullet.rectangle") {
                        Table(parsedItems) {
                            TableColumn("名称", value: \.name)
                                .width(min: 120, ideal: 180, max: 260)
                            TableColumn("大小", value: \.size)
                                .width(min: 90, ideal: 120, max: 160)
                            TableColumn("类型", value: \.kind)
                                .width(min: 60, ideal: 80, max: 100)
                            TableColumn("路径", value: \.path)
                        }
                        .frame(minHeight: 180, maxHeight: 260)
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

    private func runAnalyze(moPath: String) {
        didFallbackFromJSON = false
        if let jsonFlag = appState.capabilities.analyzeJSONFlag {
            lastAttemptUsedJSON = true
            runner.run(.analyze, moPath: moPath, arguments: ["analyze", jsonFlag])
        } else {
            lastAttemptUsedJSON = false
            runner.run(.analyze, moPath: moPath)
        }
    }

    private func handleFallbackIfNeeded(status: CommandRunStatus, moPath: String) {
        guard lastAttemptUsedJSON, !didFallbackFromJSON else { return }

        switch status {
        case .failed, .launchFailed:
            didFallbackFromJSON = true
            lastAttemptUsedJSON = false
            runner.run(.analyze, moPath: moPath)
        case .succeeded:
            if MoleJSONParsers.analyzeItems(from: runner.stdoutText) == nil {
                didFallbackFromJSON = true
                lastAttemptUsedJSON = false
                runner.run(.analyze, moPath: moPath)
            }
        default:
            break
        }
    }
}
