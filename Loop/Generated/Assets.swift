// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSImage
  typealias Image = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  typealias Image = UIImage
#endif

// swiftlint:disable file_length

struct AssetType: ExpressibleByStringLiteral {
  fileprivate var value: String

  var image: Image {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let image = Image(named: value, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    let image = bundle.image(forResource: value)
    #elseif os(watchOS)
    let image = Image(named: value)
    #endif
    guard let result = image else { fatalError("Unable to load image \(value).") }
    return result
  }

  init(stringLiteral value: String) {
    self.value = value
  }

  init(extendedGraphemeClusterLiteral value: String) {
    self.init(stringLiteral: value)
  }

  init(unicodeScalarLiteral value: String) {
    self.init(stringLiteral: value)
  }
}

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
enum Asset {
  enum Activities {
    static let apartment: AssetType = "apartment"
    static let bubble: AssetType = "bubble"
    static let coffeeCup: AssetType = "coffee-cup"
    static let envelope: AssetType = "envelope"
    static let magicWand: AssetType = "magic-wand"
    static let phoneHandset: AssetType = "phone-handset"
    static let shirt: AssetType = "shirt"
    static let star: AssetType = "star"
    static let user: AssetType = "user"
  }
  static let envelope: AssetType = "envelope"
  static let logo: AssetType = "logo"
  enum Menu {
    static let userPlus: AssetType = "userPlus"
  }
  static let shape: AssetType = "shape"

  static let allValues = [
    Activities.apartment,
    Activities.bubble,
    Activities.coffeeCup,
    Activities.envelope,
    Activities.magicWand,
    Activities.phoneHandset,
    Activities.shirt,
    Activities.star,
    Activities.user,
    envelope,
    logo,
    Menu.userPlus,
    shape,
  ]
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

extension Image {
  convenience init!(asset: AssetType) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle(for: BundleToken.self)
    self.init(named: asset.value, in: bundle, compatibleWith: nil)
    #elseif os(OSX) || os(watchOS)
    self.init(named: asset.value)
    #endif
  }
}

private final class BundleToken {}
