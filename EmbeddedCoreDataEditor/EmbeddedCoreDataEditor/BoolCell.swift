import UIKit

final class BoolCell: AttributeCell {
  // MARK: - Properties
  let valueSwitch = UISwitch()
  // MARK: - Creating
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: type(of: self).identifier)
    valueSwitch.translatesAutoresizingMaskIntoConstraints = false
    valueSwitch.isOn = false
    valueSwitch.addTarget(self, action: #selector(BoolCell.takeBool), for: .valueChanged)
    stackView.addArrangedSubview(valueSwitch)
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  // MARK: - AttributeCell
  override class var identifier: String {
    return "BoolCell"
  }
  override func configure(with attributeObjectPair: AttributeObjectPair) {
    super.configure(with: attributeObjectPair)
    guard let boolValue: Bool = attributeObjectPair.value() else {
      valueSwitch.isOn = false
      return
    }
    valueSwitch.isOn = boolValue
  }
}

extension BoolCell {
  func takeBool() {
    delegate?.attributeCell(self, didChangeValue: valueSwitch.isOn)
  }
}
