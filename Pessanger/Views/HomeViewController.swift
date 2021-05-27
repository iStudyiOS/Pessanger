//
//  HomeViewController.swift
//  Pessanger
//
//  Created by KEEN on 2021/05/10.
//

import UIKit
import SnapKit
import MapKit
import CoreLocation

class HomeViewController: UIViewController {
  // MARK: UI - Button
  var chatButton = UIButton()
  var profileButton = UIButton()
  var mapView = MKMapView()
  var locationManager = CLLocationManager()
  var currentLocarion: CLLocation!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.addSubview(mapView)
    self.view.addSubview(chatButton)
    self.view.addSubview(profileButton)
    
    // MARK: Constraints
    mapView.snp.makeConstraints { make in
      make.bottom.equalToSuperview()
      make.top.equalToSuperview()
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
    }
    chatButton.snp.makeConstraints { make in
      make.bottom.equalTo(-20)
      make.size.equalTo(CGSize(width: 70, height: 70))
      make.left.equalTo(20)
    }
    profileButton.snp.makeConstraints { make in
      make.bottom.equalTo(-20)
      make.size.equalTo(CGSize(width: 70, height: 70))
      make.right.equalTo(-20)
    }
    // configure
    setSearchBar()
    setChatButton()
    setProfileButton()
  }
  
  func setChatButton() {
    chatButton.backgroundColor = .white
    chatButton.layer.cornerRadius = 70 * 0.5
    chatButton.clipsToBounds = true
    chatButton.setImage(UIImage(named: "ic_chat"), for: .normal)
    chatButton.imageEdgeInsets = UIEdgeInsets(top: 13, left: 12, bottom: 13, right: 12)
    makeShadow(chatButton)
    chatButton.addTarget(self, action: #selector(chatButtonAction), for: .touchUpInside)
  }
  func setProfileButton() {
    profileButton.backgroundColor = .white
    profileButton.layer.cornerRadius = 70 * 0.5
    profileButton.clipsToBounds = true
    profileButton.setImage(UIImage(named: "ic_profile"), for: .normal)
    profileButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    makeShadow(profileButton)
    profileButton.addTarget(self, action: #selector(profileButtonAction), for: .touchUpInside)
  }
  
  func makeShadow(_ item: UIButton) {
    item.layer.masksToBounds = false
    item.layer.shadowColor = UIColor.gray.cgColor
    item.layer.shadowOpacity = 0.5
    item.layer.shadowOffset = CGSize.zero
    item.layer.shadowRadius = 5
  }
  
  // MARK: Setting searchBar
  func setSearchBar() {
    let searchBar = UISearchBar()
    searchBar.setImage(UIImage(named: "ic_search"), for: UISearchBar.Icon.search, state: .normal)
    self.navigationController?.navigationBar.topItem?.titleView = searchBar
    
    searchBar.setImage(UIImage(named: "ic_clear"), for: .clear, state: .normal)
    searchBar.placeholder = "이름을 검색하세요."
    searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
    
    searchBar.searchTextField.layer.shadowColor = UIColor.black.cgColor
    searchBar.layer.shadowOpacity = 0.25
    searchBar.layer.shadowOffset = CGSize(width: 2, height: 2)
    searchBar.layer.shadowRadius = 5
    
    if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
      textfield.backgroundColor = UIColor.white
      textfield.layer.cornerRadius = 17
      textfield.clipsToBounds = true
      
      if let leftView = textfield.leftView as? UIImageView {
        leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
        leftView.tintColor = UIColor.black
      }
      
      if let rightView = textfield.rightView as? UIImageView {
        rightView.image = rightView.image?.withRenderingMode(.alwaysTemplate)
        rightView.tintColor = UIColor.black
      }
    }
  }
  
  // MARK: Button Action
  @objc func chatButtonAction(_ sender: UIButton!) {
    let vc = ChatViewController(viewModel: ChatViewModel(opponentName: "Elon Musk"))
    vc.title = "대화"
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewControllerFromLeft(vc)
  }
  
  @objc func profileButtonAction(_ sender: UIButton!) {
    let vc = SettingsViewController()
    vc.title = "프로필"
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(vc, animated: true)
  }
  
  @objc fileprivate func pushFromLeftButtonTapped() {
    let vc = ChatViewController(viewModel: ChatViewModel(opponentName: "Elon Musk"))
    navigationController?.pushViewControllerFromLeft(vc)
  }
}
