import UIKit

final class DatePickerVC: UIViewController {
  // MARK: - Properties
  var date: Date {
    return datePicker.date
  }
  private let datePicker = UIDatePicker()
  // MARK: - Creating
  init() {
    super.init(nibName: nil, bundle: nil)
    configure()
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  // MARK: - Configure
  private func configure() {
    view.backgroundColor = .white
    edgesForExtendedLayout = UIRectEdge()
    datePicker.datePickerMode = .dateAndTime
    datePicker.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(datePicker)
    let margins = view.layoutMarginsGuide
    datePicker.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
    datePicker.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
    datePicker.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
    datePicker.widthAnchor.constraint(equalTo: margins.widthAnchor).isActive = true
    datePicker.heightAnchor.constraint(equalToConstant: 200.0).isActive = true
  }
  func configure(with date: Date?) {
    datePicker.date = date ?? Date()
  }
}
