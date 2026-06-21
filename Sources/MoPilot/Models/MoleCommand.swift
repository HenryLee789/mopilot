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
            "清理预览"
        case .clean:
            "清理"
        case .analyze:
            "磁盘分析"
        case .status:
            "系统状态"
        case .uninstall:
            "卸载"
        case .uninstallDryRun:
            "卸载预览"
        case .optimizeDryRun:
            "优化预览"
        case .optimize:
            "优化"
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
