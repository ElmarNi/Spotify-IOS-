//
//  SearchViewController.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 01.05.23.
//

import UIKit
import SafariServices

class SearchViewController: UIViewController {

    private var categories = [Category]()
    
    private let searchController: UISearchController = {
        let resultController = SearchResultViewController()
        let searchController = UISearchController(searchResultsController: resultController)
        searchController.searchBar.placeholder = "Songs, Artists, Albums"
        searchController.searchBar.searchBarStyle = .minimal
        searchController.definesPresentationContext = true
        return searchController
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.tintColor = .label
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    private let collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(
            sectionProvider: { _, _ -> NSCollectionLayoutSection? in
                let item = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(1)))
                
                item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(0.5),
                        heightDimension: .absolute(150)),
                    repeatingSubitem: item,
                    count: 2)
                
                return NSCollectionLayoutSection(group: group)
            }))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        
        APICaller.shared.getCategories { [weak self] result in
            DispatchQueue.main.async {
                switch result{
                case .success(let categories):
                    self?.categories = categories
                    self?.collectionView.reloadData()
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

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, SearchResultViewControllerDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let resultController = searchController.searchResultsController as? SearchResultViewController,
              searchText.isEmpty
        else{
            return
        }
        
        resultController.clear()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let resultController = searchController.searchResultsController as? SearchResultViewController,
              let query = searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else{
            return
        }

        resultController.delegate = self

        APICaller.shared.search(with: query) {[weak self] resul in
            DispatchQueue.main.async {
                switch resul{
                case .success(let results):
                    resultController.update(with: results)
                case .failure(_):
                    self?.handleError(success: false)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CategoryCollectionViewCell.identifier,
            for: indexPath
        ) as? CategoryCollectionViewCell else{
            return UICollectionViewCell()
        }
        
        let category = categories[indexPath.row]
        cell.configure(with: CategoryCellViewModel(title: category.name,
                                                   artworkUrl: URL(string: category.icons.first?.url ?? "" )))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        let categoryViewController = CategoryViewController(category: category)
        categoryViewController.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(categoryViewController, animated: true)
    }
    
    func didTapResult(_ result: SearchResult) {
        switch result{
        case .album(let model):
            
            let albumViewController = AlbumViewController(album: model)
            navigationController?.pushViewController(albumViewController, animated: true)
            albumViewController.navigationItem.largeTitleDisplayMode = .never
            
        case .track(let model):
            break
        case .playlist(let model):
            
            let playlistViewController = PlayListViewController(playlist: model)
            navigationController?.pushViewController(playlistViewController, animated: true)
            playlistViewController.navigationItem.largeTitleDisplayMode = .never
            
        case .artist(let model):
            
            guard let url = URL(string: model.external_urls["spotify"] ?? "") else{
                return
            }
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true)
            
        }
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
