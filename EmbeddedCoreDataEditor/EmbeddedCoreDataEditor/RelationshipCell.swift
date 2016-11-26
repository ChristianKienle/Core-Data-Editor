import UIKit
import CoreData

struct RelationshipObjectPair {
  let object: NSManagedObject
  let relationship: NSRelationshipDescription
  func value<T>() -> T? {
    return object.value(forKey: relationship.name) as? T
  }
}

final class RelationshipCell: UITableViewCell {
  // MARK: - Globals
  class var identifier: String {
    return "RelationshipCell"
  }
  // MARK: - Creating
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: type(of: self).identifier)
  }
  init() {
    super.init(style: .subtitle, reuseIdentifier: type(of: self).identifier)
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  // MARK: - Configures
  func configure(with pair: RelationshipObjectPair) {
    let relationship = pair.relationship
    textLabel?.text = relationship.name
    let text: String
    if relationship.isToMany {
      imageView?.image = UIImage(named: "toMany", in: Bundle(for: type(of:self)), compatibleWith: traitCollection)
      if let relatedObjects: NSSet = pair.value() {
        text = "\(relatedObjects.count) Object(s)"
      } else {
        text = "null"
      }
    } else {
      imageView?.image = UIImage(named: "toOne", in: Bundle(for: type(of:self)), compatibleWith: traitCollection)
      if let relatedObject: NSManagedObject = pair.value() {
        text = relatedObject.objectID.humanReadableRepresentation(hideEntityName: false)
      } else {
        text = "null"
      }
    }
    detailTextLabel?.text = text
  }
}
