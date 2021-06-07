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

// TODO: 사용자 heading 표시하기...
// TODO: 경로 표시하기.

protocol HandleMapSearch {
  func dropPinZoomIn(placemark: MKPlacemark)
}

protocol HeadingDelegate : AnyObject {
    func headingChanged(_ heading: CLLocationDirection)
}

final class HomeViewController: UIViewController, UISearchControllerDelegate {
  
  // MARK: UI - Button
  var chatButton = UIButton()
  var profileButton = UIButton()
  
  var mapView = MKMapView()
//  var locationManager = CLLocationManager()
  lazy var locationManager: CLLocationManager = {
      let manager = CLLocationManager()
      return manager
  }()
  var currentLocation: CLLocation! // 현재 위치 주소
  var resultSearchController = UISearchController()
  var destination = CLLocationCoordinate2D() // 경로 탐색시 도착지 주소
  
  var userHeading: CLLocationDirection?
  var headingImageView: UIImageView?
  var selectedPin: MKPlacemark? = nil
  
  private let user: UserController
  private var searchTableVC: LocationSearchTable!
  private let toggleButton = UIButton()
  
  init(user: UserController) {
    self.user = user
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: view-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // subviews
    self.view.addSubview(mapView)
    self.view.addSubview(chatButton)
    self.view.addSubview(profileButton)
    self.view.addSubview(toggleButton)
    
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
    toggleButton.snp.makeConstraints { make in
      make.top.equalTo(150)
      make.size.equalTo(CGSize(width: 70, height: 70))
      make.right.equalTo(-30)
    }
    // configure
    setLocationManager()
    setResultSearchBar()
    setChatButton()
    setProfileButton()
    setLocationSearchTable()
  }
  
  // MARK: Setup
  func setLocationManager() {
    mapView.showsUserLocation = true
    mapView.showsTraffic = true
    mapView.showsBuildings = true
    
    if CLLocationManager.locationServicesEnabled() {
      print("location service ON.")
      locationManager.requestWhenInUseAuthorization()
    } else {
      print("location service OFF.")
    }
    
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest // bettery
    locationManager.startUpdatingLocation()
    locationManager.stopUpdatingHeading()
  }
  
