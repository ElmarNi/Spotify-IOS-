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
                    self?.collectionView.reloadData()
                    self?.collectionView.isHidden = false
                    self?.activityIndicator.stopAnimating()
                case .failure(_):
                    self?.handleError(success: false)
                }
            }
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShare))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        activityIndicator.center = view.center
    }
    @objc func didTapShare(){
        guard let url = URL(string: album.external_urls["spotify"] ?? "") else { return }
        let activityController = UIActivityViewController(activityItems: [url], applicationActivities: [])
        activityController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(activityController, animated: true)
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
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    
    private func handleError(success: Bool){
        guard success else {
            let alert = UIAlertController(title: "Error", message: "Something went wrong when getting album data", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: {[weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true)
            return
        }
    }
}
