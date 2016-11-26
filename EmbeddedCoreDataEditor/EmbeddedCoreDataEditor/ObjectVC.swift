import Foundation
import UIKit
import CoreData
import CoreDataEditorKit

final class ObjectVC: UITableViewController {
  // MARK: - Properties
  private let object: NSManagedObject
  private let attributes: [NSAttributeDescription]
  // MARK: - Creating
  init(object: NSManagedObject) {
    self.object = object
    self.attributes = Array(object.entity.attributesByName.values).filter { $0.isSupported }
    super.init(nibName: nil, bundle: nil)
    self.tableView.register(StringCell.self, forCellReuseIdentifier: StringCell.identifier)
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    title = object.objectID.humanReadableRepresentation(hideEntityName: false)
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 100.0
    tableView.reloadData()
  }

  // MARK: - Table view data source
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return attributes.count
  }
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let attribute = self.attribute(for: indexPath)
    let cell = tableView.dequeueReusableCell(withIdentifier: attribute.cellIdentifier, for: indexPath)

    switch attribute.attributeClass {
    case .string:
      guard let cell = cell as? StringCell else {
        fatalError()
      }
      let pair = AttributeObjectPair(object: object, attribute: attribute)
      cell.configure(with: pair)
      cell.delegate = self
    }
    return cell
  }
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  }
  // MARK: - Private Helper
  private func attribute(for indexPath: IndexPath) -> NSAttributeDescription {
    return attributes[indexPath.row]
  }

}

extension ObjectVC: AttributeCellDelegate {
  func attributeCell(_ cell: AttributeCell, didChangeValue value: Any?) {
    
  }
}

enum AttributeClass {
  case string
}

fileprivate extension NSAttributeDescription {
  var isSupported: Bool {
    let type = attributeType
    if type == .stringAttributeType { return true }
//    if type.hasFloatingPointCharacteristics || type.hasIntegerCharacteristics || type == .stringAttributeType {
//      return true
//    }
    return false
  }
  var cellIdentifier: String {
    return StringCell.identifier
  }
  var attributeClass: AttributeClass {
    return .string
  }
}
