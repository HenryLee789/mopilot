import CoreGraphics
import Foundation

let ownerName = CommandLine.arguments.dropFirst().first ?? "MoPilot"

guard let windows = CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID) as? [[String: Any]] else {
    fatalError("Unable to list windows")
}

let candidates = windows.filter { window in
    let owner = window[kCGWindowOwnerName as String] as? String
    let layer = window[kCGWindowLayer as String] as? Int
    let bounds = window[kCGWindowBounds as String] as? [String: Any]
    let width = bounds?["Width"] as? Double ?? 0
    let height = bounds?["Height"] as? Double ?? 0
    return owner == ownerName && layer == 0 && width > 200 && height > 200
}

guard let window = candidates.first,
      let windowNumber = window[kCGWindowNumber as String] as? UInt32 else {
    fatalError("No visible \(ownerName) window found")
}

print(windowNumber)
