import AppKit
let size = NSSize(width: 1024, height: 1024)
let image = NSImage(size: size)
image.lockFocus()
NSColor(srgbRed: 0.15, green: 0.32, blue: 0.26, alpha: 1).setFill()
NSRect(origin: .zero, size: size).fill()
let cream = NSColor(srgbRed: 0.96, green: 0.94, blue: 0.87, alpha: 1)
let stroke = NSBezierPath(roundedRect: NSRect(x: 198, y: 182, width: 628, height: 660), xRadius: 55, yRadius: 55)
NSColor(srgbRed: 0.31, green: 0.47, blue: 0.38, alpha: 1).setStroke()
stroke.lineWidth = 5
stroke.stroke()
let text = "W" as NSString
let font = NSFont(name: "Baskerville", size: 530) ?? NSFont.systemFont(ofSize: 530)
let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: cream]
let measured = text.size(withAttributes: attrs)
text.draw(at: NSPoint(x: (1024-measured.width)/2, y: 252), withAttributes: attrs)
cream.setStroke()
let line = NSBezierPath()
line.move(to: NSPoint(x: 380, y: 265)); line.line(to: NSPoint(x: 644, y: 265)); line.lineWidth = 6; line.stroke()
image.unlockFocus()
let bitmap = NSBitmapImageRep(data: image.tiffRepresentation!)!
try bitmap.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
