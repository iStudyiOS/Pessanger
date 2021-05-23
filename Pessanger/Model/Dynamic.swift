//
//  Dynamic.swift
//  Pessanger
//
//  Created by 홍경표 on 2021/05/23.
//

import Foundation

final class Dynamic<T> {
  
  typealias Listener = (T) -> Void
  var listener: Listener?
  var value: T {
    didSet {
      listener?(value)
    }
  }
  
  init(_ v: T) {
    value = v
  }
  
  func bind(_ listener: Listener?) {
    self.listener = listener
  }
  
  func bindAndFire(_ listener: Listener?) {
    self.listener = listener
    listener?(value)
  }
  
}
