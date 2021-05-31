//
//  Error.swift
//  Pessanger
//
//  Created by bart Shin on 25/05/2021.
//

import Foundation

extension String: Error {}


extension String: LocalizedError {
		public var errorDescription: String? { return self }
}

