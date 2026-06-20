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
            title: "Analyze 磁盘分析",
            subtitle: "优先使用 JSON 输出构建列表；当前 CLI 不支持或解析失败时自动回退原始日志。",
            systemImage: "chart.pie",
            runner: runner
        ) {
            if let moPath = appState.cliStatus.path {
                ProductCard(title: "分析控制台", systemImage: "chart.pie") {
                    Text(appState.capabilities.analyzeModeDescription)
                        .font(.callout)
                        .foregroundStyle(.secondary)

                    HStack {
                        Button {
                            runAnalyze(moPath: moPath)
                        } label: {
                            Label("执行分析", systemImage: "chart.pie")
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(runner.isRunning)

                        RunnerCancelButton(runner: runner)
                        CopyLogButton(text: runner.logText)
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
