import Foundation
import CoreData

public extension NSManagedObject {
  public var isValid: Bool {
    return self.validationErrors_cde.isEmpty
  }
}
