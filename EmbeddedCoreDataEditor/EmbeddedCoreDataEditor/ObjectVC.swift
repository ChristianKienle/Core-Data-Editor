import Foundation
import UIKit
import CoreData
import CoreDataEditorKit

final class ObjectVC: UITableViewController {
  // MARK: - Properties
  let context: NSManagedObjectContext
  let object: NSManagedObject
  var didSave: ((Void) -> (Void))?
  var didCancel: ((Void) -> (Void))?
  private let attributes: [NSAttributeDescription]
  private let relationships: [NSRelationshipDescription]
  // MARK: - Creating
  init(context: NSManagedObjectContext, object: NSManagedObject) {
    self.context = context
    self.object = object
    self.attributes = Array(object.entity.attributesByName.values).filter { $0.isSupported }
    self.relationships = Array(object.entity.relationshipsByName.values)
    super.init(nibName: nil, bundle: nil)
    configureNavigationItem()
    AttributeClass.all.forEach { attributeClass in
      self.tableView.register(attributeClass.cellClass, forCellReuseIdentifier: attributeClass.cellIdentifier)
    }
    tableView.register(RelationshipCell.self, forCellReuseIdentifier: RelationshipCell.identifier)
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    let entityName = object.entity.name ?? ""
    title = "New \(entityName)"
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 100.0
    tableView.reloadData()
    updateUI()
  }
  // MARK: - Table view data source
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0: return "Attributes"
    case 1: return "Relationships"
    default: return nil
    }
  }
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0: return attributes.count
    case 1: return relationships.count
    default: return 0
    }
  }
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0: return attributeCell(forRowAt: indexPath)
    case 1: return relationshipCell(forRowAt: indexPath)
    default: fatalError()
    }
  }
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return false
  }
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath.section {
    case 0: return
    case 1:
      let alert = UIAlertController(title: "Create or Pick Object?", message: nil, preferredStyle: .actionSheet)
      alert.addAction(UIAlertAction(title: "Create new Object", style: .default, handler: { _ in
        let relationship = self.relationship(for: indexPath)
        let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.parent = self.context
        let destinationEntity = relationship.destinationEntity!
        let relatedObject = NSManagedObject(entity: destinationEntity, insertInto: childContext)
        let childObject = childContext.object(with: self.object.objectID)
        print("set \(relationship.name) of \(self.object.entity.name!) to object of type \(relatedObject.entity.name)")
        childObject.setValue(relatedObject, forKey: relationship.name)
        let objectVC = ObjectVC(context: childContext, object: relatedObject)
        objectVC.didSave = {
          do {
            try objectVC.object.managedObjectContext?.save()
          } catch {
            // TODO: Validation
            print(error)
          }
          let _ = self.navigationController?.popToViewController(self, animated: true)
          self.tableView.reloadData()
        
        }
        objectVC.didCancel = {
          let _ = self.navigationController?.popToViewController(self, animated: true)
        }
        self.navigationController?.pushViewController(objectVC, animated: true)
      }))
      alert.addAction(UIAlertAction(title: "Pick existing Object", style: .default, handler: { _ in
        let relationship = self.relationship(for: indexPath)
        let objectsVC = SingleObjectPickerVC(context: self.context, entity: relationship.destinationEntity!)
        objectsVC.didSelectObject = { selectedObjectID in
          print("selected")
          let selectedObject = self.context.object(with: selectedObjectID)
          self.object.setValue(selectedObject, forKey: relationship.name)
          let _ = self.navigationController?.popToViewController(self, animated: true)
        }
        self.navigationController?.pushViewController(objectsVC, animated: true)
      }))
      present(alert, animated: true, completion: nil)
    default: fatalError()
    }
  }
  
  // MARK: - Private Helper
  private func attribute(for indexPath: IndexPath) -> NSAttributeDescription {
    precondition(indexPath.section == 0)
    return attributes[indexPath.row]
  }
  private func relationship(for indexPath: IndexPath) -> NSRelationshipDescription {
    precondition(indexPath.section == 1)
    return relationships[indexPath.row]
  }
  private func configureNavigationItem() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(type(of:self).save(_:)))
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(type(of:self).cancel(_:)))
  }
  fileprivate func updateUI() {
    navigationItem.rightBarButtonItem?.isEnabled = object.isValid
  }
  
  private func attributeCell(forRowAt indexPath: IndexPath) -> AttributeCell {
    let attribute = self.attribute(for: indexPath)
    guard let cell = tableView.dequeueReusableCell(withIdentifier: attribute.cellIdentifier, for: indexPath) as? AttributeCell else {
      fatalError()
    }
    let pair = AttributeObjectPair(object: object, attribute: attribute)
    cell.configure(with: pair)
    cell.delegate = self
    return cell
  }
  private func relationshipCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
    let relationship = self.relationship(for: indexPath)
    guard let cell = tableView.dequeueReusableCell(withIdentifier: RelationshipCell.identifier, for: indexPath) as? RelationshipCell else {
      fatalError()
    }
    let pair = RelationshipObjectPair(object: object, relationship: relationship)
    cell.configure(with: pair)
    cell.accessoryType = .disclosureIndicator
    return cell
  }
  // MARK: - Actions
  func save(_ sender: Any?) {
    didSave?()
  }
  func cancel(_ sender: Any?) {
    didCancel?()
  }
}

