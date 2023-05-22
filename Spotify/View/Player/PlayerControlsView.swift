//
//  PlayerControlsView.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 17.05.23.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer

protocol PlayerControlsViewDelegate: AnyObject{
    func playerControlsViewDidTapPlayPauseButton(_ playerControlsView: PlayerControlsView)
    func playerControlsViewDidTapNextButton(_ playerControlsView: PlayerControlsView)
    func playerControlsViewDidTapBackButton(_ playerControlsView: PlayerControlsView)
    func playerControlsViewSliderValueChanged(_ playerControlsView: PlayerControlsView, _ playBackSlider: UISlider)
}

final class PlayerControlsView: UIView {
    
    weak var delegate: PlayerControlsViewDelegate?
    private var outputVolumeObserve: NSKeyValueObservation?
    private let audioSession = AVAudioSession.sharedInstance()
    
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
    
    private let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "00:00"
        return label
    }()
    
    private let overallDurationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private let playBackSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = .label
        slider.minimumValue = 0
        return slider
    }()
    
    private let stackViewDuration: UIStackView = {
        let stackView = UIStackView()
        return stackView
    }()
    
    private let volumeDown: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "speaker.wave.1.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let volumeUp: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "speaker.wave.3.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let volumeSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = .label
        slider.minimumValue = 0
        slider.maximumValue = 1
        return slider
    }()
    
    private let stackViewVolume: UIStackView = {
        let stackView = UIStackView()
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        backgroundColor = .clear
        
        addSubview(nameLabel)
        addSubview(subTitleLabel)
        addSubview(backButton)
        addSubview(playPauseButton)
        addSubview(nextButton)
        stackViewVolume.addSubview(volumeSlider)
        stackViewVolume.addSubview(volumeUp)
        stackViewVolume.addSubview(volumeDown)
        addSubview(stackViewVolume)
        stackViewDuration.addSubview(currentTimeLabel)
        stackViewDuration.addSubview(overallDurationLabel)
        stackViewDuration.addSubview(playBackSlider)
        addSubview(stackViewDuration)
        
        PlaybackPresenter.shared.delegate = self
        
        playPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        playBackSlider.addTarget(self, action: #selector(playBackSliderValueChanged), for: .valueChanged)
        volumeUp.addTarget(self, action: #selector(didTapVolumeUp), for: .touchUpInside)
        volumeDown.addTarget(self, action: #selector(didTapVolumeDown), for: .touchUpInside)
        volumeSlider.addTarget(self, action: #selector(volumeSliderValueChange), for: .valueChanged)
        
        try? audioSession.setActive(true)
        volumeSlider.value = audioSession.outputVolume
        outputVolumeObserve = audioSession.observe(\.outputVolume) {[weak self] (audioSession, changes) in
            self?.volumeSlider.value = audioSession.outputVolume
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setUpNameLabelsUI()
        setUpVolumeUI()
        setUpControlButtonsUI()
        setUpDurationUI()
    }
    
}

extension PlayerControlsView {
    
    @objc private func didTapPlayPause(){
        delegate?.playerControlsViewDidTapPlayPauseButton(self)
    }
    
    @objc private func didTapNext(){
        delegate?.playerControlsViewDidTapNextButton(self)
    }
    
    @objc private func didTapBack(){
        delegate?.playerControlsViewDidTapBackButton(self)
    }
    
    @objc private func playBackSliderValueChanged(){
        delegate?.playerControlsViewSliderValueChanged(self, playBackSlider)
    }
    
    @objc private func didTapVolumeUp(){
        MPVolumeView.shared.volumeUp()
    }
    
    @objc private func didTapVolumeDown(){
        MPVolumeView.shared.volumeDown()
    }
    
    @objc private func volumeSliderValueChange(){
        MPVolumeView.shared.setVolume(volumeSlider.value)
    }
    
    private func setUpDurationUI(){
        currentTimeLabel.sizeToFit()
        overallDurationLabel.sizeToFit()
        playBackSlider.sizeToFit()
        
        stackViewDuration.frame = CGRect(x: 0, y: playPauseButton.top - playBackSlider.height - 20, width: width, height: playBackSlider.height)
        currentTimeLabel.frame = CGRect(x: 10,
                                        y: (stackViewDuration.height - 20) / 2,
                                        width: 46, height: 20)
        overallDurationLabel.frame = CGRect(x: stackViewDuration.width - overallDurationLabel.width - 10,
                                            y: (stackViewDuration.height - 20) / 2,
                                            width: 46, height: 20)
        playBackSlider.frame = CGRect(x: currentTimeLabel.right + 10,
                                      y: (stackViewDuration.height - playBackSlider.height) / 2,
                                      width: stackViewDuration.width - currentTimeLabel.right - overallDurationLabel.width - 30,
                                      height: playBackSlider.height)
    }
    
    private func setUpControlButtonsUI(){
        let yAxisForButtons = stackViewVolume.top - 54
        let buttonSize: CGFloat = 60
        
        playPauseButton.frame = CGRect(x: (width - buttonSize) / 2, y: yAxisForButtons, width: buttonSize, height: 34)
        backButton.frame = CGRect(x: ((width - buttonSize) / 2) - buttonSize - 20, y: yAxisForButtons, width: buttonSize, height: 34)
        nextButton.frame = CGRect(x: playPauseButton.right + 20, y: yAxisForButtons, width: buttonSize, height: 34)
    }
    
    private func setUpVolumeUI(){
        volumeSlider.sizeToFit()
        
        stackViewVolume.frame = CGRect(x: 0, y: height - 50, width: width, height: volumeSlider.height)
        volumeDown.frame = CGRect(x: 10, y: (stackViewVolume.height - 23) / 2, width: 23, height: 23)
        volumeUp.frame = CGRect(x: stackViewVolume.width - 42, y: (stackViewVolume.height - 23) / 2, width: 32, height: 23)
        volumeSlider.frame = CGRect(x: volumeDown.right + 10,
                                    y: (stackViewVolume.height - volumeSlider.height) / 2,
                                    width: stackViewVolume.width - volumeDown.right - volumeUp.width - 30,
                                    height: volumeSlider.height)
    }
    
    private func setUpNameLabelsUI()
    {
        nameLabel.sizeToFit()
        subTitleLabel.sizeToFit()

        nameLabel.frame = CGRect(x: 10, y: 10, width: width - 20, height: min(nameLabel.height, 50))
        subTitleLabel.frame = CGRect(x: 10, y: nameLabel.bottom, width: width - 20, height: min(subTitleLabel.height, 50))
    }
    
    func configure(with viewModel: PlayerControlsViewModel){
        nameLabel.text = viewModel.title
        subTitleLabel.text = viewModel.subTitle
        overallDurationLabel.text = stringFromTimeInterval(interval: viewModel.duration)
        playBackSlider.maximumValue = Float(viewModel.duration)
    }
    
    func changePlayPauseButtonImage(){
        let pauseImage = UIImage(systemName: "pause", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        let playImage = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        playPauseButton.setImage(playPauseButton.currentImage == pauseImage ? playImage : pauseImage, for: .normal)
    }
    
    func changePlayBackSliderValue(value: Float){
        if !playBackSlider.isTouchInside{
            playBackSlider.value = value
        }
    }
    
    func changeCurrentTimeLabelText(text: String?){
        currentTimeLabel.text = text
    }
    
    func setAudioSessionToFalse(){
        try? audioSession.setActive(false)
    }
    
}

extension PlayerControlsView: PlaybackPresenterDelegate {
    
    func playerItemDidPlayToEndTime() {
        changePlayPauseButtonImage()
    }

}
