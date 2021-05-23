//
//  Extensions.swift
//  Pessanger
//
//  Created by KEEN on 2021/05/16.
//

import Foundation
import UIKit

extension UINavigationController {
  // viewController 왼쪽에서 오른쪽 방향으로 push하는 함수
  func pushViewControllerFromLeft(_ viewController: UIViewController) {
    let transition = CATransition()
    transition.duration = 0.3
    transition.type = CATransitionType.push
    transition.subtype = CATransitionSubtype.fromLeft
    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    view.window!.layer.add(transition, forKey: kCATransition)
    pushViewController(viewController, animated: false)
  }
  // viewController 왼쪽 방향으로 pop하는 함수
  func popViewControllerToLeft() {
    let transition = CATransition()
    transition.duration = 0.3
    transition.type = CATransitionType.push
    transition.subtype = CATransitionSubtype.fromRight
    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    view.window!.layer.add(transition, forKey: kCATransition)
    popViewController(animated: false)
  }
}

