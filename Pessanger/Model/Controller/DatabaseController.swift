//
//  DatabaseController.swift
//  Pessanger
//
//  Created by bart Shin on 21/05/2021.
//
<<<<<<< HEAD
import Firebase
import FirebaseFirestore

class DatabaseController: DictionaryConverter {
	
	fileprivate let db: Firestore
	fileprivate var listeners: [ListenerRegistration]
	fileprivate var realTimeListeners: [DatabaseHandle]
	fileprivate let realTimeDbUrl = "https://pessanger-a3120-default-rtdb.asia-southeast1.firebasedatabase.app/"
	fileprivate let realTimeDbRef: DatabaseReference
	
	func writeTemplet(_ templet: [String: Any], path: PathRealTime) -> Promise<Void> {
		
		guard path.isWritable else {
			return Promise<Void>.rejected(with: DbError.badAttempt("Write for \(path) is not implemented"))
		}
		let promise = Promise<Void>()
		let ref = realTimeDbRef.child(path.route)
		ref.setValue(templet) { error, _ in
			if error == nil {
				promise.resolve(with: ())
			}else {
				promise.reject(with: error!)
			}
		}
		return promise
	}
=======

import FirebaseFirestore

class DatabaseController {
	
	private let db: Firestore
	private var listeners: [ListenerRegistration]
>>>>>>> main
	
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
	
<<<<<<< HEAD
	func retreive<T>(path: PathRealTime, as: T.Type) -> Promise<T> {
		let promise = Promise<T>()
		let ref = realTimeDbRef.child(path.route)
		ref.getData { error, snapshot in
			if error == nil,
				 snapshot.exists(),
				 let result = snapshot.value as? T {
				promise.resolve(with: result)
			}else {
				promise.reject(with: DbError.emptyData)
=======
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
>>>>>>> main
			}
		}
		return promise
	}
	
<<<<<<< HEAD
	func retrieve<T>(path: Path, as returnType: T.Type) -> Promise<T> where T: Decodable {
		if path.field == Path.all {
			return retrieveObject(path: path, as: returnType)
		}else {
			return retrieveField(path: path, as: returnType)
		}
	}
	
