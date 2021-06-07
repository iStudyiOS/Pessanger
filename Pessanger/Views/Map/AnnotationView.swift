//
//  AnnotationView.swift
//  Pessanger
//
//  Created by KEEN on 2021/05/31.
//

import Foundation
import MapKit

class AnnotationView : MKAnnotationView , HeadingDelegate {
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
  }
  
  func headingChanged(_ heading: CLLocationDirection) {
    UIView.animate(withDuration: 0.1, animations: { [unowned self] in
      self.transform = CGAffineTransform(rotationAngle: CGFloat(heading / 180 * .pi))
    })
  }
}
