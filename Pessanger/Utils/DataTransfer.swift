//
//  ImageTransfer.swift
//  Pessanger
//
//  Created by bart Shin on 24/05/2021.
//

import Foundation
import Firebase
import UIKit

protocol DataTransfer {
	
	/// Folder name in server to upload image
	associatedtype Folder: RawRepresentable where Folder.RawValue: StringProtocol
	associatedtype UploadPath: StringProtocol
	
	func getUploadPath(folder: Folder, fileUid: String) -> String
}


extension DataTransfer {
	
	func getLocalFilename(serverUrl: URL) -> String {
		print("url: \(serverUrl) \n filename: \(serverUrl.lastPathComponent)")
		return serverUrl.lastPathComponent
	}
	
	func storeData(_ data: Data, filename: String) -> Bool {
		let url = FileManager.getUrlForInDocumentDir(filename: filename)
		do {
			try data.write(to: url, options: .atomic)
			return true
		}
		catch {
			print("Fail to write file for \(filename)")
			return false
		}
	}
	
	func getDataInDevice(serverUrl: URL) -> Data? {
		let localUrl = FileManager.getUrlForInDocumentDir(filename: getLocalFilename(serverUrl: serverUrl))
		guard FileManager.default.fileExists(atPath: localUrl.path) else {
			return nil
		}
		return FileManager.default.contents(atPath: localUrl.path)
	}
	
	/**
	Upload data to server
	- returns:
	Promise of url (To download data next time)
	- parameters:
		- path: Created by function - getUploadPath
		- filename: Unique file name  created by assosiated method
	*/
	func uploadData(_ data: Data, path: UploadPath) -> Promise<URL> {
		let promise = Promise<URL>()
		let filename = UUID().uuidString
		let uploadRef = Storage.storage().reference(withPath: "\(path)/\(filename).png")
		let metaData = StorageMetadata()
		metaData.contentType = "image/png"
		let uploadTask = uploadRef.putData(data, metadata: metaData) { downloadMetadata, error in
			if error != nil {
				promise.reject(with: ImageTransferError.uploadError(error!.localizedDescription))
			}
		}
		uploadTask.observe(.success) { _ in
			uploadRef.downloadURL { url, error in
				if url != nil, error == nil {
					promise.resolve(with: url!)
				}else {
					promise.reject(
						with: ImageTransferError.uploadError("Fail to get url for uploaded image \n \(error?.localizedDescription ?? "")"))
				}
			}
		}
		return promise
	}
	/// Download data from server, store in device
	func downloadData(url: URL, storeInDevice: Bool) -> Promise<Data> {
		let promise = Promise<Data>()
		URLSession.shared.dataTask(with: url) { data, response, error in
			if error == nil,
				 data != nil {
				let filename = getLocalFilename(serverUrl: url)
				if storeInDevice, !storeData(data!, filename: filename) {
					print("Fail to store data in device for url: \(url)")
				}
				promise.resolve(with: data!)
			}else {
				promise.reject(with: ImageTransferError.downloadError(error?.localizedDescription ?? ""))
			}
		}
		return promise
	}
}

enum ImageTransferError: Error {
	case uploadError (String)
	case downloadError (String)
}
