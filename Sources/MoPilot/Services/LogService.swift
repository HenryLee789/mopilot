import AppKit
import Foundation

struct LogService {
    let directoryURL: URL

    init(directoryURL: URL = LogService.defaultDirectoryURL()) {
        self.directoryURL = directoryURL
    }

    static func defaultDirectoryURL() -> URL {
        FileManager.default
            .urls(for: .libraryDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Logs", isDirectory: true)
            .appendingPathComponent("MoPilot", isDirectory: true)
    }

    func ensureDirectoryExists() throws {
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )
    }

    func save(result: CommandResult) throws -> URL {
        try ensureDirectoryExists()

        let timestamp = DateFormatter.logFileTimestamp.string(from: result.startedAt)
        let fileName = "\(timestamp)_\(result.command.fileNameComponent).log"
        let fileURL = directoryURL.appendingPathComponent(fileName)

        let content = """
        MoPilot Command Log
        ===================
        Started At: \(DateFormatter.logDisplayTimestamp.string(from: result.startedAt))
        Ended At: \(DateFormatter.logDisplayTimestamp.string(from: result.endedAt))
        Command: \(result.commandLine)
        Exit Code: \(result.exitCode.map(String.init) ?? "N/A")
        Cancelled: \(result.wasCancelled ? "true" : "false")

        STDOUT
        ------
        \(result.stdout)

        STDERR
        ------
        \(result.stderr)
        """

        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }

    func openDirectory() throws {
        try ensureDirectoryExists()
        NSWorkspace.shared.open(directoryURL)
    }
}
