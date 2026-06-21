import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: MoleAppState
    @State private var logMessage = ""

    var body: some View {
        MoPilotPage(theme: .settings, maxWidth: 920) {
            PageHeader(
                title: "设置",
                subtitle: "配置本机 mo 命令路径、日志目录和安全保护状态。",
                systemImage: "gearshape"
            )

            ProductCard(title: "Mole 命令路径", systemImage: "terminal") {
                TextField("默认自动检测 which mo", text: $appState.manualMolePath)
                    .textFieldStyle(.roundedBorder)

                HStack(spacing: 10) {
                    SecondaryHoverButton(
                        title: "保存并重新检测",
                        systemImage: "checkmark.circle",
                        accent: MoPilotTheme.settings.accentColor
                    ) {
                        Task { await appState.refresh() }
                    }

                    SecondaryHoverButton(
                        title: "清除手动路径",
                        systemImage: "xmark.circle",
                        accent: MoPilotPalette.rose
                    ) {
                        appState.clearManualPath()
                        Task { await appState.refresh() }
                    }

                    SecondaryHoverButton(
                        title: "重新检测",
                        systemImage: "arrow.clockwise",
                        accent: MoPilotTheme.smartScan.accentColor
                    ) {
                        Task { await appState.refresh() }
                    }
                }

                if let path = appState.cliStatus.path {
                    InfoRow(label: "当前使用", value: path)
                } else if case .missing(let message) = appState.cliStatus {
                    Text(message)
                        .foregroundStyle(.secondary)
                }
            }

            ProductCard(title: "安全保护", systemImage: "lock.shield") {
                Toggle("启用安全预览保护", isOn: .constant(true))
                    .disabled(true)
                Text("危险操作必须先预览，并在执行前弹出确认。该保护当前不允许关闭。")
                    .foregroundStyle(.secondary)
                InfoRow(label: "磁盘分析", value: appState.capabilities.analyzeModeDescription)
                InfoRow(label: "系统状态", value: appState.capabilities.statusModeDescription)
            }

            ProductCard(title: "日志", systemImage: "doc.text") {
                InfoRow(label: "保存目录", value: appState.logService.directoryURL.path)
                HStack(spacing: 10) {
                    SecondaryHoverButton(
                        title: "打开日志目录",
                        systemImage: "folder",
                        accent: MoPilotTheme.settings.accentColor
                    ) {
                        do {
                            try appState.logService.openDirectory()
                            logMessage = "已打开日志目录。"
                        } catch {
                            logMessage = "打开失败：\(error.localizedDescription)"
                        }
                    }

                    SecondaryHoverButton(
                        title: "复制路径",
                        systemImage: "doc.on.doc",
                        accent: MoPilotTheme.files.accentColor
                    ) {
                        Pasteboard.copy(appState.logService.directoryURL.path)
                    }

                    SecondaryHoverButton(
                        title: "复制诊断信息",
                        systemImage: "stethoscope",
                        accent: MoPilotTheme.smartScan.accentColor
                    ) {
                        Pasteboard.copy(diagnosticsText)
                        logMessage = "已复制诊断信息。"
                    }
                }
                Text(logMessage)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var diagnosticsText: String {
        let cliPath = appState.cliStatus.path ?? "未检测到"
        let cliVersion = appState.cliStatus.version ?? "未知"
        return """
        MoPilot 诊断信息
        应用版本：0.6.3
        Mole CLI 路径：\(cliPath)
        Mole CLI 版本：\(cliVersion)
        磁盘分析模式：\(appState.capabilities.analyzeModeDescription)
        系统状态模式：\(appState.capabilities.statusModeDescription)
        macOS: \(appState.systemInfo.macOSVersion)
        设备架构：\(appState.systemInfo.architecture)
        日志目录：\(appState.logService.directoryURL.path)
        """
    }
}
