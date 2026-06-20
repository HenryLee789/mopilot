import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let iconsetURL = root.appendingPathComponent("Sources/MoPilot/Resources/AppIcon.iconset", isDirectory: true)
let icnsURL = root.appendingPathComponent("Sources/MoPilot/Resources/AppIcon.icns")

try? FileManager.default.removeItem(at: iconsetURL)
try? FileManager.default.removeItem(at: icnsURL)
try FileManager.default.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

let outputs: [(name: String, pixels: Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

func image(size: Int) -> NSImage {
    let canvas = NSSize(width: size, height: size)
    let image = NSImage(size: canvas)
    image.lockFocus()

    let rect = NSRect(origin: .zero, size: canvas)
    let radius = CGFloat(size) * 0.22
    let path = NSBezierPath(roundedRect: rect.insetBy(dx: CGFloat(size) * 0.035, dy: CGFloat(size) * 0.035), xRadius: radius, yRadius: radius)
    path.addClip()

    NSGradient(colors: [
        NSColor(red: 0.06, green: 0.10, blue: 0.18, alpha: 1),
        NSColor(red: 0.02, green: 0.42, blue: 0.36, alpha: 1),
        NSColor(red: 0.50, green: 0.64, blue: 0.40, alpha: 1)
    ])?.draw(in: rect, angle: 38)

    let ring = NSBezierPath(ovalIn: rect.insetBy(dx: CGFloat(size) * 0.17, dy: CGFloat(size) * 0.17))
    NSColor.white.withAlphaComponent(0.14).setStroke()
    ring.lineWidth = max(1, CGFloat(size) * 0.035)
    ring.stroke()

    let tickPath = NSBezierPath()
    tickPath.move(to: NSPoint(x: CGFloat(size) * 0.69, y: CGFloat(size) * 0.70))
    tickPath.curve(
        to: NSPoint(x: CGFloat(size) * 0.83, y: CGFloat(size) * 0.84),
        controlPoint1: NSPoint(x: CGFloat(size) * 0.76, y: CGFloat(size) * 0.72),
        controlPoint2: NSPoint(x: CGFloat(size) * 0.81, y: CGFloat(size) * 0.77)
    )
    NSColor.white.withAlphaComponent(0.78).setStroke()
    tickPath.lineWidth = max(1, CGFloat(size) * 0.055)
    tickPath.lineCapStyle = .round
    tickPath.stroke()

    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    let font = NSFont.systemFont(ofSize: CGFloat(size) * 0.31, weight: .bold)
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor.white,
        .paragraphStyle: paragraph,
        .kern: -CGFloat(size) * 0.012
    ]
    let textRect = NSRect(x: CGFloat(size) * 0.08, y: CGFloat(size) * 0.34, width: CGFloat(size) * 0.84, height: CGFloat(size) * 0.34)
    ("Mo" as NSString).draw(in: textRect, withAttributes: attributes)

    image.unlockFocus()
    return image
}

func writePNG(_ image: NSImage, to url: URL) throws {
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let data = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "MoPilotIcon", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create PNG"])
    }
    try data.write(to: url)
}

for output in outputs {
    try writePNG(image(size: output.pixels), to: iconsetURL.appendingPathComponent(output.name))
}

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", iconsetURL.path, "-o", icnsURL.path]
try process.run()
process.waitUntilExit()

guard process.terminationStatus == 0 else {
    throw NSError(domain: "MoPilotIcon", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "iconutil failed"])
}

try? FileManager.default.removeItem(at: iconsetURL)
print("Generated \(icnsURL.path)")
