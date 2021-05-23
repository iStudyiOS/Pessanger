//
//  ReceivedMessageCell.swift
//  Pessanger
//
//  Created by 홍경표 on 2021/05/23.
//

import UIKit

final class ReceivedMessageCell: UITableViewCell {
  
  static var reuseIdentifier: String { return String(describing: Self.self) }
  
  let nameLabel: UILabel = {
    let nameLabel = PaddingLabel()
    nameLabel.text = "??"
    nameLabel.layer.cornerRadius = 10
    nameLabel.layer.masksToBounds = true
    return nameLabel
  }()
  
  let contentLabel: UILabel = {
    let contentLabel = PaddingLabel()
    contentLabel.backgroundColor = .systemGray5
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
    
    let imageView = UIImageView(image: UIImage(named: "ic_profile"))
    let labelStackView: UIStackView = {
      let stackView = UIStackView()
      stackView.axis = .vertical
      stackView.distribution = .fill
      stackView.alignment = .leading
      stackView.spacing = 5
      return stackView
    }()
    labelStackView.addArrangedSubview(nameLabel)
    labelStackView.addArrangedSubview(contentLabel)
    
    let container: UIStackView = {
      let stackView = UIStackView()
      stackView.axis = .horizontal
      stackView.distribution = .fill
      stackView.alignment = .top
      stackView.spacing = 5
      return stackView
    }()
    container.addArrangedSubview(imageView)
    container.addArrangedSubview(labelStackView)
    imageView.snp.makeConstraints {
      $0.width.height.equalTo(30)
    }
    self.contentView.addSubview(container)
    container.snp.makeConstraints {
      $0.top.bottom.leading.equalTo(self.contentView.safeAreaLayoutGuide).inset(10)
      $0.trailing.equalTo(self.contentView.safeAreaLayoutGuide).inset(50)
    }
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(_ message: Message) {
    nameLabel.text = message.sender
    contentLabel.text = message.content
  }
  
}
