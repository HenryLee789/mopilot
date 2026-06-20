import Foundation

enum MoleJSONParsers {
    static func analyzeItems(from text: String) -> [AnalyzeItem]? {
        guard let data = text.data(using: .utf8),
              let report = try? JSONDecoder().decode(AnalyzeJSONReport.self, from: data) else {
            return nil
        }

        return report.entries.map { entry in
            AnalyzeItem(
                name: entry.name,
                path: entry.path,
                size: ByteFormatting.fileSize(entry.size),
                kind: entry.isDir ? "目录" : "文件"
            )
        }
    }

    static func statusMetrics(from text: String) -> (metrics: [StatusMetric], processes: [ProcessMetric])? {
        guard let data = text.data(using: .utf8),
              let report = try? JSONDecoder().decode(StatusJSONReport.self, from: data) else {
            return nil
        }

        let metrics = [
            StatusMetric(
                title: "健康评分",
                value: report.healthScore.map(String.init) ?? "未知",
                detail: report.healthScoreMessage ?? "来自 mo status",
                systemImage: "heart.text.square"
            ),
            StatusMetric(
                title: "CPU",
                value: ByteFormatting.percent(report.cpu?.usage),
                detail: "Load \(formatLoad(report.cpu?.load1)) / \(formatLoad(report.cpu?.load5)) / \(formatLoad(report.cpu?.load15))",
                systemImage: "cpu"
            ),
            StatusMetric(
                title: "内存",
                value: ByteFormatting.percent(report.memory?.usedPercent),
                detail: "\(ByteFormatting.fileSize(report.memory?.used)) / \(ByteFormatting.fileSize(report.memory?.total))",
                systemImage: "memorychip"
            ),
            StatusMetric(
                title: "磁盘",
                value: ByteFormatting.percent(report.disks.first?.usedPercent),
                detail: "\(report.disks.first?.mount ?? "/") · \(ByteFormatting.fileSize(report.disks.first?.used)) / \(ByteFormatting.fileSize(report.disks.first?.total))",
                systemImage: "internaldrive"
            ),
            StatusMetric(
                title: "网络",
                value: networkValue(report.network),
                detail: networkDetail(report.network),
                systemImage: "network"
            ),
            StatusMetric(
                title: "电池",
                value: report.batteries.first?.percent.map { "\($0)%" } ?? "未知",
                detail: report.batteries.first?.status ?? "未检测到电池状态",
                systemImage: "battery.75"
            )
        ]

        let processes = report.topProcesses.map { process in
            ProcessMetric(
                name: process.name,
                cpu: ByteFormatting.percent(process.cpu),
                memory: ByteFormatting.percent(process.memory)
            )
        }

        return (metrics, processes)
    }

    private static func formatLoad(_ value: Double?) -> String {
        guard let value else { return "?" }
        return String(format: "%.2f", value)
    }

    private static func networkValue(_ interfaces: [NetworkJSON]) -> String {
        let rx = interfaces.reduce(0) { $0 + ($1.rxRateMBS ?? 0) }
        let tx = interfaces.reduce(0) { $0 + ($1.txRateMBS ?? 0) }
        return String(format: "↓ %.2f / ↑ %.2f MB/s", rx, tx)
    }

    private static func networkDetail(_ interfaces: [NetworkJSON]) -> String {
        interfaces.first { ($0.ip ?? "").isEmpty == false }
            .map { "\($0.name) · \($0.ip ?? "")" } ?? "未检测到活跃 IP"
    }
}

private struct AnalyzeJSONReport: Decodable {
    let entries: [AnalyzeEntryJSON]
}

private struct AnalyzeEntryJSON: Decodable {
    let name: String
    let path: String
    let size: Int64?
    let isDir: Bool

    enum CodingKeys: String, CodingKey {
        case name
        case path
        case size
        case isDir = "is_dir"
    }
}

private struct StatusJSONReport: Decodable {
    let healthScore: Int?
    let healthScoreMessage: String?
    let cpu: CPUJSON?
    let memory: MemoryJSON?
    let disks: [DiskJSON]
    let network: [NetworkJSON]
    let batteries: [BatteryJSON]
    let topProcesses: [TopProcessJSON]

    enum CodingKeys: String, CodingKey {
        case healthScore = "health_score"
        case healthScoreMessage = "health_score_msg"
        case cpu
        case memory
        case disks
        case network
        case batteries
        case topProcesses = "top_processes"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        healthScore = try container.decodeIfPresent(Int.self, forKey: .healthScore)
        healthScoreMessage = try container.decodeIfPresent(String.self, forKey: .healthScoreMessage)
        cpu = try container.decodeIfPresent(CPUJSON.self, forKey: .cpu)
        memory = try container.decodeIfPresent(MemoryJSON.self, forKey: .memory)
        disks = try container.decodeIfPresent([DiskJSON].self, forKey: .disks) ?? []
        network = try container.decodeIfPresent([NetworkJSON].self, forKey: .network) ?? []
        batteries = try container.decodeIfPresent([BatteryJSON].self, forKey: .batteries) ?? []
        topProcesses = try container.decodeIfPresent([TopProcessJSON].self, forKey: .topProcesses) ?? []
    }
}

private struct CPUJSON: Decodable {
    let usage: Double?
    let load1: Double?
    let load5: Double?
    let load15: Double?
}

private struct MemoryJSON: Decodable {
    let used: Int64?
    let total: Int64?
    let usedPercent: Double?

    enum CodingKeys: String, CodingKey {
        case used
        case total
        case usedPercent = "used_percent"
    }
}

private struct DiskJSON: Decodable {
    let mount: String?
    let used: Int64?
    let total: Int64?
    let usedPercent: Double?

    enum CodingKeys: String, CodingKey {
        case mount
        case used
        case total
        case usedPercent = "used_percent"
    }
}

private struct NetworkJSON: Decodable {
    let name: String
    let rxRateMBS: Double?
    let txRateMBS: Double?
    let ip: String?

    enum CodingKeys: String, CodingKey {
        case name
        case rxRateMBS = "rx_rate_mbs"
        case txRateMBS = "tx_rate_mbs"
        case ip
    }
}

private struct BatteryJSON: Decodable {
    let percent: Int?
    let status: String?
}

private struct TopProcessJSON: Decodable {
    let name: String
    let cpu: Double?
    let memory: Double?
}
