//
//  PlaylistHeaderCollectionReusableView.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 11.05.23.
//

import UIKit
import SDWebImage

protocol PlaylistHeaderCollectionReusableViewDelegate: AnyObject{
    func playlistHeaderCollectionReusableViewDidTapPlay(_ header: PlaylistHeaderCollectionReusableView)
}

class PlaylistHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "PlaylistHeaderCollectionReusableView"
    
    weak var delegate: PlaylistHeaderCollectionReusableViewDelegate?
    
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
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen
        let image = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        return button
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        return stackView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.tintColor = .label
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        
        stackView.addSubview(nameLabel)
        stackView.addSubview(descriptionLabel)
        stackView.addSubview(ownerNameLabel)
        stackView.addSubview(playButton)
        
        addSubview(stackView)
        addSubview(coverImageView)
        coverImageView.addSubview(activityIndicator)
        
        playButton.addTarget(self, action: #selector(didTapPlay), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc func didTapPlay(){
        delegate?.playlistHeaderCollectionReusableViewDidTapPlay(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        descriptionLabel.sizeToFit()
        nameLabel.sizeToFit()
        ownerNameLabel.sizeToFit()
        stackView.sizeToFit()
        
        let imageSize: CGFloat = width / 1.5
        
        let descriptionLabelHeight = descriptionLabel.text?.getHeightForLabel(font: UIFont.systemFont(ofSize: 18, weight: .regular),
                                                                              width: (width - 80)) ?? 50
        
        let nameLabelHeight = nameLabel.text?.getHeightForLabel(font: UIFont.systemFont(ofSize: 22, weight: .semibold),
                                                                width: (width - 80)) ?? 20
        
        let ownerNameLabelHeight = ownerNameLabel.text?.getHeightForLabel(font: UIFont.systemFont(ofSize: 18, weight: .light),
                                                                          width: (width - 80)) ?? 20

        coverImageView.frame = CGRect(x: (width - imageSize) / 2, y: 20, width: imageSize, height: imageSize)
        stackView.frame = CGRect(x: 0, y: coverImageView.bottom + 10, width: width, height: (descriptionLabelHeight + nameLabelHeight + ownerNameLabelHeight + 20))
        nameLabel.frame = CGRect(x: 10, y: 0, width: width - 80, height: nameLabelHeight)
        descriptionLabel.frame = CGRect(x: 10, y: nameLabel.bottom + 10, width: width - 80, height: descriptionLabelHeight)
        ownerNameLabel.frame = CGRect(x: 10, y: descriptionLabel.bottom + 10, width: width - 80, height: ownerNameLabelHeight)
        playButton.frame = CGRect(x: stackView.width - 60, y: (stackView.height - 50) / 2, width: 50, height: 50)
        activityIndicator.frame = CGRect(x: coverImageView.width / 2, y: coverImageView.height / 2, width: 0, height: 0)
    }
    
    func configure(with viewModel: PlaylistHeaderViewModel){
        nameLabel.text = viewModel.name
        ownerNameLabel.text = viewModel.ownerName
        descriptionLabel.text = viewModel.description
        coverImageView.sd_setImage(with: viewModel.artworkUrl){[weak self] _,_,_,_ in
            self?.activityIndicator.stopAnimating()
        }
    }
}
