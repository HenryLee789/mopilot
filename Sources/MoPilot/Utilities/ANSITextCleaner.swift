import Foundation

enum ANSITextCleaner {
    private static let ansiPattern = "\u{001B}\\[[0-?]*[ -/]*[@-~]"
    private static let carriageReturnPattern = "\r+"

    static func clean(_ text: String) -> String {
        let withoutANSI = text.replacingOccurrences(
            of: ansiPattern,
            with: "",
            options: .regularExpression
        )
        return withoutANSI.replacingOccurrences(
            of: carriageReturnPattern,
            with: "\n",
            options: .regularExpression
        )
    }
}
