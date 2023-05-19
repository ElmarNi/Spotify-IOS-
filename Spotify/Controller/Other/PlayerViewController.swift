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
    func didSlideSlider(_ value: Float)
}

class PlayerViewController: UIViewController {

    weak var dataSource: PlayerDataSource?
    weak var delegate: PlayerViewControllerDelegate?
    
    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.tintColor = .label
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    private let playerControls = PlayerControlsView()
    
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
        coverImageView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.width)
        playerControls.frame = CGRect(x: 10,
                                      y: coverImageView.bottom + 10,
                                      width: view.width - 20,
                                      height: (view.height - coverImageView.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - 10))
        activityIndicator.frame = CGRect(x: coverImageView.width / 2, y: coverImageView.height / 2, width: 0, height: 0)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        delegate?.viewClosed(playerControls)
    }
    
    func refreshUI(){
        configure()
    }
    
    private func configure(){
        coverImageView.sd_setImage(with: dataSource?.imageUrl){[weak self] _,_,_,_ in
            self?.activityIndicator.stopAnimating()
        }
        playerControls.configure(with: PlayerControlsViewModel(title: dataSource?.name, subTitle: dataSource?.subTitle))
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

extension PlayerViewController: PlayerControlsViewDelegate{
    
    func playerControlsView(_ playerControlsView: PlayerControlsView, didSlideSlider value: Float) {
        delegate?.didSlideSlider(value)
    }
    
    func playerControlsViewDidTapPlayPauseButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapPlayPause(playerControlsView)
    }
    
    func playerControlsViewDidTapNextButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapNext(playerControlsView, self)
    }
    
    func playerControlsViewDidTapBackButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapBack(playerControlsView, self)
    }
    
}
