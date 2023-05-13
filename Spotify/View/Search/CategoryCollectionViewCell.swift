//
//  CategoryCollectionViewCell.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 13.05.23.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    static let identifier = "CategoryCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .white
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 22, weight: .semibold)
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
        
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        contentView.addSubview(label)
        contentView.addSubview(imageView)
        imageView.addSubview(activityIndicator)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.sizeToFit()
        let imageSize = contentView.width / 3
        label.frame = CGRect(x: 10, y: contentView.height - label.height - 10, width: contentView.width - 20, height: label.height)
        imageView.frame = CGRect(x: (contentView.width - imageSize) - 10, y: 10, width: imageSize, height: imageSize)
        activityIndicator.frame = CGRect(x: imageView.width / 2, y: imageView.height / 2, width: 0, height: 0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        imageView.image = UIImage(systemName: "music.quarternote.3", withConfiguration: UIImage.SymbolConfiguration(pointSize: 50, weight: .regular))
    }
    
    func configure(with viewModel: CategoryCellViewModel){
        label.text = viewModel.title
        imageView.sd_setImage(with: viewModel.artworkUrl) {[weak self] _,_,_,_ in
            self?.activityIndicator.stopAnimating()
        }
        contentView.backgroundColor = generateRandomColor()
    }
    
    private func generateRandomColor() -> UIColor {
        let redValue = CGFloat(drand48())
        let greenValue = CGFloat(drand48())
        let blueValue = CGFloat(drand48())
        
        let randomColor = UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1.0)
            
        return randomColor
    }
}
