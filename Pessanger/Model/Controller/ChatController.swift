//
//  ChatController.swift
//  Pessanger
//
//  Created by bart Shin on 30/05/2021.
//

import Foundation

class ChatController: DictionaryConverter {
	
	typealias UserUid = String
	typealias ChatRoomUid = String
	
	@Published private(set) var chatRoomEntered: [ChatRoomUid: ChatRoomController]
	private(set) var listenChatRooms: ([ChatRoomUid]) -> Void = { _ in }
	fileprivate let db: DatabaseController
	fileprivate let user: UserInfo
	fileprivate var referFriendsInfo: () -> [UserInfo]
	
	func openChatRoom(with others: [UserInfo]) -> Promise<ChatRoomUid>{
		let parcicipants = others.compactMap({ $0.uid }) + [user.uid]
		let newChatRoom = ChatRoomInfo(master: user.uid, participants: parcicipants)
		
		return invite(users: parcicipants, to: newChatRoom.uid)
			.chained { [self] in
				createChat(for: newChatRoom)
			}
	}
	
	func invite(users: [UserUid], to chatRoomUid: ChatRoomUid) -> Promise<Void> {
		let promise = Promise<Void>()
		var invited = [UserUid: Bool?]()
		users.forEach{ user in
			invited[user] = nil
			db.addValues(values: [chatRoomUid], path:  .chatRoomsOfUser(userUid: user))
				.observe { result in
					if case .failure = result {
						invited[user] = false
					}else {
						invited[user] = true
					}
					if !invited.values.contains(where: { $0 == nil }) {
						if invited.values.contains(where: { success in !success! }) {
							promise.reject(with: "Fail to invite chat room member")
						}else {
							promise.resolve(with: ())
						}
					}
				}
		}
		return promise
	}
	
	fileprivate func createChat(for chatRoom: ChatRoomInfo) -> Promise<ChatRoomUid> {
		 db.writeTemplet(createNewChatRoomTemplet(for: chatRoom),
			path: .chatRoomInfo(chatRoomUid: chatRoom.uid))
			.transFormed(with: { () -> ChatController.ChatRoomUid in
				self.createChatRoomController(of: chatRoom.uid)
				return  chatRoom.uid
			})
	}
	
	fileprivate func initListener() {
		listenChatRooms = { [weak self] chatRoomUids in
			guard let strongSelf = self else {
				return
			}
			if chatRoomUids.isEmpty {
				strongSelf.chatRoomEntered = [:]
			}
			let enteredChatRoomUids = strongSelf.chatRoomEntered.keys
			let newChatRoomUids = chatRoomUids.filter { uid in
				!enteredChatRoomUids.contains(uid)
			}
			if !newChatRoomUids.isEmpty {
				newChatRoomUids.forEach {
					strongSelf.createChatRoomController(of: $0)
				}
			}
		}
	}
	
	fileprivate func createChatRoomController(of chatRoomUid: ChatRoomUid) {
		
		let newController = ChatRoomController(db: db, chatRoomUid: chatRoomUid, user: user)
		chatRoomEntered[chatRoomUid] = newController
	}
	
	fileprivate func createNewChatRoomTemplet(for chatRoomInfo: ChatRoomInfo) -> [String: Any] {
		let firstMessage: [String: Any]
		do {
			firstMessage = try toDictionary( MessageData(
																						senderUid: UserInfo.systemUid,
																						content: "새로운 채팅이 시작되었습니다",
																						date: Date(), imageUrl: nil))
		}
		catch {
			assertionFailure("Fail to create new chat room templete")
			return [:]
		}
		return [
			"status": ["lastBucket" : 1,
								 "lastMessage": 1,
								 "master": chatRoomInfo.master,
								 "participants": chatRoomInfo.participants
			],
			"1": ["1": firstMessage]
		]
	}
	
	init(db: DatabaseController, user: UserInfo, referFriends: @escaping () -> [UserInfo]) {
		self.db = db
		self.user = user
		referFriendsInfo = referFriends
		chatRoomEntered = [:]
		initListener()
	}
	
	class ChatRoomController: ObservableObject, DictionaryConverter {
		
		@Published private(set) var lastMessage: MessageData
		@Published var newMessage: MessageData?
		@Published private(set) var participants: [UserUid: UserInfo]
		
		let uid: ChatRoomUid
		fileprivate let db: DatabaseController
		private(set) var user: UserInfo
		private(set) var master : UserInfo?
		fileprivate var masterUid: UserUid?
		private(set) var attachedListeners = [Listener: UInt]()
		private(set) var lastBucket: Int?
		private(set) var lastMessageNum: Int? {
			didSet {
				fetchLastMessage()
			}
		}
		var excludeMe: [UserInfo] {
			Array(participants.values).filter {
				$0 != user
			}
		}
		
		func stareMessages(bucket: Int) {
			let listener = db.attachListener(
				path: .messages(chatRoomUid: uid, bucket: bucket),
				for: .childAdded) { [weak self] (result: [String: Any]?) in
				guard let strongSelf = self,
					let dict = result else {
					return
				}
				if let message: MessageData = strongSelf.toObject(dictionary: dict) {
					strongSelf.newMessage = message
				}
			}
			attachedListeners[.messages] = listener
		}
		
