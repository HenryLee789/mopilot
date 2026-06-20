import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: MoleAppState
    @State private var logMessage = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                PageHeader(
                    title: "Settings 设置",
                    subtitle: "配置本机 mo 命令路径、日志目录和安全保护状态。"
                )

                GroupBox("Mole 命令路径") {
                    VStack(alignment: .leading, spacing: 10) {
                        TextField("默认自动检测 which mo", text: $appState.manualMolePath)
                            .textFieldStyle(.roundedBorder)

                        HStack {
                            Button("保存并重新检测") {
                                Task { await appState.refresh() }
                            }
                            Button("清除手动路径") {
                                appState.clearManualPath()
                                Task { await appState.refresh() }
                            }
                            Button("重新检测") {
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
                }

                GroupBox("安全保护") {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("启用 dry-run 保护", isOn: .constant(true))
                            .disabled(true)
                        Text("危险操作必须先预览，并在执行前弹出确认。该保护当前不允许关闭。")
                            .foregroundStyle(.secondary)
                        InfoRow(label: "Analyze", value: appState.capabilities.analyzeModeDescription)
                        InfoRow(label: "Status", value: appState.capabilities.statusModeDescription)
                    }
                }

                GroupBox("日志") {
                    VStack(alignment: .leading, spacing: 10) {
                        InfoRow(label: "保存目录", value: appState.logService.directoryURL.path)
                        HStack {
                            Button("打开日志目录") {
                                do {
                                    try appState.logService.openDirectory()
                                    logMessage = "已打开日志目录。"
                                } catch {
                                    logMessage = "打开失败：\(error.localizedDescription)"
                                }
                            }
                            Button("复制路径") {
                                Pasteboard.copy(appState.logService.directoryURL.path)
                            }
                            Button("复制诊断信息") {
                                Pasteboard.copy(diagnosticsText)
                                logMessage = "已复制诊断信息。"
                            }
                        }
                        Text(logMessage)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
                }
            }
            .padding(24)
            .frame(maxWidth: 920, alignment: .leading)
        }
    }

    private var diagnosticsText: String {
        let cliPath = appState.cliStatus.path ?? "not detected"
        let cliVersion = appState.cliStatus.version ?? "unknown"
        return """
        MoPilot Diagnostics
        App Version: 0.2.0
        Mole CLI Path: \(cliPath)
        Mole CLI Version: \(cliVersion)
        Analyze Mode: \(appState.capabilities.analyzeModeDescription)
        Status Mode: \(appState.capabilities.statusModeDescription)
        macOS: \(appState.systemInfo.macOSVersion)
        Architecture: \(appState.systemInfo.architecture)
        Log Directory: \(appState.logService.directoryURL.path)
        """
    }
}
