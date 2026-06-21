import SwiftUI
import Foundation

struct DashboardView: View {
    @EnvironmentObject private var appState: MoleAppState
    @Binding var selection: AppSection
    @StateObject private var scanRunner = CommandRunner()
    @State private var scanProgress = 0.0
    @State private var showCleanConfirmation = false

    var body: some View {
        MoPilotPage(maxWidth: 1180) {
            dashboardHeader
            scanStatusCard
            macStatusGrid
            featureGrid
        }
        .onChange(of: scanRunner.status) { status in
            handleScanStatusChange(status)
        }
        .alert("确认执行清理", isPresented: $showCleanConfirmation) {
            Button("取消", role: .cancel) {}
            Button("Clean Now", role: .destructive) {
                if let moPath = appState.cliStatus.path {
                    scanRunner.run(.clean, moPath: moPath)
                }
            }
        } message: {
            Text("即将执行 mo clean。请确认你已经查看 dry-run 预览结果。MoPilot 不会静默输入管理员密码。")
        }
    }

    private var dashboardHeader: some View {
        HStack(alignment: .firstTextBaseline, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("MoPilot")
                    .font(.system(size: 34, weight: .bold))
                    .lineLimit(1)
                Text("\(appState.systemInfo.macOSVersion) · \(appState.systemInfo.architecture) · \(appState.systemInfo.freeDiskSpace) 可用")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Spacer()

            StatusTag(
                title: appState.cliStatus.isInstalled ? "Mole CLI Connected" : "Install mo first",
                accent: appState.cliStatus.isInstalled ? MoPilotPalette.mint : MoPilotPalette.amber
            )
        }
    }