		func disregardMessages() {
			attachedListeners[.messages] = nil
		}
		
		func findUser(uid: UserUid) -> UserInfo {
			if uid == UserInfo.systemUid {
				return .system
			}
			return participants[uid] ?? UserInfo.missing
		}
		
		func getMessage(bucket: Int, messageNum: Int) -> Promise<MessageData> {
			db.retreive(path: .message(chatRoomUid: uid, bucket: bucket, messageNum: messageNum), as: [String: Any].self)
				.transFormed { [self] dict in
					if let message: MessageData = toObject(dictionary: dict) {
						return message
					}
					return MessageData.missing
				}
		}
		
		func getMessages(bucket: Int) -> Promise<[MessageData]> {
			db.retreive(path: .messages(chatRoomUid: uid, bucket: bucket),
									as: NSArray.self)
				.transFormed { [weak self] array -> [MessageData] in
					guard let strongSelf = self else {
						return []
					}
					return array.compactMap { element in
						if let dict = element as? [String: Any],
							 let message: MessageData = strongSelf.toObject(dictionary: dict){
							return message
						}else {
							return MessageData.missing
						}
					}.sorted { lhs, rhs in
						lhs.date < rhs.date
					}
				}
		}
		
		func sendMessage(_ content: String, url: URL? = nil) -> Promise<Void> {
			guard lastBucket != nil, lastMessageNum != nil else {
				return Promise<Void>.rejected(with: "Not connected with server")
			}
			let newMessage = MessageData(
				senderUid: user.uid,
				content: content,
				date: Date(), imageUrl: url)
			guard let templet = try? toDictionary(newMessage) else {
				return Promise<Void>.rejected(with: DatabaseController.DbError.encodingError)
			}
			return assureNewSpace()
				.chained {[self] newCount in
					db.writeTemplet(templet,
					 path: .message(chatRoomUid: uid,
													bucket: lastBucket!,
													messageNum: newCount))
				}
		}
		
		fileprivate func assureNewSpace() -> Promise<Int> {
			let promise = Promise<Int>()
			db.increaseCount(path: .chatRoomStatus(chatRoomUid: uid), for: ["lastMessage"])
				.observe { result in
					if case .success(let dict) = result,
						 let newCount = dict["lastMessage"] as? Int{
						promise.resolve(with: newCount)
					}else if case .failure(let error) = result {
						promise.reject(with: error)
					}
				}
			return promise
		}
		
		fileprivate func startListenStatus() {
			let listener = db.attachListener(path: .chatRoomStatus(chatRoomUid: uid)) {
				[weak weakSelf = self] (result: [String: Any]?) in
				if result != nil {
					weakSelf?.updateStatus(by: result!)
				}else {
					print("Fail to listen chat room status")
				}
			}
			attachedListeners[.status] = listener
		}
		
		fileprivate func getStatus() {
			_ = db.retreive(path: .chatRoomStatus(chatRoomUid: uid), as: [String: Any].self).transFormed { [weak weakSelf = self] dict in
				weakSelf?.updateStatus(by: dict)
			}
		}
		
		fileprivate func updateStatus(by dict: [String: Any]) {
			StatusKey.allCases.forEach { key in
					switch key {
					case .master:
						masterUid = dict[key.rawValue] as? UserUid
					case .lastMessage:
						lastMessageNum = dict[key.rawValue] as? Int
					case .lastBucket:
						if let bucket = dict[key.rawValue] as? Int {
							lastBucket = bucket
						}
					case .participants:
						guard let users = dict[key.rawValue] as? [UserUid],
									users != Array(participants.keys) else{
							return
						}
						if users.isEmpty {
							participants = [:]
							return
						}
						_ = db.retrieveObjects(uidList: users, path: .userInfo(userUid: users.first!), as: [UserInfo].self).transFormed { infos in
							users.forEach { uid in
								self.participants[uid] = infos.first(where: {
									$0.uid == uid
								})
						}
						}
					}
				}
		}
		
		fileprivate func fetchLastMessage() {
			guard let bucket = lastBucket,
						let meesageNum = lastMessageNum else {
				return
			}
			_ = getMessage(bucket: bucket, messageNum: meesageNum)
				.transFormed { [weak weakSelf = self] message in
					weakSelf?.lastMessage = message
				}
		}
		
		fileprivate init(db: DatabaseController, chatRoomUid: ChatRoomUid, user: UserInfo) {
			self.db = db
			self.user = user
			self.uid = chatRoomUid
			self.lastMessage = .missing
			self.participants = [:]
			getStatus()
			startListenStatus()
		}
		
		deinit {
			attachedListeners.values.forEach {
				db.detachListener($0)
			}
		}
	}
	enum StatusKey: String, CaseIterable {
		case master
		case lastBucket
		case participants
		case lastMessage
	}
	
	enum Listener {
		case status
		case messages
	}
}


