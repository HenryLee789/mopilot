import Foundation

enum ByteFormatting {
    static func fileSize(_ bytes: Int64?) -> String {
        guard let bytes else { return "未知" }
        return ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }

    static func percent(_ value: Double?) -> String {
        guard let value else { return "未知" }
        return String(format: "%.1f%%", value)
    }
}
