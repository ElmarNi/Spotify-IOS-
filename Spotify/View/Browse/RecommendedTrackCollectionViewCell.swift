//
//  RecommendedTrackCollectionViewCell.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 08.05.23.
//

import UIKit

class RecommendedTrackCollectionViewCell: UICollectionViewCell {
    static let identifier = "RecommendedTrackCollectionViewCell"
    
    private let albumCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 1
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .thin)
        label.numberOfLines = 1
        return label
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
        contentView.clipsToBounds = true
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(albumCoverImageView)
        stackView.addSubview(trackNameLabel)
        stackView.addSubview(artistNameLabel)
        contentView.addSubview(stackView)
        albumCoverImageView.addSubview(activityIndicator)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        trackNameLabel.sizeToFit()
        artistNameLabel.sizeToFit()
        
        let imageSize = contentView.height - 4
        
        albumCoverImageView.frame = CGRect(x: 5,
                                           y: 2,
                                           width: imageSize,
                                           height: imageSize)
        
        stackView.frame = CGRect(x: albumCoverImageView.right + 5,
                                 y: (contentView.height - trackNameLabel.height - artistNameLabel.height) / 2,
                                 width: contentView.width - albumCoverImageView.width - 15,
                                 height: trackNameLabel.height + artistNameLabel.height)
        
        trackNameLabel.frame = CGRect(x: 0,
                                      y: 0,
                                      width: stackView.width,
                                      height: trackNameLabel.height)
        
        artistNameLabel.frame = CGRect(x: 0,
                                       y: trackNameLabel.bottom,
                                       width: stackView.width,
                                       height: artistNameLabel.height)
        
        activityIndicator.frame = CGRect(x: albumCoverImageView.width / 2, y: albumCoverImageView.height / 2, width: 0, height: 0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackNameLabel.text = nil
        artistNameLabel.text = nil
        albumCoverImageView.image = nil
    }
    
    func configure(with viewModel: RecommendedTracksCellViewModel){
        trackNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
        albumCoverImageView.sd_setImage(with: viewModel.artworkUrl) {[weak self] _,_,_,_ in
            self?.activityIndicator.stopAnimating()
        }
    }
}
