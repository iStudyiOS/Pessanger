//
//  LocationSearchTable.swift
//  Pessanger
//
//  Created by KEEN on 2021/05/27.
//

// TODO: HomeVC에서와 동일한 코드. 나중에 리팩토링

import UIKit
import MapKit

class LocationSearchTable: UITableViewController {
  var handleMapSearchDelegate: HandleMapSearch? = nil
  
  var matchingItems: [MKMapItem] = []
  var mapView: MKMapView? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let viewController = LocationSearchTable()
    let nav = UINavigationController(rootViewController: viewController)
    self.navigationController?.present(nav, animated: true, completion: nil)
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(ResultTableViewCell.self, forCellReuseIdentifier: "resultCell")
    
//    tableView.rowHeight = UITableView.automaticDimension
//    tableView.estimatedRowHeight = UITableView.automaticDimension
  }
  
  // MARK: Parsing Address
  func parseAddress(_ selectedItem:MKPlacemark) -> String {
    // 주소 띄어쓰기 관련 설정
    // 도시 이름 띄어쓰기
    let firstSpace = (selectedItem.locality != nil && selectedItem.administrativeArea != nil) ? " " : ""
    let secondSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
    // 번가,도시 사이 컴마 찍기
    let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
    
    let addressLine = String( // 시 구 동, 지번
      format:"%@%@%@%@%@%@%@",
      // 시
      selectedItem.administrativeArea ?? "",
      firstSpace,
      // 구
      selectedItem.locality ?? "",
      secondSpace,
      // 동
      selectedItem.thoroughfare ?? "",
      comma,
      // 지번
      selectedItem.subThoroughfare ?? ""
    )
    return addressLine
  }
}

// MARK: UISearchResultsUpdating
extension LocationSearchTable: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    guard let mapView = mapView,
          let searchBarText = searchController.searchBar.text else { return }
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = searchBarText
    request.region = mapView.region
    let search = MKLocalSearch(request: request)
    search.start { response, _ in
      guard let response = response else {
        return
      }
      self.matchingItems = response.mapItems
      self.tableView.reloadData()
    }
  }
}

// MARK: TableViewDelegate
extension LocationSearchTable {
  override func tableView(
    _ tableView: UITableView,
   numberOfRowsInSection section: Int) -> Int {
    return matchingItems.count
  }

  override func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! ResultTableViewCell
    let selectedItem = matchingItems[indexPath.row].placemark
    cell.textLabel?.textColor = .black
    cell.detailTextLabel?.textColor = .lightGray
    cell.textLabel?.text = selectedItem.name
    cell.detailTextLabel?.text = parseAddress(selectedItem)
    return cell
  }
}

// MARK: HandleMapSearchDelegate
extension LocationSearchTable {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedItem = matchingItems[indexPath.row].placemark
    handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
    dismiss(animated: true, completion: nil)
  }
}
