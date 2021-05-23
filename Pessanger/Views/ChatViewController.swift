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
  
  private enum Constants {
    static let bottomViewHeight: CGFloat = 30 + 10
    static let sendButtonImage: UIImage? = UIImage(named: "ic_send")
    static let sendButtonSize: CGFloat = 25
    static let maxInputLines: Int = 4
  }
  
  // MARK: - Properties
  private let tempOpponentName: String
  private var dummy: [Message] = [
    Message(isMe: false, sender: "Elon Musk", content: "Hello", time: nil),
    Message(isMe: false, sender: "Elon Musk", content: "Go DOGE", time: nil),
    Message(isMe: true, sender: "Pio", content: "Hi h i", time: nil),
  ]
  private var isInputActive: Bool = false
  
  // MARK: - Views
  private let tableView: UITableView = {
    let tableView = UITableView()
    tableView.backgroundColor = .systemBackground
    return tableView
  }()
  private let inputTextView: UITextView = {
    let textView = UITextView()
    textView.font = .preferredFont(forTextStyle: .body)
    textView.backgroundColor = .systemGray5
    textView.layer.cornerRadius = 10
    textView.textContainerInset = .init(top: 5, left: 10, bottom: 5, right: 10)
    textView.isScrollEnabled = false
    return textView
  }()
  private let sendMessageButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(Constants.sendButtonImage, for: .normal)
    button.imageView?.contentMode = .scaleAspectFit
    button.isEnabled = false
    return button
  }()
  private let generateDummyButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("🛠", for: .normal)
    return button
  }()
  private let bottomView: UIView = {
    let view = UIView()
    view.backgroundColor = .systemGray6
    return view
  }()
  private let containerView: UIStackView = {
    let view = UIStackView()
    view.axis = .vertical
    view.distribution = .fill
    view.alignment = .fill
    return view
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
  
  // MARK: - Setup
  private func setUp() {
    setupNavigation()
    setUpUI()
    setUpTableView()
    setUpListeners()
    setUpInputTextView()
  }
  
  fileprivate func setupNavigation() {
    navigationController?.navigationBar.tintColor = .black
    navigationItem.hidesBackButton = true
    navigationItem.setRightBarButton(backBarButton, animated: false)
  }
  
  private func setUpUI() {
    self.title = tempOpponentName
    self.view.backgroundColor = .systemBackground
    
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: generateDummyButton)
    
    bottomView.addSubview(inputTextView)
    bottomView.addSubview(sendMessageButton)
    sendMessageButton.snp.makeConstraints {
      $0.height.width.equalTo(inputTextView.font!.lineHeight)
      $0.top.greaterThanOrEqualToSuperview().inset(5)
      $0.bottom.equalToSuperview().inset(5 + inputTextView.textContainerInset.bottom + inputTextView.contentInset.bottom)
      $0.trailing.equalToSuperview().inset(15)
    }
    inputTextView.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(10)
      $0.top.bottom.equalToSuperview().inset(5)
      $0.trailing.equalTo(sendMessageButton.snp.leading).offset(-15)
      $0.height.lessThanOrEqualTo(inputTextView.font!.lineHeight * CGFloat(Constants.maxInputLines) + inputTextView.textContainerInset.top + inputTextView.textContainerInset.bottom)
    }
    
    containerView.addArrangedSubview(tableView)
    containerView.addArrangedSubview(bottomView)
    
    self.view.addSubview(containerView)
    containerView.snp.makeConstraints {
      $0.edges.equalTo(self.view.safeAreaLayoutGuide)
    }
  }
  
  private func setUpTableView() {
    tableView.register(ReceivedMessageCell.self, forCellReuseIdentifier: ReceivedMessageCell.reuseIdentifier)
    tableView.register(SentMessageCell.self, forCellReuseIdentifier: SentMessageCell.reuseIdentifier)
    tableView.dataSource = self
    tableView.separatorStyle = .none
  }
  
  private func setUpListeners() {
    let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing))
    self.view.addGestureRecognizer(tap)
    generateDummyButton.addTarget(self, action: #selector(generateDummy), for: .touchUpInside)
    sendMessageButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
  }
  
  private func setUpInputTextView() {
    inputTextView.delegate = self
  }
  
  // MARK: - Methods
  @objc fileprivate func popToLeftBarButtonItemTapped() {
    navigationController?.popViewControllerToLeft()
  }
  
  @objc private func generateDummy() {
    var randomContent = (1...Int.random(in: 1...3)).map { _ in
      String(repeating: "\(Int.random(in: 0...9))", count: Int.random(in: 1...10)) + "\n"
    }.reduce("", +)
    randomContent.removeLast() // 마지막 \n 제거
    let randomMessage = Message(isMe: false, sender: tempOpponentName, content: randomContent, time: nil)
    addMessage(randomMessage)
  }
  
  @objc private func sendMessage() {
    let content = inputTextView.text ?? ""
    let randomMessage = Message(isMe: true, sender: "Pio", content: content, time: nil)
    addMessage(randomMessage)
    inputTextView.text.removeAll()
    sendMessageButton.isEnabled = false
  }
  
  private func addMessage(_ message: Message) {
    dummy.append(message)
    let lastIndexPath = IndexPath(row: dummy.count-1, section: 0)
    
    UIView.performWithoutAnimation {
      tableView.insertRows(at: [lastIndexPath], with: .none)
    }
    tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
  }
  
}

