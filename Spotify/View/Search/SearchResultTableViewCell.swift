//
//  SearchResultTableViewCell.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 16.05.23.
//

import UIKit
import SDWebImage

class SearchResultTableViewCell: UITableViewCell {

    static let identifier = "SearchResultTableViewCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let iconimageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.tintColor = .label
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        return stackView
    }()
  
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(iconimageView)
        contentView.addSubview(stackView)
        iconimageView.addSubview(activityIndicator)
        stackView.addSubview(titleLabel)
        stackView.addSubview(subTitleLabel)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.sizeToFit()
        subTitleLabel.sizeToFit()
        
        iconimageView.frame = CGRect(x: 5, y: 5, width: contentView.height - 10, height: contentView.height - 10)
        stackView.frame = CGRect(x: iconimageView.right + 10,
                                 y: (contentView.height - (titleLabel.height + subTitleLabel.height)) / 2,
                                 width: contentView.width - iconimageView.width - 20,
                                 height: titleLabel.height + subTitleLabel.height)
        
        titleLabel.frame = CGRect(x: 0, y: 0, width: stackView.width, height: titleLabel.height)
        subTitleLabel.frame = CGRect(x: 0, y: titleLabel.bottom, width: stackView.width, height: subTitleLabel.height)
        activityIndicator.frame = CGRect(x: iconimageView.width / 2, y: iconimageView.height / 2, width: 0, height: 0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        iconimageView.image = nil
    }
    
    func configure(with viewModel: SearchResultCellViewModel){
        titleLabel.text = viewModel.title
        subTitleLabel.text = viewModel.subTitle
        iconimageView.sd_setImage(with: viewModel.imageUrl) {[weak self] _,_,_,_ in
            self?.activityIndicator.stopAnimating()
        }
        
        iconimageView.layer.cornerRadius = viewModel.subTitle == nil ? (contentView.height - 10) / 2 : 0
    }
    
}
