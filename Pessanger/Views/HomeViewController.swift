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

class HomeViewController: UIViewController, MTMapViewDelegate {
  
  var mapView: MTMapView?

  var mapPoint1: MTMapPoint?
  var poiItem1: MTMapPOIItem?
  
  var locationManager: CLLocationManager!
  var currentLocation: CLLocationCoordinate2D!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    

    requestAuthorization()
    // 위치 업데이트
//    locationManager.startUpdatingLocation()
     // 위,경도 가져오기
//    guard let coor = locationManager.location?.coordinate else {
//      print("현재 위치 가져오기 실패.")
//      return
//    }

    
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
