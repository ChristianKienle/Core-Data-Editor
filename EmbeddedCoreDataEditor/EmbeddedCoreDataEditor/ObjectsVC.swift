import Foundation
import UIKit
import CoreData
import CoreDataEditorKit

class ObjectsVC: UITableViewController {
  // MARK: - Properties
  fileprivate let context: NSManagedObjectContext
  private let entity: NSEntityDescription
  fileprivate var objectIDs = [NSManagedObjectID]()
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
    cell.shouldIndentWhileEditing = true
    cell.selectionStyle = .default
    cell.indentationLevel = 1
    cell.textLabel?.text = objectID.humanReadableRepresentation(hideEntityName: true)
    return cell
  }
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    return .none
  }
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let objectID = self.objectID(for: indexPath)
    guard let object = try? context.existingObject(with: objectID) else {
      return
    }
    // Push an ObjectVC in order to edit an existing Object
    let objectVC = ObjectVC(context: context, object: object)
    objectVC.didSave = {
      let object = objectVC.object
      do {
        try object.managedObjectContext?.save()
        try self.context.save()
      } catch {
        // TODO: Validation
        print(error)
      }
      self.fetchObjectIDs()
      let _ = self.navigationController?.popToViewController(self, animated: true)
    }
    objectVC.didCancel = {
      let _ = self.navigationController?.popToViewController(self, animated: true)
    }
    navigationController?.pushViewController(objectVC, animated: true)
  }
  
  // MARK: - Private Helper
  fileprivate func fetchObjectIDs() {
    let request = NSFetchRequest<NSManagedObjectID>(entityName: entity.name!)
    request.resultType = .managedObjectIDResultType
    request.entity = entity
    guard let fetchedIDs = try? context.fetch(request) else {
      return
    }
    objectIDs = fetchedIDs
  }
  fileprivate func objectID(for indexPath: IndexPath) -> NSManagedObjectID {
    return objectIDs[indexPath.row]
  }
  private func setupNewObjectButton() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addObject(_:)))
  }
  func addObject(_ sender: Any?) {
    let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    childContext.parent = context
    let object = NSManagedObject(entity: entity, insertInto: childContext)
    // Present an ObjectVC modally
    let objectVC = ObjectVC(context: childContext, object: object)
    objectVC.didSave = {
      let object = objectVC.object
      do {
        try object.managedObjectContext?.save()
        try self.context.save()
      } catch {
        // TODO: Validation
        print(error)
      }
      self.dismiss(animated: true) {
        self.fetchObjectIDs()
      }
    }
    objectVC.didCancel = {
      self.dismiss(animated: true)
    }
    let nc = UINavigationController(rootViewController: objectVC)
    present(nc, animated: true, completion: nil)
  }
}

final class SingleObjectPickerVC: ObjectsVC {
  // MARK: - Properties
  var didSelectObject: ((NSManagedObjectID) -> (Void))?
  private let preselectedObject: NSManagedObject?
  // MARK: - Creating
  init(context: NSManagedObjectContext, entity: NSEntityDescription, preselectedObject: NSManagedObject?) {
    self.preselectedObject = preselectedObject
    super.init(context: context, entity: entity)
    tableView.allowsSelectionDuringEditing = true
    setEditing(true, animated: false)
    tableView.setEditing(true, animated: false)
    isEditing = true
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if let preselectedObject = preselectedObject, let index = objectIDs.index(of: preselectedObject.objectID) {
      tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .middle)
    }
  }
  // MARK: - UITableView
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard tableView.isEditing == false else {
      let objectID = self.objectID(for: indexPath)
      didSelectObject?(objectID)
      return
    }
    super.tableView(tableView, didSelectRowAt: indexPath)
  }
}

// [Assign(n)] ---- TITLE ---- [Cancel]
final class MultipleObjectsPickerVC: ObjectsVC {
  // MARK: - Properties
  var didSelectObjects: ((Set<NSManagedObjectID>) -> (Void))?
  var didCancel: ((Void) -> (Void))?
  private let preselectedObjects: Set<NSManagedObject>
  // MARK: - Creating
  init(context: NSManagedObjectContext, entity: NSEntityDescription, preselectedObjects: Set<NSManagedObject>) {
    self.preselectedObjects = preselectedObjects
    super.init(context: context, entity: entity)
    tableView.allowsSelectionDuringEditing = true
    tableView.allowsMultipleSelectionDuringEditing = true
    setEditing(true, animated: false)
    tableView.setEditing(true, animated: false)
    isEditing = true
    setupButtons()
    updateAssignButton()
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let rows = (preselectedObjects.flatMap { objectIDs.index(of: $0.objectID) })
    let indexPaths = rows.map { IndexPath(row: $0, section: 0) }
    indexPaths.forEach {
      self.tableView.selectRow(at: $0, animated: false, scrollPosition: .middle)
    }
    updateAssignButton()
  }
  // MARK: - UITableView
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard tableView.isEditing == false else {
      updateAssignButton()
      return
    }
    super.tableView(tableView, didSelectRowAt: indexPath)
  }
  override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    super.tableView(tableView, didDeselectRowAt: indexPath)
    updateAssignButton()
  }
  // MARK: - Setup Buttons
  private func setupButtons() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Assign", style: .done, target: self, action: #selector(type(of: self).pickSelectedObjects(_:)))
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(type(of: self).cancel(_:)))
  }
  private func updateAssignButton() {
    let count = tableView.indexPathsForSelectedRows?.count ?? 0
    navigationItem.leftBarButtonItem?.title = "Assign (\(count))"
  }
  func pickSelectedObjects(_ sender: Any?) {
    let objectIDs = (tableView.indexPathsForSelectedRows ?? []).map { indexPath in
      return self.objectID(for: indexPath)
    }
    didSelectObjects?(Set(objectIDs))
  }
  func cancel(_ sender: Any?) {
    didCancel?()
  }
}