	/// Get entire document from server
	fileprivate func retrieveObject<T>(path: Path, as returnType: T.Type) -> Promise<T> where T: Decodable {
=======
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
>>>>>>> main
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
<<<<<<< HEAD
	fileprivate func retrieveField<T>(path: Path, as returnType: T.Type) -> Promise<T> where T: Decodable {
	let promise = Promise<T>()
=======
	private func retrieveField<T>(path: Path, as returnType: T.Type) -> Promise<T> where T: Decodable {
		let promise = Promise<T>()
>>>>>>> main
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
<<<<<<< HEAD
	func retrieveObjects<T>(uidList: [String], path: Path, as returnType: [T].Type) -> Promise<[T]> where T: Decodable {
=======
	func retrieveObjects<T>(uidList: [String], path: Path, as returnType: [T].Type) -> Future<[T]> where T: Decodable {
>>>>>>> main
		
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
	
<<<<<<< HEAD
	func increaseCount(path: PathRealTime, for keys: [String]) -> Promise<[String: Any]>  {
		let promise = Promise<[String: Any]>()
		var increased = [String: Any]()
		keys.forEach {
			increased[$0] = ServerValue.increment(1)
		}
		
		let ref = realTimeDbRef.child(path.route)
		ref.updateChildValues(increased)
		ref.getData { error, snapshot in
			if error == nil,
				 snapshot.exists(),
				 let dict = snapshot.value as? [String: Any]{
				var result = [String: Any]()
				keys.forEach {
					result[$0] = dict[$0]
				}
				promise.resolve(with: result)
			}
		}
		return promise
	}
	
=======
>>>>>>> main
	/**
		Add listner to server
		- parameters:
			- handler: Fuction is called when change occur
			- result: Will be dictonary type if sucess
			- error: Will be error if fail
<<<<<<< HEAD
		- returns: Listner reference have to be detached when stop listen
	*/
	func attachListener<T>(path: PathRealTime, for event: ListenerEvent = .value, handler: @escaping (_ result: T?) -> Void) -> DatabaseHandle{
		let ref = realTimeDbRef.child(path.route)
		let listener = ref.observe(event.serverType) { snapshot in
			if let result = snapshot.value as? T {
				handler(result)
			}else {
				handler(nil)
			}
		}
		realTimeListeners.append(listener)
		return listener
	}
	
	
	/**
		Add listner to server
		- parameters:
			- handler: Fuction is called when change occur
			- result: Will be dictonary type if sucess
			- error: Will be error if fail
		- returns: Listner reference have to be detached when stop listen
	*/
	func attachListener(path: Path , handler: @escaping (_ result: [String: Any]?, _ error: Error?) -> Void) {
=======
		- returns: Listner reference have to be removed when stop listen
	*/
	func addListener(path: Path , handler: @escaping (_ result: [String: Any]?, _ error: Error?) -> Void) {
>>>>>>> main
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
	
	
<<<<<<< HEAD
	func detachListener(_ listener: DatabaseHandle) {
		realTimeDbRef.removeObserver(withHandle: listener)
		realTimeListeners.removeAll {
			$0 == listener
		}
	}
	
	func updateValue<T>(_ value: T, path: Path) -> Promise<Void>  {
		
		guard path.field != Path.all else {
			return Promise<Void>.rejected(with: DbError.badAttempt("Entire document can't be updated, try write object"))
		}
		let promise = Promise<Void>()
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
		
		guard path.field != Path.all else {
			return Promise<Void>.rejected(with: DbError.badAttempt("Add values for \(path) illegal use write object instead"))
		}
		let promise = Promise<Void>()
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
	
	fileprivate func addTimeStamp(to dict: [String: Any]) -> [String: Any] {
=======
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
>>>>>>> main
		var added = dict
		added["lastActivated"] = Date().timeIntervalSinceReferenceDate
		return added
	}
	
	init() {
		db = Firestore.firestore()
		listeners = []
<<<<<<< HEAD
		realTimeListeners = []
		realTimeDbRef = Database.database(url: realTimeDbUrl).reference()
=======
>>>>>>> main
	}
	
	deinit {
		listeners.forEach { listner in
			listner.remove()
		}
<<<<<<< HEAD
		realTimeListeners.forEach { listener in
			realTimeDbRef.removeObserver(withHandle: listener)
		}
=======
>>>>>>> main
	}
	
	enum DbError: Error, Equatable {
		case encodingError
		case decodingError
		case badAttempt (String)
		case fireStoreError (String)
<<<<<<< HEAD
		case firError (String)
		case emptyData
	}
	
	/// Determine path for real-time database
	enum PathRealTime {
		case chatRoomInfo (chatRoomUid: String)
		case chatRoomStatus (chatRoomUid: String)
		case messages (chatRoomUid: String, bucket: Int)
		case message (chatRoomUid: String, bucket: Int, messageNum: Int)
		
		var isWritable: Bool {
			switch self {
			case .chatRoomInfo(_), .message(_, _, _):
				return true
			case .chatRoomStatus(_), .messages(_, _):
				return false
			}
		}
		
		var route: String {
			switch self {
			case .chatRoomInfo(let chatRoomUid):
				return "chatRooms/\(chatRoomUid)"
			case .chatRoomStatus(let chatRoomUid):
				return "chatRooms/\(chatRoomUid)/status"
			case .messages(let chatRoomUid, let bucket):
				return "chatRooms/\(chatRoomUid)/\(bucket)"
			case .message(let chatRoomUid, let bucket, let messageNum):
				return "chatRooms/\(chatRoomUid)/\(bucket)/\(messageNum)"
			}
		}
	}
	
	/// Determine path for server database
	enum Path {
		case friends (userUid: String)
		case chatRoomsOfUser (userUid: String)
=======
		case emptyData
	}
	
	/// Determine path for server
	enum Path {
		case friends (userUid: String)
		case chatRoomsOfUser (userUid: String)
		case chatRoomInfo (chatRoomId: String)
>>>>>>> main
		case userInfo (userUid: String)
		case requestSent (userUid: String)
		case requestReceived (userUid: String)
		case location (userUid: String)
		
		var collection: String {
<<<<<<< HEAD
			"users"
		}
		var docId: String {
			
=======
			switch self {
			case .chatRoomsOfUser(_), .friends(_), .userInfo(_) , .requestSent(_), .requestReceived(_), .location(_):
				return "users"
			case .chatRoomInfo(_):
				return "chatRooms"
			}
		}
		var docId: String {
>>>>>>> main
			switch self {
			case .chatRoomsOfUser(let id),
					 .friends(let id),
					 .userInfo(let id),
					 .requestSent(let id),
					 .requestReceived(let id),
<<<<<<< HEAD
					 .location(let id):
				return id
			}
		}
		
=======
					 .location(let id),
					 .chatRoomInfo(let id):
				return id
			}
		}
>>>>>>> main
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
<<<<<<< HEAD
=======
			case .chatRoomInfo(_):
				return Path.all
>>>>>>> main
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
<<<<<<< HEAD
=======
			case .chatRoomInfo(_):
				return .chatRoomInfo(chatRoomId: id)
>>>>>>> main
			case .requestSent(_):
				return .requestSent(userUid: id)
			case .requestReceived(_):
				return .requestReceived(userUid: id)
			case .location(_):
				return .location(userUid: id)
			}
		}
	}
<<<<<<< HEAD
	enum ListenerEvent {
		case value
		case childAdded
		case childRemoved
		case childMoved
		
		var serverType: DataEventType {
			switch self {
			case .value:
				return .value
			case .childAdded:
				return .childAdded
			case .childRemoved:
				return .childRemoved
			case .childMoved:
				return .childMoved
			}
		}
	}
=======
>>>>>>> main
}

