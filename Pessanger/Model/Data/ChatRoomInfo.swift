//
//  ChatRoomInfo.swift
//  Pessanger
//
//  Created by bart Shin on 25/05/2021.
//

import Foundation

struct ChatRoomInfo: Codable {
	
	typealias UserUid = String
	
	private(set) var participants: [UserUid]
	private(set) var master: UserUid
	let uid: String
	
	
	init(master: UserUid, participants: [UserUid]) {
		self.master = master
		self.participants = [master] + participants
		self.uid = UUID().uuidString
	}
}
