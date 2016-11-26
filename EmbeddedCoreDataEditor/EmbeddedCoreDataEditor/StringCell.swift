import UIKit

final class StringCell: AttributeCell {
  // MARK: - Properties
  let valueTextField = UITextField()
  // MARK: - Creating
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: type(of: self).identifier)
    valueTextField.translatesAutoresizingMaskIntoConstraints = false
    valueTextField.text = ""
    valueTextField.delegate = self
    valueTextField.placeholder = "null"
    stackView.addArrangedSubview(valueTextField)
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  // MARK: - AttributeCell
  override class var identifier: String {
    return "StringCell"
  }
  override func configure(with attributeObjectPair: AttributeObjectPair) {
    super.configure(with: attributeObjectPair)
    valueTextField.text = attributeObjectPair.value()
  }
}

extension StringCell: UITextFieldDelegate {
  func textFieldDidEndEditing(_ textField: UITextField) {
    delegate?.attributeCell(self, didChangeValue: textField.text)
  }
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
