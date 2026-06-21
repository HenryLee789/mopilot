import Foundation

struct SystemInfoService {
    static func current() -> SystemInfo {
        let version = ProcessInfo.processInfo.operatingSystemVersionString
        let disk = diskSpace()
        return SystemInfo(
            macOSVersion: version,
            architecture: architecture,
            freeDiskSpace: disk.free,
            totalDiskSpace: disk.total
        )
    }

    private static var architecture: String {
        #if arch(arm64)
        return "Apple 芯片 (arm64)"
        #elseif arch(x86_64)
        return "Intel 芯片 (x86_64)"
        #else
        return "未知架构"
        #endif
    }

    private static func diskSpace() -> (free: String, total: String) {
        let rootURL = URL(fileURLWithPath: "/")
        do {
            let values = try rootURL.resourceValues(forKeys: [
                .volumeAvailableCapacityForImportantUsageKey,
                .volumeTotalCapacityKey
            ])
            let free = values.volumeAvailableCapacityForImportantUsage.map(formatBytes) ?? "未知"
            let total = values.volumeTotalCapacity.map { formatBytes(Int64($0)) } ?? "未知"
            return (free, total)
        } catch {
            return ("未知", "未知")
        }
    }

    private static func formatBytes(_ bytes: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
}
