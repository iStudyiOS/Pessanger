//
//  LocationSearchTable.swift
//  Pessanger
//
//  Created by KEEN on 2021/05/27.
//

// TODO: HomeVC에서와 동일한 코드. 나중에 리팩토링

import UIKit
import MapKit
import Combine

class LocationSearchTable: UITableViewController {
  var handleMapSearchDelegate: HandleMapSearch? = nil
  

  var matchingItems: [MKMapItem] = []
  var mapView: MKMapView? = nil
	
	// Search User
	var user: NetworkController!
	var observeFriendCancellable: AnyCancellable?
	private var searchUserRequest: Promise<[UserInfo]>? {
		didSet {
			oldValue?.reject(with: "Not required")
			_ = searchUserRequest?.transFormed(with: {  [weak self] users in
				if let strongSelf = self {
					strongSelf.searchedUsers = users.filter({
						$0 != strongSelf.user.myInfo
					})
				}
			})
		}
	}
	private var searchedUsers = [UserInfo]() {
		didSet {
			if searchCategory != .map {
				tableView.reloadData()
			}
		}
	}
	var searchCategory: Category = .map {
		willSet {
			searchUserRequest?.reject(with: "Not required")
		}
		didSet {
			tableView.reloadData()
		}
	}
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let viewController = LocationSearchTable()
    let nav = UINavigationController(rootViewController: viewController)
    self.navigationController?.present(nav, animated: true, completion: nil)
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(ResultTableViewCell.self, forCellReuseIdentifier: "resultCell")
		observeFriendCancellable = user.friend.objectWillChange.sink(receiveValue: { [weak weakSelf = self] in
			if weakSelf?.searchCategory != .map {
				weakSelf?.tableView.reloadData()
			}
		})
//    tableView.rowHeight = UITableView.automaticDimension
//    tableView.estimatedRowHeight = UITableView.automaticDimension
  }
  
  // MARK: Parsing Address
  func parseAddress(_ selectedItem:MKPlacemark) -> String {
    // 주소 띄어쓰기 관련 설정
    // 도시 이름 띄어쓰기
    let firstSpace = (selectedItem.locality != nil && selectedItem.administrativeArea != nil) ? " " : ""
    let secondSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
    // 번가,도시 사이 컴마 찍기
    let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
    
    let addressLine = String( // 시 구 동, 지번
      format:"%@%@%@%@%@%@%@",
      // 시
      selectedItem.administrativeArea ?? "",
      firstSpace,
      // 구
      selectedItem.locality ?? "",
      secondSpace,
      // 동
      selectedItem.thoroughfare ?? "",
      comma,
      // 지번
      selectedItem.subThoroughfare ?? ""
    )
    return addressLine
  }
	
	enum Category: CaseIterable {
		case map
		case friend
		case user
		
		var koreanString: String {
			switch self {
			case .map:
				return "지도 검색"
			case .user:
				return "유저 검색"
			case .friend:
				return "친구 검색"
			}
		}
	}
}

// MARK: UISearchResultsUpdating
extension LocationSearchTable: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    guard let mapView = mapView,
          let searchBarText = searchController.searchBar.text else { return }
		switch searchCategory {
		case .map:
			let request = MKLocalSearch.Request()
			request.naturalLanguageQuery = searchBarText
			request.region = mapView.region
			let search = MKLocalSearch(request: request)
			search.start { response, _ in
				guard let response = response else {
					return
				}
				self.matchingItems = response.mapItems
				self.tableView.reloadData()
			}
		case .user:
			// Search by return key
			break
		case .friend:
			searchedUsers = user.friend.infoLists[.friends]!.filter({ $0.nickname.contains(searchBarText)
			})
		}
	}
}

// MARK: TableViewDelegate
extension LocationSearchTable {
  override func tableView(
    _ tableView: UITableView,
   numberOfRowsInSection section: Int) -> Int {
		if searchCategory == .map {
			return matchingItems.count
		}else {
			return searchedUsers.count
		}
  }

