import Foundation

enum AnalyzeParser {
    static func parse(_ text: String) -> [AnalyzeItem] {
        text
            .split(whereSeparator: \.isNewline)
            .compactMap { parseLine(String($0)) }
    }

    private static func parseLine(_ line: String) -> AnalyzeItem? {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if let item = match(pattern: #"^\s*([0-9]+(?:\.[0-9]+)?\s?(?:B|KB|MB|GB|TB|KiB|MiB|GiB|TiB))\s+(.+)$"#, in: trimmed, sizeIndex: 1, pathIndex: 2) {
            return item
        }

        if let item = match(pattern: #"^\s*(/.+?)\s+([0-9]+(?:\.[0-9]+)?\s?(?:B|KB|MB|GB|TB|KiB|MiB|GiB|TiB))\s*$"#, in: trimmed, sizeIndex: 2, pathIndex: 1) {
            return item
        }

        return nil
    }

    private static func match(pattern: String, in line: String, sizeIndex: Int, pathIndex: Int) -> AnalyzeItem? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }

        let range = NSRange(line.startIndex..<line.endIndex, in: line)
        guard let match = regex.firstMatch(in: line, range: range),
              let sizeRange = Range(match.range(at: sizeIndex), in: line),
              let pathRange = Range(match.range(at: pathIndex), in: line) else {
            return nil
        }

        let size = String(line[sizeRange]).trimmingCharacters(in: .whitespaces)
        let path = String(line[pathRange]).trimmingCharacters(in: .whitespaces)
        guard path.hasPrefix("/") || path.hasPrefix("~") else { return nil }

        return AnalyzeItem(path: path, size: size)
    }
}
