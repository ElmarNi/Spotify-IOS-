//
//  SearchResultViewController.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 13.05.23.
//

import UIKit

protocol SearchResultViewControllerDelegate: AnyObject{
    func didTapResult(_ result: SearchResult)
}

class SearchResultViewController: UIViewController {
    
    var sections = [SearchSection]()
    
    weak var delegate: SearchResultViewControllerDelegate?
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.identifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isHidden = true
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableView.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        clear()
    }
    
    func update(with results: [SearchResult]){
        var artists: [SearchResult] = []
        var tracks: [SearchResult] = []
        var playlists: [SearchResult] = []
        var albums: [SearchResult] = []
        
        for item in results{
            switch item{
            case .album:
                albums.append(item)
            case .artist:
                artists.append(item)
            case .track:
                tracks.append(item)
            case .playlist:
                playlists.append(item)
            }
        }
        
        sections = [
            SearchSection(title: "Songs", result: tracks),
            SearchSection(title: "Artists", result: artists),
            SearchSection(title: "Playlists", result: playlists),
            SearchSection(title: "Albums", result: albums)
        ]
        
        tableView.reloadData()
        tableView.isHidden = results.isEmpty
    }
    
    func clear(){
        sections = []
        tableView.reloadData()
        tableView.isHidden = true
    }
}

extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].result.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let result = sections[indexPath.section].result[indexPath.row]
        
        switch result{
        case .album(let model):
            
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SearchResultTableViewCell.identifier,
                for: indexPath
            ) as? SearchResultTableViewCell else
            {
                return UITableViewCell()
            }
            
            cell.configure(with: SearchResultCellViewModel(title: model.name,
                                                           subTitle: model.artists.first?.name,
                                                           imageUrl: URL(string: model.images.first?.url ?? "")))
            
            return cell
            
        case .track(let model):
            
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SearchResultTableViewCell.identifier,
                for: indexPath
            ) as? SearchResultTableViewCell else
            {
                return UITableViewCell()
            }
            
            cell.configure(
                with: SearchResultCellViewModel(title: model.name,
                                                           subTitle: model.artists.first?.name,
                                                           imageUrl: URL(string: model.album?.images.first?.url ?? "")))
            
            return cell
            
        case .playlist(let model):
            
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SearchResultTableViewCell.identifier,
                for: indexPath
            ) as? SearchResultTableViewCell else
            {
                return UITableViewCell()
            }
            
            cell.configure(with: SearchResultCellViewModel(title: model.name,
                                                           subTitle: model.owner.display_name,
                                                           imageUrl: URL(string: model.images.first?.url ?? "")))
            
            return cell
            
        case .artist(let model):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SearchResultTableViewCell.identifier,
                for: indexPath
            ) as? SearchResultTableViewCell else
            {
                return UITableViewCell()
            }
            
            cell.configure(with: SearchResultCellViewModel(title: model.name,
                                                           subTitle: nil,
                                                           imageUrl: URL(string: model.images?.first?.url ?? "")))
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = sections[indexPath.section].result[indexPath.row]
        delegate?.didTapResult(result)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
}
