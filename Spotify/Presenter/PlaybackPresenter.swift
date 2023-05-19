//
//  PlaybackPresenter.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 16.05.23.
//

import Foundation
import UIKit
import AVFoundation

protocol PlayerDataSource: AnyObject{
    var name: String? { get }
    var subTitle: String? { get }
    var imageUrl: URL? { get }
    var external_urls: [String: String]? { get }
}

protocol PlaybackPresenterDelegate: AnyObject{
    func playerItemDidPlayToEndTime()
}

final class PlaybackPresenter {
    
    static let shared = PlaybackPresenter()
    
    weak var delegate: PlaybackPresenterDelegate?
    private var track: AudioTrack?
    private var tracks = [AudioTrack]()
    private var index = 0
    
    var currentTrack: AudioTrack? {
        
        if let track = track, tracks.isEmpty{
            return track
        }
        else if !tracks.isEmpty {
            return tracks[index]
        }
        else{
            return nil
        }
        
    }
    
    var player: AVPlayer?
    var playerQueue: AVQueuePlayer?
    private var playerViewController: PlayerViewController?
    
    func startPlayback(from viewController: UIViewController, track: AudioTrack){
        
        guard let url = URL(string: track.preview_url ?? "") else {
//            let alert = UIAlertController(title: "Error", message: "Song hasn't a preview", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
//            viewController.present(alert, animated: true)
            return
        }
        
        player = AVPlayer(url: url)
        player?.volume = 0.5
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)
        
        let playerViewController = PlayerViewController()
        playerViewController.title = track.name
        playerViewController.dataSource = self
        playerViewController.delegate = self
        
        viewController.present(UINavigationController(rootViewController: playerViewController), animated: true) { [weak self] in
            self?.player?.play()
        }
        
        self.track = track
        self.tracks = []
    }
    
    func startPlayback(from viewController: UIViewController, tracks: [AudioTrack]){
        
        let playerViewController = PlayerViewController()
        playerViewController.dataSource = self
        playerViewController.delegate = self
        self.playerViewController = playerViewController
        
        self.track = nil
        self.tracks = tracks
        
        playerQueue = AVQueuePlayer(items: tracks.compactMap({
            guard let url = URL(string: $0.preview_url ?? "") else { return nil }
            return AVPlayerItem(url: url)
        }))
        
        
        
        playerQueue?.items().forEach({
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(playerDidFinishPlaying),
                                                   name: .AVPlayerItemDidPlayToEndTime,
                                                   object: $0)
        })
        
        playerQueue?.volume = 0.5
        
        guard playerQueue?.items().count != 0 else {
//            let alert = UIAlertController(title: "Error", message: "Album hasn't any song with preview", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
//            viewController.present(alert, animated: true)
            return
        }
        
        viewController.present(UINavigationController(rootViewController: playerViewController), animated: true) { [weak self] in
            self?.playerQueue?.play()
        }
        
    }
    
    @objc private func playerDidFinishPlaying(){
        
        if let player = player {
            delegate?.playerItemDidPlayToEndTime()
            player.seek(to: CMTime.zero)
        }
        
        if let playerQueue = playerQueue {
            print("l")
            if index < (tracks.count - 1) {
                index += 1
                playerViewController?.refreshUI()
            }
            else{
                
                self.playerQueue = AVQueuePlayer(items: tracks.compactMap({
                    guard let url = URL(string: $0.preview_url ?? "") else { return nil }
                    return AVPlayerItem(url: url)
                }))
                
                index = 0
                playerViewController?.refreshUI()
                delegate?.playerItemDidPlayToEndTime()
                playerQueue.pause()
                
                guard let playerQueue = self.playerQueue else { return }
                
                playerQueue.items().forEach({
                    NotificationCenter.default.addObserver(self,
                                                           selector: #selector(playerDidFinishPlaying),
                                                           name: .AVPlayerItemDidPlayToEndTime,
                                                           object: $0)
                })
            }
        }
    }

}

