//
//  AlbumHeaderCollectionReusableView.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 12.05.23.
//

import UIKit
import SDWebImage

protocol AlbumHeaderCollectionReusableViewDelegate: AnyObject{
    func albumHeaderCollectionReusableViewDidTapPlay(_ header: AlbumHeaderCollectionReusableView)
}

class AlbumHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "AlbumHeaderCollectionReusableView"
    
    weak var delegate: AlbumHeaderCollectionReusableViewDelegate?
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
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
        stackView.addSubview(dateLabel)
        stackView.addSubview(artistNameLabel)
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
        delegate?.albumHeaderCollectionReusableViewDidTapPlay(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dateLabel.sizeToFit()
        nameLabel.sizeToFit()
        artistNameLabel.sizeToFit()
        stackView.sizeToFit()
        
        let imageSize: CGFloat = width / 1.5
        
        let dateLabelHeight = dateLabel.text?.getHeightForLabel(font: UIFont.systemFont(ofSize: 16, weight: .regular),
                                                                              width: (width - 80)) ?? 20
        
        let nameLabelHeight = nameLabel.text?.getHeightForLabel(font: UIFont.systemFont(ofSize: 22, weight: .semibold),
                                                                width: (width - 80)) ?? 20
        
        let artistNameLabelHeight = artistNameLabel.text?.getHeightForLabel(font: UIFont.systemFont(ofSize: 18, weight: .light),
                                                                          width: (width - 80)) ?? 20

        coverImageView.frame = CGRect(x: (width - imageSize) / 2, y: 20, width: imageSize, height: imageSize)
        stackView.frame = CGRect(x: 0, y: coverImageView.bottom + 10, width: width, height: (dateLabelHeight + nameLabelHeight + dateLabelHeight + 20))
        nameLabel.frame = CGRect(x: 10, y: 0, width: width - 80, height: nameLabelHeight)
        artistNameLabel.frame = CGRect(x: 10, y: nameLabel.bottom + 10, width: width - 80, height: artistNameLabelHeight)
        dateLabel.frame = CGRect(x: 10, y: artistNameLabel.bottom + 10, width: width - 80, height: dateLabelHeight)
        playButton.frame = CGRect(x: stackView.width - 60, y: (stackView.height - 50) / 2, width: 50, height: 50)
        activityIndicator.frame = CGRect(x: coverImageView.width / 2, y: coverImageView.height / 2, width: 0, height: 0)
    }
    
    func configure(with viewModel: AlbumHeaderViewModel){
        nameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
        dateLabel.text = viewModel.date
        coverImageView.sd_setImage(with: viewModel.artworkUrl){[weak self] _,_,_,_ in
            self?.activityIndicator.stopAnimating()
        }
    }
}
