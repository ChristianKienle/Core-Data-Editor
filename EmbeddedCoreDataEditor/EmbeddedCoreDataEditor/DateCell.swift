import UIKit

final class DateCell: AttributeCell {
  // MARK: - Properties
  let valueTextField = UITextField()
  private var datePicker: DatePickerVC?
  private var date: Date?
  // MARK: - Creating
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: type(of: self).identifier)
    valueTextField.translatesAutoresizingMaskIntoConstraints = false
    
    valueTextField.text = ""
    valueTextField.delegate = self
    stackView.addArrangedSubview(valueTextField)
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  // MARK: - AttributeCell
  override class var identifier: String {
    return "DateCell"
  }
  override func configure(with attributeObjectPair: AttributeObjectPair) {
    super.configure(with: attributeObjectPair)
    guard let dateValue: Date = attributeObjectPair.value() else {
      date = nil
      valueTextField.text = ""
      return
    }
    date = dateValue
    valueTextField.text = dateValue.description
  }
  
  func showDatePicker() {
    datePicker = DatePickerVC()
    datePicker?.configure(with: date)
    guard let presentingVC = delegate?.presentingViewController(for: self), let datePicker = datePicker else {
      return
    }
    let nc = UINavigationController(rootViewController: datePicker)
    datePicker.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(takeDateFromPresentedDatePicker(_:)))
    presentingVC.present(nc, animated: true, completion: nil)
  }
  
  func takeDateFromPresentedDatePicker(_ sender: Any?) {
    guard let presentingVC = delegate?.presentingViewController(for: self) else {
      return
    }
    presentingVC.dismiss(animated: true) { [weak self] in
      guard let strongSelf = self else {
        return
      }
      strongSelf.delegate?.attributeCell(strongSelf, didChangeValue: strongSelf.datePicker?.date)
      strongSelf.datePicker = nil
    }
  }
}

extension DateCell: UITextFieldDelegate {
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    showDatePicker()
    return true
  }
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
