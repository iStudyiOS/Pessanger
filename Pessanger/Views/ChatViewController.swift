//
//  ChatViewController.swift
//  Pessanger
//
//  Created by KEEN on 2021/05/10.
//

import UIKit
import SnapKit

struct Message {
    var isMe: Bool
    var sender: String
    var content: String
    var time: Date?
}

final class ChatViewController: UIViewController {
  
  // MARK: - Properties
  private let tempOpponentName: String
  private var dummy: [Message] = [
    Message(isMe: false, sender: "Elon Musk", content: "Hello", time: nil),
    Message(isMe: false, sender: "Elon Musk", content: "Go DOGE", time: nil),
    Message(isMe: true, sender: "Pio", content: "Hi h i", time: nil),
  ]
  private var activeInputView: UIView?
  
  // MARK: - Views
  private let tableView: UITableView = {
    let tableView = UITableView()
    tableView.backgroundColor = .systemBackground
    return tableView
  }()
  private let inputTextView: UITextView = {
    let textField = UITextView()
    textField.backgroundColor = .systemGreen
    return textField
  }()
  private let generateDummyButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("🛠", for: .normal)
    return button
  }()
  lazy var backBarButton = UIBarButtonItem(title: "뒤로 >", style: .done, target: self, action: #selector(popToLeftBarButtonItemTapped))
  
  // MARK: - Initialize
  init(opponentName: String) { // TODO: DI
    self.tempOpponentName = opponentName
    super.init(nibName: nil, bundle: nil)
  }
  required init?(coder: NSCoder) {
    fatalError("Only initializable by code.")
  }
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing))
//    tap.cancelsTouchesInView = false
    self.view.addGestureRecognizer(tap)
    
    setUp()
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  private func setUp() {
    setupNavigation()
    setUpUI()
    
    tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reuseIdentifier)
    tableView.register(MessageCell2.self, forCellReuseIdentifier: MessageCell2.reuseIdentifier)
    tableView.dataSource = self
    tableView.separatorStyle = .none
    
    generateDummyButton.addTarget(self, action: #selector(generateDummy), for: .touchUpInside)
    
    
  }
  
  private func setUpUI() {
    self.title = tempOpponentName
    self.view.backgroundColor = .systemBackground
    
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: generateDummyButton)
    
    self.view.addSubview(tableView)
    self.view.addSubview(inputTextView)
    
    tableView.snp.makeConstraints {
      $0.top.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
      $0.bottom.equalTo(inputTextView.snp.top)
    }
    
    inputTextView.snp.makeConstraints {
      $0.top.equalTo(tableView.snp.bottom)
      $0.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
      $0.height.equalTo(44)
      $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(0)
    }
  }
  
  // MARK: Setup
  fileprivate func setupNavigation() {
    navigationController?.navigationBar.tintColor = .black
    navigationItem.hidesBackButton = true
    navigationItem.setRightBarButton(backBarButton, animated: false)
  }
  
  // MARK: Action
  @objc fileprivate func popToLeftBarButtonItemTapped() {
    navigationController?.popViewControllerToLeft()
  }

  @objc private func generateDummy() {
    let randomContent = (0..<Int.random(in: 1...3)).map { _ in
      String(repeating: "\(Int.random(in: 0...9))", count: Int.random(in: 1...10)) + "\n"
    }.reduce("", +)
    let randomIsMe = Bool.random()
    let randomMessage = Message(isMe: randomIsMe, sender: randomIsMe ? "Pio" : "Elon Musk", content: randomContent, time: nil)
    dummy.append(randomMessage)
    let lastIndexPath = IndexPath(row: dummy.count-1, section: 0)
    tableView.insertRows(at: [lastIndexPath], with: .none)
    tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
  }
  
  @objc private func keyboardWillShow(notification: Notification) {
    guard activeInputView == nil else { return }
    activeInputView = inputTextView
    
    guard let info = notification.userInfo,
          let size = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
          let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
          let curve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
      return
    }
    
    self.inputTextView.snp.updateConstraints {
      $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(size.cgRectValue.height)
    }
    self.tableView.contentOffset.y += size.cgRectValue.height
    
    self.view.layoutIfNeeded()
    UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions.init(rawValue: curve), animations: {
      self.view.layoutIfNeeded()
    })
  }
  
  @objc private func keyboardWillHide(notification: Notification) {
    activeInputView = nil
    
    guard let info = notification.userInfo,
          let size = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
          let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
          let curve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
      return
    }
    
    inputTextView.snp.updateConstraints {
      $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(0)
    }
    self.tableView.contentOffset.y = max(0, self.tableView.contentOffset.y - size.cgRectValue.height)

    self.view.layoutIfNeeded()
    UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
      self.view.layoutIfNeeded()
    })
  }
  
}

