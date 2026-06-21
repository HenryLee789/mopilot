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
        MoPilot 命令日志
        =================
        开始时间：\(DateFormatter.logDisplayTimestamp.string(from: result.startedAt))
        结束时间：\(DateFormatter.logDisplayTimestamp.string(from: result.endedAt))
        执行命令：\(result.commandLine)
        退出码：\(result.exitCode.map(String.init) ?? "无")
        是否取消：\(result.wasCancelled ? "是" : "否")

        标准输出
        ------
        \(result.stdout)

        错误输出
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
