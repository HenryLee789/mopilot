import SwiftUI

struct CleanView: View {
    @EnvironmentObject private var appState: MoleAppState
    @StateObject private var runner = CommandRunner()
    @State private var showCleanConfirmation = false
    @State private var didAutoPreview = false

    var body: some View {
        CommandPageLayout(
            title: "系统垃圾",
            subtitle: "默认先运行 mo clean --dry-run。确认看过安全预览后，才允许执行 mo clean。",
            systemImage: "sparkles",
            theme: .cleanup,
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
            Text("即将执行 mo clean。请确认你已经查看安全预览结果。该操作可能清理系统或应用缓存；如 mo 需要管理员权限，本软件不会静默输入密码。")
        }
    }

    private var missingMessage: String {
        if case .missing(let message) = appState.cliStatus {
            return message
        }
        return "未检测到 Mole CLI，请先安装：brew install mole"
    }

    private func cleanScanPanel(moPath: String) -> some View {
        ModernCard(cornerRadius: 28, padding: 24, accent: MoPilotTheme.cleanup.accentColor, showsAccentLine: true) {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(runner.hasSuccessfulRun(.clean) ? "清理已完成" : runner.hasSuccessfulRun(.cleanDryRun) ? "预览已完成" : "安全清理扫描")
                        .font(.system(size: 28, weight: .bold))
                    Text(runner.hasSuccessfulRun(.cleanDryRun) ? "你可以查看日志确认范围，再执行真实清理。" : "先做安全预览，只预览、不删除。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if runner.isRunning {
                    ProgressCard(
                        title: "正在安全预览",
                        detail: "后台调用 mo，日志会实时显示在下方。",
                        progress: 0.64,
                        isActive: true,
                        accent: MoPilotTheme.cleanup.accentColor
                    )
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 14)], spacing: 14) {
                    FeatureCard(title: "系统缓存", subtitle: "系统缓存范围以 mo 输出为准。", estimate: runner.hasSuccessfulRun(.cleanDryRun) ? "已预览" : "待预览", status: "预览", systemImage: "internaldrive", accent: MoPilotTheme.cleanup.accentColor)
                    FeatureCard(title: "应用缓存", subtitle: "应用缓存预览后才允许清理。", estimate: runner.hasSuccessfulRun(.clean) ? "已清理" : "受保护", status: "确认", systemImage: "app.dashed", accent: MoPilotTheme.cleanup.accentColor)
                    FeatureCard(title: "日志记录", subtitle: "每次命令自动保存日志文件。", estimate: runner.lastLogURL?.lastPathComponent ?? "自动保存", status: "日志", systemImage: "doc.text", accent: MoPilotPalette.amber)
                }

                HStack(spacing: 12) {
                    PrimaryButton(title: runner.hasSuccessfulRun(.cleanDryRun) ? "重新预览" : "开始扫描", systemImage: "magnifyingglass", isEnabled: !runner.isRunning, theme: .cleanup) {
                        didAutoPreview = true
                        runner.run(.cleanDryRun, moPath: moPath)
                    }

                    PrimaryButton(title: "立即清理", systemImage: "trash", role: .destructive, isEnabled: !runner.isRunning && runner.hasSuccessfulRun(.cleanDryRun), theme: .cleanup) {
                        showCleanConfirmation = true
                    }

                    RunnerCancelButton(runner: runner)
                    CopyLogButton(text: runner.logText)
                }
            }
        }
    }
}
