import SwiftUI

struct OptimizeView: View {
    @EnvironmentObject private var appState: MoleAppState
    @StateObject private var runner = CommandRunner()
    @State private var showOptimizeConfirmation = false

    var body: some View {
        CommandPageLayout(
            title: "隐私保护",
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
                            Text("隐私与安全预览")
                                .font(.system(size: 26, weight: .bold))
                            Text("此页面不新增额外隐私清理逻辑，只展示并执行本机 mo optimize 的安全预览和确认流程。")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                        StatusTag(title: runner.hasSuccessfulRun(.optimizeDryRun) ? "已预览" : "先预览", accent: MoPilotTheme.protection.accentColor)
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 190), spacing: 14)], spacing: 14) {
                        FeatureCard(title: "安全预览", subtitle: "先查看 mo 输出，不直接修改系统。", estimate: runner.hasSuccessfulRun(.optimizeDryRun) ? "可执行" : "必需", status: "预览", systemImage: "doc.text.magnifyingglass", accent: MoPilotTheme.protection.accentColor)
                        FeatureCard(title: "二次确认", subtitle: "真实执行前弹出确认窗口。", estimate: "手动确认", status: "受保护", systemImage: "lock.shield", accent: MoPilotPalette.amber)
                    }

                    if runner.isRunning {
                        ProgressCard(title: "正在预览优化项", detail: "后台调用 mo optimize。", progress: 0.56, isActive: true, accent: MoPilotTheme.protection.accentColor)
                    }

                    if let moPath = appState.cliStatus.path {
                        HStack(spacing: 12) {
                            PrimaryButton(title: "开始预览", systemImage: "doc.text.magnifyingglass", isEnabled: !runner.isRunning, theme: .protection) {
                                runner.run(.optimizeDryRun, moPath: moPath)
                            }

                            PrimaryButton(title: "执行优化", systemImage: "slider.horizontal.3", role: .destructive, isEnabled: !runner.isRunning && runner.hasSuccessfulRun(.optimizeDryRun), theme: .protection) {
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
            Text("即将执行 mo optimize。请确认你已经查看安全预览结果。该操作可能修改系统偏好或优化项；如 mo 需要管理员权限，本软件不会静默输入密码。")
        }
    }

    private var missingMessage: String {
        if case .missing(let message) = appState.cliStatus {
            return message
        }
        return "未检测到 Mole CLI，请先安装：brew install mole"
    }
}
