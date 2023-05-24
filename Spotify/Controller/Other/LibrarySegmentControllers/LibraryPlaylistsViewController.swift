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
        addLongTapGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noPlayListView.frame = CGRect(x: 0, y: (view.height - 100) / 2, width: view.width, height: 100)
        activityIndicator.frame = CGRect(x: view.width / 2, y: view.height / 2, width: 0, height: 0)
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
                case .failure(_):
                    showAlert(message: "Something went wrong when getting data", title: "Error", target: self)
                }
                self?.activityIndicator.stopAnimating()
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
                showAlert(message: "Playlist name can't be empty", title: "Error", target: self)
                return
            }
            self?.activityIndicator.startAnimating()
            
            APICaller.shared.createPlaylist(with: text) { result in
                DispatchQueue.main.async {
                    switch result{
                    case true:
                        HapticsManager.shared.vibrate(for: .success)
                        self?.getPlaylistsData()
                    case false:
                        HapticsManager.shared.vibrate(for: .error)
                        showAlert(message: "Something went wrong when creating playlist", title: "Error", target: self)
                    }
                }
            }
            
        }))
        
        present(alert, animated: true)
    }
    
    private func addLongTapGesture(){
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        tableView.addGestureRecognizer(gesture)
    }
    
    @objc private func didLongPress(_ gesture: UILongPressGestureRecognizer){
        if gesture.state == .began {
            let touchPoint = gesture.location(in: tableView)
            guard let indexPath = tableView.indexPathForRow(at: touchPoint) else { return }
            
            let model = playlists[indexPath.row]
            let alertController = UIAlertController(title: model.name,
                                                    message: "Would you like remove this playlist?",
                                                    preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alertController.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: {[weak self] _ in
                APICaller.shared.unfollowPlaylist(playlist: model) { success in
                    DispatchQueue.main.async {
                        if success {
                            showAlert(message: "Playlist successfully removed", title: "Success", target: self)
                            self?.playlists.remove(at: indexPath.row)
                            self?.tableView.reloadData()
                            HapticsManager.shared.vibrate(for: .success)
                        }
                        else {
                            showAlert(message: "Something went wrong when removing playlist", title: "Error", target: self)
                            HapticsManager.shared.vibrate(for: .error)
                        }
                    }
                }
            }))
            present(alertController, animated: true)
            HapticsManager.shared.vibrateForSelection()
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
        HapticsManager.shared.vibrateForSelection()
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
