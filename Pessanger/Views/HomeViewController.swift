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
  
  var mapView: MTMapView?
  var mapPoint1: MTMapPoint?
  var poiItem1: MTMapPOIItem?
  
  var locationManager: CLLocationManager!
  var currentLocation: CLLocationCoordinate2D!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setSearchBar()
    
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
    }
  }
  
  // MARK: setting searchBar
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
