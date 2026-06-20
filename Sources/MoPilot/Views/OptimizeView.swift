import SwiftUI

struct OptimizeView: View {
    @EnvironmentObject private var appState: MoleAppState
    @StateObject private var runner = CommandRunner()
    @State private var showOptimizeConfirmation = false

    var body: some View {
        CommandPageLayout(
            title: "Optimize 系统优化",
            subtitle: "默认先运行 mo optimize --dry-run。执行优化前必须再次确认。",
            systemImage: "slider.horizontal.3",
            runner: runner
        ) {
            ProductCard(title: "优化预览", systemImage: "slider.horizontal.3") {
                Text("系统优化可能影响系统设置或服务行为。请先查看 dry-run 输出，再决定是否执行。")
                    .foregroundStyle(.secondary)

                if let moPath = appState.cliStatus.path {
                    HStack {
                        Button {
                            runner.run(.optimizeDryRun, moPath: moPath)
                        } label: {
                            Label("预览优化", systemImage: "doc.text.magnifyingglass")
                        }
                        .disabled(runner.isRunning)

                        Button {
                            showOptimizeConfirmation = true
                        } label: {
                            Label("执行优化", systemImage: "slider.horizontal.3")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                        .disabled(runner.isRunning || !runner.hasSuccessfulRun(.optimizeDryRun))

                        RunnerCancelButton(runner: runner)
                        CopyLogButton(text: runner.logText)
                    }
                } else {
                    CLIUnavailableView(message: missingMessage)
                }
            }
        }
        .alert("确认执行优化", isPresented: $showOptimizeConfirmation) {
            Button("取消", role: .cancel) {}
            Button("执行优化", role: .destructive) {
                if let moPath = appState.cliStatus.path {
                    runner.run(.optimize, moPath: moPath)
                }
            }
        } message: {
            Text("即将执行 mo optimize。请确认你已经查看 dry-run 结果。该操作可能修改系统偏好或优化项；如 mo 需要管理员权限，本软件不会静默输入密码。")
        }
    }

    private var missingMessage: String {
        if case .missing(let message) = appState.cliStatus {
            return message
        }
        return "未检测到 Mole CLI，请先安装：brew install mole"
    }
}
