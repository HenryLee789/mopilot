import Foundation

enum MoleCommand: String, Hashable {
    case cleanDryRun
    case clean
    case analyze
    case status
    case uninstall
    case uninstallDryRun
    case optimizeDryRun
    case optimize

    var displayName: String {
        switch self {
        case .cleanDryRun:
            "Clean Dry Run"
        case .clean:
            "Clean"
        case .analyze:
            "Analyze"
        case .status:
            "Status"
        case .uninstall:
            "Uninstall"
        case .uninstallDryRun:
            "Uninstall Dry Run"
        case .optimizeDryRun:
            "Optimize Dry Run"
        case .optimize:
            "Optimize"
        }
    }

    var fileNameComponent: String {
        switch self {
        case .cleanDryRun:
            "clean-dry-run"
        case .clean:
            "clean"
        case .analyze:
            "analyze"
        case .status:
            "status"
        case .uninstall:
            "uninstall"
        case .uninstallDryRun:
            "uninstall-dry-run"
        case .optimizeDryRun:
            "optimize-dry-run"
        case .optimize:
            "optimize"
        }
    }

    var arguments: [String] {
        switch self {
        case .cleanDryRun:
            ["clean", "--dry-run"]
        case .clean:
            ["clean"]
        case .analyze:
            ["analyze"]
        case .status:
            ["status"]
        case .uninstall:
            ["uninstall"]
        case .uninstallDryRun:
            ["uninstall", "--dry-run"]
        case .optimizeDryRun:
            ["optimize", "--dry-run"]
        case .optimize:
            ["optimize"]
        }
    }
}
