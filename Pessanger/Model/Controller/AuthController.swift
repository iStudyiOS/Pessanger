//
//  AuthController.swift
//  Pessanger
//
//  Created by bart Shin on 20/05/2021.
//

import FirebaseAuth
import FirebaseFirestore
import Security

class AuthController {
	
	private(set) var autoSignIn: Bool
	private(set) var savingCredential: Bool
	private let autoSignInUserDefaultKey = "usingAutoSignIn"
	private let savingCredentialUserDefaultKey = "savingCredential"
	private let emailUserDefaultKey = "emailSaved"
	let dbController: DatabaseController
	
	func changeAutoSignIn(to using: Bool) {
		autoSignIn = using
		UserDefaults.standard.setValue(using, forKey: autoSignInUserDefaultKey)
	}
	
	func getCurrentUser() -> User? {
		return Auth.auth().currentUser
	}
	
	func changeAutoSaveCredential(to saving: Bool) {
		savingCredential = saving
		UserDefaults.standard.setValue(saving, forKey: savingCredentialUserDefaultKey)
	}
	
	func retrieveSavedCredential() -> Credential? {
		guard let email = UserDefaults.standard.string(forKey: emailUserDefaultKey),
					let password = readPassWordFromKeyChain(for: email),
					!email.isEmpty,
					!password.isEmpty else {
			return nil
		}
		return Credential(email: email, password: password)
	}
	
	func signIn(credential: Credential,
							completion: @escaping (UserInfo) -> Void,
							errorHandler: @escaping (Error) -> Void ) {
		Auth.auth().signIn(withEmail: credential.email,
											 password: credential.password)
		{ [self] signInResult, error in
			if error == nil, signInResult != nil {
				if savingCredential {
					saveCredential(credential)
				}
				dbController.retrieve(path: .userInfo(userUid: signInResult!.user.uid), as: UserInfo.self).observe { infoResult in
					if case .success(let myInfo) = infoResult {
						completion(myInfo)
					}else {
						errorHandler(AuthError.firebaseError(error?.localizedDescription ?? ""))
					}
				}
			}else {
				errorHandler(AuthError.firebaseError(error?.localizedDescription ?? ""))
			}
		}
	}
	
	func signOut() throws {
		do{
		try Auth.auth().signOut()
		}
		catch {
			throw AuthError.firebaseError("Fail to sign out\n \(error.localizedDescription)")
		}
	}
	
	func createUser(credential: Credential, nickname: String,  completion: @escaping (UserInfo) -> Void, errorHandler: @escaping (Error) -> Void ) {
		Auth.auth().createUser(withEmail: credential.email,
													 password: credential.password) { [self] result, error in
			if error == nil, result != nil {
				let userInfo = UserInfo(nickname: nickname, uid: result!.user.uid)
				self.dbController.writeObject(userInfo, path: .userInfo(userUid: userInfo.uid)).observe { result in
					if case .success = result {
						if savingCredential {
							saveCredential(credential)
						}
						completion(userInfo)
					}else {
						errorHandler(AuthError.firebaseError(error?.localizedDescription ?? ""))
					}
				}
			}else {
				errorHandler(AuthError.firebaseError(error?.localizedDescription ?? ""))
			}
		}
	}
	
	
	private func saveCredential(_ credential: Credential) {
		UserDefaults.standard.setValue(credential.email, forKey: emailUserDefaultKey)
		if savePassWordInKeyChain(
				email: credential.email,
				password: credential.password) != errSecSuccess {
			print("Error to save password in keychain")
		}
	}
	
	private func savePassWordInKeyChain(email: String, password: String) -> OSStatus{
		guard let encodedPassword = password.data(using: String.Encoding.utf8) else {
			return errSecInvalidEncoding
		}
		let query: [CFString: Any] = [
			kSecClass: kSecClassGenericPassword,
			kSecAttrService: Bundle.main.bundleIdentifier!,
			kSecAttrAccount: email,
			kSecValueData: encodedPassword]
		SecItemDelete(query as CFDictionary)
		
		return SecItemAdd(query as CFDictionary, nil)
	}
	
	private func readPassWordFromKeyChain(for email: String) -> String? {
		let query: [CFString: Any] = [
			kSecClass: kSecClassGenericPassword,
			kSecAttrService: Bundle.main.bundleIdentifier!,
			kSecAttrAccount: email,
			kSecMatchLimit: kSecMatchLimitOne,
			kSecReturnAttributes: true,
			kSecReturnData: true
		]
		var item: AnyObject?
		if SecItemCopyMatching(query as CFDictionary, &item) != errSecSuccess{
			return nil
		}
		if let foundItem = item as? [String: Any],
			 let password = String(
				data: foundItem[kSecValueData as String] as! Data,
				encoding: .utf8) {
			return password
		}else {
			return nil
		}
	}
	/**
	- Password length is more than 8.
	- At least 1 Alphabet in Password.
	- At least 1 Special Character in Password. */
	func isValidPassword(_ password: String) -> Bool {
		let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
		return passwordTest.evaluate(with: password)
	}
	
	func isValidEmail(_ email:String) -> Bool {
		
		let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
		let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
		return emailTest.evaluate(with: email)
	}
	
	init(dbController: DatabaseController) {
		savingCredential = UserDefaults.standard.bool(forKey: savingCredentialUserDefaultKey)
		autoSignIn = UserDefaults.standard.bool(forKey: autoSignInUserDefaultKey)
		self.dbController = dbController
	}
   
	enum AuthError: Error {
		case autoSignInFail (String)
		case firebaseError (String)
	}
	
	struct Credential {
		let email: String
		let password: String
		
		init(email: String, password: String) {
			self.email = email
			self.password = password
		}
	}
}
