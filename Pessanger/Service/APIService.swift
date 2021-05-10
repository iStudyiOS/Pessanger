//
//  APIService.swift
//  Pessanger
//
//  Created by KEEN on 2021/05/10.
//

import Foundation

extension Bundle {
  var apiKey: String {
    guard let file = self.path(forResource: "Info", ofType: "plist") else { return "" }
    
    guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
    guard let key = resource["KAKAO_APP_KEY"] as? String else { fatalError("Info.plist에 API_KEY설정을 해주세요.")}
    return key
  }
}
