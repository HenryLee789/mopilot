import Foundation

struct MoleDetector {
    static func detect(manualPath: String?) async -> MoleCLIStatus {
        await Task.detached {
            if let manualPath, !manualPath.isEmpty {
                return detectManualPath(manualPath)
            }
            return detectWithWhich()
        }.value
    }

    private static func detectManualPath(_ path: String) -> MoleCLIStatus {
        guard FileManager.default.isExecutableFile(atPath: path) else {
            return .missing(message: "手动指定的路径不可执行：\(path)")
        }

        let version = run(executable: path, arguments: ["--version"])
        let versionText = firstDisplayLine(version.stdout)
        return .installed(path: path, version: versionText.isEmpty ? "未知版本" : versionText)
    }

    private static func detectWithWhich() -> MoleCLIStatus {
        let which = run(executable: "/usr/bin/env", arguments: ["which", "mo"])
        guard which.exitCode == 0 else {
            return .missing(message: "请先安装 Mole CLI：brew install mole")
        }

        let path = which.stdout.trimmedForDisplay
        guard !path.isEmpty else {
            return .missing(message: "which mo 未返回可用路径")
        }

        let version = run(executable: path, arguments: ["--version"])
        let versionText = firstDisplayLine(version.stdout)
        return .installed(path: path, version: versionText.isEmpty ? "未知版本" : versionText)
    }

    private static func firstDisplayLine(_ text: String) -> String {
        text
            .split(whereSeparator: \.isNewline)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty } ?? ""
    }

    private static func run(executable: String, arguments: [String]) -> SimpleProcessResult {
        let process = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.environment = ProcessEnvironment.defaultEnvironment
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return SimpleProcessResult(stdout: "", stderr: error.localizedDescription, exitCode: -1)
        }

        let stdout = String(data: outputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        let stderr = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        return SimpleProcessResult(stdout: stdout, stderr: stderr, exitCode: process.terminationStatus)
    }
}

private struct SimpleProcessResult {
    let stdout: String
    let stderr: String
    let exitCode: Int32
}
