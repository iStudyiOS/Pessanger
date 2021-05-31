//
//  ChatController.swift
//  Pessanger
//
//  Created by bart Shin on 30/05/2021.
//

import Foundation

class ChatController {
  
  typealias UserUid = String
  typealias ChatRoomUid = String
  
  private let db: DatabaseController
  private let userUid: UserUid
  private(set) var chatRoomEntered: [ChatRoomInfo]
  private(set) var listenChatRooms: ([ChatRoomUid]) -> Void = { _ in }
  
  func openChatRoom(with users: [UserInfo]) -> Promise<Void>{
    let newChatRoom = ChatRoomInfo(master: userUid, participants: users.compactMap({ $0.uid }))
    return db.writeObject(newChatRoom, path: .chatRoomInfo(chatRoomId: newChatRoom.uid))
  }
  
  private func initListener() {
    listenChatRooms = { [weak self] chatRoomUids in
      guard !chatRoomUids.isEmpty,
            let strongSelf = self else {
        return
      }
      let chatRoomPromise = strongSelf.db.retrieveObjects(uidList: chatRoomUids, path: .chatRoomInfo(chatRoomId: chatRoomUids.first!), as: [ChatRoomInfo].self)
      chatRoomPromise.observe { result in
        if case .success(let chatRooms) = result {
          strongSelf.chatRoomEntered = chatRooms
        }else {
          print("Fail to get chat rooms info")
        }
      }
    }
  }
  
  init(db: DatabaseController, userUid: UserUid) {
    self.db = db
    self.userUid = userUid
    chatRoomEntered = []
    
    initListener()
  }
  
}
