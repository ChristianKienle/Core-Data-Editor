import UIKit
import CoreData
final class EntityCell: UITableViewCell {
  class var identifier: String { return "EntityCell" }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .value1, reuseIdentifier: type(of: self).identifier)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(with entity: NSEntityDescription, count: Int) {
    detailTextLabel?.text = String(count)
    textLabel?.text = entity.name
    imageView?.image = UIImage(named: "Entity", in: Bundle.init(for: type(of:self)), compatibleWith: traitCollection)
  }
}
final class EntitiesVC: UITableViewController {
  // MARK: - Properties
  private let entities: [NSEntityDescription]
  private let context: NSManagedObjectContext
  // MARK: - Creating
  init(context: NSManagedObjectContext) {
    self.context = context
    self.entities = context.persistentStoreCoordinator?.managedObjectModel.entities ?? []
    super.init(nibName: nil, bundle: nil)
    self.tableView.register(EntityCell.self, forCellReuseIdentifier: EntityCell.identifier)
    hidesBottomBarWhenPushed = true
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
    let cell = tableView.dequeueReusableCell(withIdentifier: EntityCell.identifier, for: indexPath) as! EntityCell
    let entity = self.entity(for: indexPath)
    let count = self.numberOfObjects(in: entity)
    cell.configure(with: entity, count: count)
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
  private func numberOfObjects(in entity: NSEntityDescription) -> Int {
    let request = NSFetchRequest<NSNumber>(entityName: entity.name!)
    request.entity = entity
    request.resultType = .countResultType
    guard let count = try? context.count(for: request) else {
      fatalError()
    }
    return count
  }
}
