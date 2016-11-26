import UIKit

final class StringCell: AttributeCell {
  let valueTextField = UITextField()
  override class var identifier: String {
    return "StringCell"
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: type(of: self).identifier)
    valueTextField.translatesAutoresizingMaskIntoConstraints = false
    valueTextField.borderStyle = .line
    valueTextField.text = "Hello world"
    valueTextField.delegate = self
    stackView.addArrangedSubview(valueTextField)
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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
