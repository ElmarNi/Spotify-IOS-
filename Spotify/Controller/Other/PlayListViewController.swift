//
//  PlayListViewController.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 01.05.23.
//

import UIKit
import SDWebImage

class PlayListViewController: UIViewController {
    
    private let playlist: PlayList
    private var viewModels = [RecommendedTracksCellViewModel]()
    private var tracks = [AudioTrack]()
    public var isOwner = false
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.tintColor = .label
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    private var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    init(playlist: PlayList) {
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout  = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.frame.width, height: 60)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        title = playlist.name
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        
        collectionView.isHidden = true
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(RecommendedTrackCollectionViewCell.self,
                                forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        
        collectionView.register(PlaylistHeaderCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier)
        
        APICaller.shared.getPlaylistDetails(for: playlist) {[weak self] result in
            DispatchQueue.main.async {
                switch result{
                case .success(let model):
                    
                    self?.viewModels = model.tracks.items.compactMap({
                        RecommendedTracksCellViewModel(
                            name: $0.track.name,
                            artworkUrl: URL(string: $0.track.album?.images.first?.url ?? ""),
                            artistName: $0.track.artists.first?.name ?? "")
                    })
                    
                    self?.tracks = model.tracks.items.compactMap({ $0.track })
                    
                    self?.collectionView.reloadData()
                    self?.collectionView.isHidden = false
                    self?.activityIndicator.stopAnimating()
                    
                case .failure(_):
                    showAlert(message: "Something went wrong when getting data", title: "Error", target: self)
                }
            }
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShare))
        addLongTapGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        activityIndicator.center = view.center
    }
    
    
    private func addLongTapGesture(){
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        collectionView.addGestureRecognizer(gesture)
    }
    
    @objc private func didTapShare(){
        guard let url = URL(string: playlist.external_urls["spotify"] ?? "") else { return }
        let activityController = UIActivityViewController(activityItems: [url], applicationActivities: [])
        activityController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(activityController, animated: true)
    }
    
    @objc private func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began, isOwner {
            let touchPoint = gesture.location(in: collectionView)
            guard let indexPath = collectionView.indexPathForItem(at: touchPoint) else { return }
            
            let model = tracks[indexPath.row]
            let alertController = UIAlertController(title: model.name,
                                                    message: "Would you like to remove this from a playlist?",
                                                    preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alertController.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: {[weak self] _ in
                guard let strongSelf = self else { return }
                APICaller.shared.removeTrackFromPlaylist(track: model, playlist: strongSelf.playlist) {success in
                    DispatchQueue.main.async{
                        if success {
                            strongSelf.tracks.remove(at: indexPath.row)
                            strongSelf.viewModels.remove(at: indexPath.row)
                            strongSelf.collectionView.reloadData()
                            showAlert(message: "Track successfully removed to playlist", title: "Success", target: strongSelf)
                            HapticsManager.shared.vibrate(for: .success)
                        }
                        else {
                            showAlert(message: "Something went wrong when removing track to playlist", title: "Error", target: strongSelf)
                            HapticsManager.shared.vibrate(for: .error)
                        }
                    }
                }
            }))
            present(alertController, animated: true)
            HapticsManager.shared.vibrateForSelection()
        }
    }
    
    @objc func didTapClose(){
        dismiss(animated: true)
    }
}

extension PlayListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PlaylistHeaderCollectionReusableViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier,
            for: indexPath) as? RecommendedTrackCollectionViewCell else {
            return UICollectionViewCell()
        }
        let model = viewModels[indexPath.row]
        cell.configure(with: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier,
            for: indexPath) as? PlaylistHeaderCollectionReusableView,
              kind == UICollectionView.elementKindSectionHeader else{
            return UICollectionReusableView()
        }
        
        header.configure(with: PlaylistHeaderViewModel(name: playlist.name,
                                                       description: playlist.description,
                                                       ownerName: playlist.owner.display_name,
                                                       artworkUrl: URL(string: playlist.images.first?.url ?? "")))
        header.delegate = self
        
        return header
    }
    
    func playlistHeaderCollectionReusableViewDidTapPlay(_ header: PlaylistHeaderCollectionReusableView) {
        PlaybackPresenter.shared.startPlayback(from: self, tracks: self.tracks)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        var descriptionLabelHeight = playlist.description.getHeightForLabel(font: UIFont.systemFont(ofSize: 18, weight: .regular),
                                                                            width: (UIScreen.main.bounds.width - 80))
        var nameLabelHeight = playlist.name.getHeightForLabel(font: UIFont.systemFont(ofSize: 22, weight: .semibold),
                                                              width: (UIScreen.main.bounds.width - 80))
        var ownerNameLabelHeight = playlist.owner.display_name.getHeightForLabel(font: UIFont.systemFont(ofSize: 18, weight: .light),
                                                                                 width: (UIScreen.main.bounds.width - 80))
        
        if descriptionLabelHeight <= 0 { descriptionLabelHeight = 50 }
        if nameLabelHeight <= 0 { nameLabelHeight = 20 }
        if ownerNameLabelHeight <= 0 { ownerNameLabelHeight = 20 }
        
        return CGSize(width: view.width, height: (view.width / 1.5) + (nameLabelHeight + descriptionLabelHeight + ownerNameLabelHeight) + 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        collectionView.deselectItem(at: indexPath, animated: true)
        PlaybackPresenter.shared.startPlayback(from: self, track: self.tracks[indexPath.row])
    }
    
}
