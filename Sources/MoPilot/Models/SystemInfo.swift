import Foundation

struct SystemInfo: Equatable {
    let macOSVersion: String
    let architecture: String
    let freeDiskSpace: String
    let totalDiskSpace: String
}

struct AnalyzeItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let path: String
    let size: String
    let kind: String

    init(name: String = "", path: String, size: String, kind: String = "") {
        self.name = name
        self.path = path
        self.size = size
        self.kind = kind
    }
}

struct StatusMetric: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let value: String
    let detail: String
    let systemImage: String
}

struct ProcessMetric: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let cpu: String
    let memory: String
}
