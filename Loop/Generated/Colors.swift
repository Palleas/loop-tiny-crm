// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSColor
  typealias Color = NSColor
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIColor
  typealias Color = UIColor
#endif

// swiftlint:disable file_length

// swiftlint:disable operator_usage_whitespace
extension Color {
  convenience init(rgbaValue: UInt32) {
    let red   = CGFloat((rgbaValue >> 24) & 0xff) / 255.0
    let green = CGFloat((rgbaValue >> 16) & 0xff) / 255.0
    let blue  = CGFloat((rgbaValue >>  8) & 0xff) / 255.0
    let alpha = CGFloat((rgbaValue      ) & 0xff) / 255.0

    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
}
// swiftlint:enable operator_usage_whitespace

// swiftlint:disable identifier_name line_length type_body_length
struct ColorName {
  let rgbaValue: UInt32
  var color: Color { return Color(named: self) }

  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#030303"></span>
  /// Alpha: 100% <br/> (0x030303ff)
  static let black = ColorName(rgbaValue: 0x030303ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#a4aab3"></span>
  /// Alpha: 100% <br/> (0xa4aab3ff)
  static let coolGrey = ColorName(rgbaValue: 0xa4aab3ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ff5656"></span>
  /// Alpha: 100% <br/> (0xff5656ff)
  static let grapefruit = ColorName(rgbaValue: 0xff5656ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#c1c1c1"></span>
  /// Alpha: 100% <br/> (0xc1c1c1ff)
  static let pinkishGrey = ColorName(rgbaValue: 0xc1c1c1ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ececec"></span>
  /// Alpha: 100% <br/> (0xecececff)
  static let white = ColorName(rgbaValue: 0xecececff)
}
// swiftlint:enable identifier_name line_length type_body_length

extension Color {
  convenience init(named color: ColorName) {
    self.init(rgbaValue: color.rgbaValue)
  }
}
