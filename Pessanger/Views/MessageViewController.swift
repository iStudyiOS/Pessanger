//
//  MessageViewController.swift
//  Pessanger
//
//  Created by KEEN on 2021/05/10.
//

import UIKit
import SnapKit
import Combine

final class MessageViewController: UIViewController {
  
	private let user: NetworkController
	private var observeChatRoomCancellable: AnyCancellable?
	
  // MARK: - Properties
	private var modelWithObservers: [ChatViewModel: AnyCancellable] = [:]
	private var list: [ChatViewModel] {
		Array(modelWithObservers.keys)
	}
	
  // MARK: - Views
  private let tableView: UITableView = {
    let tableView = UITableView()
    tableView.backgroundColor = .systemBackground
    return tableView
  }()
  private let searchController: UISearchController = .init()
  private let backButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(.rightArrow.withRenderingMode(.alwaysTemplate), for: .normal)
    button.tintColor = .label
    return button
  }()
  
  // MARK: - Initialize
	init(user: NetworkController) {
		self.user = user
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
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    navigationItem.hidesSearchBarWhenScrolling = true
  }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		observeChatRooms()
		tableView.reloadData()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		observeChatRoomCancellable = nil
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
    navigationItem.hidesSearchBarWhenScrolling = false
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
  
	fileprivate func observeChatRooms() {
		observeChatRoomCancellable = user.chat.$chatRoomEntered.sink { [weak self] chatRooms in
			guard let strongSelf = self else {
				return
			}
			let currentChatRooms = strongSelf.modelWithObservers.keys
			let newChatRooms = chatRooms.filter { dict in
				!currentChatRooms.contains(where: {
					$0.uid == dict.key
				})
			}.values.compactMap { chatRoom -> ChatViewModel in
				let othersName = chatRoom.excludeMe.compactMap {
					$0.nickname
				}
				 return ChatViewModel(opponentName: othersName.joined(separator: ", "), chatRoom: chatRoom)
			}
			
			let closedChatRooms = currentChatRooms.filter { chatRoom in
				!chatRooms.keys.contains(where: {
					$0 == chatRoom.uid
				})
			}
			closedChatRooms.forEach {
				strongSelf.modelWithObservers[$0] = nil
			}
			newChatRooms.forEach { item in
				strongSelf.modelWithObservers[item] = item.objectWillChange.sink {
					guard let index = strongSelf.list.firstIndex(of: item) else {
						return
					}
					DispatchQueue.main.async{
						strongSelf.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
					}
				}
			}
		}
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
		let unRead = item.unReadMessageCount > 0 ? "(\(item.unReadMessageCount))": ""
		cell.configure(name: "\(item.opponentName.value) \(unRead)", recentMessage: item.lastMessage)
    return cell
  }

}

// MARK: - Implement TableView Delegate
extension MessageViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    let chatViewModel = list[indexPath.row]
    let chatVC = ChatViewController(viewModel: chatViewModel)
    self.navigationController?.pushViewControllerFromLeft(chatVC)
  }
  
}
