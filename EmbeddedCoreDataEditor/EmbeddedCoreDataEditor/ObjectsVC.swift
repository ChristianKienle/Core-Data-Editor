import Foundation
import UIKit
import CoreData
import CoreDataEditorKit

fileprivate extension UIStackView {
  func removeAllArrangedSubviews() {
    let views = arrangedSubviews
    views.forEach {
      $0.removeFromSuperview()
      //self.removeArrangedSubview($0)
    }
  }
}

// rawValue: segmentIndex
fileprivate enum SizeClass: Int {
  case compact = 0
  case regular = 1
  init?(segmentIndex: Int) {
    self.init(rawValue: segmentIndex)
  }
  var title: String {
    switch self {
    case .compact: return "Compact"
    case .regular: return "Regular"
    }
  }
  var segmentIndex: Int {
    return rawValue
  }
  func insertAsSegment(in segmentedControl: UISegmentedControl) {
    segmentedControl.insertSegment(withTitle: title, at: segmentIndex, animated: false)
  }
}


fileprivate final class SizePicker: UISegmentedControl {
  var sizeClassDidChange: ((SizeClass) -> (Void))?
  init() {
    super.init(frame: .zero)
    SizeClass.compact.insertAsSegment(in: self)
    SizeClass.regular.insertAsSegment(in: self)
    selectedSegmentIndex = SizeClass.regular.segmentIndex
    addTarget(self, action: #selector(takeSizeClassFromSender(_:)), for: .valueChanged)
    sizeToFit()
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  func configure(with sizeClass: SizeClass) {
    selectedSegmentIndex = sizeClass.segmentIndex
  }
  func takeSizeClassFromSender(_ sender: SizePicker?) {
    guard let sizeClass = SizeClass(segmentIndex: selectedSegmentIndex) else {
      fatalError()
    }
    sizeClassDidChange?(sizeClass)
  }
  var sizeClass: SizeClass {
    return SizeClass(segmentIndex: selectedSegmentIndex)!
  }
}

private final class ObjectCell: UITableViewCell {
  // MARK: - Globals
  class var identifier: String {
    return "ObjectCell"
  }
  // MARK: - Properties
  let stackView = UIStackView()
  // MARK: - Creating
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: type(of: self).identifier)
    configureCell()
  }
  init() {
    super.init(style: .default, reuseIdentifier: type(of: self).identifier)
    configureCell()
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  // MARK: - Configure
  private func configureCell() {
    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(stackView)
    let margins = contentView.layoutMarginsGuide
    
    stackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
    stackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
    stackView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
    stackView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
  }
  func configure(with object: NSManagedObject, sizeClass: SizeClass) {
    let entity = object.entity
    let attributes = Array(entity.attributesByName.values.sorted { (l, r) -> Bool in
      if l.attributeType == .stringAttributeType && r.attributeType != .stringAttributeType {
        return true
      }
      if l.attributeType != .stringAttributeType && r.attributeType == .stringAttributeType {
        return false
      }
      return l.name < r.name
    })
    let sizedAttributes: [NSAttributeDescription]
    switch sizeClass {
    case .regular:
      sizedAttributes = attributes
    case .compact:
        let reducedCount = min(max(1, Int(attributes.count / 5)), attributes.count)
        sizedAttributes = Array(attributes.prefix(reducedCount))
      }
    
    stackView.removeAllArrangedSubviews()
    stackView.spacing = 9.0
    sizedAttributes.forEach { attribute in
      let stack = UIStackView()
      stack.axis = .vertical
      let nameLabel = UILabel()
      nameLabel.text = attribute.name
      nameLabel.font = UIFont.systemFont(ofSize: 9.0)
      nameLabel.textColor = .gray
      let valueLabel = UILabel()
      valueLabel.text = object.string(for: attribute.name) ?? "null"
      stack.addArrangedSubview(nameLabel)
      stack.addArrangedSubview(valueLabel)
      self.stackView.addArrangedSubview(stack)
    }
  }
}

class ObjectsVC: UITableViewController {
  // MARK: - Properties
  fileprivate let context: NSManagedObjectContext
  private let entity: NSEntityDescription
  private let sizePicker = SizePicker()
  private var sizeClass: SizeClass {
    return sizePicker.sizeClass
  }
  fileprivate var objects = [NSManagedObject]()
  // MARK: - Creating
  init(context: NSManagedObjectContext, entity: NSEntityDescription) {
    self.context = context
    self.entity = entity
    super.init(nibName: nil, bundle: nil)
    setupNewObjectButton()
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.estimatedRowHeight = 150.0
    self.tableView.register(ObjectCell.self, forCellReuseIdentifier: ObjectCell.identifier)
    let sizePickerItem = UIBarButtonItem(customView: sizePicker)
    
    let leftSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let rightSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    toolbarItems = [leftSpace, sizePickerItem, rightSpace]
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    title = entity.name
    fetchObjects()
    tableView.reloadData()
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    sizePicker.sizeClassDidChange = { sizeClass in
      self.tableView.reloadRows(at: self.tableView.indexPathsForVisibleRows ?? [], with: .automatic)
    }
    navigationController?.setToolbarHidden(false, animated: true)
  }
  // MARK: - Table view data source
  override func numberOfSections(in tableView: UITableView) -> Int {
    return objects.count
  }
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return objects.isEmpty ? 0 : 1
  }
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ObjectCell.identifier, for: indexPath) as! ObjectCell
    let object = self.object(for: indexPath)
    cell.shouldIndentWhileEditing = true
    cell.selectionStyle = .default
    cell.indentationLevel = 1
    cell.configure(with: object, sizeClass: sizeClass)
    return cell
  }
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let object = self.objects[section]
    return object.objectID.humanReadableRepresentation(hideEntityName: false)
  }
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    return .none
  }
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let object = self.object(for: indexPath)
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
      self.fetchObjects()
      let _ = self.navigationController?.popToViewController(self, animated: true)
    }
    objectVC.didCancel = {
      let _ = self.navigationController?.popToViewController(self, animated: true)
    }
    navigationController?.pushViewController(objectVC, animated: true)
  }
  
  // MARK: - Private Helper
  fileprivate func fetchObjects() {
    let request = NSFetchRequest<NSManagedObject>(entityName: entity.name!)
    request.resultType = .managedObjectResultType
    request.entity = entity
    guard let objects = try? context.fetch(request) else {
      return
    }
    self.objects = objects
  }
  fileprivate func object(for indexPath: IndexPath) -> NSManagedObject {
    return objects[indexPath.section]
  }
  fileprivate func object(forSection section: Int) -> NSManagedObject {
    return objects[section]
  }
  fileprivate func indexPaths(forObjects objs: Set<NSManagedObject>) -> Set<IndexPath> {
    let sections = (objs.flatMap { objects.index(of: $0) })
    let indexPaths = Set(sections.map { IndexPath(row: 0, section: $0) })
    return indexPaths
  }
  fileprivate func indexPath(forObject object: NSManagedObject) -> IndexPath {
    let section = objects.index(of: object)!
    let indexPath = IndexPath(row: 0, section: section)
    return indexPath
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
        self.fetchObjects()
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
    if let preselectedObject = preselectedObject {
      let index = self.indexPath(forObject: preselectedObject)
      tableView.selectRow(at: index, animated: true, scrollPosition: .middle)
    }
  }
  // MARK: - UITableView
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard tableView.isEditing == false else {
      let object = self.object(for: indexPath)
      didSelectObject?(object.objectID)
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
    let indexPaths = self.indexPaths(forObjects: preselectedObjects)
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
    defer {
      updateAssignButton()
    }
    guard super.responds(to: #selector(ObjectsVC.tableView(_:didDeselectRowAt:))) else {
      return
    }
    super.tableView(tableView, didDeselectRowAt: indexPath)
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
      return self.object(for: indexPath).objectID
    }
    didSelectObjects?(Set(objectIDs))
  }
  func cancel(_ sender: Any?) {
    didCancel?()
  }
}
