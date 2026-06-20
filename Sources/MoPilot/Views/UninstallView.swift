import SwiftUI

struct UninstallView: View {
    @EnvironmentObject private var appState: MoleAppState
    @StateObject private var runner = CommandRunner()
    @State private var showTerminalConfirmation = false
    @State private var launchMessage = ""

    var body: some View {
        CommandPageLayout(
            title: "Uninstall 卸载残留",
            subtitle: "先运行 mo uninstall --dry-run 预览；真实卸载只通过 Terminal.app 交互执行。即使 mo 进入 TUI，MoPilot 也不会自动确认删除。",
            runner: runner
        ) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("该功能可能涉及应用卸载和残留扫描。", systemImage: "exclamationmark.triangle")
                    Label("MoPilot 不会自动确认删除选项。", systemImage: "hand.raised")
                    Label("如 mo 需要管理员权限，请在终端中自行确认。", systemImage: "lock")
                }
                .foregroundStyle(.secondary)

                if let moPath = appState.cliStatus.path {
                    HStack {
                        Button {
                            runner.run(.uninstallDryRun, moPath: moPath)
                        } label: {
                            Label("预览卸载扫描", systemImage: "doc.text.magnifyingglass")
                        }
                        .disabled(runner.isRunning)

                        Button {
                            showTerminalConfirmation = true
                        } label: {
                            Label("打开终端运行 mo uninstall", systemImage: "terminal")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                        .disabled(runner.isRunning)

                        RunnerCancelButton(runner: runner)
                        CopyLogButton(text: runner.logText)
                    }
                    Text(launchMessage)
                        .foregroundStyle(.secondary)
                } else {
                    CLIUnavailableView(message: missingMessage)
                }
            }
        }
        .alert("在终端中运行卸载扫描", isPresented: $showTerminalConfirmation) {
            Button("取消", role: .cancel) {}
            Button("打开终端") {
                openTerminal()
            }
        } message: {
            Text("即将打开 Terminal.app 并运行 mo uninstall。请在终端中查看交互提示，不要盲目确认删除。")
        }
    }

    private func openTerminal() {
        guard let moPath = appState.cliStatus.path else { return }
        do {
            try AppleScriptTerminalLauncher.openTerminal(command: ShellEscaping.commandLine([moPath, "uninstall"]))
            launchMessage = "已请求打开 Terminal.app。"
        } catch {
            launchMessage = "打开终端失败：\(error.localizedDescription)"
        }
    }

    private var missingMessage: String {
        if case .missing(let message) = appState.cliStatus {
            return message
        }
        return "未检测到 Mole CLI，请先安装：brew install mole"
    }
}
