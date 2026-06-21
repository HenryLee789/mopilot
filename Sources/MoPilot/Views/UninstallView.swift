import SwiftUI

struct UninstallView: View {
    @EnvironmentObject private var appState: MoleAppState
    @StateObject private var runner = CommandRunner()

    @State private var apps: [InstalledApp] = []
    @State private var selectedNames: Set<String> = []
    @State private var previewedNames: Set<String> = []
    @State private var previewCandidateNames: Set<String> = []
    @State private var searchText = ""
    @State private var isLoadingApps = false
    @State private var listMessage = ""
    @State private var showUninstallConfirmation = false
    @State private var lastRunWasPreview = false
    @State private var lastRunWasUninstall = false
    @State private var hasLoadedOnce = false

    var body: some View {
        CommandPageLayout(
            title: "Uninstaller",
            subtitle: "在图形界面中选择应用，先 dry-run 预览，再确认后台调用 mo uninstall 完成卸载。默认移入废纸篓，不使用永久删除。",
            systemImage: "app.badge",
            theme: .applications,
            runner: runner
        ) {
            VStack(alignment: .leading, spacing: 14) {
                safetyNotes

                if let moPath = appState.cliStatus.path {
                    toolbar(moPath: moPath)
                    appList
                    selectedSummary
                } else {
                    CLIUnavailableView(message: missingMessage)
                }
            }
        }
        .task(id: appState.cliStatus.path) {
            guard let moPath = appState.cliStatus.path, !hasLoadedOnce else { return }
            hasLoadedOnce = true
            await refreshApps(moPath: moPath)
        }
        .onChange(of: selectedNames) { _ in
            if previewedNames != selectedNames {
                previewedNames = []
            }
        }
        .onChange(of: runner.status) { status in
            switch status {
            case .succeeded where lastRunWasPreview:
                previewedNames = previewCandidateNames
                lastRunWasPreview = false
            case .succeeded where lastRunWasUninstall:
                selectedNames = []
                previewedNames = []
                previewCandidateNames = []
                lastRunWasUninstall = false
                if let moPath = appState.cliStatus.path {
                    Task { await refreshApps(moPath: moPath) }
                }
            case .failed, .cancelled, .launchFailed:
                lastRunWasPreview = false
                lastRunWasUninstall = false
            default:
                break
            }
        }
        .alert("确认卸载应用", isPresented: $showUninstallConfirmation) {
            Button("取消", role: .cancel) {}
            Button("卸载到废纸篓", role: .destructive) {
                if let moPath = appState.cliStatus.path {
                    runUninstall(moPath: moPath)
                }
            }
        } message: {
            Text("即将后台执行 mo uninstall \(selectedNamesForCommand.joined(separator: " "))。MoPilot 会在你确认后向 mo 发送确认输入。请确认你已经查看 dry-run 预览。")
        }
    }

    private var safetyNotes: some View {
        ProductCard(title: "安全流程", systemImage: "lock.shield") {
            Label("卸载前必须先选择应用并执行 dry-run 预览。", systemImage: "doc.text.magnifyingglass")
            Label("点击卸载后 MoPilot 后台运行 mo uninstall，不再打开 Terminal.app。", systemImage: "desktopcomputer")
            Label("默认移动到 macOS 废纸篓，不使用 --permanent。", systemImage: "trash")
        }
    }

    private func toolbar(moPath: String) -> some View {
        ProductCard(title: "卸载控制台", systemImage: "app.badge") {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    TextField("搜索应用、Bundle ID 或路径", text: $searchText)
                        .textFieldStyle(.roundedBorder)

                    Button {
                        Task { await refreshApps(moPath: moPath) }
                    } label: {
                        Label("刷新列表", systemImage: "arrow.clockwise")
                    }
                    .disabled(isLoadingApps || runner.isRunning)
                }

                HStack(spacing: 12) {
                    PrimaryButton(title: "Preview Selection", systemImage: "doc.text.magnifyingglass", isEnabled: !selectedNames.isEmpty && !runner.isRunning, theme: .applications) {
                        runPreview(moPath: moPath)
                    }

                    PrimaryButton(title: "Uninstall", systemImage: "trash", role: .destructive, isEnabled: canUninstallSelected && !runner.isRunning, theme: .applications) {
                        showUninstallConfirmation = true
                    }

                    RunnerCancelButton(runner: runner)
                    CopyLogButton(text: runner.logText)
                }

                if !listMessage.isEmpty {
                    Text(listMessage)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var appList: some View {
        ProductCard(title: "已安装应用", systemImage: "square.grid.2x2") {
            if isLoadingApps {
                HStack {
                    ProgressView()
                    Text("正在读取 mo uninstall --list...")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else if filteredApps.isEmpty {
                Text(apps.isEmpty ? "暂无应用列表，点击刷新列表。" : "没有匹配的应用。")
                    .foregroundStyle(.secondary)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredApps) { app in
                            UninstallAppRow(
                                app: app,
                                isSelected: selectedNames.contains(app.uninstallName),
                                duplicateCount: duplicateCount(for: app),
                                isSelfApp: isSelfApp(app),
                                toggle: { toggle(app) }
                            )
                        }
                    }
                }
                .frame(minHeight: 220, maxHeight: 360)
            }
        }
    }

    private var selectedSummary: some View {
        ProductCard(title: "选中项", systemImage: "checklist") {
            if selectedApps.isEmpty {
                Text("尚未选择应用。")
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text("已选择 \(selectedApps.count) 个应用，传给 mo 的卸载名：\(selectedNamesForCommand.joined(separator: ", "))")
                        .textSelection(.enabled)
                    Text(canUninstallSelected ? "dry-run 已完成，可以执行卸载。" : "请先预览当前选中项。")
                        .foregroundStyle(canUninstallSelected ? .green : .secondary)
                }
            }
        }
    }

