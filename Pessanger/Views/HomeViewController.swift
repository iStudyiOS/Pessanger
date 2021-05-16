//
//  HomeViewController.swift
//  Pessanger
//
//  Created by KEEN on 2021/05/10.
//

import UIKit
import SnapKit
import CoreLocation

public let DEFAULT_POSITION = MTMapPointGeo(latitude: 37.566508, longitude: 126.977945)

class HomeViewController: UIViewController {
  // MARK: UI - Button
  var chatButton = UIButton()
  var profileButton = UIButton()
  
  var mapView: MTMapView?
  var mapPoint1: MTMapPoint?
  var poiItem1: MTMapPOIItem?
  
  var locationManager: CLLocationManager!
  var currentLocation: CLLocationCoordinate2D!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // MARK: Setting MapView
    requestAuthorization()

    // 지도 불러오기
    mapView = MTMapView(frame: self.view.bounds)
    
    if let mapView = mapView {
      mapView.delegate = self
      mapView.baseMapType = .standard
      
      // 지도 중심점, 레벨
      mapView.setMapCenter(MTMapPoint(geoCoord: DEFAULT_POSITION), zoomLevel: 4, animated: true)
      
      // 현재 위치 트래킹
      mapView.showCurrentLocationMarker = true
      mapView.currentLocationTrackingMode = .onWithoutHeading
      
      // 마커 추가
      self.mapPoint1 = MTMapPoint(geoCoord: MTMapPointGeo(latitude: 37.566508, longitude: 126.977945))
      poiItem1 = MTMapPOIItem()
      poiItem1?.markerType = MTMapPOIItemMarkerType.bluePin
      poiItem1?.mapPoint = mapPoint1
      poiItem1?.itemName = "현재위치"
      mapView.add(poiItem1)
                          
      self.view.addSubview(mapView)
      self.view.addSubview(chatButton)
      self.view.addSubview(profileButton)

      // MARK: Constraints
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
  }
  // MARK: Setting Button
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
    print("chat button pressed.")
    let vc = ChatViewController()
    vc.title = "대화"
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewControllerFromLeft(vc)
  }
  
  @objc func profileButtonAction(_ sender: UIButton!) {
    print("profile button pressed.")
    let vc = ProfileViewController()
    vc.title = "프로필"
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(vc, animated: true)
  }
  
  @objc fileprivate func pushFromLeftButtonTapped() {
    let vc = ChatViewController()
    navigationController?.pushViewControllerFromLeft(vc)
  }
}

// MARK: extensions
extension HomeViewController: MTMapViewDelegate {
  // Custom: 현 위치 트래킹 함수
  func mapView(_ mapView: MTMapView!, updateCurrentLocation location: MTMapPoint!, withAccuracy accuracy: MTMapLocationAccuracy) {
    let currentLocation = location?.mapPointGeo()
    if let latitude = currentLocation?.latitude, let longitude = currentLocation?.longitude{
      print("MTMapView updateCurrentLocation (\(latitude),\(longitude)) accuracy (\(accuracy))")
    }
  }
  
  func mapView(_ mapView: MTMapView?, updateDeviceHeading headingAngle: MTMapRotationAngle) {
    print("MTMapView updateDeviceHeading (\(headingAngle)) degrees")
  }
  
  // 위치 허가 요청 함수.
  private func requestAuthorization() {
    if locationManager == nil {
      locationManager = CLLocationManager()
      // 위치 추적 권한 요청
      locationManager!.requestWhenInUseAuthorization()
      // 배터리에 맞게 최적의 정확도 권장
      locationManager!.desiredAccuracy = kCLLocationAccuracyBest
      locationManager!.delegate = self
      locationManagerDidChangeAuthorization(locationManager)
    } else {
      locationManager.startMonitoringSignificantLocationChanges()
    }
  }
}

extension HomeViewController: CLLocationManagerDelegate {
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    if manager.authorizationStatus == .authorizedWhenInUse {
      currentLocation = locationManager.location?.coordinate
      LocationService.shared.latitude = currentLocation.latitude
      LocationService.shared.longitude = currentLocation.longitude
    }
  }
}
