//
//  UrlExtension.swift
//  Pessanger
//
//  Created by bart Shin on 21/05/2021.
//

import UIKit

extension URL {
	
	static func localURLOfImageInAssest(_ name: String, fileExtension: String = "png") -> URL? {
				let fileManager = FileManager.default
				guard let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {return nil}
				let url = cacheDirectory.appendingPathComponent("\(name).\(fileExtension)")
				let path = url.path
				if !fileManager.fileExists(atPath: path) {
						guard let image = UIImage(named: name), let data = image.pngData() else {return nil}
						fileManager.createFile(atPath: path, contents: data, attributes: nil)
				}
				return url
		}
}
