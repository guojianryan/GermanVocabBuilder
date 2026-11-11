import AppKit

// Reproducible 1024 px artwork. iOS applies the outer app-icon mask.
let size = NSSize(width: 1024, height: 1024)
let image = NSImage(size: size)
func color(_ hex: UInt32) -> NSColor {
    NSColor(srgbRed: CGFloat((hex >> 16) & 255) / 255,
            green: CGFloat((hex >> 8) & 255) / 255,
            blue: CGFloat(hex & 255) / 255, alpha: 1)
}
func rotated(_ degrees: CGFloat, center: NSPoint, draw: () -> Void) {
    NSGraphicsContext.saveGraphicsState()
    let transform = NSAffineTransform()
    transform.translateX(by: center.x, yBy: center.y)
    transform.rotate(byDegrees: degrees)
    transform.concat()
    draw()
    NSGraphicsContext.restoreGraphicsState()
}
func shadowed(blur: CGFloat, offset: NSSize, draw: () -> Void) {
    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.25)
    shadow.shadowBlurRadius = blur
    shadow.shadowOffset = offset
    shadow.set()
    draw()
    NSGraphicsContext.restoreGraphicsState()
}
image.lockFocus()
let bounds = NSRect(origin: .zero, size: size)
NSGradient(starting: color(0x326D58), ending: color(0x132E28))!.draw(in: bounds, angle: -65)

// A quiet halo adds depth without competing with the central silhouette.
color(0x80B998).withAlphaComponent(0.06).setFill()
NSBezierPath(ovalIn: NSRect(x: 80, y: 130, width: 860, height: 860)).fill()

// The offset card makes this a collection of words, rather than a single letter.
rotated(10, center: NSPoint(x: 550, y: 486)) {
    shadowed(blur: 34, offset: NSSize(width: 0, height: -18)) {
        color(0xB8CDB1).setFill()
        NSBezierPath(roundedRect: NSRect(x: -268, y: -310, width: 536, height: 620), xRadius: 58, yRadius: 58).fill()
    }
}
rotated(-9, center: NSPoint(x: 468, y: 506)) {
    let card = NSRect(x: -268, y: -318, width: 536, height: 636)
    shadowed(blur: 30, offset: NSSize(width: 0, height: -16)) {
        color(0xFAF1DE).setFill()
        NSBezierPath(roundedRect: card, xRadius: 56, yRadius: 56).fill()
    }
    let text = "W" as NSString
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont(name: "Baskerville-SemiBold", size: 400) ?? NSFont.systemFont(ofSize: 400, weight: .semibold),
        .foregroundColor: color(0x234E40)
    ]
    let measured = text.size(withAttributes: attributes)
    text.draw(at: NSPoint(x: -measured.width / 2, y: -174), withAttributes: attributes)

    // A subtle baseline and three gender colors give the card its own identity.
    color(0xD8CBB5).setFill()
    NSBezierPath(roundedRect: NSRect(x: -154, y: -208, width: 308, height: 7), xRadius: 3.5, yRadius: 3.5).fill()
    for (index, hex) in [UInt32(0x3979BF), 0xC9516C, 0x438157].enumerated() {
        color(hex).setFill()
        NSBezierPath(roundedRect: NSRect(x: -105 + CGFloat(index) * 78, y: -263, width: 54, height: 16), xRadius: 8, yRadius: 8).fill()
    }
}

// A speech bubble suggests using a word, with a small spark of discovery.
shadowed(blur: 24, offset: NSSize(width: 0, height: -12)) {
    let bubble = NSBezierPath(roundedRect: NSRect(x: 620, y: 624, width: 242, height: 226), xRadius: 77, yRadius: 77)
    let tail = NSBezierPath()
    tail.move(to: NSPoint(x: 648, y: 669))
    tail.line(to: NSPoint(x: 623, y: 600))
    tail.line(to: NSPoint(x: 724, y: 642))
    tail.close()
    bubble.append(tail)
    bubble.windingRule = .nonZero
    color(0xDA8253).setFill()
    bubble.fill()
}
let spark = NSBezierPath()
spark.move(to: NSPoint(x: 741, y: 804))
spark.curve(to: NSPoint(x: 804, y: 738), controlPoint1: NSPoint(x: 751, y: 756), controlPoint2: NSPoint(x: 759, y: 748))
spark.curve(to: NSPoint(x: 741, y: 672), controlPoint1: NSPoint(x: 759, y: 728), controlPoint2: NSPoint(x: 751, y: 720))
spark.curve(to: NSPoint(x: 678, y: 738), controlPoint1: NSPoint(x: 731, y: 720), controlPoint2: NSPoint(x: 723, y: 728))
spark.curve(to: NSPoint(x: 741, y: 804), controlPoint1: NSPoint(x: 723, y: 748), controlPoint2: NSPoint(x: 731, y: 756))
spark.close()
color(0xFFF5DF).setFill()
spark.fill()
image.unlockFocus()

// Export opaque RGB: App Store icons must not contain an alpha channel.
let rgb = CGColorSpace(name: CGColorSpace.sRGB)!
let context = CGContext(data: nil, width: 1024, height: 1024, bitsPerComponent: 8,
                        bytesPerRow: 4096, space: rgb, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
context.draw(image.cgImage(forProposedRect: nil, context: nil, hints: nil)!, in: CGRect(x: 0, y: 0, width: 1024, height: 1024))
let bitmap = NSBitmapImageRep(cgImage: context.makeImage()!)
try bitmap.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
