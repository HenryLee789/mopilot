import Foundation

enum MoleUninstallService {
    static func listInstalledApps(moPath: String) async throws -> [InstalledApp] {
        try await Task.detached {
            let result = run(executable: moPath, arguments: ["uninstall", "--list"])
            guard result.exitCode == 0 else {
                throw UninstallServiceError.commandFailed(result.stderr.isEmpty ? result.stdout : result.stderr)
            }

            guard let data = result.stdout.data(using: .utf8) else {
                throw UninstallServiceError.invalidOutput("mo uninstall --list 没有返回 UTF-8 输出")
            }

            do {
                return try JSONDecoder().decode([InstalledApp].self, from: data)
            } catch {
                throw UninstallServiceError.invalidOutput(error.localizedDescription)
            }
        }.value
    }

    private static func run(executable: String, arguments: [String]) -> SimpleProcessResult {
        let process = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        let inputPipe = Pipe()

        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.environment = ProcessEnvironment.defaultEnvironment
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        process.standardInput = inputPipe

        do {
            try process.run()
            try? inputPipe.fileHandleForWriting.close()
            process.waitUntilExit()
        } catch {
            return SimpleProcessResult(stdout: "", stderr: error.localizedDescription, exitCode: -1)
        }

        let stdout = ANSITextCleaner.clean(String(data: outputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "")
        let stderr = ANSITextCleaner.clean(String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "")
        return SimpleProcessResult(stdout: stdout, stderr: stderr, exitCode: process.terminationStatus)
    }
}

enum UninstallServiceError: LocalizedError {
    case commandFailed(String)
    case invalidOutput(String)

    var errorDescription: String? {
        switch self {
        case .commandFailed(let message):
            return message.isEmpty ? "mo uninstall --list 执行失败" : message
        case .invalidOutput(let message):
            return "无法解析应用列表：\(message)"
        }
    }
}

private struct SimpleProcessResult {
    let stdout: String
    let stderr: String
    let exitCode: Int32
}
