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
    static let cellPadding: (top: Int, bottom: Int, leading: Int, trailing: Int) = (
      top: 5,
      bottom: 5,
      leading: 5,
      trailing: 5
    )
  }
  
  // Cell 내부에 기본적으로 Padding(안쪽 여백)을 주기 위한 뷰
  private let paddingContainer: UIView = UIView()
  
  private let contentLabel: UILabel = {
    let contentLabel = UILabel()
    contentLabel.textColor = .white
    contentLabel.numberOfLines = 0
    contentLabel.lineBreakMode = .byCharWrapping
    return contentLabel
  }()
  private lazy var contentLabelWithPadding: UIView = {
    let paddingView = UIView()
    paddingView.backgroundColor = .systemBlue
    paddingView.layer.cornerRadius = 10
    paddingView.layer.masksToBounds = true
    paddingView.addSubview(contentLabel)
    contentLabel.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(5)
    }
    return paddingView
  }()
  
  private override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.backgroundColor = .clear
    self.selectionStyle = .none
    
    self.layoutMargins = .zero
    self.separatorInset = .zero
    self.preservesSuperviewLayoutMargins = false
    
    paddingContainer.addSubview(contentLabelWithPadding)
    contentLabelWithPadding.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.trailing.equalToSuperview().inset(10)
      $0.leading.greaterThanOrEqualToSuperview().inset(50)
    }
    
    self.contentView.addSubview(paddingContainer)
    paddingContainer.snp.makeConstraints {
      $0.top.equalToSuperview().inset(Constants.cellPadding.top)
      $0.bottom.equalToSuperview().inset(Constants.cellPadding.bottom)
      $0.leading.equalToSuperview().inset(Constants.cellPadding.leading)
      $0.trailing.equalToSuperview().inset(Constants.cellPadding.trailing)
    }
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(_ message: Message) {
    contentLabel.text = message.content
  }
}
