//
//  PaddingLabel.swift
//  Pessanger
//
//  Created by 홍경표 on 2021/05/23.
//

import UIKit

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
    let insets = self.inset
    super.drawText(in: rect.inset(by: insets))
  }
  
  override var intrinsicContentSize: CGSize {
    let size = super.intrinsicContentSize
    return CGSize(
      width: size.width + self.inset.left + self.inset.right,
      height: size.height + self.inset.top + self.inset.bottom
    )
  }
  
}