  func setLocationSearchTable() {
    resultSearchController.delegate = self
    
    let locationSearchTable = LocationSearchTable()
    resultSearchController = UISearchController(searchResultsController: locationSearchTable)
    navigationItem.searchController = resultSearchController
    resultSearchController.searchResultsUpdater = locationSearchTable
    
    locationSearchTable.mapView = mapView
    locationSearchTable.handleMapSearchDelegate = self
    locationSearchTable.user = user
    
    searchTableVC = locationSearchTable
    resultSearchController.searchBar.delegate = searchTableVC
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
  func setToggleButton() {
    toggleButton.backgroundColor = .white
    toggleButton.layer.cornerRadius = 70 * 0.5
    toggleButton.clipsToBounds = true
    toggleButton.setImage(UIImage(systemName: "arrow.triangle.2.circlepath.circle"), for: .normal)
    makeShadow(toggleButton)
    toggleButton.addTarget(self, action: #selector(tapToggleButton), for: .touchUpInside)
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
  
  // MARK: Setting resultSearchBar
  func setResultSearchBar() {
    self.navigationItem.searchController = resultSearchController
    self.navigationItem.title = "친구 찾기"
    
    let searchBar = resultSearchController.searchBar
    searchBar.placeholder = "이름을 검색하세요."
    searchBar.sizeToFit()
    searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
    searchBar.searchTextField.layer.shadowColor = UIColor.black.cgColor
    searchBar.layer.shadowOpacity = 0.25
    searchBar.layer.shadowOffset = CGSize(width: 2, height: 2)
    resultSearchController.searchBar.layer.shadowRadius = 5
    
    definesPresentationContext = true
    
    if let textfield = resultSearchController.searchBar.value(forKey: "searchField") as? UITextField {
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
    let messageVC = MessageViewController()
    navigationController?.pushViewControllerFromLeft(messageVC)
  }
  
  @objc private func tapToggleButton() {
    let alert = UIAlertController(title: "검색 설정", message: "", preferredStyle: .alert)
    LocationSearchTable.Category.allCases.forEach { category in
      alert.addAction(UIAlertAction(title: category.koreanString, style: .default, handler: { _ in
        self.searchTableVC.searchCategory = category
      }))
    }
    present(alert, animated: true)
  }
  
  @objc func profileButtonAction(_ sender: UIButton!) {
    let vc = SettingsViewController()
    vc.title = "프로필"
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(vc, animated: true)
  }
  
  func searchBarTapped() {
    let vc = LocationSearchTable()
    navigationController?.pushViewController(vc, animated: true)
  }
  
  @objc func getDirections(){
    if let selectedPin = selectedPin {
      let mapItem = MKMapItem(placemark: selectedPin)
      let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
      mapItem.openInMaps(launchOptions: launchOptions)
    }
  }
}

// MARK: CLLocationManagerDelegate
extension HomeViewController: CLLocationManagerDelegate {
  func printCoordinates() {
    if let locaton = locationManager.location?.coordinate {
      print("location: \(locaton)")
    }
  }
  func render(_ locations: CLLocation) {
    let coordinate = CLLocationCoordinate2D(latitude: locations.coordinate.latitude, longitude: locations.coordinate.longitude)
    printCoordinates()
    
    let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) // delta 값이 1보다 작을수록 확대됨.
    let region = MKCoordinateRegion(center: coordinate,
                                    span: span)
    self.mapView.setRegion(region, animated: true)
  }
  
  // 업데이트 되는 위치 정보 표시.
  func locationManager(
    _ manager: CLLocationManager,
    didUpdateLocations locations: [CLLocation]) {
    currentLocation = locations.first
    //    currentLocation = manager.location
    guard currentLocation != nil else {
      print("currentLocation is nil.")
      return
    }
    print("got location!")
    printCoordinates()
    manager.stopUpdatingLocation()
    render(currentLocation)
    user.updateLocation(location: .init(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude))
  }
  
  func locationManager(
    _ manager: CLLocationManager,
    didFailWithError error: Error) {
    print(error.localizedDescription)
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    if newHeading.headingAccuracy < 0 { return }
    
    let heading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
    userHeading = heading
  }
  
  // 경로 표시
  func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
    
    let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
    let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
    
    let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
    let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
    
    let sourceAnnotation = MKPointAnnotation()
    
    if let location = sourcePlacemark.location {
      sourceAnnotation.coordinate = location.coordinate
    }
    
    let destinationAnnotation = MKPointAnnotation()
    
    if let location = destinationPlacemark.location {
      destinationAnnotation.coordinate = location.coordinate
    }
    
    self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
    
    let directionRequest = MKDirections.Request()
    directionRequest.source = sourceMapItem
    directionRequest.destination = destinationMapItem
    directionRequest.transportType = .automobile
    
    // 경로 계산
    let directions = MKDirections(request: directionRequest)
    
    directions.calculate {
      (response, error) -> Void in
      
      guard let response = response else {
        if let error = error {
          print("Error: \(error)")
        }
        return
      }
      
      let route = response.routes[0]
      
      self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
      
      let rect = route.polyline.boundingMapRect
      self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
    }
  }
}

// MARK: MKMapViewDelegate
extension HomeViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: NSStringFromClass(Annotation.self))
    if (annotationView == nil) {
      annotationView = AnnotationView(annotation: annotation, reuseIdentifier: NSStringFromClass(Annotation.self))
    } else {
      annotationView!.annotation = annotation
    }
    
    if let annotation = annotation as? Annotation {
      annotation.headingDelegate = annotationView as? HeadingDelegate
      annotationView!.image = UIImage(named: "black_arrow_up")
    }
    return annotationView
  }
  
  // heading
  func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
    if views.last?.annotation is MKUserLocation {
      addHeadingView(toAnnotationView: views.last!)
    }
  }
  
  func addHeadingView(toAnnotationView annotationView: MKAnnotationView) {
    if headingImageView == nil {
      let image = UIImage(named: "black_arrow")
      headingImageView = UIImageView(image: image)
      headingImageView!.frame = CGRect(x: (annotationView.frame.size.width - image!.size.width)/2,
                                       y: (annotationView.frame.size.height - image!.size.height)/2,
                                       width: image!.size.width, height: image!.size.height)
      annotationView.insertSubview(headingImageView!, at: 0)
      headingImageView!.isHidden = true
    }
  }
  
  func updateHeadingRotation() {
    if let heading = userHeading,
    let headingImageView = headingImageView {
      
      headingImageView.isHidden = false
      let rotation = CGFloat(heading/180 * Double.pi)
      headingImageView.transform = CGAffineTransform(rotationAngle: rotation)
    }
  }
}

// MARK: Handle Map Search
extension HomeViewController: HandleMapSearch {
  func dropPinZoomIn(placemark:MKPlacemark){
    // cache the pin
    selectedPin = placemark
    // clear existing pins
    mapView.removeAnnotations(mapView.annotations)
    let annotation = MKPointAnnotation()
    annotation.coordinate = placemark.coordinate
    annotation.title = placemark.name
    if let city = placemark.locality,
       let state = placemark.administrativeArea {
      annotation.subtitle = "\(city) \(state)"
    }
    mapView.addAnnotation(annotation)
    let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
    let region = MKCoordinateRegion(center: placemark.coordinate,
                                    span: span)
    mapView.setRegion(region, animated: true)
  }
}

