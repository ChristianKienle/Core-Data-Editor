import Foundation
import CoreData
import UIKit

@objc public final class Editor: NSObject {
  // Properties
  private let context: NSManagedObjectContext
  // Creating
  public init(context: NSManagedObjectContext) {
    self.context = context
    super.init()
  }
  // Working with the Editor
  public func enable() {
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(Editor.show))
    gestureRecognizer.numberOfTapsRequired = 4;
    applicationWindow?.addGestureRecognizer(gestureRecognizer)
  }
  // Private stuff
  @objc func show() {
    let entitiesVC = EntitiesVC(context: context)
    let navigationController = UINavigationController(rootViewController: entitiesVC)
    applicationWindow?.rootViewController?.show(navigationController, sender: self)
  }
  private var applicationWindow: UIWindow? {
    return UIApplication.shared.windows[0]
  }
}
