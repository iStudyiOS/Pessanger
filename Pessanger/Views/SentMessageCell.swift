//
//  SentMessageCell.swift
//  Pessanger
//
//  Created by 홍경표 on 2021/05/23.
//

import UIKit

final class SentMessageCell: UITableViewCell {
  
  static var reuseIdentifier: String { return String(describing: Self.self) }
  
  let container: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.distribution = .fill
    stackView.alignment = .trailing
    stackView.spacing = 5
    return stackView
  }()
  
  let contentLabel: UILabel = {
    let contentLabel = PaddingLabel()
    contentLabel.backgroundColor = .systemBlue
    contentLabel.textColor = .systemBackground
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
    
    container.addArrangedSubview(contentLabel)
    
    self.contentView.addSubview(container)
    container.snp.makeConstraints {
      $0.top.bottom.trailing.equalTo(self.contentView.safeAreaLayoutGuide).inset(10)
      $0.leading.equalTo(self.contentView.safeAreaLayoutGuide).inset(50)
    }
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(_ message: Message) {
    contentLabel.text = message.content
  }
  
}
