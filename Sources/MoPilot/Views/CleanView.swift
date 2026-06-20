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
        HStack(spacing: 26) {
            SmartScannerOrb(
                systemImage: runner.isRunning ? "magnifyingglass" : runner.hasSuccessfulRun(.cleanDryRun) ? "checkmark.shield" : "sparkles",
                title: runner.isRunning ? "扫描中" : runner.hasSuccessfulRun(.cleanDryRun) ? "已预览" : "清理",
                subtitle: runner.isRunning ? "dry-run" : runner.hasSuccessfulRun(.cleanDryRun) ? "可确认" : "安全扫描",
                isActive: runner.isRunning || !runner.hasSuccessfulRun(.cleanDryRun)
            )
            .frame(width: 198, height: 198)

            VStack(alignment: .leading, spacing: 15) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(runner.hasSuccessfulRun(.cleanDryRun) ? "预览已完成" : "安全清理扫描")
                        .font(.title2.weight(.bold))
                    Text(runner.hasSuccessfulRun(.cleanDryRun) ? "你可以查看日志确认范围，再执行真实清理。" : "先运行 dry-run，只预览、不删除。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    scanTile("系统缓存", "sudo 项会提示", "externaldrive.badge.timemachine", MoPilotPalette.blue)
                    scanTile("应用缓存", "预览后清理", "app.dashed", MoPilotPalette.mint)
                    scanTile("日志输出", "自动保存", "doc.text", MoPilotPalette.amber)
                }

                HStack(spacing: 12) {
                    SmartActionButton(title: runner.hasSuccessfulRun(.cleanDryRun) ? "重新扫描" : "开始扫描", systemImage: "magnifyingglass") {
                        didAutoPreview = true
                        runner.run(.cleanDryRun, moPath: moPath)
                    }
                    .disabled(runner.isRunning)

                    Button(role: .destructive) {
                        showCleanConfirmation = true
                    } label: {
                        Label("清理", systemImage: "trash")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .disabled(runner.isRunning || !runner.hasSuccessfulRun(.cleanDryRun))

                    RunnerCancelButton(runner: runner)
                    CopyLogButton(text: runner.logText)
                }
            }
        }
        .padding(22)
        .background(.regularMaterial)
        .background(
            LinearGradient(
                colors: [
                    MoPilotPalette.mint.opacity(0.14),
                    MoPilotPalette.teal.opacity(0.10),
                    MoPilotPalette.blue.opacity(0.075)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(MoPilotPalette.mint.opacity(0.22), lineWidth: 1)
        }
    }

    private func scanTile(_ title: String, _ value: String, _ icon: String, _ accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(accent)
            Text(title)
                .font(.headline)
            Text(value)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
