import Foundation

@MainActor
final class CommandRunner: ObservableObject {
    @Published private(set) var status: CommandRunStatus = .idle
    @Published private(set) var logText = ""
    @Published private(set) var stdoutText = ""
    @Published private(set) var stderrText = ""
    @Published private(set) var lastExitCode: Int32?
    @Published private(set) var lastLogURL: URL?
    @Published private(set) var completedCommands: Set<MoleCommand> = []

    private let logService: LogService
    private var process: Process?
    private var startedAt: Date?
    private var activeCommand: MoleCommand?
    private var activeCommandLine = ""
    private var cancellationRequested = false

    var isRunning: Bool {
        status.isRunning
    }

    init(logService: LogService = LogService()) {
        self.logService = logService
    }

    func run(_ command: MoleCommand, moPath: String, arguments: [String]? = nil, standardInput: String? = nil) {
        guard !isRunning else { return }

        let resolvedArguments = arguments ?? command.arguments
        resetForNewRun(command: command, moPath: moPath, arguments: resolvedArguments)

        let process = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        process.executableURL = URL(fileURLWithPath: moPath)
        process.arguments = resolvedArguments
        process.environment = ProcessEnvironment.defaultEnvironment
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        let inputPipe = Pipe()
        process.standardInput = inputPipe

        outputPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty else { return }
            let text = String(data: data, encoding: .utf8) ?? String(decoding: data, as: UTF8.self)
            Task { @MainActor in
                self?.appendOutput(text, isError: false)
            }
        }

        errorPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty else { return }
            let text = String(data: data, encoding: .utf8) ?? String(decoding: data, as: UTF8.self)
            Task { @MainActor in
                self?.appendOutput(text, isError: true)
            }
        }

        process.terminationHandler = { [weak self] finishedProcess in
            outputPipe.fileHandleForReading.readabilityHandler = nil
            errorPipe.fileHandleForReading.readabilityHandler = nil
            Task { @MainActor in
                self?.finish(exitCode: finishedProcess.terminationStatus)
            }
        }

        self.process = process

        do {
            try process.run()
            appendSystemLine("开始执行：\(activeCommandLine)")
            if let standardInput {
                inputPipe.fileHandleForWriting.write(Data(standardInput.utf8))
            }
            try? inputPipe.fileHandleForWriting.close()
        } catch {
            status = .launchFailed(error.localizedDescription)
            appendSystemLine("启动失败：\(error.localizedDescription)")
            processDidFailToLaunch()
        }
    }

    func cancel() {
        guard isRunning else { return }
        cancellationRequested = true
        appendSystemLine("已请求取消当前任务。")
        process?.terminate()
    }

    func clearLog() {
        guard !isRunning else { return }
        logText = ""
        stdoutText = ""
        stderrText = ""
        lastExitCode = nil
        lastLogURL = nil
        status = .idle
    }

    func hasSuccessfulRun(_ command: MoleCommand) -> Bool {
        completedCommands.contains(command)
    }

    private func resetForNewRun(command: MoleCommand, moPath: String, arguments: [String]) {
        status = .running
        logText = ""
        stdoutText = ""
        stderrText = ""
        lastExitCode = nil
        lastLogURL = nil
        startedAt = Date()
        activeCommand = command
        activeCommandLine = ShellEscaping.commandLine([moPath] + arguments)
        cancellationRequested = false
    }

    private func appendOutput(_ text: String, isError: Bool) {
        let cleanText = ANSITextCleaner.clean(text)
        if isError {
            stderrText += cleanText
        } else {
            stdoutText += cleanText
        }
        logText += cleanText
    }

    private func appendSystemLine(_ text: String) {
        let line = "[MoPilot] \(text)\n"
        logText += line
    }

    private func finish(exitCode: Int32) {
        lastExitCode = exitCode
        process = nil

        if cancellationRequested {
            status = .cancelled(exitCode)
        } else if exitCode == 0 {
            status = .succeeded(exitCode)
            if let activeCommand {
                completedCommands.insert(activeCommand)
            }
        } else {
            status = .failed(exitCode)
        }

        appendSystemLine(status.label)
        saveLog(exitCode: exitCode, wasCancelled: cancellationRequested)
    }

    private func processDidFailToLaunch() {
        let errorText = logText
        stderrText += errorText
        saveLog(exitCode: nil, wasCancelled: false)
        process = nil
    }

    private func saveLog(exitCode: Int32?, wasCancelled: Bool) {
        guard let activeCommand, let startedAt else { return }

        let result = CommandResult(
            command: activeCommand,
            commandLine: activeCommandLine,
            startedAt: startedAt,
            endedAt: Date(),
            stdout: stdoutText,
            stderr: stderrText,
            exitCode: exitCode,
            wasCancelled: wasCancelled
        )

        do {
            lastLogURL = try logService.save(result: result)
            if let lastLogURL {
                appendSystemLine("日志已保存：\(lastLogURL.path)")
            }
        } catch {
            appendSystemLine("日志保存失败：\(error.localizedDescription)")
        }
    }
}
