//
//  FileManager.swift
//  Pessanger
//
//  Created by bart Shin on 24/05/2021.
//

import Foundation

extension FileManager {
	static func getUrlForInDocumentDir(filename: String) -> URL {

			let documentsURL =
				FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
			return documentsURL.appendingPathComponent(filename)
	}
}