    private var filteredApps: [InstalledApp] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return apps }
        return apps.filter { app in
            app.name.lowercased().contains(query) ||
            app.bundleID.lowercased().contains(query) ||
            app.path.lowercased().contains(query) ||
            app.uninstallName.lowercased().contains(query)
        }
    }

    private var selectedApps: [InstalledApp] {
        apps.filter { selectedNames.contains($0.uninstallName) }
    }

    private var selectedNamesForCommand: [String] {
        apps.map(\.uninstallName).filter { selectedNames.contains($0) }.uniqued()
    }

    private var canUninstallSelected: Bool {
        !selectedNames.isEmpty && previewedNames == selectedNames
    }

    private func refreshApps(moPath: String) async {
        isLoadingApps = true
        listMessage = ""
        do {
            let loadedApps = try await MoleUninstallService.listInstalledApps(moPath: moPath)
            apps = loadedApps
            selectedNames = selectedNames.intersection(Set(loadedApps.map(\.uninstallName)))
            previewedNames = []
            listMessage = "已加载 \(loadedApps.count) 个应用。"
        } catch {
            listMessage = error.localizedDescription
        }
        isLoadingApps = false
    }

    private func toggle(_ app: InstalledApp) {
        guard !isSelfApp(app) else { return }
        if selectedNames.contains(app.uninstallName) {
            selectedNames.remove(app.uninstallName)
        } else {
            selectedNames.insert(app.uninstallName)
        }
    }

    private func runPreview(moPath: String) {
        previewCandidateNames = selectedNames
        lastRunWasPreview = true
        runner.run(
            .uninstallDryRun,
            moPath: moPath,
            arguments: ["uninstall", "--dry-run"] + selectedNamesForCommand,
            standardInput: "y\n"
        )
    }

    private func runUninstall(moPath: String) {
        lastRunWasPreview = false
        lastRunWasUninstall = true
        runner.run(
            .uninstall,
            moPath: moPath,
            arguments: ["uninstall"] + selectedNamesForCommand,
            standardInput: "y\n"
        )
    }

    private func duplicateCount(for app: InstalledApp) -> Int {
        apps.filter { $0.uninstallName == app.uninstallName }.count
    }

    private func isSelfApp(_ app: InstalledApp) -> Bool {
        app.bundleID == "io.github.mopilot.app"
    }

    private var missingMessage: String {
        if case .missing(let message) = appState.cliStatus {
            return message
        }
        return "未检测到 Mole CLI，请先安装：brew install mole"
    }
}

private struct UninstallAppRow: View {
    let app: InstalledApp
    let isSelected: Bool
    let duplicateCount: Int
    let isSelfApp: Bool
    let toggle: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: toggle) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? MoPilotPalette.mint.opacity(0.18) : Color.secondary.opacity(0.08))
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? MoPilotPalette.teal : .secondary)
                        .font(.title3)
                }
                .frame(width: 34, height: 34)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(app.name)
                            .font(.headline)
                        Text(app.size)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if duplicateCount > 1 {
                            Text("同名 \(duplicateCount) 个")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                        if isSelfApp {
                            Text("当前应用")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Text(app.path)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Text(app.bundleID)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(12)
            .background(
                LinearGradient(
                    colors: rowBackgroundColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(rowStrokeColor, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .disabled(isSelfApp)
        .opacity(isSelfApp ? 0.55 : 1)
        .onHover { isHovered = $0 }
        .animation(.easeOut(duration: 0.16), value: isHovered)
        .animation(.easeOut(duration: 0.16), value: isSelected)
    }

    private var rowBackgroundColors: [Color] {
        if isSelected {
            return [MoPilotPalette.mint.opacity(0.18), MoPilotPalette.blue.opacity(0.10)]
        }
        if isHovered {
            return [Color.white.opacity(0.10), MoPilotPalette.teal.opacity(0.06)]
        }
        return [Color.clear, Color.clear]
    }

    private var rowStrokeColor: Color {
        if isSelected {
            return MoPilotPalette.teal.opacity(0.45)
        }
        if isHovered {
            return MoPilotPalette.teal.opacity(0.22)
        }
        return Color.secondary.opacity(0.12)
    }
}

private extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
