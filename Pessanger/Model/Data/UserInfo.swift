//
//  UserInfo.swift
//  Pessanger
//
//  Created by bart Shin on 20/05/2021.
//

import Foundation
import UIKit

struct UserInfo: Codable {
	
	static let defaultProfileImage = UIImage(named: "ic_profile")!
	
	let nickname: String
	let imageUrls: [URL]
	let profileImageUrl: URL?
	var lastActivated: Date
	var lastLocation: Location?
	let uid: String
	
	struct Location: Codable, Equatable {
		var latitude: Double
		var longitude: Double
	}
	
	init(nickname: String, uid: String) {
		self.nickname = nickname
		self.uid = uid
		self.imageUrls = []
		self.profileImageUrl = nil
		self.lastActivated = Date()
		self.lastLocation = nil
	}
	
	static let systemUid = "system"
	static var missing: UserInfo {
		UserInfo(nickname: "Missing user", uid: systemUid)
	}
	static var system: UserInfo {
		UserInfo(nickname: "system", uid: systemUid)
	}
}

extension UserInfo: Equatable {
	static func == (lhs: UserInfo, rhs: UserInfo) -> Bool { lhs.uid == rhs.uid
	}
}

extension UserInfo: Hashable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(uid)
	}
}
