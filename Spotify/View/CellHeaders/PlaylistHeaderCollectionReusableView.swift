//
//  PlaylistHeaderCollectionReusableView.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 11.05.23.
//

import UIKit
import SDWebImage

class PlaylistHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "PlaylistHeaderCollectionReusableView"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let ownerNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .light)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(nameLabel)
        addSubview(descriptionLabel)
        addSubview(ownerNameLabel)
        addSubview(coverImageView)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        descriptionLabel.sizeToFit()
        nameLabel.sizeToFit()
        ownerNameLabel.sizeToFit()
        
        let imageSize: CGFloat = width / 1.5
        let descriptionLabelHeight = descriptionLabel.text?.getHeightForLabel(font: UIFont.systemFont(ofSize: 18, weight: .regular))
        let nameLabelHeight = nameLabel.text?.getHeightForLabel(font: UIFont.systemFont(ofSize: 22, weight: .semibold))
        let ownerNameLabelHeight = ownerNameLabel.text?.getHeightForLabel(font: UIFont.systemFont(ofSize: 18, weight: .light))

        coverImageView.frame = CGRect(x: (width - imageSize) / 2, y: 20, width: imageSize, height: imageSize)
        nameLabel.frame = CGRect(x: 10, y: coverImageView.bottom + 10, width: width - 20, height: nameLabelHeight ?? 20)
        descriptionLabel.frame = CGRect(x: 10, y: nameLabel.bottom + 10, width: width - 20, height: descriptionLabelHeight ?? 50)
        ownerNameLabel.frame = CGRect(x: 10, y: descriptionLabel.bottom + 10, width: width - 20, height: ownerNameLabelHeight ?? 20)
    }
    
    func configure(with viewModel: PlaylistHeaderViewModel){
        nameLabel.text = viewModel.name
        ownerNameLabel.text = viewModel.ownerName
        descriptionLabel.text = viewModel.description
        coverImageView.sd_setImage(with: viewModel.artworkUrl)
    }
}
