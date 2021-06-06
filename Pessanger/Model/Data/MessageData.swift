//
//  MessageData.swift
//  Pessanger
//
//  Created by bart Shin on 01/06/2021.
//

import Foundation

struct MessageData: Codable {
	
	typealias UserUid = String
	let senderUid: UserUid
	let content: String
	let date: Date
	let imageUrl: URL?
	
	static var missing: MessageData {
		MessageData(senderUid: UserInfo.system.uid, content: "Missing message", date: Date(), imageUrl: nil)
	}
}
