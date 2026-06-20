import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var appState: MoleAppState
    @Binding var selection: AppSection

    var body: some View {
        MoPilotPage(maxWidth: 1100) {
            PageHeader(
                title: "MoPilot",
                subtitle: "非官方 GUI Wrapper，只调用本机已安装的 Mole CLI。先预览，再执行。",
                systemImage: "wrench.and.screwdriver"
            )

            dashboardHero

            HStack(alignment: .top, spacing: 14) {
                ProductCard(title: "CLI 连接", systemImage: appState.cliStatus.isInstalled ? "checkmark.seal" : "exclamationmark.triangle") {
                    cliStatusContent
                }

                ProductCard(title: "安全保护", systemImage: "lock.shield") {
                    Label("Clean / Optimize 必须先 dry-run", systemImage: "doc.text.magnifyingglass")
                    Label("真实执行前必须再次确认", systemImage: "hand.raised")
                    Label("不会静默输入 sudo 密码", systemImage: "lock")
                    Label("Uninstall 默认移入废纸篓", systemImage: "trash")
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

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 190), spacing: 12)], spacing: 12) {
                entryButton(.clean, note: "扫描缓存并预览")
                entryButton(.analyze, note: "分析磁盘占用")
                entryButton(.uninstall, note: "选择应用并卸载")
                entryButton(.optimize, note: "预览系统优化项")
                entryButton(.status, note: "查看系统状态")
            }
        }
    }

    private var dashboardHero: some View {
        ProductCard(title: "维护驾驶舱", systemImage: "sparkles") {
            HStack(spacing: 22) {
                AnimatedScanRing(systemImage: appState.cliStatus.isInstalled ? "checkmark.shield" : "exclamationmark.triangle", isActive: appState.cliStatus.isInstalled)
                    .frame(width: 128, height: 128)

                VStack(alignment: .leading, spacing: 14) {
                    Text(appState.cliStatus.isInstalled ? "Mole CLI 已就绪" : "需要安装 Mole CLI")
                        .font(.title.weight(.bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text(appState.cliStatus.isInstalled ? "你可以先运行清理预览、磁盘分析或系统状态检查。所有高风险操作都会保留确认步骤。" : "MoPilot 只负责图形界面包装，需要先安装本机 mo 命令。")
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    diskMeter

                    HStack {
                        Button {
                            selection = .clean
                        } label: {
                            Label("开始 Clean 预览", systemImage: "sparkles")
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!appState.cliStatus.isInstalled)

                        Button {
                            selection = .status
                        } label: {
                            Label("查看状态", systemImage: "waveform.path.ecg")
                        }
                        .disabled(!appState.cliStatus.isInstalled)

                        Button {
                            Task { await appState.refresh() }
                        } label: {
                            Label("重新检测", systemImage: "arrow.clockwise")
                        }
                    }
                }
            }
        }
    }

    private var diskMeter: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text("磁盘空间")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(appState.systemInfo.freeDiskSpace) 可用")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.12))
                    Capsule()
                        .fill(LinearGradient(
                            colors: [MoPilotPalette.mint, MoPilotPalette.teal, MoPilotPalette.amber.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: max(10, proxy.size.width * diskFreeRatio))
                }
            }
            .frame(height: 10)
        }
        .frame(maxWidth: 520)
    }

    private var diskFreeRatio: CGFloat {
        guard let free = numericPrefix(appState.systemInfo.freeDiskSpace),
              let total = numericPrefix(appState.systemInfo.totalDiskSpace),
              total > 0 else {
            return 0.62
        }
        return CGFloat(min(max(free / total, 0.05), 1))
    }

    @ViewBuilder
    private var cliStatusContent: some View {
        HStack {
            Image(systemName: appState.cliStatus.isInstalled ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundStyle(appState.cliStatus.isInstalled ? MoPilotPalette.mint : MoPilotPalette.amber)
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
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(sectionAccent(section).opacity(0.14))
                    Image(systemName: section.systemImage)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(sectionAccent(section))
                }
                .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 3) {
                    Text(section.shortTitle)
                        .font(.headline)
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 74, alignment: .leading)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(sectionAccent(section).opacity(0.2), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .disabled(!appState.cliStatus.isInstalled && section != .settings)
    }

    private func sectionAccent(_ section: AppSection) -> Color {
        switch section {
        case .dashboard:
            return MoPilotPalette.teal
        case .clean:
            return MoPilotPalette.mint
        case .analyze:
            return MoPilotPalette.blue
        case .uninstall:
            return MoPilotPalette.rose
        case .optimize:
            return MoPilotPalette.amber
        case .status:
            return MoPilotPalette.teal
        case .settings:
            return .secondary
        }
    }

    private func numericPrefix(_ text: String) -> Double? {
        let token = text.split(separator: " ").first.map(String.init) ?? text
        return Double(token)
    }
}
