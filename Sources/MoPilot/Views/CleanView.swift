import SwiftUI

struct CleanView: View {
    @EnvironmentObject private var appState: MoleAppState
    @StateObject private var runner = CommandRunner()
    @State private var showCleanConfirmation = false
    @State private var didAutoPreview = false

    var body: some View {
        CommandPageLayout(
            title: "Clean 清理缓存",
            subtitle: "默认先运行 mo clean --dry-run。确认看过预览后，才允许执行 mo clean。",
            systemImage: "sparkles",
            runner: runner
        ) {
            if let moPath = appState.cliStatus.path {
                ProductCard(title: "清理预览", systemImage: "sparkles") {
                    Text("MoPilot 会先调用 mo clean --dry-run，把将要清理的内容显示出来。确认无误后，真实清理按钮才会启用。")
                        .foregroundStyle(.secondary)

                    HStack {
                        Button {
                            didAutoPreview = true
                            runner.run(.cleanDryRun, moPath: moPath)
                        } label: {
                            Label("重新预览", systemImage: "doc.text.magnifyingglass")
                        }
                        .disabled(runner.isRunning)

                        Button {
                            showCleanConfirmation = true
                        } label: {
                            Label("执行清理", systemImage: "trash")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .disabled(runner.isRunning || !runner.hasSuccessfulRun(.cleanDryRun))

                        RunnerCancelButton(runner: runner)
                        CopyLogButton(text: runner.logText)
                    }
                }
            } else {
                CLIUnavailableView(message: missingMessage)
            }
        }
        .task(id: appState.cliStatus.path) {
            guard let moPath = appState.cliStatus.path, !didAutoPreview, runner.logText.isEmpty else { return }
            didAutoPreview = true
            runner.run(.cleanDryRun, moPath: moPath)
        }
        .alert("确认执行清理", isPresented: $showCleanConfirmation) {
            Button("取消", role: .cancel) {}
            Button("执行清理", role: .destructive) {
                if let moPath = appState.cliStatus.path {
                    runner.run(.clean, moPath: moPath)
                }
            }
        } message: {
            Text("即将执行 mo clean。请确认你已经查看 dry-run 结果。该操作可能清理系统或应用缓存；如 mo 需要管理员权限，本软件不会静默输入密码。")
        }
    }

    private var missingMessage: String {
        if case .missing(let message) = appState.cliStatus {
            return message
        }
        return "未检测到 Mole CLI，请先安装：brew install mole"
    }
}
