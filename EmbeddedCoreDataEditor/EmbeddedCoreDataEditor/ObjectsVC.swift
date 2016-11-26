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
    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ObjectCell")
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    title = entity.name
    let request = NSFetchRequest<NSManagedObjectID>(entityName: entity.name!)
    request.resultType = .managedObjectIDResultType
    request.entity = entity
    guard let fetchedIDs = try? context.fetch(request) else {
      return
    }
    objectIDs = fetchedIDs
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
    let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectCell", for: indexPath)
    let objectID = self.objectID(for: indexPath)
    cell.textLabel?.text = objectID.humanReadableRepresentation(hideEntityName: true)
    return cell
  }
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
  }
  // MARK: - Private Helper
  private func objectID(for indexPath: IndexPath) -> NSManagedObjectID {
    return objectIDs[indexPath.row]
  }
}
