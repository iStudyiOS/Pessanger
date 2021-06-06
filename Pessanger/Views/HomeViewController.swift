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

protocol HandleMapSearch {
  func dropPinZoomIn(placemark: MKPlacemark)
}

final class HomeViewController: UIViewController, UISearchControllerDelegate {
	
  // MARK: UI - Button
  var chatButton = UIButton()
  var profileButton = UIButton()
  
  var mapView = MKMapView()
  var locationManager = CLLocationManager()
  var currentLocation: CLLocation!
  var resultSearchController = UISearchController()
  
  var selectedPin: MKPlacemark? = nil
	
<<<<<<< HEAD
	private let user: NetworkController
	private var searchTableVC: LocationSearchTable!
	private let toggleButton = UIButton()
	
	init(user: NetworkController) {
=======
	private let user: UserController
	private var searchTableVC: LocationSearchTable!
	private let toggleButton = UIButton()
	
	init(user: UserController) {
>>>>>>> main
		self.user = user
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
  // MARK: view-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    // mapView
    mapView.showsUserLocation = true
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest // bettery
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
    
    if CLLocationManager.locationServicesEnabled() {
      print("location service ON.")
    } else {
      print("location service OFF.")
    }
    
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
    setResultSearchBar()
    setChatButton()
    setProfileButton()
		setToggleButton()
    
    // locationSearchTable
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
    searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
    searchBar.searchTextField.layer.shadowColor = UIColor.black.cgColor
    searchBar.layer.shadowOpacity = 0.25
    searchBar.layer.shadowOffset = CGSize(width: 2, height: 2)
    resultSearchController.searchBar.layer.shadowRadius = 5
    
    searchBar.sizeToFit()
    resultSearchController.dimsBackgroundDuringPresentation = true
    
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
		let messageVC = MessageViewController(user: user)
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
}

// MARK: MKMapViewDelegate
extension HomeViewController: MKMapViewDelegate {
  func mapView(
    _ mapView: MKMapView,
    viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation is MKUserLocation {
      //return nil so map view draws "blue dot" for standard user location
      return nil
    }
    let reuseId = "pin"
    var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
    
    pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
    pinView?.pinTintColor = UIColor.orange
    pinView?.canShowCallout = true
    let smallSquare = CGSize(width: 30, height: 30)
    
    let button = UIButton(frame: CGRect(origin: .zero, size: smallSquare))
    button.setBackgroundImage(UIImage(systemName: "car.fill"), for: .normal)
    button.addTarget(self, action: #selector(getDirections), for: .touchUpInside)
    pinView?.leftCalloutAccessoryView = button
    return pinView
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