  override func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! ResultTableViewCell
		cell.textLabel?.textColor = .black
		cell.detailTextLabel?.textColor = .lightGray
		
		if searchCategory == .map {
			let selectedItem = matchingItems[indexPath.row].placemark
			cell.textLabel?.text = selectedItem.name
			cell.detailTextLabel?.text = parseAddress(selectedItem)
		}
		else {
			let userOfCell = searchedUsers[indexPath.row]
			var cellTitle = userOfCell.nickname
			
			if user.friend.infoLists[.friends]!.contains(userOfCell) {
				cellTitle += " (친구등록된 유저)"
			}else if user.friend.infoLists[.requestSent]!.contains(userOfCell) {
				cellTitle += " (내가 친구 요청한 유저)"
			}else if user.friend.infoLists[.requestReceived]!.contains(userOfCell) {
				cellTitle += " (나에게 친구 요청한 유저)"
			}
			cell.textLabel?.text = cellTitle
			cell.detailTextLabel?.text = "마지막 로그인 \(userOfCell.lastActivated)"
		}
    return cell
  }
}

// MARK: HandleMapSearchDelegate
extension LocationSearchTable {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		switch searchCategory {
		case .map:
			let selectedItem = matchingItems[indexPath.row].placemark
			handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
			dismiss(animated: true, completion: nil)
		case .friend:
			let selectedFriend = searchedUsers[indexPath.row]
			
			let alert = UIAlertController(title: selectedFriend.nickname, message: nil, preferredStyle: .actionSheet)
			alert.addAction(UIAlertAction(title: "채팅 하기", style: .default, handler: { [self] _ in
				_ = user.chat.openChatRoom(with: [selectedFriend]).transFormed { newChatRoom in
					guard let chatRoom = user.chat.chatRoomEntered[newChatRoom] else {
						assertionFailure("Chat controller is not created")
						return
					}
					let names = chatRoom.excludeMe.compactMap {
						$0.nickname
					}
					DispatchQueue.main.async { [self] in
						let messageVC = MessageViewController(user: user)
						let chatVC = ChatViewController(viewModel: ChatViewModel(opponentName: names.joined(separator: ", "), chatRoom: chatRoom))
						presentingViewController?.navigationController?.pushViewController(messageVC, animated: false)
						presentingViewController?.navigationController?.pushViewControllerFromLeft(chatVC)
					}
				}
			}))
			if let userLocation = searchedUsers[indexPath.row].lastLocation {
				alert.addAction(UIAlertAction(title: "위치 보기", style: .default, handler: { [self] _ in
					let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: userLocation.latitude, longitude: userLocation.longitude))
					handleMapSearchDelegate?.dropPinZoomIn(placemark: placemark)
					dismiss(animated: true)
				}))
				present(alert, animated: true)
			}
			
		case .user:
			let userSelected = searchedUsers[indexPath.row]
			guard !user.friend.infoLists[.friends]!.contains(userSelected),
						!user.friend.infoLists[.requestSent]!.contains(userSelected) else {
				return
			}
			let isReceieved = user.friend.infoLists[.requestReceived]!.contains(userSelected)
			
			let alert = UIAlertController(title: "친구 요청",
																		message: isReceieved ? "친구 요청 수락하기" : "친구 요청 보내기", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { [self] _ in
				if isReceieved {
					_ = user.friend.addToFriend(userSelected)
				}else {
					_ = user.friend.sendRequest(to: userSelected)
				}
			}))
			alert.addAction(UIAlertAction(title: "취소", style: .cancel))
			self.present(alert, animated: true)
		}
	}
}

extension LocationSearchTable: UISearchBarDelegate {
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		guard let searchText = searchBar.text,
					!searchText.isEmpty else {
			return
		}
		if searchCategory == .user {
			searchUserRequest = user.friend.searchUser(nickname: searchText)
		}
	}
}
