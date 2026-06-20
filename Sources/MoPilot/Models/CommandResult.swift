import Foundation

enum CommandRunStatus: Equatable {
    case idle
    case running
    case succeeded(Int32)
    case failed(Int32)
    case cancelled(Int32?)
    case launchFailed(String)

    var label: String {
        switch self {
        case .idle:
            "未执行"
        case .running:
            "执行中"
        case .succeeded(let code):
            "完成，退出码 \(code)"
        case .failed(let code):
            "失败，退出码 \(code)"
        case .cancelled(let code):
            if let code {
                "已取消，退出码 \(code)"
            } else {
                "已取消"
            }
        case .launchFailed:
            "启动失败"
        }
    }

    var isRunning: Bool {
        if case .running = self {
            return true
        }
        return false
    }
}

struct CommandResult {
    let command: MoleCommand
    let commandLine: String
    let startedAt: Date
    let endedAt: Date
    let stdout: String
    let stderr: String
    let exitCode: Int32?
    let wasCancelled: Bool

    var succeeded: Bool {
        exitCode == 0 && !wasCancelled
    }
}
