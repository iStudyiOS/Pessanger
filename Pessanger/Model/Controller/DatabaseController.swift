//
//  DatabaseController.swift
//  Pessanger
//
//  Created by bart Shin on 21/05/2021.
//

import FirebaseFirestore

class DatabaseController {
	
	private let db: Firestore
	private var listeners: [ListenerRegistration]
	
	func writeObject<T>(_ object: T, path: Path) -> Promise<Void> where T: Encodable {
		let promise = Promise<Void>()
		do {
			let encoded = try toDictionary(object)
			db.collection(path.collection).document(path.docId).setData(path.field == Path.all ? encoded: [path.field: encoded]) { error in
				if error == nil {
					promise.resolve(with: ())
				}else {
					promise.reject(with: DbError.fireStoreError(error!.localizedDescription))
				}
			}
		}
		catch{
			promise.reject(with: DbError.encodingError)
		}
		return promise
	}
	
	func retrieve<T>(path: Path, as returnType: T.Type) -> Promise<T> where T: Decodable {
		if path.field == Path.all {
			return retrieveObject(path: path, as: returnType)
		}else {
			return retrieveField(path: path, as: returnType)
		}
	}
	
	func updateValue<T>(_ value: T, path: Path) -> Promise<Void>  {
		let promise = Promise<Void>()
		guard path.field != Path.all else {
			promise.reject(with: DbError.badAttempt("Entire document can't be updated, try write object"))
			return promise
		}
		db.collection(path.collection).document(path.docId).updateData(addTimeStamp(to: [path.field: value]) ) { error in
			if error == nil {
				promise.resolve(with: ())
			}else {
				promise.reject(with: DbError.fireStoreError(error!.localizedDescription))
			}
		}
		return promise
	}
	
	func addValues<T>(values: [T], path: Path) -> Promise<Void> where T: Equatable, T: Decodable{
		let promise = Promise<Void>()
		guard path.field != Path.all else {
			promise.reject(with: DbError.badAttempt("Add values for \(path) illegal use write object instead"))
			return promise
		}
		
		db.collection(path.collection).document(path.docId).updateData(addTimeStamp(to: [path.field: FieldValue.arrayUnion(values)]) ) { error in
			if error == nil {
				promise.resolve(with: ())
			}else {
				promise.reject(with: DbError.fireStoreError(error!.localizedDescription))
			}
		}
		return promise
	}
	
	func removeValues<T>(values: [T], path: Path) -> Promise<Void> where T: Equatable, T: Decodable{
	 
		let getValue = retrieve(path: path, as: [T].self)
		
		let promise = getValue.chained {  [self] existing -> Promise<Void> in
			
			var removed = existing
			removed.removeAll { values.contains($0) }
			return updateValue(removed, path: path)
		}
		return promise
	}
	
	/// Get entire document from server
	private func retrieveObject<T>(path: Path, as returnType: T.Type) -> Promise<T> where T: Decodable {
		let promise = Promise<T>()
		db.collection(path.collection).document(path.docId).getDocument { snapshot, error in
			if error == nil,
				 let document = snapshot,
				 document.exists,
				 let dictionary = document.data() ,
				 let object: T = self.toObject(dictionary: dictionary){
				promise.resolve(with: object)
			}
			else {
				promise.reject(with: DbError.fireStoreError(error?.localizedDescription ?? ""))
			}
		}
		return promise
	}
	
	// Get specific field from server
	private func retrieveField<T>(path: Path, as returnType: T.Type) -> Promise<T> where T: Decodable {
		let promise = Promise<T>()
		db.collection(path.collection).document(path.docId).getDocument { snapshot, error in
			if error == nil,
				 let document = snapshot,
				 document.exists,
				 let dictionary = document.data(){
				if let fieldExist = dictionary[path.field] as? T{
					promise.resolve(with: fieldExist)
				}else {
					promise.reject(with: DbError.emptyData)
				}
			}
			else {
				promise.reject(with: DbError.fireStoreError(error?.localizedDescription ?? ""))
			}
		}
		return promise
	}
	
