//
//  PlayerControlsView.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 17.05.23.
//

import Foundation
import UIKit

protocol PlayerControlsViewDelegate: AnyObject{
    func playerControlsViewDidTapPlayPauseButton(_ playerControlsView: PlayerControlsView)
    func playerControlsViewDidTapNextButton(_ playerControlsView: PlayerControlsView)
    func playerControlsViewDidTapBackButton(_ playerControlsView: PlayerControlsView)
    func playerControlsView(_ playerControlsView: PlayerControlsView, didSlideSlider value: Float)
}

final class PlayerControlsView:UIView {
    
    weak var delegate: PlayerControlsViewDelegate?
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "backward.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "pause", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "forward.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let volumeSlider: UISlider = {
        let slider = UISlider()
        slider.value = 0.5
        return slider
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(volumeSlider)
        addSubview(nameLabel)
        addSubview(subTitleLabel)
        addSubview(backButton)
        addSubview(playPauseButton)
        addSubview(nextButton)
        clipsToBounds = true
        backgroundColor = .clear
        
        PlaybackPresenter.shared.delegate = self
        
        volumeSlider.addTarget(self, action: #selector(didSlideSlider(_:)), for: .valueChanged)
        playPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.sizeToFit()
        subTitleLabel.sizeToFit()
        
        
        nameLabel.frame = CGRect(x: 10, y: 10, width: width - 20, height: min(nameLabel.height, 50))
        subTitleLabel.frame = CGRect(x: 10, y: nameLabel.bottom, width: width - 20, height: min(subTitleLabel.height, 50))
        
        let buttonSize: CGFloat = 60
        playPauseButton.frame = CGRect(x: (width - buttonSize) / 2, y: height - buttonSize - 60, width: buttonSize, height: 34)
        backButton.frame = CGRect(x: ((width - buttonSize) / 2) - buttonSize - 20, y: height - buttonSize - 60, width: buttonSize, height: 34)
        nextButton.frame = CGRect(x: playPauseButton.right + 20, y: height - buttonSize - 60, width: buttonSize, height: 34)
        
        volumeSlider.frame = CGRect(x: 10, y: playPauseButton.bottom + 20, width: width - 20, height: 34)
    }
    
}

extension PlayerControlsView: PlaybackPresenterDelegate{
    
    func playerItemDidPlayToEndTime() {
        changePlayPauseButtonImage()
    }
    
    @objc private func didSlideSlider(_ slider: UISlider){
        let value = slider.value
        delegate?.playerControlsView(self, didSlideSlider: value)
    }
    
    @objc private func didTapPlayPause(){
        delegate?.playerControlsViewDidTapPlayPauseButton(self)
    }
    
    @objc private func didTapNext(){
        delegate?.playerControlsViewDidTapNextButton(self)
    }
    
    @objc private func didTapBack(){
        delegate?.playerControlsViewDidTapBackButton(self)
    }
    
    func configure(with viewModel: PlayerControlsViewModel){
        nameLabel.text = viewModel.title
        subTitleLabel.text = viewModel.subTitle
    }
    
    func changePlayPauseButtonImage(){
        let pauseImage = UIImage(systemName: "pause", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        let playImage = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        playPauseButton.setImage(playPauseButton.currentImage == pauseImage ? playImage : pauseImage, for: .normal)
    }
    
}