extension PlaybackPresenter: PlayerDataSource{
    var name: String? {
        return currentTrack?.name
    }
    
    var subTitle: String? {
        return currentTrack?.artists.first?.name
    }
    
    var imageUrl: URL? {
        return URL(string: currentTrack?.album?.images.first?.url ?? "")
    }
    
    var external_urls: [String: String]? {
        return currentTrack?.external_urls
    }
}

extension PlaybackPresenter: PlayerViewControllerDelegate {
    
    func didTapPlayPause(_ playerControlsView: PlayerControlsView) {
        
        if let player = player {
            if player.timeControlStatus == .playing {
                player.pause()
            }
            else{
                player.play()
            }
        }
        
        if let playerQueue = playerQueue {
            if playerQueue.timeControlStatus == .playing {
                playerQueue.pause()
            }
            else{
                playerQueue.play()
            }
        }
        
        playerControlsView.changePlayPauseButtonImage()
        
    }
    
    func didTapBack(_ playerControlsView: PlayerControlsView, _ playerViewController: PlayerViewController) {
        
        if let player = player {
            if player.timeControlStatus == .paused {
                playerControlsView.changePlayPauseButtonImage()
            }
            player.seek(to: CMTime.zero)
            player.play()
        }
        
        if let playerQueue = playerQueue {
            if index > 0 {
                index -= 1
                let track = tracks[index]
                guard let url = URL(string: track.preview_url ?? ""), let currentItem = playerQueue.currentItem else { return }
                
                playerQueue.replaceCurrentItem(with: AVPlayerItem(url: url))
                currentItem.seek(to: CMTime.zero, completionHandler: nil)
                playerQueue.insert(currentItem, after: playerQueue.currentItem)
                
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(playerDidFinishPlaying),
                                                       name: .AVPlayerItemDidPlayToEndTime,
                                                       object: playerQueue.currentItem)
                
                playerViewController.refreshUI()
                
                if playerQueue.timeControlStatus == .paused {
                    playerControlsView.changePlayPauseButtonImage()
                    playerQueue.play()
                }
            }
            else{
                playerQueue.seek(to: CMTime.zero)
                if playerQueue.timeControlStatus == .paused {
                    playerControlsView.changePlayPauseButtonImage()
                    playerQueue.play()
                }
            }
        }
        
    }
    
    func didTapNext(_ playerControlsView: PlayerControlsView, _ playerViewController: PlayerViewController) {
        
        if let player = player {
            if player.timeControlStatus == .playing {
                playerControlsView.changePlayPauseButtonImage()
            }
            player.pause()
        }
        
        if let playerQueue = playerQueue {
            if index < (tracks.count - 1) {
                playerQueue.advanceToNextItem()
                index += 1
                playerViewController.refreshUI()
                if playerQueue.timeControlStatus == .paused {
                    playerControlsView.changePlayPauseButtonImage()
                    playerQueue.play()
                }
            }
            else{
                if playerQueue.timeControlStatus == .playing {
                    playerControlsView.changePlayPauseButtonImage()
                }
                playerQueue.pause()
            }
        }
        
    }
    
    func viewClosed(_ playerControlsView: PlayerControlsView) {
        if let player = player {
            if player.timeControlStatus == .playing {
                playerControlsView.changePlayPauseButtonImage()
            }
            player.pause()
        }
        
        if let playerQueue = playerQueue {
            if playerQueue.timeControlStatus == .playing {
                playerControlsView.changePlayPauseButtonImage()
            }
            playerQueue.pause()
            playerQueue.removeAllItems()
        }
        
        self.player = nil
        self.playerQueue = nil
        index = 0
    }
    
    func didSlideSlider(_ value: Float) {
        
        if let player = player {
            player.volume = value
        }
        
        if let playerQueue = playerQueue {
            playerQueue.volume = value
        }
        
    }
    
}
