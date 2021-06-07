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
// 여기가 결과 검색하는 tableviewcell 선언한부분입니다. 기본 스타일에서 subtitle이 포함된 테이블뷰 셀을 사용했어요!
