//
//  PlayerViewController.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 01.05.23.
//

import UIKit
import SDWebImage

protocol PlayerViewControllerDelegate:AnyObject{
    func didTapPlayPause(_ playerControlsView: PlayerControlsView)
    func didTapBack(_ playerControlsView: PlayerControlsView, _ playerViewController: PlayerViewController)
    func didTapNext(_ playerControlsView: PlayerControlsView, _ playerViewController: PlayerViewController)
    func viewClosed(_ playerControlsView: PlayerControlsView)
    func playerControlsViewSliderValueChanged(_ playerControlsView: PlayerControlsView, _ playBackSlider: UISlider)
}

class PlayerViewController: UIViewController {

    weak var dataSource: PlayerDataSource?
    weak var delegate: PlayerViewControllerDelegate?
    
    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
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
    
    let playerControls = PlayerControlsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(coverImageView)
        view.addSubview(playerControls)
        coverImageView.addSubview(activityIndicator)
        playerControls.delegate = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                           target: self,
                                                           action: #selector(didTapClose))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                                           target: self,
                                                           action: #selector(didTapAction))
        
        configure()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let nameLabel = dataSource?.name ?? ""
        let nameLabelHeight = nameLabel.getHeightForLabel(font: UIFont.systemFont(ofSize: 20, weight: .semibold),
                                    width: (UIScreen.main.bounds.width - 40))
        
        let subTitleLabel = dataSource?.subTitle ?? ""
        let subTitleLabelHeight = subTitleLabel.getHeightForLabel(font: UIFont.systemFont(ofSize: 18, weight: .regular),
                                    width: (UIScreen.main.bounds.width - 40))
        
        let playerControlsHeight = subTitleLabelHeight + nameLabelHeight + 205
        
        playerControls.frame = CGRect(x: 10,
                                      y: view.height - playerControlsHeight - 10,
                                      width: view.width - 20,
                                      height: playerControlsHeight)
        
        let coverImageViewHeight = view.height - playerControlsHeight - 10 - view.safeAreaInsets.top
        coverImageView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: coverImageViewHeight)
        activityIndicator.frame = CGRect(x: coverImageView.width / 2, y: coverImageView.height / 2, width: 0, height: 0)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        delegate?.viewClosed(playerControls)
        playerControls.setAudioSessionToFalse()
    }
    
    func refreshUI(){
        configure()
    }
    
    private func configure(){
        coverImageView.sd_setImage(with: dataSource?.imageUrl){[weak self] _,_,_,_ in
            self?.activityIndicator.stopAnimating()
        }
        playerControls.configure(with: PlayerControlsViewModel(title: dataSource?.name,
                                                               subTitle: dataSource?.subTitle,
                                                               duration: dataSource?.duration ?? 0))
        
    }
    
    @objc func didTapClose(){
        dismiss(animated: true)
    }
    
    @objc func didTapAction(){
        guard let url = URL(string: dataSource?.external_urls?["spotify"] ?? "") else { return }
        let activityController = UIActivityViewController(activityItems: [url], applicationActivities: [])
        activityController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(activityController, animated: true)
    }

}

extension PlayerViewController: PlayerControlsViewDelegate {
    
    func playerControlsViewDidTapPlayPauseButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapPlayPause(playerControlsView)
    }
    
    func playerControlsViewDidTapNextButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapNext(playerControlsView, self)
    }
    
    func playerControlsViewDidTapBackButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapBack(playerControlsView, self)
    }
    
    func playerControlsViewSliderValueChanged(_ playerControlsView: PlayerControlsView, _ playBackSlider: UISlider) {
        delegate?.playerControlsViewSliderValueChanged(playerControlsView, playBackSlider)
    }
    
}
