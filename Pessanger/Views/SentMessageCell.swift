//
//  SentMessageCell.swift
//  Pessanger
//
//  Created by 홍경표 on 2021/05/23.
//

import UIKit

final class SentMessageCell: UITableViewCell {
  
  static var reuseIdentifier: String { return String(describing: Self.self) }
  
  private enum Constants {
    static let padding: (top: Int, bottom: Int, leading: Int, trailing: Int) = (
      top: 5,
      bottom: 5,
      leading: 5,
      trailing: 5
    )
  }
  
  // Cell 내부에 기본적으로 Padding(안쪽 여백)을 주기 위한 뷰
  private let paddingContainer: UIView = UIView()
  
  let contentLabel: UILabel = {
    let contentLabel = PaddingLabel()
    contentLabel.backgroundColor = .systemBlue
    contentLabel.textColor = .white
    contentLabel.layer.cornerRadius = 10
    contentLabel.layer.masksToBounds = true
    contentLabel.numberOfLines = 0
    return contentLabel
  }()
  
  private override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.backgroundColor = .clear
    self.selectionStyle = .none
    
    self.layoutMargins = .zero
    self.separatorInset = .zero
    self.preservesSuperviewLayoutMargins = false
    
    paddingContainer.addSubview(contentLabel)
    contentLabel.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.trailing.equalToSuperview().inset(10)
      $0.leading.greaterThanOrEqualToSuperview().inset(50)
    }
    
    self.contentView.addSubview(paddingContainer)
    paddingContainer.snp.makeConstraints {
      $0.top.equalToSuperview().inset(Constants.padding.top)
      $0.bottom.equalToSuperview().inset(Constants.padding.bottom)
      $0.leading.equalToSuperview().inset(Constants.padding.leading)
      $0.trailing.equalToSuperview().inset(Constants.padding.trailing)
    }
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(_ message: Message) {
    contentLabel.text = message.content
  }
  
}
