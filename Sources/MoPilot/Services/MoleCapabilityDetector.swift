import Foundation

struct MoleCapabilityDetector {
    static func detect(moPath: String) async -> MoleCapabilities {
        await Task.detached {
            MoleCapabilities(
                analyzeJSONFlag: jsonFlag(for: "analyze", moPath: moPath),
                statusJSONFlag: jsonFlag(for: "status", moPath: moPath)
            )
        }.value
    }

    private static func jsonFlag(for subcommand: String, moPath: String) -> String? {
        let help = run(executable: moPath, arguments: [subcommand, "--help"])
        let combined = "\(help.stdout)\n\(help.stderr)"

        if combined.contains("--json") {
            return "--json"
        }

        if combined.contains("-json") {
            return "-json"
        }

        return nil
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
            return SimpleProcessResult(stdout: "", stderr: error.localizedDescription)
        }

        let stdout = String(data: outputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        let stderr = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        return SimpleProcessResult(stdout: stdout, stderr: stderr)
    }
}

private struct SimpleProcessResult {
    let stdout: String
    let stderr: String
}
