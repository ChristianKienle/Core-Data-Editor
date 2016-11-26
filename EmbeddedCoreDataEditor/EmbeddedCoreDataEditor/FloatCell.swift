import UIKit

final class FloatCell: AttributeCell {
  // MARK: - Properties
  let valueTextField = UITextField()
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
    return "FloatCell"
  }
  override func configure(with attributeObjectPair: AttributeObjectPair) {
    super.configure(with: attributeObjectPair)
    guard let numberValue: Float = attributeObjectPair.value() else {
      valueTextField.text = ""
      return
    }
    valueTextField.text = String(numberValue)
  }

}

extension FloatCell: UITextFieldDelegate {
  func textFieldDidEndEditing(_ textField: UITextField) {
    let formatter = NumberFormatter()
    formatter.allowsFloats = true
    guard let floatValue = formatter.number(from: textField.text ?? "")?.floatValue else {
      delegate?.attributeCell(self, didChangeValue: nil)
      return
    }
    delegate?.attributeCell(self, didChangeValue: floatValue)
  }
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
