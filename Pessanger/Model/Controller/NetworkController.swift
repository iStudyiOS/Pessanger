//
//  UserController.swift
//  Pessanger
//
//  Created by bart Shin on 23/05/2021.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import UIKit

class NetworkController: DictionaryConverter {
	
	let friend: FriendController
	let chat: ChatController
	
	fileprivate let db: DatabaseController
	fileprivate let currentFirebaseUser: User
	private(set) var myInfo: UserInfo
	private(set) var profileImage: UIImage
	private(set) var images: [UIImage]
	
	func updateLocation(location: UserInfo.Location) {
		guard location != myInfo.lastLocation else {
			return
		}
		do {
			let location = try toDictionary(location)
			_ = db.updateValue(location, path: .location(userUid: myInfo.uid))
		}
		catch {
			print("Fail to convert location")
		}
	}
	
	private func loadProfileImage() {
		if let data = getDataInDevice(serverUrl: myInfo.profileImageUrl!),
			 let storedImage = UIImage(data: data){
			self.profileImage = storedImage
		}else {
			let promise = downloadData(url: myInfo.profileImageUrl!, storeInDevice: true)
			promise.observe { [weak weakSelf = self ] result in
				if case .success(let data) = result,
					 let image = UIImage(data: data) {
					weakSelf?.profileImage = image
				}else {
					weakSelf?.profileImage = UserInfo.defaultProfileImage
				}
			}
		}
	}
	
	fileprivate func observeMyInfo() {
		let observer: ([String: Any]?, Error?) -> Void = {[weak weakSelf = self] info, error in
			if let newInfo = info,
				 error == nil {
				weakSelf?.distributeNewInfo(newInfo: newInfo)
			}
		}
		db.attachListener(path: .userInfo(userUid: myInfo.uid), handler: observer)
	}
	
	fileprivate func distributeNewInfo(newInfo: [String: Any]) {
		FriendController.ListKey.allCases.forEach { key in
			if let newUids = newInfo[key.rawValue] as? [String]
				{
				friend.listenersForUserUid[key]?(newUids)
			}
		}
		if let chatRooms = newInfo["chatRooms"] as? [String] {
			chat.listenChatRooms(chatRooms)
		}
	}
	
	init(db: DatabaseController, user: User, info: UserInfo) {
		self.currentFirebaseUser = user
		self.db = db
		self.myInfo = info
		self.images = []
		let friendController = FriendController(db: db, userUid: info.uid)
		self.friend = friendController
		self.chat = ChatController(db: db, user: info, referFriends: {
			friendController.infoLists[.friends]!
		})
		if info.profileImageUrl != nil {
			self.profileImage = UIImage()
			loadProfileImage()
		}else {
			self.profileImage = UserInfo.defaultProfileImage
		}
		self.observeMyInfo()
	}
}

extension NetworkController: DataTransfer {
	
	func getUploadPath(folder: Folder, fileUid: String) -> String {
		"\(folder.rawValue)/\(fileUid)"
	}
	typealias UploadPath = String
	
	enum Folder: String {
		case profileImage
	}
}
