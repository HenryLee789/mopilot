import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: MoleAppState
    @State private var selection: AppSection? = .dashboard

    var body: some View {
        NavigationSplitView {
            List(AppSection.allCases, selection: $selection) { section in
                Label(section.title, systemImage: section.systemImage)
                    .tag(section)
            }
            .listStyle(.sidebar)
            .navigationTitle("MoPilot")
        } detail: {
            detailView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    }

    @ViewBuilder
    private var detailView: some View {
        switch selection ?? .dashboard {
        case .dashboard:
            DashboardView(selection: Binding(
                get: { selection ?? .dashboard },
                set: { selection = $0 }
            ))
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
