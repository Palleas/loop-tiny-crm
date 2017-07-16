// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation
import UIKit
import Loop

// swiftlint:disable file_length
// swiftlint:disable line_length
// swiftlint:disable type_body_length

protocol StoryboardSceneType {
  static var storyboardName: String { get }
}

extension StoryboardSceneType {
  static func storyboard() -> UIStoryboard {
    return UIStoryboard(name: self.storyboardName, bundle: Bundle(for: BundleToken.self))
  }

  static func initialViewController() -> UIViewController {
    guard let vc = storyboard().instantiateInitialViewController() else {
      fatalError("Failed to instantiate initialViewController for \(self.storyboardName)")
    }
    return vc
  }
}

extension StoryboardSceneType where Self: RawRepresentable, Self.RawValue == String {
  func viewController() -> UIViewController {
    return Self.storyboard().instantiateViewController(withIdentifier: self.rawValue)
  }
  static func viewController(identifier: Self) -> UIViewController {
    return identifier.viewController()
  }
}

protocol StoryboardSegueType: RawRepresentable { }

extension UIViewController {
  func perform<S: StoryboardSegueType>(segue: S, sender: Any? = nil) where S.RawValue == String {
    performSegue(withIdentifier: segue.rawValue, sender: sender)
  }
}

enum StoryboardScene {
  enum Main: String, StoryboardSceneType {
    static let storyboardName = "Main"

    case addLeadScene = "AddLead"
    static func instantiateAddLead() -> Loop.AddLeadViewController {
      guard let vc = StoryboardScene.Main.addLeadScene.viewController() as? Loop.AddLeadViewController
      else {
        fatalError("ViewController 'AddLead' is not of the expected class Loop.AddLeadViewController.")
      }
      return vc
    }

    case connectWithTwitterScene = "connectWithTwitter"
    static func instantiateConnectWithTwitter() -> Loop.ConnectWithTwitterViewController {
      guard let vc = StoryboardScene.Main.connectWithTwitterScene.viewController() as? Loop.ConnectWithTwitterViewController
      else {
        fatalError("ViewController 'connectWithTwitter' is not of the expected class Loop.ConnectWithTwitterViewController.")
      }
      return vc
    }
  }
}

enum StoryboardSegue {
  enum Main: String, StoryboardSegueType {
    case userSearch = "UserSearch"
  }
}

private final class BundleToken {}
