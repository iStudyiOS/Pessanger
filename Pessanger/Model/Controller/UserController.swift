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

class UserController {
  
  private let db: DatabaseController
  let friend: FriendController
  let chat: ChatController
  
  private let current: User
  private(set) var info: UserInfo
  private(set) var profileImage: UIImage
  private(set) var images: [UIImage]
  
  func updateLocation(location: UserInfo.Location) {
    guard location != info.lastLocation else {
      return
    }
    do {
      let location = try db.toDictionary(location)
      db.updateValue(location, path: .location(userUid: info.uid)).observe { result in
        print(result)
      }
    }
    catch {
      print("Fail to convert location")
    }
  }
  
  private func loadProfileImage() {
    if let data = getDataInDevice(serverUrl: info.profileImageUrl!),
       let storedImage = UIImage(data: data){
      self.profileImage = storedImage
    }else {
      let promise = downloadData(url: info.profileImageUrl!, storeInDevice: true)
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
  
  private func observeMyInfo() {
    let observer: ([String: Any]?, Error?) -> Void = {[weak weakSelf = self] info, error in
      if let newInfo = info,
         error == nil {
        weakSelf?.distributeNewInfo(newInfo: newInfo)
      }
    }
    db.addListener(path: .userInfo(userUid: info.uid), handler: observer)
  }
  
  private func distributeNewInfo(newInfo: [String: Any]) {
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
    self.current = user
    self.db = db
    self.info = info
    self.images = []
    self.friend = FriendController(db: db, userUid: info.uid)
    self.chat = ChatController(db: db, userUid: info.uid)
    if info.profileImageUrl != nil {
      self.profileImage = UIImage()
      loadProfileImage()
    }else {
      self.profileImage = UserInfo.defaultProfileImage
    }
    self.observeMyInfo()
  }
}

extension UserController: DataTransfer {
  
  func getUploadPath(folder: Folder, fileUid: String) -> String {
    "\(folder.rawValue)/\(fileUid)"
  }
  typealias UploadPath = String
  
  enum Folder: String {
    case profileImage
  }
  
}