// MARK: - TableView DataSource

extension ChatViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.dummy.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let message = dummy[indexPath.row]
    
    if message.isMe {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: SentMessageCell.reuseIdentifier, for: indexPath) as? SentMessageCell else { return UITableViewCell() }
      cell.configure(dummy[indexPath.row])
      return cell
    } else {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: ReceivedMessageCell.reuseIdentifier, for: indexPath) as? ReceivedMessageCell else { return UITableViewCell() }
      cell.configure(dummy[indexPath.row])
      return cell
    }
  }
  
}

// MARK: - TextView Delegate

extension ChatViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    sendMessageButton.isEnabled = !textView.text.isEmpty
    if !textView.isScrollEnabled {
      textView.sizeToFit()
    }
    if let lineHeight = textView.font?.lineHeight {
      let textHeight = textView.contentSize.height - (textView.contentInset.top + textView.contentInset.bottom) - (textView.textContainerInset.top + textView.textContainerInset.bottom)
      if Int(textHeight / lineHeight) >= Constants.maxInputLines {
        textView.isScrollEnabled = true
      } else {
        textView.isScrollEnabled = false
      }
    }
  }
}

// MARK: - Handle Keyboard Noti

extension ChatViewController {
  
  @objc private func keyboardWillShow(notification: Notification) {
    guard !isInputActive else { return }
    isInputActive = true
    
    guard let info = notification.userInfo,
          let size = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
          let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
          let curve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
      return
    }
    
    self.containerView.snp.updateConstraints {
      $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(size.cgRectValue.height)
    }
    self.tableView.contentOffset.y += size.cgRectValue.height
    
    self.view.layoutIfNeeded()
    UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions.init(rawValue: curve), animations: {
      self.view.layoutIfNeeded()
    })
  }
  
  @objc private func keyboardWillHide(notification: Notification) {
    isInputActive = false
    
    guard let info = notification.userInfo,
          let size = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
          let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
      return
    }
    
    containerView.snp.updateConstraints {
      $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(0)
    }
    self.tableView.contentOffset.y = max(0, self.tableView.contentOffset.y - size.cgRectValue.height)

    self.view.layoutIfNeeded()
    UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
      self.view.layoutIfNeeded()
    })
  }
  
}

final class ReceivedMessageCell: UITableViewCell {
  
  static var reuseIdentifier: String { return String(describing: Self.self) }
  
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
    contentLabel.numberOfLines = 0
    return contentLabel
  }()
  
  private override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.backgroundColor = .clear
    self.selectionStyle = .none
    
    self.layoutMargins = .zero
    self.separatorInset = .zero
    self.preservesSuperviewLayoutMargins = false
    
    let imageView = UIImageView(image: UIImage(named: "ic_profile"))
    let labelStackView: UIStackView = {
      let stackView = UIStackView()
      stackView.axis = .vertical
      stackView.distribution = .fill
      stackView.alignment = .leading
      stackView.spacing = 5
      return stackView
    }()
    labelStackView.addArrangedSubview(nameLabel)
    labelStackView.addArrangedSubview(contentLabel)
    
    let container: UIStackView = {
      let stackView = UIStackView()
      stackView.axis = .horizontal
      stackView.distribution = .fill
      stackView.alignment = .top
      stackView.spacing = 5
      return stackView
    }()
    container.addArrangedSubview(imageView)
    container.addArrangedSubview(labelStackView)
    imageView.snp.makeConstraints {
      $0.width.height.equalTo(30)
    }
    self.contentView.addSubview(container)
    container.snp.makeConstraints {
      $0.top.bottom.leading.equalTo(self.contentView.safeAreaLayoutGuide).inset(10)
      $0.trailing.equalTo(self.contentView.safeAreaLayoutGuide).inset(50)
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

final class SentMessageCell: UITableViewCell {
  
  static var reuseIdentifier: String { return String(describing: Self.self) }
  
  let container: UIStackView = {
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
    contentLabel.numberOfLines = 0
    return contentLabel
  }()
  
  private override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.backgroundColor = .clear
    self.selectionStyle = .none
    
    self.layoutMargins = .zero
    self.separatorInset = .zero
    self.preservesSuperviewLayoutMargins = false
    
    container.addArrangedSubview(contentLabel)
    
    self.contentView.addSubview(container)
    container.snp.makeConstraints {
      $0.top.bottom.trailing.equalTo(self.contentView.safeAreaLayoutGuide).inset(10)
      $0.leading.equalTo(self.contentView.safeAreaLayoutGuide).inset(50)
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
