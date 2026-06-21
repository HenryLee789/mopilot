import SwiftUI

struct CleanView: View {
    @EnvironmentObject private var appState: MoleAppState
    @StateObject private var runner = CommandRunner()
    @State private var showCleanConfirmation = false
    @State private var didAutoPreview = false

    var body: some View {
        CommandPageLayout(
            title: "System Junk",
            subtitle: "默认先运行 mo clean --dry-run。确认看过预览后，才允许执行 mo clean。",
            systemImage: "sparkles",
            runner: runner
        ) {
            if let moPath = appState.cliStatus.path {
                cleanScanPanel(moPath: moPath)
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

    private func cleanScanPanel(moPath: String) -> some View {
        ModernCard(cornerRadius: 24, padding: 24, accent: MoPilotPalette.blue, showsAccentLine: true) {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(runner.hasSuccessfulRun(.clean) ? "清理已完成" : runner.hasSuccessfulRun(.cleanDryRun) ? "预览已完成" : "安全清理扫描")
                        .font(.system(size: 28, weight: .bold))
                    Text(runner.hasSuccessfulRun(.cleanDryRun) ? "你可以查看日志确认范围，再执行真实清理。" : "先运行 dry-run，只预览、不删除。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if runner.isRunning {
                    ProgressCard(
                        title: "Running dry-run",
                        detail: "后台调用 mo，日志会实时显示在下方。",
                        progress: 0.64,
                        isActive: true,
                        accent: MoPilotPalette.blue
                    )
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 14)], spacing: 14) {
                    FeatureCard(title: "System Cache", subtitle: "系统缓存范围以 mo 输出为准。", estimate: runner.hasSuccessfulRun(.cleanDryRun) ? "Previewed" : "Pending", status: "Dry-run", systemImage: "internaldrive", accent: MoPilotPalette.blue)
                    FeatureCard(title: "App Cache", subtitle: "应用缓存预览后才允许清理。", estimate: runner.hasSuccessfulRun(.clean) ? "Cleaned" : "Protected", status: "Confirm", systemImage: "app.dashed", accent: MoPilotPalette.mint)
                    FeatureCard(title: "Saved Logs", subtitle: "每次命令自动保存日志文件。", estimate: runner.lastLogURL?.lastPathComponent ?? "Auto", status: "Log", systemImage: "doc.text", accent: MoPilotPalette.amber)
                }

                HStack(spacing: 12) {
                    PrimaryButton(title: runner.hasSuccessfulRun(.cleanDryRun) ? "重新预览" : "Start Scan", systemImage: "magnifyingglass", isEnabled: !runner.isRunning) {
                        didAutoPreview = true
                        runner.run(.cleanDryRun, moPath: moPath)
                    }

                    PrimaryButton(title: "Clean Now", systemImage: "trash", role: .destructive, isEnabled: !runner.isRunning && runner.hasSuccessfulRun(.cleanDryRun)) {
                        showCleanConfirmation = true
                    }

                    RunnerCancelButton(runner: runner)
                    CopyLogButton(text: runner.logText)
                }
            }
        }
    }
}
