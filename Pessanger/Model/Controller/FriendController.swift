//
//  FriendController.swift
//  Pessanger
//
//  Created by bart Shin on 23/05/2021.
//

import Foundation

class FriendController: ObservableObject {
  
  typealias UserUid = String
  
  private let db: DatabaseController
  private(set) var infoLists: [ListKey: [UserInfo]]
  private let userUid: UserUid
  var listenersForUserUid: [ListKey: (([UserUid]) -> Void)] = [:] {
    didSet {
      objectWillChange.send()
    }
  }
  
  func searchUser(nickname: String) -> Promise<[UserInfo]> {
    db.query(key: "nickname", value: nickname, path: .userInfo(userUid: ""), as: [UserInfo].self)
  }
  
  func sendRequest(to companion: UserInfo) -> Promise<Void> {
    let sendPromise =  db.addValues(values: [companion.uid], path: .requestSent(userUid: userUid))
    let arrivePromise = db.addValues(values: [userUid], path: .requestReceived(userUid: companion.uid))
    let compounded: Promise<Void> = .dual(first: sendPromise, second: arrivePromise)
    return compounded
  }
  
  func addToFriend(_ companion: UserInfo) -> Promise<Void> {
    let addToMine = db.addValues(values: [companion.uid], path: .friends(userUid: userUid))
    let addToCompanion = db.addValues(values: [userUid], path: .friends(userUid: companion.uid))
    return Promise<Void>.dual(first: addToMine, second: addToCompanion)
  }
  
  private func initListener() {
    ListKey.allCases.forEach { key in
      listenersForUserUid[key] = { [self] uids in
        guard !uids.isEmpty else  {
          infoLists[key] = []
          return
        }
        db.retrieveObjects(uidList: uids, path: .userInfo(userUid: uids.first!), as: [UserInfo].self).observe { result in
          if case .success(let infos) = result {
            infoLists[key] = infos
          }else {
            print("Fail to get user info for \(key.rawValue) \n \(uids)")
          }
        }
      }
    }
  }
  
  private func clearRequests() {
    let requestKeys: [ListKey] = [.requestSent, .requestReceived]
    requestKeys.forEach { key in
      var requestApproved = infoLists[key]!
      requestApproved.removeAll {
        infoLists[.friends]!.contains($0)
      }
      if !requestApproved.isEmpty {
        _ = db.removeValues(values: requestApproved, path: key == .requestSent ? .requestSent(userUid: userUid): .requestReceived(userUid: userUid))
      }
    }
  }
  
  init(db: DatabaseController, userUid: UserUid) {
    self.userUid = userUid
    self.db = db
    infoLists = [:]
    ListKey.allCases.forEach {
      infoLists[$0] = []
    }
    initListener()
  }
  
  enum ListKey: String, CaseIterable {
    case friends
    case requestReceived
    case requestSent
  }
}
