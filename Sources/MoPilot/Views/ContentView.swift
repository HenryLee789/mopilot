import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: MoleAppState
    @State private var selection: AppSection? = .dashboard

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selection, cliInstalled: appState.cliStatus.isInstalled)
        } detail: {
            detailView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationSplitViewStyle(.balanced)
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
        switch selectedSection {
        case .dashboard:
            DashboardView(selection: selectedSectionBinding)
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

    private var selectedSection: AppSection {
        selection ?? .dashboard
    }

    private var selectedSectionBinding: Binding<AppSection> {
        Binding(
            get: { selectedSection },
            set: { selection = $0 }
        )
    }
}
