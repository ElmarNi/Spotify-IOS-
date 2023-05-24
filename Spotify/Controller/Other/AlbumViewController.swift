//
//  AlbumViewController.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 11.05.23.
//

import UIKit

class AlbumViewController: UIViewController {

    private let album: Album
    
    private var viewModels = [AlbumCellViewModel]()
    private var tracks = [AudioTrack]()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.tintColor = .label
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    private var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    init(album: Album) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = album.name
        view.backgroundColor = .systemBackground
        
        let layout  = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.frame.width, height: 45)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        
        collectionView.isHidden = true
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(AlbumCollectionViewCell.self, forCellWithReuseIdentifier: AlbumCollectionViewCell.identifier)
        collectionView.register(AlbumHeaderCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: AlbumHeaderCollectionReusableView.identifier)
        
        APICaller.shared.getAlbumDetails(for: album) {[weak self] result in
            DispatchQueue.main.async {
                switch result{
                case .success(let model):
                    self?.viewModels = model.tracks.items.compactMap({
                        AlbumCellViewModel(name: $0.name, artistName: $0.artists.first?.name ?? "")
                    })
                    self?.tracks = model.tracks.items
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
        guard let url = URL(string: album.external_urls["spotify"] ?? "") else { return }
        
        let customItem = SaveAlbumActivity {
            APICaller.shared.saveAlbum(album: self.album) { [weak self] success in
                DispatchQueue.main.async {
                    if success {
                        NotificationCenter.default.post(name: .albumSavedNotification, object: nil)
                        showAlert(message: "Album successfully saved", title: "Success", target: self)
                        HapticsManager.shared.vibrate(for: .success)
                    }
                    else {
                        showAlert(message: "Something went wrong when saving album", title: "Error", target: self)
                        HapticsManager.shared.vibrate(for: .error)
                    }
                }
            }
        }
        
        let activityController = UIActivityViewController(activityItems: [url], applicationActivities: [customItem])
        activityController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(activityController, animated: true)
    }
    
    @objc private func didLongPress(_ gesture: UILongPressGestureRecognizer){
        if gesture.state == .began {
            let touchPoint = gesture.location(in: collectionView)
            guard let indexPath = collectionView.indexPathForItem(at: touchPoint) else { return }
            
            let model = tracks[indexPath.row]
            let alertController = UIAlertController(title: model.name,
                                                    message: "Would you like to add this to a playlist?",
                                                    preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alertController.addAction(UIAlertAction(title: "Add to playlist", style: .default, handler: {[weak self] _ in
                DispatchQueue.main.async {
                    let libraryPlaylist = LibraryPlaylistsViewController()
                    libraryPlaylist.title = "Select playlist"
                    libraryPlaylist.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                                                       target: self,
                                                                                       action: #selector(self?.didTapClose))
                    libraryPlaylist.selectionHandler = { playlist in
                        APICaller.shared.addTrackToPlaylist(track: model, playlist: playlist) {[weak self] success in
                            if success {
                                showAlert(message: "Track successfully added to playlist", title: "Success", target: self)
                                HapticsManager.shared.vibrate(for: .success)
                            }
                            else {
                                showAlert(message: "Something went wrong when adding track to playlist", title: "Error", target: self)
                                HapticsManager.shared.vibrate(for: .error)
                            }
                        }
                    }
                    self?.present(UINavigationController(rootViewController: libraryPlaylist), animated: true)
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

extension AlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, AlbumHeaderCollectionReusableViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AlbumCollectionViewCell.identifier,
            for: indexPath) as? AlbumCollectionViewCell else{
            return UICollectionViewCell()
        }
        let model = viewModels[indexPath.row]
        cell.configure(with: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: AlbumHeaderCollectionReusableView.identifier,
            for: indexPath) as? AlbumHeaderCollectionReusableView,
              kind == UICollectionView.elementKindSectionHeader else{
            return UICollectionReusableView()
        }
        
        header.configure(with: AlbumHeaderViewModel(name: album.name,
                                                    date: album.release_date,
                                                    artistName: album.artists.first?.name ?? "",
                                                    artworkUrl: URL(string: album.images.first?.url ?? "")))
        header.delegate = self
        
        return header
    }
    
    func albumHeaderCollectionReusableViewDidTapPlay(_ header: AlbumHeaderCollectionReusableView) {
        
        self.tracks = self.tracks.compactMap({
            var track = $0
            track.album = self.album
            return track
        })
        
        PlaybackPresenter.shared.startPlayback(from: self, tracks: self.tracks)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        var dateLabelHeight = album.release_date.getHeightForLabel(font: UIFont.systemFont(ofSize: 16, weight: .regular),
                                                                            width: (UIScreen.main.bounds.width - 80))
        
        var nameLabelHeight = album.name.getHeightForLabel(font: UIFont.systemFont(ofSize: 22, weight: .semibold),
                                                              width: (UIScreen.main.bounds.width - 80))
        
        let artistName = album.artists.first?.name ?? ""
    
        var artistNameLabelHeight = artistName.getHeightForLabel(font: UIFont.systemFont(ofSize: 18, weight: .light),
                                                                                 width: (UIScreen.main.bounds.width - 80))

        if dateLabelHeight <= 0 { dateLabelHeight = 20 }
        if nameLabelHeight <= 0 { nameLabelHeight = 20 }
        if artistNameLabelHeight <= 0 { artistNameLabelHeight = 20 }

        return CGSize(width: view.width, height: (view.width / 1.5) + (nameLabelHeight + dateLabelHeight + artistNameLabelHeight) + 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        collectionView.deselectItem(at: indexPath, animated: true)
        self.tracks[indexPath.row].album = self.album
        PlaybackPresenter.shared.startPlayback(from: self, track: self.tracks[indexPath.row])
    }
    
}
