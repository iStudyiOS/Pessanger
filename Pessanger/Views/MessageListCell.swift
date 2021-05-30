//
//  MessageListCell.swift
//  Pessanger
//
//  Created by 홍경표 on 2021/05/30.
//

import UIKit

final class MessageListCell: UITableViewCell {
  
  static var reuseIdentifier: String { return String(describing: Self.self) }
  
  private enum Constants {
    static let imageViewSize: CGFloat = 50
    static let cellPadding: (top: Int, bottom: Int, leading: Int, trailing: Int) = (
      top: 8,
      bottom: 8,
      leading: 13,
      trailing: 13
    )
  }
  
  // Cell 내부에 기본적으로 Padding(안쪽 여백)을 주기 위한 뷰
  private let paddingContainer: UIView = UIView()
  
  private let profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "ic_profile")
    imageView.layer.cornerRadius = Constants.imageViewSize / 2
    imageView.layer.masksToBounds = true
    return imageView
  }()
  
  private let nameLabel: UILabel = {
    let nameLabel = UILabel()
    nameLabel.textColor = .label
    nameLabel.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .medium)
    return nameLabel
  }()
  
  private let contentLabel: UILabel = {
    let contentLabel = UILabel()
    contentLabel.textColor = .secondaryLabel
    contentLabel.font = .preferredFont(forTextStyle: .subheadline)
    contentLabel.lineBreakMode = .byTruncatingTail
    return contentLabel
  }()
  
  private let dateLabel: UILabel = {
    let dateLabel = UILabel()
    dateLabel.textColor = .secondaryLabel
    dateLabel.font = .preferredFont(forTextStyle: .subheadline)
    return dateLabel
  }()
  
  private override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.backgroundColor = .clear
    self.selectionStyle = .none
    
    self.layoutMargins = .zero
    self.separatorInset = .zero
    self.preservesSuperviewLayoutMargins = false
    
    let contentDateLabels: UIStackView = {
      let contentDateLabels = UIStackView()
      contentDateLabels.axis = .horizontal
      contentDateLabels.distribution = .fill
      contentDateLabels.alignment = .fill
      contentDateLabels.addArrangedSubview(contentLabel)
      contentDateLabels.addArrangedSubview(dateLabel)
      dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
      return contentDateLabels
    }()
    
    let labelStackView: UIStackView = {
      let labelStackView = UIStackView()
      labelStackView.axis = .vertical
      labelStackView.distribution = .fill
      labelStackView.alignment = .leading
      labelStackView.addArrangedSubview(nameLabel)
      labelStackView.addArrangedSubview(contentDateLabels)
      return labelStackView
    }()
    
    let stackView: UIStackView = {
      let stackView = UIStackView()
      stackView.axis = .horizontal
      stackView.distribution = .fill
      stackView.alignment = .center
      stackView.spacing = 10
      stackView.addArrangedSubview(profileImageView)
      stackView.addArrangedSubview(labelStackView)
      
      profileImageView.snp.makeConstraints {
        $0.width.height.equalTo(Constants.imageViewSize)
      }
      return stackView
    }()
    
    paddingContainer.addSubview(stackView)
    stackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
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
  
  func configure(name: String, content: String, date: Date = Date()) {
    nameLabel.text = name
    contentLabel.text = content
    dateLabel.text = date.formattedString(type: .one)
  }
  
}
