import Foundation

enum ProcessEnvironment {
    static var defaultEnvironment: [String: String] {
        var environment = ProcessInfo.processInfo.environment
        let existingPath = environment["PATH"] ?? ""
        let fallbackPaths = [
            "/opt/homebrew/bin",
            "/usr/local/bin",
            "/usr/bin",
            "/bin",
            "/usr/sbin",
            "/sbin"
        ]
        let mergedPath = ([existingPath] + fallbackPaths)
            .filter { !$0.isEmpty }
            .joined(separator: ":")
        environment["PATH"] = mergedPath
        return environment
    }
}