	/**
				Get object array from server
				- parameters:
					- uidList: Unique id for each element
					- as: Must be array
				- returns: Promise will be array of object if success, wil be rejected if fail
	*/
	func retrieveObjects<T>(uidList: [String], path: Path, as returnType: [T].Type) -> Future<[T]> where T: Decodable {
		
		let promise = Promise<[T]>()
		var downloadingList = Set(uidList)
		var fetchedList = [T]()
		uidList.forEach { uid in
			let promiseForElement = retrieveObject(path: path.changeId(uid), as: T.self)
			promiseForElement.observe { result in
				downloadingList.remove(uid)
				if case .success(let fetched) = result {
					fetchedList.append(fetched)
				}
				if downloadingList.isEmpty {
					promise.resolve(with: fetchedList)
				}
			}
		}
		return promise
	}
	/**
			Query by key, value
			- parameters:
				 - as: Must be array
			- returns: Promise will be result array if success, wil be rejected if fail
	*/
	func query<T>(key: String, value: Any, path: Path, as returnType: [T].Type) -> Promise<[T]> where T: Decodable {
		let promise = Promise<[T]>()
		db.collection(path.collection).whereField(key, isEqualTo: value).getDocuments { snapshot, error in
			if error != nil {
				promise.reject(with: error!)
			}else {
				let fetchedList = snapshot!.documents.compactMap { document -> T? in
					if path.field == Path.all {
						let dictionary = document.data()
						let converted: T? = self.toObject(dictionary: dictionary)
						return converted
					}
					if let dictionary = document.get(path.field) as? [String: Any] ,
						 let converted: T = self.toObject(dictionary: dictionary){
						 return converted
						}
					return nil
				}
				promise.resolve(with: fetchedList)
			}
		}
		return promise
	}
	
	/**
		Add listner to server
		- parameters:
			- handler: Fuction is called when change occur
			- result: Will be dictonary type if sucess
			- error: Will be error if fail
		- returns: Listner reference have to be removed when stop listen
	*/
	func addListener(path: Path , handler: @escaping (_ result: [String: Any]?, _ error: Error?) -> Void) {
		let listener = db.collection(path.collection).document(path.docId).addSnapshotListener { snapshot, error in
			if snapshot != nil, error == nil,
				 snapshot!.exists,
				 let doc = snapshot!.data(){
				handler(doc, nil)
			}else {
				handler(nil, DbError.fireStoreError(error?.localizedDescription ?? ""))
			}
		}
		listeners.append(listener)
	}
	
	
	func toDictionary<T> (_ object: T) throws -> [String: Any] where T: Encodable {
	  if let encoded = object as? [String: Any] {
			return encoded
		}
		let jsonData = try JSONEncoder().encode(object)
		if let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String : Any] {
			return dictionary
		}else {
			throw DbError.encodingError
		}
	}
	
	private func toObject<T> (dictionary: [String: Any]) -> T? where T: Decodable{
		try? JSONDecoder().decode(T.self, from: JSONSerialization.data(withJSONObject: dictionary, options: .fragmentsAllowed))
	}
	
	private func addTimeStamp(to dict: [String: Any]) -> [String: Any] {
		var added = dict
		added["lastActivated"] = Date().timeIntervalSinceReferenceDate
		return added
	}
	
	init() {
		db = Firestore.firestore()
		listeners = []
	}
	
	deinit {
		listeners.forEach { listner in
			listner.remove()
		}
	}
	
	enum DbError: Error, Equatable {
		case encodingError
		case decodingError
		case badAttempt (String)
		case fireStoreError (String)
		case emptyData
	}
	
	/// Determine path for server
	enum Path {
		case friends (userUid: String)
		case chatRoomsOfUser (userUid: String)
		case chatRoomInfo (chatRoomId: String)
		case userInfo (userUid: String)
		case requestSent (userUid: String)
		case requestReceived (userUid: String)
		case location (userUid: String)
		
		var collection: String {
			switch self {
			case .chatRoomsOfUser(_), .friends(_), .userInfo(_) , .requestSent(_), .requestReceived(_), .location(_):
				return "users"
			case .chatRoomInfo(_):
				return "chatRooms"
			}
		}
		var docId: String {
			switch self {
			case .chatRoomsOfUser(let id),
					 .friends(let id),
					 .userInfo(let id),
					 .requestSent(let id),
					 .requestReceived(let id),
					 .location(let id),
					 .chatRoomInfo(let id):
				return id
			}
		}
		/// Get entire document without specific field
		static let all = "All"
		var field: String {
			switch self {
			case .chatRoomsOfUser(_):
				return "chatRooms"
			case .location(_):
				return "lastLocation"
			case .friends(_):
				return "friends"
			case .requestSent(_):
				return "requestSent"
			case .requestReceived(_):
				return "requestReceived"
			case .userInfo(_):
				return Path.all
			case .chatRoomInfo(_):
				return Path.all
			}
		}
		func changeId(_ id: String) -> Path {
			switch self {
			case .chatRoomsOfUser(_):
				return .chatRoomsOfUser(userUid: id)
			case .friends(_):
				return .friends(userUid: id)
			case .userInfo(_):
				return .userInfo(userUid: id)
			case .chatRoomInfo(_):
				return .chatRoomInfo(chatRoomId: id)
			case .requestSent(_):
				return .requestSent(userUid: id)
			case .requestReceived(_):
				return .requestReceived(userUid: id)
			case .location(_):
				return .location(userUid: id)
			}
		}
	}
}

