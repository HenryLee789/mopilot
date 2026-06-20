import Foundation

struct MoleCapabilities: Equatable {
    var analyzeJSONFlag: String?
    var statusJSONFlag: String?

    static let empty = MoleCapabilities()

    var analyzeModeDescription: String {
        if let analyzeJSONFlag {
            return "JSON 模式：mo analyze \(analyzeJSONFlag)"
        }
        return "原始日志模式：mo analyze"
    }

    var statusModeDescription: String {
        if let statusJSONFlag {
            return "JSON 模式：mo status \(statusJSONFlag)"
        }
        return "原始日志模式：mo status"
    }
}
