import Foundation
import CoreData

public extension NSAttributeType {
  public var hasFloatingPointCharacteristics: Bool {
    switch self {
    case .doubleAttributeType, .floatAttributeType, .decimalAttributeType: return true
    default: return false
    }
  }
  public var hasIntegerCharacteristics: Bool {
    switch self {
    case .integer16AttributeType, .integer32AttributeType, .integer64AttributeType: return true
    default: return false
    }
  }
}
