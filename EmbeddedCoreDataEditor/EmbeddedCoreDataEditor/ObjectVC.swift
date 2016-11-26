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
    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AttributeCell")
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    title = object.objectID.humanReadableRepresentation(hideEntityName: false)
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
    let cell = tableView.dequeueReusableCell(withIdentifier: "AttributeCell", for: indexPath)
    let attribute = self.attribute(for: indexPath)
    cell.textLabel?.text = attribute.name
    return cell
  }
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  }
  // MARK: - Private Helper
  private func attribute(for indexPath: IndexPath) -> NSAttributeDescription {
    return attributes[indexPath.row]
  }

}

fileprivate extension NSAttributeDescription {
  var isSupported: Bool {
    let type = attributeType
    if type.hasFloatingPointCharacteristics || type.hasIntegerCharacteristics || type == .stringAttributeType {
      return true
    }
    return false
  }
}
