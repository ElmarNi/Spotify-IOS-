//
//  LibraryPlaylistsViewController.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 19.05.23.
//

import UIKit
 
class LibraryPlaylistsViewController: UIViewController {
    
    private var playlists = [PlayList]()
    private let noPlayListView = ActionLabelView()
    public var selectionHandler: ((PlayList) -> Void)?
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.tintColor = .label
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableView.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        
        tableView.delegate = self
        tableView.dataSource = self
        setupNoPlaylistView()
        getPlaylistsData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noPlayListView.frame = CGRect(x: 0, y: 0, width: view.width, height: 100)
        noPlayListView.center = view.center
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        activityIndicator.center = view.center
        tableView.frame = view.frame
    }

}

extension LibraryPlaylistsViewController{
    
    private func getPlaylistsData(){
        APICaller.shared.getCurrentUserPlaylists { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let playlists):
                    self?.playlists = playlists
                    self?.updateUI()
                    self?.activityIndicator.stopAnimating()
                case .failure(_):
                    self?.handleError(success: false, message: "Something went wrong when getting data")
                }
            }
        }
    }
    
    private func setupNoPlaylistView(){
        noPlayListView.configure(with: ActionLabelViewModel(text: "You don't have any playlists yet.", actionTitle: "Create"))
        noPlayListView.delegate = self
        view.addSubview(noPlayListView)
    }
    
    private func updateUI(){
        if playlists.isEmpty{
            noPlayListView.isHidden = false
        }
        else{
            noPlayListView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    public func showCreateAlert(){
        let alert = UIAlertController(title: "New Playlist",
                                      message: "Enter Playlist name",
                                      preferredStyle: .alert)
        
        alert.addTextField{ textField in
            textField.placeholder = "Playlist..."
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: {[weak self] _ in
            
            guard let field = alert.textFields?.first,
                  let text = field.text,
                  !text.trimmingCharacters(in: .whitespaces).isEmpty else {
                self?.handleError(success: false, message: "Playlist name can't be empty")
                return
            }
            self?.activityIndicator.startAnimating()
            
            APICaller.shared.createPlaylist(with: text) { result in
                DispatchQueue.main.async {
                    switch result{
                    case true:
                        self?.getPlaylistsData()
                    case false:
                        self?.handleError(success: false, message: "Something went wrong when creating playlist")
                    }
                }
            }
            
        }))
        
        present(alert, animated: true)
    }
    
    private func handleError(success: Bool, message: String){
        guard success else {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
    }
    
}

extension LibraryPlaylistsViewController: ActionLabelViewDelegate{
    
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        showCreateAlert()
    }
    
}

extension LibraryPlaylistsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SearchResultTableViewCell.identifier,
            for: indexPath
        ) as? SearchResultTableViewCell else{
            return UITableViewCell()
        }
        
        let playlist = playlists[indexPath.row]
        cell.configure(with: SearchResultCellViewModel(title: playlist.name,
                                                       subTitle: playlist.owner.display_name,
                                                       imageUrl: URL(string: playlist.images.first?.url ?? "")))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let playlist = playlists[indexPath.row]
        
        guard selectionHandler == nil else {
            selectionHandler?(playlist)
            dismiss(animated: true)
            return
        }
        
        let playListController = PlayListViewController(playlist: playlist)
        playListController.isOwner = true
        navigationController?.pushViewController(playListController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}
