//
//  PaddingLabel.swift
//  Pessanger
//
//  Created by 홍경표 on 2021/05/23.
//

import UIKit

// Width가 고정이 아니고 최대 Width가 되었을 때 마지막 글자가 잘릴 수 있음..

final class PaddingLabel: UILabel {
  
  let inset: UIEdgeInsets
  
  init(inset: UIEdgeInsets = .init(top: 5, left: 5, bottom: 5, right: 5)) {
    self.inset = inset
    super.init(frame: .zero)
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func drawText(in rect: CGRect) {
    let paddingRect = rect.insetBy(dx: 5, dy: 5)
    super.drawText(in: paddingRect)
  }
  
  override var intrinsicContentSize: CGSize {
    let size = super.intrinsicContentSize
    return CGSize(
      width: size.width + self.inset.left + self.inset.right,
      height: size.height + self.inset.top + self.inset.bottom
    )
  }
  
  override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
    let paddingBounds = bounds.inset(by: inset)
    let newTextRect = super.textRect(forBounds: paddingBounds, limitedToNumberOfLines: 0)
    return newTextRect
  }
}
