//
//  ChatViewController.swift
//  Pessanger
//
//  Created by KEEN on 2021/05/10.
//

import UIKit
import SnapKit

final class ChatViewController: UIViewController {
  
  private enum Constants {
    static let bottomViewHeight: CGFloat = 30 + 10
    static let sendButtonImage: UIImage? = UIImage(named: "ic_send")
    static let sendButtonSize: CGFloat = 25
    static let maxInputLines: Int = 4
  }
  
  // MARK: - Properties
  private var isInputActive: Bool = false
  private var inputLineHeight: CGFloat = 0
  let viewModel: ChatViewModel // TODO: IOC(프로토콜로,,)
  
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
    textView.textContainer.lineFragmentPadding = 0
    textView.textContainerInset = .init(top: 5, left: 5, bottom: 5, right: 5)
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
  private let backButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(.rightArrow.withRenderingMode(.alwaysTemplate), for: .normal)
    button.tintColor = .label
    return button
  }()
  
  // MARK: - Initialize
  init(viewModel: ChatViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  required init?(coder: NSCoder) {
    fatalError("Only initializable by code.")
  }
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    bindViewModel()
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
  
  // MARK: - Bind ViewModel
  private func bindViewModel() {
    viewModel.opponentName.bindAndFire { [weak self] opponentName in
      self?.title = opponentName
    }
    
    viewModel.messages.bindAndFire { [weak self] messages in
      guard let self = self else { return }
      
      // 백그라운드 스레드(네트워크)에서 받은 메시지를 메인 스레드에서 처리
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        let numberOfVisibleCells = self.tableView.numberOfRows(inSection: 0)
        let diff = messages.count - numberOfVisibleCells
        let lastIndexPath = IndexPath(row: messages.count - 1, section: 0)
        
        if diff > 1 {
          self.tableView.reloadData()
          self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
        } else if diff == 1 {
          UIView.performWithoutAnimation { [weak self] in
            self?.tableView.insertRows(at: [lastIndexPath], with: .none)
          }
          self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
        }
      }
    }
  }
  
  // MARK: - Setup
  private func setUp() {
    setupNavigation()
    setUpUI()
    setUpTableView()
    setUpListeners()
    setUpInputTextView()
  }
  
  private func setupNavigation() {
    navigationItem.hidesBackButton = true
    navigationItem.setRightBarButton(UIBarButtonItem(customView: backButton), animated: false)
  }
  
  private func setUpUI() {
    self.view.backgroundColor = .systemBackground
    
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: generateDummyButton)
    
    inputLineHeight = inputTextView.sizeThatFits(inputTextView.frame.size).height - inputTextView.textContainerInset.top - inputTextView.textContainerInset.bottom
    
    bottomView.addSubview(inputTextView)
    bottomView.addSubview(sendMessageButton)
    sendMessageButton.snp.makeConstraints {
      $0.height.width.equalTo(inputLineHeight)
      $0.top.greaterThanOrEqualToSuperview().inset(5)
      $0.bottom.equalToSuperview().inset(5 + inputTextView.textContainerInset.bottom + inputTextView.contentInset.bottom)
      $0.trailing.equalToSuperview().inset(15)
    }
    inputTextView.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(10)
      $0.top.bottom.equalToSuperview().inset(5)
      $0.trailing.equalTo(sendMessageButton.snp.leading).offset(-15)
      let maxHeight = ceil(inputLineHeight) * CGFloat(Constants.maxInputLines) + inputTextView.textContainerInset.top + inputTextView.textContainerInset.bottom
      $0.height.lessThanOrEqualTo(maxHeight)
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
    backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    generateDummyButton.addTarget(self, action: #selector(generateDummy), for: .touchUpInside)
    sendMessageButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
  }
  
  private func setUpInputTextView() {
    inputTextView.delegate = self
  }
  
  // MARK: - Methods
  @objc fileprivate func backButtonTapped() {
    navigationController?.popViewControllerToLeft()
  }
  
  @objc private func sendMessage() {
    let content = inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !content.isEmpty else { return }
    
    let newMessage = Message(isMe: true, sender: "Pio", content: content, time: Date())
    viewModel.addMessage(newMessage)
    
    clearInput()
  }
  
  @objc private func generateDummy() { // For Tests
    viewModel.receiveMessage()
  }
  
}

// MARK: - TableView DataSource
extension ChatViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.viewModel.messages.value.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let message = viewModel.messages.value[indexPath.row]
    
    if message.isMe {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: SentMessageCell.reuseIdentifier, for: indexPath) as? SentMessageCell else { return UITableViewCell() }
      cell.configure(message)
      return cell
    } else {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: ReceivedMessageCell.reuseIdentifier, for: indexPath) as? ReceivedMessageCell else { return UITableViewCell() }
      cell.configure(message)
      return cell
    }
  }
  
}

// MARK: - TextView Delegate
extension ChatViewController: UITextViewDelegate {
  
  func textViewDidChange(_ textView: UITextView) {
    sendMessageButton.isEnabled = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    
    let currentContentSize = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
    let numberOfLines = Int((currentContentSize.height - textView.textContainerInset.top - textView.textContainerInset.bottom) / inputLineHeight)
    
    if numberOfLines > Constants.maxInputLines {
      textView.isScrollEnabled = true
    } else {
      textView.isScrollEnabled = false
    }
  }
  
  private func clearInput() {
    inputTextView.isScrollEnabled = false
    inputTextView.text.removeAll()
    inputTextView.insertText("")
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
