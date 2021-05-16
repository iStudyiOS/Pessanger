//
//  ChatViewController.swift
//  Pessanger
//
//  Created by KEEN on 2021/05/10.
//

import UIKit
import SnapKit

class ChatViewController: UIViewController {
  
  lazy var backBarButton = UIBarButtonItem(title: "뒤로 >", style: .done, target: self, action: #selector(popToLeftBarButtonItemTapped))
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigation()
    // 임시
    view.backgroundColor = .red
  }
  
  // MARK: Setup
  fileprivate func setupNavigation() {
    navigationController?.navigationBar.tintColor = .black
    navigationItem.hidesBackButton = true
    navigationItem.setRightBarButton(backBarButton, animated: false)
  }
  
  // MARK: Action
  @objc fileprivate func popToLeftBarButtonItemTapped() {
    navigationController?.popViewControllerToLeft()
  }
}
