//
//  ProfileViewController.swift
//  Pessanger
//
//  Created by 강민성 on 2021/05/15.
//

import UIKit

class ProfileViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigation()
    // 임시
    view.backgroundColor = .blue
  }
  
  // MARK: Setup
  fileprivate func setupNavigation() {
    navigationController?.navigationBar.tintColor = .black
  }
}
