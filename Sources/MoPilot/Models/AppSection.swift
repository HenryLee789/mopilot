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

    var title: String {
        switch self {
        case .dashboard:
            "Dashboard"
        case .clean:
            "Clean 清理"
        case .analyze:
            "Analyze 分析"
        case .uninstall:
            "Uninstall 卸载"
        case .optimize:
            "Optimize 优化"
        case .status:
            "Status 状态"
        case .settings:
            "Settings 设置"
        }
    }

    var shortTitle: String {
        switch self {
        case .dashboard:
            "Dashboard"
        case .clean:
            "Clean"
        case .analyze:
            "Analyze"
        case .uninstall:
            "Uninstall"
        case .optimize:
            "Optimize"
        case .status:
            "Status"
        case .settings:
            "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard:
            "rectangle.grid.2x2"
        case .clean:
            "sparkles"
        case .analyze:
            "chart.pie"
        case .uninstall:
            "trash"
        case .optimize:
            "slider.horizontal.3"
        case .status:
            "waveform.path.ecg"
        case .settings:
            "gearshape"
        }
    }
}
