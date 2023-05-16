//
//  CategoryViewController.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 13.05.23.
//

import UIKit

class CategoryViewController: UIViewController {

    private let category: Category
    
    private var playlists = [PlayList]()
    
    private let collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, _ in
            
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)))
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(200),
                    heightDimension: .absolute(200)),
                repeatingSubitem: item,
                count: 2)
            
            return NSCollectionLayoutSection(group: group)
            
        }))
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.tintColor = .label
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    init(category: Category) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = category.name
        view.backgroundColor = .systemBackground
        
        collectionView.register(FeaturedPlaylistCollectionViewCell.self, forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isHidden = true
        
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        
        APICaller.shared.getCategoryPlaylists(category: category) {[weak self] result in
            DispatchQueue.main.async {
                switch result{
                case .success(let model):
                    self?.playlists = model
                    self?.collectionView.reloadData()
                    self?.collectionView.isHidden = false
                    self?.activityIndicator.stopAnimating()
                case .failure(_):
                    self?.handleError(success: false)
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        activityIndicator.center = view.center
    }
    
}

extension CategoryViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier,
            for: indexPath)
                as? FeaturedPlaylistCollectionViewCell else{
            return UICollectionViewCell()
        }
        
        let playlist = playlists[indexPath.row]
        cell.configure(with: FeaturedPlaylistsCellViewModel(name: playlist.name,
                                                            artworkUrl: URL(string: playlist.images.first?.url ?? ""),
                                                            creatorName: playlist.owner.display_name))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let playlist = playlists[indexPath.row]
        let playListViewController = PlayListViewController(playlist: playlist)
        playListViewController.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(playListViewController, animated: true)
    }
    
    private func handleError(success: Bool){
        guard success else {
            let alert = UIAlertController(title: "Error", message: "Something went wrong when getting data", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: {[weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true)
            return
        }
    }
    
}
