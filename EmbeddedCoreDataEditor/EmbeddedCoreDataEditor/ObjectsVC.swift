import Foundation
import UIKit
import CoreData
import CoreDataEditorKit

final class ObjectsVC: UITableViewController {
  // MARK: - Properties
  private let context: NSManagedObjectContext
  private let entity: NSEntityDescription
  private var objectIDs = [NSManagedObjectID]()
  // MARK: - Creating
  init(context: NSManagedObjectContext, entity: NSEntityDescription) {
    self.context = context
    self.entity = entity
    super.init(nibName: nil, bundle: nil)
    setupNewObjectButton()
    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ObjectIDCell")
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    title = entity.name
    fetchObjectIDs()
    tableView.reloadData()
  }
  // MARK: - Table view data source
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return objectIDs.count
  }
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectIDCell", for: indexPath)
    let objectID = self.objectID(for: indexPath)
    cell.textLabel?.text = objectID.humanReadableRepresentation(hideEntityName: true)
    return cell
  }
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let objectID = self.objectID(for: indexPath)
    guard let object = try? context.existingObject(with: objectID) else {
      return
    }
    let objectVC = ObjectVC(context: context, object: object)
    navigationController?.pushViewController(objectVC, animated: true)
  }
  // MARK: - Private Helper
  private func fetchObjectIDs() {
    let request = NSFetchRequest<NSManagedObjectID>(entityName: entity.name!)
    request.resultType = .managedObjectIDResultType
    request.entity = entity
    guard let fetchedIDs = try? context.fetch(request) else {
      return
    }
    objectIDs = fetchedIDs
  }
  private func objectID(for indexPath: IndexPath) -> NSManagedObjectID {
    return objectIDs[indexPath.row]
  }
  private func setupNewObjectButton() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addObject(_:)))
  }
  func addObject(_ sender: Any?) {
    let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    childContext.parent = context
    let object = NSManagedObject(entity: entity, insertInto: childContext)
    let objectVC = ObjectVC(context: childContext, object: object)
    objectVC.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveObject(_:)))
    let nc = UINavigationController(rootViewController: objectVC)
    present(nc, animated: true, completion: nil)
  }
  func saveObject(_ sender: Any?) {
    guard let objectNC = presentedViewController as? UINavigationController else {
      return
    }
    guard let objectVC = objectNC.topViewController as? ObjectVC else {
      return
    }
    let object = objectVC.object
    do {
      try object.managedObjectContext?.save()
    } catch {
      print(error)
    }
    dismiss(animated: true) {
      self.fetchObjectIDs()
    }
  }
}
