import UIKit
import CoreData

struct RelationshipObjectPair {
  let object: NSManagedObject
  let relationship: NSRelationshipDescription
  func value<T>() -> T? {
    return object.value(forKey: relationship.name) as? T
  }
}



class RelationshipCell: UITableViewCell {
  // MARK: - Globals
  class var identifier: String {
    return "RelationshipCell"
  }
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: type(of: self).identifier)
    configureCell()
  }
  init() {
    super.init(style: .subtitle, reuseIdentifier: type(of: self).identifier)
    configureCell()
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  private func configureCell() {
  
  }
  
  func configure(with pair: RelationshipObjectPair) {
    textLabel?.text = pair.relationship.name
    guard let relatedObject: NSManagedObject? = pair.value() else {
      detailTextLabel?.text = "null"
      return
    }
    detailTextLabel?.text = relatedObject?.objectID.humanReadableRepresentation(hideEntityName: false)
  }

  
}

class ToOneRelationshipCell: UITableViewCell {
  
  
}

