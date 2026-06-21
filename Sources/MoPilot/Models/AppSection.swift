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

    var theme: MoPilotTheme {
        switch self {
        case .dashboard:
            .smartScan
        case .clean:
            .cleanup
        case .analyze:
            .files
        case .uninstall:
            .applications
        case .optimize:
            .protection
        case .status:
            .smartScan
        case .settings:
            .settings
        }
    }

    var sidebarGroup: SidebarGroup {
        switch self {
        case .dashboard:
            .main
        case .clean:
            .cleanup
        case .analyze:
            .files
        case .uninstall:
            .applications
        case .optimize:
            .protection
        case .status:
            .main
        case .settings:
            .system
        }
    }
}

enum SidebarGroup: String, CaseIterable, Identifiable {
    case main = ""
    case cleanup = "清理"
    case files = "文件"
    case applications = "应用"
    case protection = "防护"
    case system = "系统"

    var id: String { rawValue }

    var title: String { rawValue }

    var sections: [AppSection] {
        AppSection.sidebarSections.filter { $0.sidebarGroup == self }
    }
}
