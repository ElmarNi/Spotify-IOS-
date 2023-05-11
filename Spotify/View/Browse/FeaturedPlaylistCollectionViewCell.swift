//
//  FeaturedPlaylistCollectionViewCell.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 08.05.23.
//

import UIKit
import SDWebImage

class FeaturedPlaylistCollectionViewCell: UICollectionViewCell {
    static let identifier = "FeaturedPlaylistCollectionViewCell"
    
    private let playlistCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let playlistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let creatorNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .thin)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
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
        contentView.clipsToBounds = true
        contentView.addSubview(playlistCoverImageView)
        contentView.addSubview(playlistNameLabel)
        contentView.addSubview(creatorNameLabel)
        playlistCoverImageView.addSubview(activityIndicator)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        creatorNameLabel.sizeToFit()
        playlistNameLabel.sizeToFit()
        
        let imageSize = contentView.height - 70

        playlistCoverImageView.frame = CGRect(x: (contentView.width - imageSize) / 2,
                                              y: 3,
                                              width: imageSize,
                                              height: imageSize)
        
        playlistNameLabel.frame = CGRect(x: 3,
                                         y: playlistCoverImageView.bottom + 3,
                                         width: contentView.width - 6,
                                         height: playlistNameLabel.height)
        
        creatorNameLabel.frame = CGRect(x: 3,
                                        y: playlistNameLabel.bottom + 6,
                                        width: contentView.width - 6,
                                        height: creatorNameLabel.height)
        
        activityIndicator.frame = CGRect(x: playlistCoverImageView.width / 2, y: playlistCoverImageView.height / 2, width: 0, height: 0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playlistNameLabel.text = nil
        creatorNameLabel.text = nil
        playlistCoverImageView.image = nil
    }
    
    func configure(with viewModel: FeaturedPlaylistsCellViewModel){
        playlistNameLabel.text = viewModel.name
        creatorNameLabel.text = viewModel.creatorName
        playlistCoverImageView.sd_setImage(with: viewModel.artworkUrl) {[weak self] _,_,_,_ in
            self?.activityIndicator.stopAnimating()
        }
    }
}
