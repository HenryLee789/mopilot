import Foundation

@MainActor
final class MoleAppState: ObservableObject {
    @Published private(set) var cliStatus: MoleCLIStatus = .checking
    @Published private(set) var systemInfo: SystemInfo = SystemInfoService.current()
    @Published private(set) var capabilities: MoleCapabilities = .empty
    @Published private(set) var isRefreshing = false
    @Published var manualMolePath: String {
        didSet {
            UserDefaults.standard.set(manualMolePath, forKey: Self.manualPathKey)
        }
    }

    let logService = LogService()

    private static let manualPathKey = "manualMolePath"

    init() {
        manualMolePath = UserDefaults.standard.string(forKey: Self.manualPathKey) ?? ""
    }

    func refresh() async {
        isRefreshing = true
        systemInfo = SystemInfoService.current()
        let preferredPath = manualMolePath.trimmingCharacters(in: .whitespacesAndNewlines)
        let detectedStatus = await MoleDetector.detect(manualPath: preferredPath.isEmpty ? nil : preferredPath)
        cliStatus = detectedStatus
        if let moPath = detectedStatus.path {
            capabilities = await MoleCapabilityDetector.detect(moPath: moPath)
        } else {
            capabilities = .empty
        }
        isRefreshing = false
    }

    func clearManualPath() {
        manualMolePath = ""
    }
}
