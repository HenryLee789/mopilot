import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var appState: MoleAppState
    @Binding var selection: AppSection

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                PageHeader(
                    title: "MoPilot",
                    subtitle: "非官方 GUI Wrapper，只调用本机已安装的 Mole CLI，所有高风险操作先预览再执行。"
                )

                HStack(alignment: .top, spacing: 14) {
                    ProductCard(title: "CLI 连接", systemImage: appState.cliStatus.isInstalled ? "checkmark.seal" : "exclamationmark.triangle") {
                        cliStatusContent
                    }

                    ProductCard(title: "安全保护", systemImage: "lock.shield") {
                        Label("Clean / Optimize 必须先 dry-run", systemImage: "doc.text.magnifyingglass")
                        Label("真实执行前必须再次确认", systemImage: "hand.raised")
                        Label("不会静默输入 sudo 密码", systemImage: "lock")
                    }
                }

                ProductCard(title: "当前 Mac", systemImage: "desktopcomputer") {
                    Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 10) {
                        infoGridRow("macOS", appState.systemInfo.macOSVersion)
                        infoGridRow("芯片架构", appState.systemInfo.architecture)
                        infoGridRow("磁盘可用", appState.systemInfo.freeDiskSpace)
                        infoGridRow("磁盘总量", appState.systemInfo.totalDiskSpace)
                        infoGridRow("Analyze", appState.capabilities.analyzeModeDescription)
                        infoGridRow("Status", appState.capabilities.statusModeDescription)
                    }
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 12)], spacing: 12) {
                    entryButton(.clean, note: "先 dry-run，再确认清理")
                    entryButton(.analyze, note: "JSON 优先，日志兜底")
                    entryButton(.uninstall, note: "GUI 选择，后台卸载")
                    entryButton(.optimize, note: "先 dry-run，再确认优化")
                    entryButton(.status, note: "状态卡片与原始日志")
                }
            }
            .padding(24)
            .frame(maxWidth: 980, alignment: .leading)
        }
    }

    @ViewBuilder
    private var cliStatusContent: some View {
        HStack {
            Image(systemName: appState.cliStatus.isInstalled ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundStyle(appState.cliStatus.isInstalled ? .green : .orange)
            Text(appState.cliStatus.statusText)
                .font(.headline)
            Spacer()
            Button("重新检测") {
                Task { await appState.refresh() }
            }
        }

        switch appState.cliStatus {
        case .checking:
            Text("正在执行 /usr/bin/env which mo")
                .foregroundStyle(.secondary)
        case .missing(let message):
            VStack(alignment: .leading, spacing: 8) {
                Text(message)
                    .foregroundStyle(.secondary)
                Text("安装命令：brew install mole")
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
            }
        case .installed(let path, let version):
            InfoRow(label: "路径", value: path)
            InfoRow(label: "版本", value: version)
        }
    }

    private func infoGridRow(_ label: String, _ value: String) -> some View {
        GridRow {
            Text(label)
                .foregroundStyle(.secondary)
            Text(value)
                .textSelection(.enabled)
        }
    }

    private func entryButton(_ section: AppSection, note: String) -> some View {
        Button {
            selection = section
        } label: {
            HStack(spacing: 12) {
                Image(systemName: section.systemImage)
                    .font(.title3)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 3) {
                    Text(section.shortTitle)
                        .font(.headline)
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.bordered)
        .disabled(!appState.cliStatus.isInstalled && section != .settings)
    }
}