    private var scanStatusCard: some View {
        ModernCard(cornerRadius: 24, padding: 26, accent: MoPilotPalette.blue, showsAccentLine: true) {
            HStack(alignment: .center, spacing: 30) {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(scanEyebrow)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(scanHeadline)
                            .font(.system(size: 38, weight: .bold))
                            .lineLimit(2)
                            .minimumScaleFactor(0.62)
                        Text(scanSubtitle)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if scanRunner.isRunning {
                        ProgressCard(
                            title: "Scanning with Mole CLI",
                            detail: "后台执行中，UI 不会被阻塞。",
                            progress: scanProgress,
                            isActive: true,
                            accent: MoPilotPalette.blue
                        )
                    }

                    HStack(spacing: 12) {
                        primaryScanAction

                        Button {
                            selection = .status
                        } label: {
                            Label("System Status", systemImage: "waveform.path.ecg")
                        }
                        .disabled(!appState.cliStatus.isInstalled || scanRunner.isRunning)

                        if scanRunner.isRunning {
                            RunnerCancelButton(runner: scanRunner)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                DashboardGauge(
                    progress: gaugeProgress,
                    title: gaugeTitle,
                    subtitle: gaugeSubtitle,
                    systemImage: scanGaugeIcon,
                    accent: scanAccent
                )
                .frame(width: 230, height: 230)
            }
        }
    }

    @ViewBuilder
    private var primaryScanAction: some View {
        if !appState.cliStatus.isInstalled {
            PrimaryButton(title: "重新检测", systemImage: "arrow.clockwise") {
                Task { await appState.refresh() }
            }
        } else if scanRunner.isRunning {
            PrimaryButton(title: "Scanning", systemImage: "hourglass", isEnabled: false) {}
        } else if scanRunner.hasSuccessfulRun(.cleanDryRun), !scanRunner.hasSuccessfulRun(.clean) {
            PrimaryButton(title: "Clean Now", systemImage: "trash", role: .destructive) {
                showCleanConfirmation = true
            }
        } else {
            PrimaryButton(title: "Start Scan", systemImage: "magnifyingglass") {
                if let moPath = appState.cliStatus.path {
                    startScan(moPath: moPath)
                }
            }
        }
    }

    private var macStatusGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 205), spacing: 14)], spacing: 14) {
            StatusCard(title: "macOS", value: appState.systemInfo.macOSVersion, subtitle: "当前系统版本", systemImage: "macwindow", accent: MoPilotPalette.blue)
            StatusCard(title: "Chip", value: appState.systemInfo.architecture, subtitle: "设备架构", systemImage: "cpu", accent: MoPilotPalette.violet)
            StatusCard(title: "Free Space", value: appState.systemInfo.freeDiskSpace, subtitle: "总容量 \(appState.systemInfo.totalDiskSpace)", systemImage: "internaldrive", accent: MoPilotPalette.mint, progress: diskFreeRatio)
            StatusCard(title: "Safety", value: "Dry-run first", subtitle: "危险操作执行前必须确认", systemImage: "lock.shield", accent: MoPilotPalette.amber)
        }
    }

    private var featureGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cleanup Modules")
                .font(.title3.weight(.bold))

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 14)], spacing: 14) {
                FeatureCard(
                    title: "System Junk",
                    subtitle: "系统与应用缓存，先 dry-run 预览。",
                    estimate: systemJunkEstimate,
                    status: scanRunner.hasSuccessfulRun(.cleanDryRun) ? "Previewed" : "Ready",
                    systemImage: "sparkles",
                    accent: MoPilotPalette.blue,
                    isEnabled: appState.cliStatus.isInstalled
                ) {
                    selection = .clean
                }

                FeatureCard(
                    title: "Cache Files",
                    subtitle: "日志与缓存结果以 mo 输出为准。",
                    estimate: cacheEstimate,
                    status: "Protected",
                    systemImage: "tray.full",
                    accent: MoPilotPalette.mint,
                    isEnabled: appState.cliStatus.isInstalled
                ) {
                    selection = .clean
                }

                FeatureCard(
                    title: "Large Files",
                    subtitle: "调用 mo analyze 分析空间占用。",
                    estimate: "Run Analyze",
                    status: appState.capabilities.analyzeJSONFlag ?? "Raw Log",
                    systemImage: "folder",
                    accent: MoPilotPalette.teal,
                    isEnabled: appState.cliStatus.isInstalled
                ) {
                    selection = .analyze
                }

                FeatureCard(
                    title: "Privacy Cleanup",
                    subtitle: "通过 mo optimize 的安全预览检查。",
                    estimate: "Dry-run",
                    status: "Confirm",
                    systemImage: "hand.raised",
                    accent: MoPilotPalette.violet,
                    isEnabled: appState.cliStatus.isInstalled
                ) {
                    selection = .optimize
                }
            }
        }
    }

    private var scanEyebrow: String {
        if !appState.cliStatus.isInstalled { return "Mole CLI Required" }
        if scanRunner.isRunning { return "Scanning" }
        if scanRunner.hasSuccessfulRun(.clean) { return "Cleanup Complete" }
        if scanRunner.hasSuccessfulRun(.cleanDryRun) { return "Scan Result" }
        return "Mac Status"
    }

    private var scanHeadline: String {
        if !appState.cliStatus.isInstalled { return "未检测到 Mole CLI" }
        if scanRunner.isRunning { return "正在扫描可清理项目" }
        if scanRunner.hasSuccessfulRun(.clean) { return "清理已完成" }
        if scanRunner.hasSuccessfulRun(.cleanDryRun) { return "\(systemJunkEstimate) 可清理空间" }
        return "Ready for a Safe Scan"
    }

    private var scanSubtitle: String {
        if !appState.cliStatus.isInstalled { return "请先安装 Mole CLI：brew install mole，然后重新检测。" }
        if scanRunner.isRunning { return "MoPilot 正在后台调用本机 mo clean --dry-run，并实时保存日志。" }
        if scanRunner.hasSuccessfulRun(.clean) { return "你可以重新扫描，或进入各模块查看详细日志。" }
        if scanRunner.hasSuccessfulRun(.cleanDryRun) { return "已完成 dry-run 预览。执行真实清理前仍会弹出确认。" }
        return "先进行 dry-run 预览，不会在扫描阶段删除任何文件。"
    }

    private var gaugeTitle: String {
        if scanRunner.hasSuccessfulRun(.clean) { return "Done" }
        if scanRunner.hasSuccessfulRun(.cleanDryRun) { return systemJunkEstimate }
        if scanRunner.isRunning { return "\(Int(gaugeProgress * 100))%" }
        return "Safe"
    }

    private var gaugeSubtitle: String {
        if !appState.cliStatus.isInstalled { return "CLI missing" }
        if scanRunner.hasSuccessfulRun(.clean) { return "cleaned" }
        if scanRunner.hasSuccessfulRun(.cleanDryRun) { return "preview" }
        return "dry-run"
    }

    private var scanGaugeIcon: String {
        if !appState.cliStatus.isInstalled { return "exclamationmark.triangle" }
        if scanRunner.hasSuccessfulRun(.clean) { return "checkmark" }
        if scanRunner.hasSuccessfulRun(.cleanDryRun) { return "doc.text.magnifyingglass" }
        return "shield"
    }

    private var scanAccent: Color {
        if !appState.cliStatus.isInstalled { return MoPilotPalette.amber }
        if scanRunner.hasSuccessfulRun(.clean) { return MoPilotPalette.mint }
        return MoPilotPalette.blue
    }

    private var gaugeProgress: Double {
        if scanRunner.hasSuccessfulRun(.clean) { return 1 }
        if scanRunner.hasSuccessfulRun(.cleanDryRun) { return 1 }
        if scanRunner.isRunning { return scanProgress }
        return appState.cliStatus.isInstalled ? 0.76 : 0.18
    }

    private var systemJunkEstimate: String {
        if scanRunner.hasSuccessfulRun(.clean) { return "已清理" }
        if scanRunner.hasSuccessfulRun(.cleanDryRun) {
            return sizeEstimate(from: scanRunner.stdoutText + scanRunner.logText) ?? "已预览"
        }
        return "待扫描"
    }

    private var cacheEstimate: String {
        if scanRunner.hasSuccessfulRun(.clean) { return "已完成" }
        if scanRunner.hasSuccessfulRun(.cleanDryRun) { return "查看日志" }
        return "待预览"
    }

    private var diskFreeRatio: Double {
        guard let free = numericPrefix(appState.systemInfo.freeDiskSpace),
              let total = numericPrefix(appState.systemInfo.totalDiskSpace),
              total > 0 else {
            return 0.62
        }
        return min(max(free / total, 0.05), 1)
    }

    private func startScan(moPath: String) {
        scanProgress = 0.08
        scanRunner.run(.cleanDryRun, moPath: moPath)
        Task { @MainActor in
            while scanRunner.isRunning {
                try? await Task.sleep(nanoseconds: 280_000_000)
                if scanRunner.isRunning {
                    scanProgress = min(scanProgress + 0.075, 0.88)
                }
            }
        }
    }

    private func handleScanStatusChange(_ status: CommandRunStatus) {
        switch status {
        case .running:
            if scanProgress < 0.08 { scanProgress = 0.08 }
        case .succeeded:
            scanProgress = 1
        case .failed, .cancelled, .launchFailed:
            scanProgress = 0
        case .idle:
            break
        }
    }

    private func numericPrefix(_ text: String) -> Double? {
        let token = text.split(separator: " ").first.map(String.init) ?? text
        return Double(token)
    }

    private func sizeEstimate(from text: String) -> String? {
        let pattern = #"(?i)(\d+(?:\.\d+)?)\s*(B|KB|MB|GB|TB|KiB|MiB|GiB|TiB)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        let matches = regex.matches(in: text, range: range)

        let best = matches.compactMap { match -> (bytes: Double, label: String)? in
            guard let numberRange = Range(match.range(at: 1), in: text),
                  let unitRange = Range(match.range(at: 2), in: text),
                  let number = Double(text[numberRange]) else {
                return nil
            }
            let unit = String(text[unitRange])
            return (number * multiplier(for: unit), "\(number.cleanString) \(unit.uppercased())")
        }
        .max { $0.bytes < $1.bytes }

        return best?.label
    }

    private func multiplier(for unit: String) -> Double {
        switch unit.lowercased() {
        case "tb", "tib":
            return 1_099_511_627_776
        case "gb", "gib":
            return 1_073_741_824
        case "mb", "mib":
            return 1_048_576
        case "kb", "kib":
            return 1_024
        default:
            return 1
        }
    }
}

private struct DashboardGauge: View {
    let progress: Double
    let title: String
    let subtitle: String
    let systemImage: String
    let accent: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(accent.opacity(0.10))
            Circle()
                .stroke(accent.opacity(0.13), lineWidth: 18)
                .padding(12)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(
                    MoPilotPalette.smartGradient,
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .padding(12)
                .shadow(color: accent.opacity(0.22), radius: 16, x: 0, y: 8)

            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(accent)
                Text(title)
                    .font(.title2.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
                Text(subtitle)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding(28)
        }
    }
}

private extension Double {
    var cleanString: String {
        rounded(.towardZero) == self ? String(format: "%.0f", self) : String(format: "%.1f", self)
    }
}
