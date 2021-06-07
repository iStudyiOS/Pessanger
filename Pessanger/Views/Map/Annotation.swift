//
//  Annotation.swift
//  Pessanger
//
//  Created by KEEN on 2021/05/31.
//

import Foundation
import MapKit

class Annotation: MKPointAnnotation {
  weak var headingDelegate: HeadingDelegate?
  var heading: CLLocationDirection {
    didSet {
      headingDelegate?.headingChanged(heading)
    }
  }
  
  init(_ coordinate: CLLocationCoordinate2D, _ heading: CLLocationDirection) {
    self.heading = heading
    super.init()
    self.coordinate = coordinate
  }
}
