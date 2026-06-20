import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var appState: MoleAppState
    @Binding var selection: AppSection

    var body: some View {
        MoPilotPage(maxWidth: 1180) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Smart Care")
                        .font(.system(size: 42, weight: .bold))
                    Text("非官方 GUI Wrapper，只调用本机 Mole CLI。")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                statusPill
            }

            smartCarePanel
            summaryGrid
            toolGrid
        }
    }

    private var smartCarePanel: some View {
        HStack(spacing: 30) {
            SmartScannerOrb(
                systemImage: appState.cliStatus.isInstalled ? "checkmark.shield" : "exclamationmark.triangle",
                title: appState.cliStatus.isInstalled ? "Ready" : "Missing",
                subtitle: appState.cliStatus.isInstalled ? "mo connected" : "install mo",
                isActive: appState.cliStatus.isInstalled
            )
            .frame(width: 250, height: 250)

            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 7) {
                    Text(appState.cliStatus.isInstalled ? "准备好进行一次安全扫描" : "未检测到 Mole CLI")
                        .font(.title.weight(.bold))
                        .lineLimit(2)
                    Text(appState.cliStatus.isInstalled ? "先预览缓存清理、磁盘占用和系统状态。真实清理、优化、卸载都保留确认步骤。" : "安装 Mole CLI 后，MoPilot 才能开始扫描和预览。")
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                diskMeter

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    miniStatus("CLI", appState.cliStatus.isInstalled ? "已连接" : "未检测", "terminal", appState.cliStatus.isInstalled ? MoPilotPalette.mint : MoPilotPalette.amber)
                    miniStatus("保护", "dry-run 优先", "lock.shield", MoPilotPalette.blue)
                    miniStatus("Analyze", appState.capabilities.analyzeJSONFlag ?? "日志模式", "chart.pie", MoPilotPalette.teal)
                    miniStatus("Status", appState.capabilities.statusJSONFlag ?? "日志模式", "waveform.path.ecg", MoPilotPalette.violet)
                }

                HStack(spacing: 12) {
                    SmartActionButton(title: "扫描", systemImage: "magnifyingglass") {
                        selection = .clean
                    }
                    .disabled(!appState.cliStatus.isInstalled)

                    Button {
                        selection = .analyze
                    } label: {
                        Label("磁盘分析", systemImage: "chart.pie")
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
        .padding(24)
        .background(.regularMaterial)
        .background(
            LinearGradient(
                colors: [
                    MoPilotPalette.violet.opacity(0.22),
                    MoPilotPalette.blue.opacity(0.16),
                    MoPilotPalette.teal.opacity(0.14),
                    MoPilotPalette.magenta.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        }
        .shadow(color: MoPilotPalette.blue.opacity(0.18), radius: 24, x: 0, y: 16)
    }

    private var summaryGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 210), spacing: 12)], spacing: 12) {
            SummaryTile(title: "macOS", value: appState.systemInfo.macOSVersion, systemImage: "macwindow", accent: MoPilotPalette.blue)
            SummaryTile(title: "芯片", value: appState.systemInfo.architecture, systemImage: "cpu", accent: MoPilotPalette.violet)
            SummaryTile(title: "可用空间", value: appState.systemInfo.freeDiskSpace, systemImage: "internaldrive", accent: MoPilotPalette.mint)
            SummaryTile(title: "日志目录", value: "~/Library/Logs/MoPilot", systemImage: "doc.text", accent: MoPilotPalette.amber)
        }
    }

    private var toolGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 245), spacing: 12)], spacing: 12) {
            module(.clean, subtitle: "缓存 dry-run 预览", accent: MoPilotPalette.mint)
            module(.analyze, subtitle: "找出空间占用", accent: MoPilotPalette.teal)
            module(.uninstall, subtitle: "选择应用与残留", accent: MoPilotPalette.rose)
            module(.optimize, subtitle: "系统优化预览", accent: MoPilotPalette.amber)
            module(.status, subtitle: "CPU/内存/网络", accent: MoPilotPalette.violet)
        }
    }

    private var statusPill: some View {
        Label(appState.cliStatus.isInstalled ? "Mole CLI 已就绪" : "需要安装 mo", systemImage: appState.cliStatus.isInstalled ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
            .font(.callout.weight(.semibold))
            .foregroundStyle(appState.cliStatus.isInstalled ? MoPilotPalette.mint : MoPilotPalette.amber)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(.regularMaterial, in: Capsule())
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
                            colors: [MoPilotPalette.mint, MoPilotPalette.teal, MoPilotPalette.blue, MoPilotPalette.magenta],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: max(12, proxy.size.width * diskFreeRatio))
                }
            }
            .frame(height: 12)
        }
    }

    private var diskFreeRatio: CGFloat {
        guard let free = numericPrefix(appState.systemInfo.freeDiskSpace),
              let total = numericPrefix(appState.systemInfo.totalDiskSpace),
              total > 0 else {
            return 0.62
        }
        return CGFloat(min(max(free / total, 0.05), 1))
    }

    private func miniStatus(_ title: String, _ value: String, _ icon: String, _ accent: Color) -> some View {
        HStack(spacing: 9) {
            Image(systemName: icon)
                .foregroundStyle(accent)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.callout.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            Spacer()
        }
        .padding(10)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func module(_ section: AppSection, subtitle: String, accent: Color) -> some View {
        SmartModuleTile(
            title: section.shortTitle,
            subtitle: subtitle,
            systemImage: section.systemImage,
            accent: accent,
            isEnabled: appState.cliStatus.isInstalled
        ) {
            selection = section
        }
    }

    private func numericPrefix(_ text: String) -> Double? {
        let token = text.split(separator: " ").first.map(String.init) ?? text
        return Double(token)
    }
}

private struct SummaryTile: View {
    let title: String
    let value: String
    let systemImage: String
    let accent: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(accent.opacity(0.15))
                Image(systemName: systemImage)
                    .foregroundStyle(accent)
            }
            .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.callout.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            Spacer()
        }
        .padding(13)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(accent.opacity(0.14), lineWidth: 1)
        }
    }
}