extension ObjectVC: AttributeCellDelegate {
  func attributeCell(_ cell: AttributeCell, didChangeValue value: Any?) {
    guard let pair = cell.attributeObjectPair else {
      fatalError()
    }
    
    object.setValue(value, forKey: pair.attribute.name)
    guard let indexPath = tableView.indexPath(for: cell) else {
      fatalError()
    }
    tableView.reloadRows(at: [indexPath], with: .automatic)
    updateUI()
  }
  func presentingViewController(for attributeCell: AttributeCell) -> UIViewController { return self }
}
//extension ObjectVC: ObjectVCDelegate {
//  func objectVCDidSave(_ objectVC: ObjectVC) {
//    do {
//      try objectVC.object.managedObjectContext?.save()
//      try context.save()
//    } catch {
//      // TODO: Validation
//      print(error)
//    }
//    let _ = navigationController?.popToViewController(self, animated: true)
//    self.tableView.reloadData()
//  }
//  func objectVCDidCancel(_ objectVC: ObjectVC) {
//    let _ = navigationController?.popToViewController(self, animated: true)
//    self.tableView.reloadData()
//  }
//}

enum AttributeClass {
  case string, integer, bool, float, date
  static let all: [AttributeClass] = [.string, .integer, .bool, .float, .date]
  var cellClass: Swift.AnyClass {
    switch self {
    case .string: return StringCell.self
    case .bool: return BoolCell.self
    case .integer: return IntegerCell.self
    case .float: return FloatCell.self
    case .date: return DateCell.self
      
    }
  }
  var cellIdentifier: String {
    switch self {
    case .string: return StringCell.identifier
    case .bool: return BoolCell.identifier
    case .integer: return IntegerCell.identifier
    case .float: return FloatCell.identifier
    case .date: return DateCell.identifier
    }
  }
}

fileprivate extension NSAttributeDescription {
  var isSupported: Bool {
    let type = attributeType
    if type == .stringAttributeType { return true }
    if type == .booleanAttributeType { return true }
    if type == .dateAttributeType { return true }
    if type.hasIntegerCharacteristics { return true }
    if type.hasFloatingPointCharacteristics { return true }
    return false
  }
  var cellIdentifier: String {
    return attributeClass.cellIdentifier
  }
  var attributeClass: AttributeClass {
    if attributeType.hasIntegerCharacteristics {
      return .integer
    }
    if attributeType == .booleanAttributeType {
      return .bool
    }
    if attributeType == .stringAttributeType {
      return .string
    }
    if attributeType == .dateAttributeType {
      return .date
    }
    if attributeType.hasFloatingPointCharacteristics {
      return .float
    }
    return .string
  }
}
