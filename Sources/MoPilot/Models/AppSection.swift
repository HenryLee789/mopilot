import Foundation

enum AppSection: String, CaseIterable, Identifiable {
    case dashboard
    case clean
    case analyze
    case uninstall
    case optimize
    case status
    case settings

    var id: String { rawValue }

    static var sidebarSections: [AppSection] {
        [.dashboard, .clean, .analyze, .uninstall, .optimize, .settings]
    }

    var title: String {
        switch self {
        case .dashboard:
            "Dashboard"
        case .clean:
            "System Junk"
        case .analyze:
            "Large Files"
        case .uninstall:
            "Uninstaller"
        case .optimize:
            "Privacy"
        case .status:
            "System Status"
        case .settings:
            "Settings"
        }
    }

    var shortTitle: String {
        switch self {
        case .dashboard:
            "Dashboard"
        case .clean:
            "System Junk"
        case .analyze:
            "Large Files"
        case .uninstall:
            "Uninstaller"
        case .optimize:
            "Privacy"
        case .status:
            "Status"
        case .settings:
            "Settings"
        }
    }

    var sidebarSubtitle: String {
        switch self {
        case .dashboard:
            "总览与扫描"
        case .clean:
            "缓存与系统垃圾"
        case .analyze:
            "空间占用分析"
        case .uninstall:
            "应用卸载预览"
        case .optimize:
            "安全预览保护"
        case .status:
            "性能状态"
        case .settings:
            "路径与日志"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard:
            "gauge"
        case .clean:
            "sparkles"
        case .analyze:
            "folder"
        case .uninstall:
            "app.badge"
        case .optimize:
            "hand.raised"
        case .status:
            "waveform.path.ecg"
        case .settings:
            "gearshape"
        }
    }
}
