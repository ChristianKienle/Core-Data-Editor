import Foundation
import CoreData

public extension NSManagedObject {
  public var isValid: Bool {
    return self.validationErrors_cde.isEmpty
  }
  public func string(for key: String) -> String? {
    guard let property = entity.propertiesByName[key] else {
      fatalError("Invalid Key")
    }
    if let attribute = property as? NSAttributeDescription {
      return string(forAttribute: attribute)
    }
    if let relationship = property as? NSRelationshipDescription {
      return string(forRelationship: relationship)
    }
    return nil
  }
  private typealias TypeValuePair = (type: NSAttributeType, value: Any?)
  private func string(forAttribute attribute: NSAttributeDescription) -> String? {
    let typeValuePair = TypeValuePair(type: attribute.attributeType, value: self.value(forKey: attribute.name))
    switch typeValuePair {
    case (.binaryDataAttributeType, nil): return nil
    case (.binaryDataAttributeType, let value as Data): return String(value.count) + " Bytes"
    case (.stringAttributeType, nil): return nil
    case (.stringAttributeType, let value as String): return value
    case (.integer16AttributeType, nil), (.integer32AttributeType, nil), (.integer64AttributeType, nil): return nil
    case (.integer16AttributeType, let value as Int), (.integer32AttributeType, let value as Int), (.integer64AttributeType, let value as Int): return String(value)
    case (.decimalAttributeType, nil), (.doubleAttributeType, nil), (.floatAttributeType, nil): return nil
    case (.decimalAttributeType, let value as NSNumber), (.doubleAttributeType, let value as NSNumber), (.floatAttributeType, let value as NSNumber): return value.description
    case (.booleanAttributeType, nil): return nil
    case (.booleanAttributeType, let value as Bool): return String(value)
    case (.dateAttributeType, nil): return nil
    case (.dateAttributeType, let value as Date): return value.description
    default: return nil
    }
    return nil
  }
  private func string(forRelationship attribute: NSRelationshipDescription) -> String? {
    return nil
  }
}
