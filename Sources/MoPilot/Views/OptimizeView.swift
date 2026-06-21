import SwiftUI

struct OptimizeView: View {
    @EnvironmentObject private var appState: MoleAppState
    @StateObject private var runner = CommandRunner()
    @State private var showOptimizeConfirmation = false

    var body: some View {
        CommandPageLayout(
            title: "Privacy",
            subtitle: "当前入口调用 mo optimize --dry-run 做安全预览；真实执行前必须再次确认。",
            systemImage: "hand.raised",
            theme: .protection,
            runner: runner
        ) {
            ModernCard(cornerRadius: 28, padding: 24, accent: MoPilotTheme.protection.accentColor, showsAccentLine: true) {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(alignment: .top, spacing: 16) {
                        IconBadge(systemImage: "hand.raised", accent: MoPilotTheme.protection.accentColor)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Privacy and safety review")
                                .font(.system(size: 26, weight: .bold))
                            Text("此页面不新增额外隐私清理逻辑，只展示并执行本机 mo optimize 的 dry-run/确认流程。")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                        StatusTag(title: runner.hasSuccessfulRun(.optimizeDryRun) ? "Previewed" : "Dry-run first", accent: MoPilotTheme.protection.accentColor)
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 190), spacing: 14)], spacing: 14) {
                        FeatureCard(title: "Safety Preview", subtitle: "先查看 mo 输出，不直接修改系统。", estimate: runner.hasSuccessfulRun(.optimizeDryRun) ? "Ready" : "Required", status: "Dry-run", systemImage: "doc.text.magnifyingglass", accent: MoPilotTheme.protection.accentColor)
                        FeatureCard(title: "Confirmation", subtitle: "真实执行前弹出确认窗口。", estimate: "Manual", status: "Protected", systemImage: "lock.shield", accent: MoPilotPalette.amber)
                    }

                    if runner.isRunning {
                        ProgressCard(title: "Running optimize preview", detail: "后台调用 mo optimize。", progress: 0.56, isActive: true, accent: MoPilotTheme.protection.accentColor)
                    }

                    if let moPath = appState.cliStatus.path {
                        HStack(spacing: 12) {
                            PrimaryButton(title: "Preview", systemImage: "doc.text.magnifyingglass", isEnabled: !runner.isRunning, theme: .protection) {
                                runner.run(.optimizeDryRun, moPath: moPath)
                            }

                            PrimaryButton(title: "Apply", systemImage: "slider.horizontal.3", role: .destructive, isEnabled: !runner.isRunning && runner.hasSuccessfulRun(.optimizeDryRun), theme: .protection) {
                                showOptimizeConfirmation = true
                            }

                            RunnerCancelButton(runner: runner)
                            CopyLogButton(text: runner.logText)
                        }
                    } else {
                        CLIUnavailableView(message: missingMessage)
                    }
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
