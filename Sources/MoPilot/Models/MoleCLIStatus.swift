import Foundation

enum MoleCLIStatus: Equatable {
    case checking
    case missing(message: String)
    case installed(path: String, version: String)

    var isInstalled: Bool {
        if case .installed = self {
            return true
        }
        return false
    }

    var path: String? {
        if case .installed(let path, _) = self {
            return path
        }
        return nil
    }

    var version: String? {
        if case .installed(_, let version) = self {
            return version
        }
        return nil
    }

    var statusText: String {
        switch self {
        case .checking:
            "正在检测 Mole CLI..."
        case .missing:
            "未检测到 Mole CLI"
        case .installed:
            "已检测到 Mole CLI"
        }
    }
}