extension ChatViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.dummy.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let message = dummy[indexPath.row]
    
    if message.isMe {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell2.reuseIdentifier, for: indexPath) as? MessageCell2 else { return UITableViewCell() }
      cell.configure(dummy[indexPath.row])
      return cell
    } else {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.reuseIdentifier, for: indexPath) as? MessageCell else { return UITableViewCell() }
      cell.configure(dummy[indexPath.row])
      return cell
    }
  }
  
}

final class MessageCell: UITableViewCell {
  
  static var reuseIdentifier: String { return String(describing: Self.self) }
  
  let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.distribution = .fill
    stackView.alignment = .leading
    stackView.spacing = 5
    return stackView
  }()
  
  let nameLabel: UILabel = {
    let nameLabel = PaddingLabel()
    nameLabel.text = "??"
    nameLabel.layer.cornerRadius = 10
    nameLabel.layer.masksToBounds = true
    return nameLabel
  }()
  
  let contentLabel: UILabel = {
    let contentLabel = PaddingLabel()
    contentLabel.backgroundColor = .systemGray5
    contentLabel.layer.cornerRadius = 10
    contentLabel.layer.masksToBounds = true
    return contentLabel
  }()
  
  private override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.backgroundColor = .clear
    self.selectionStyle = .none
    
    self.layoutMargins = .zero
    self.separatorInset = .zero
    self.preservesSuperviewLayoutMargins = false
    
    stackView.addArrangedSubview(nameLabel)
    stackView.addArrangedSubview(contentLabel)
    
    self.contentView.addSubview(stackView)
    stackView.snp.makeConstraints {
      $0.edges.equalTo(self.contentView.safeAreaLayoutGuide).inset(10)
    }
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(_ message: Message) {
    nameLabel.text = message.sender
    contentLabel.text = message.content
  }
  
}

final class MessageCell2: UITableViewCell {
  
  static var reuseIdentifier: String { return String(describing: Self.self) }
  
  let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.distribution = .fill
    stackView.alignment = .trailing
    stackView.spacing = 5
    return stackView
  }()
  
  let contentLabel: UILabel = {
    let contentLabel = PaddingLabel()
    contentLabel.backgroundColor = .systemBlue
    contentLabel.textColor = .systemBackground
    contentLabel.layer.cornerRadius = 10
    contentLabel.layer.masksToBounds = true
    return contentLabel
  }()
  
  private override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.backgroundColor = .clear
    self.selectionStyle = .none
    
    self.layoutMargins = .zero
    self.separatorInset = .zero
    self.preservesSuperviewLayoutMargins = false
    
    stackView.addArrangedSubview(contentLabel)
    
    self.contentView.addSubview(stackView)
    stackView.snp.makeConstraints {
      $0.edges.equalTo(self.contentView.safeAreaLayoutGuide).inset(10)
    }
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(_ message: Message) {
    contentLabel.text = message.content
  }
  
}

final class PaddingLabel: UILabel {

    var topInset: CGFloat = 5.0
    var bottomInset: CGFloat = 5.0
    var leftInset: CGFloat = 5.0
    var rightInset: CGFloat = 5.0
    
    override func drawText(in rect: CGRect) {
      let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
      super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
      let size = super.intrinsicContentSize
      return CGSize(width: size.width + leftInset + rightInset, height: size.height + topInset + bottomInset)
    }
  
}
