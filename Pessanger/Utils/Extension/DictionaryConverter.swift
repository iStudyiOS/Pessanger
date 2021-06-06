//
//  DictionaryConverter.swift
//  Pessanger
//
//  Created by bart Shin on 03/06/2021.
//

import Foundation

protocol DictionaryConverter: AnyObject {
	
}

extension DictionaryConverter {
	func toDictionary<T> (_ object: T) throws -> [String: Any] where T: Encodable {
		if let encoded = object as? [String: Any] {
			return encoded
		}
		let jsonData = try JSONEncoder().encode(object)
		if let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String : Any] {
			return dictionary
		}else {
			throw encodingError
		}
	}
	
	func toObject<T> (dictionary: [String: Any]) -> T? where T: Decodable{
		try? JSONDecoder().decode(T.self, from: JSONSerialization.data(withJSONObject: dictionary, options: .fragmentsAllowed))
	}
}

fileprivate let encodingError: Error = "Fail to encoding to dictionary"
