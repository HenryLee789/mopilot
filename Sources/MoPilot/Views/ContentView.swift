import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: MoleAppState
    @State private var selection: AppSection = .dashboard

    var body: some View {
        HStack(spacing: 0) {
            SidebarView(selection: $selection, cliInstalled: appState.cliStatus.isInstalled)

            detailView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(MoPilotBackground().ignoresSafeArea())
        .task {
            await appState.refresh()
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                if appState.isRefreshing {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Button {
                        Task { await appState.refresh() }
                    } label: {
                        Label("重新检测", systemImage: "arrow.clockwise")
                        }
                    }
                }
        }
    }

    @ViewBuilder
    private var detailView: some View {
        switch selection {
        case .dashboard:
            DashboardView(selection: $selection)
        case .clean:
            CleanView()
        case .analyze:
            AnalyzeView()
        case .uninstall:
            UninstallView()
        case .optimize:
            OptimizeView()
        case .status:
            StatusView()
        case .settings:
            SettingsView()
        }
    }
}
