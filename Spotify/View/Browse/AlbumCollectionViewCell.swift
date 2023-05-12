//
//  AlbumCollectionViewCell.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 12.05.23.
//

import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {
    static let identifier = "AlbumCollectionViewCell"
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(trackNameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        trackNameLabel.sizeToFit()
        
        trackNameLabel.frame = CGRect(x: 10,
                                      y: (contentView.height - trackNameLabel.height) / 2,
                                      width: contentView.width,
                                      height: trackNameLabel.height)
        }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackNameLabel.text = nil
    }
    
    func configure(with viewModel: AlbumCellViewModel){
        trackNameLabel.text = viewModel.name
    }
}
