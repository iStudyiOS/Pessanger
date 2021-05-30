//
//  MessageViewController.swift
//  Pessanger
//
//  Created by KEEN on 2021/05/10.
//

import UIKit
import SnapKit

final class MessageViewController: UIViewController {
  
  // MARK: - Properties
  let list: [ChatViewModel] = [
    ChatViewModel(opponentName: "Elon Musk"),
    ChatViewModel(opponentName: "Naver"),
    ChatViewModel(opponentName: "Kakao"),
    ChatViewModel(opponentName: "Mama"),
    ChatViewModel(opponentName: "Papa"),
  ]
  
  // MARK: - Views
  private let tableView: UITableView = {
    let tableView = UITableView()
    tableView.backgroundColor = .systemBackground
    return tableView
  }()
  private let searchController: UISearchController = .init()
  private let backButton: UIButton = {
    let button = UIButton()
    button.setImage(.rightArrow, for: .normal)
    return button
  }()
  
  // MARK: - Initialize
  init() {
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
  
  // MARK: - Setup
  private func setUp() {
    setupNavigation()
    setUpUI()
    setUpTableView()
    setUpListeners()
  }
  
  private func setupNavigation() {
    navigationItem.hidesBackButton = true
    navigationItem.setRightBarButton(UIBarButtonItem(customView: backButton), animated: false)
    navigationItem.searchController = searchController
  }
  
  private func setUpUI() {
    self.title = "채팅"
    self.view.backgroundColor = .systemBackground
    
    self.view.addSubview(tableView)
    tableView.snp.makeConstraints {
      $0.edges.equalTo(self.view.safeAreaLayoutGuide)
    }
  }
  
  private func setUpTableView() {
    tableView.register(MessageListCell.self, forCellReuseIdentifier: MessageListCell.reuseIdentifier)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.separatorStyle = .none
  }
  
  private func setUpListeners() {
    backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
  }
  
  @objc private func backButtonTapped() {
    self.navigationController?.popViewControllerToLeft()
  }
  
}

// MARK: - Implement TableView DataSource
extension MessageViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return list.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageListCell.reuseIdentifier, for: indexPath) as? MessageListCell else {
      return UITableViewCell()
    }
    let item = list[indexPath.row]
    cell.configure(name: item.opponentName.value, recentMessage: item.messages.value.first)
    return cell
  }

}

// MARK: - Implement TableView Delegate
extension MessageViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let chatViewModel = list[indexPath.row]
    let chatVC = ChatViewController(viewModel: chatViewModel)
    self.navigationController?.pushViewControllerFromLeft(chatVC)
  }
  
}
