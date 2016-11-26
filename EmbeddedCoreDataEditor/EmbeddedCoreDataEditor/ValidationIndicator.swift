import UIKit

final class ValidationIndicator: UIButton {
  init() {
    super.init(frame: .zero)
    setTitle("✅", for: [.normal])
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  var indicatesValidState: Bool = true {
    didSet {
      if indicatesValidState {
        setTitle("✅", for: [.normal])
      } else {
        setTitle("⚠️", for: [.normal])
      }
    }
  }
}
