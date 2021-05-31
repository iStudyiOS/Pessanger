//
//  ResultTableViewCell.swift
//  Pessanger
//
//  Created by KEEN on 2021/05/27.
//

import UIKit
import SnapKit

class ResultTableViewCell: UITableViewCell {
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
