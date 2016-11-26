import UIKit
import CoreData

final class EntitiesVC: UITableViewController {
  // MARK: - Properties
  private let entities: [NSEntityDescription]
  private let context: NSManagedObjectContext
  // MARK: - Creating
  init(context: NSManagedObjectContext) {
    self.context = context
    self.entities = context.persistentStoreCoordinator?.managedObjectModel.entities ?? []
    super.init(nibName: nil, bundle: nil)
    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "EntitiyCell")
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  // MARK: - ViewController Stuff
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
    title = "Entities"
  }
  // MARK: - Table view data source
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return entities.count
  }
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "EntitiyCell", for: indexPath)
    let entity = self.entity(for: indexPath)
    cell.textLabel?.text = entity.name
    cell.imageView?.image = UIImage(named: "Entity", in: Bundle.init(for: type(of:self)), compatibleWith: traitCollection)
    return cell
  }
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let entity = self.entity(for: indexPath)
    let objectsVC = ObjectsVC(context: context, entity: entity)
    navigationController?.pushViewController(objectsVC, animated: true)
  }
  // MARK: - Private Helper
  private func entity(for indexPath: IndexPath) -> NSEntityDescription {
    return entities[indexPath.row]
  }
}
