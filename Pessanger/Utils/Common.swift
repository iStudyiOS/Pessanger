//
//  Common.swift
//  Pessanger
//
//  Created by 홍경표 on 2021/05/30.
//

import UIKit

// 전역에서 사용하는 공통 상수들을 선언하는 곳!

// 공통 이미지
extension UIImage {
  static let leftArrow: UIImage = UIImage(named: "ic_back")!
  static let rightArrow: UIImage = leftArrow.withHorizontallyFlippedOrientation()
}

// 테마 컬러
extension UIColor {
  
}
