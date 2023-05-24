//
//  LibraryAlbumsViewController.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 19.05.23.
//

import UIKit

class LibraryAlbumsViewController: UIViewController {
    
    private var albums = [Album]()
    private let noAlbumView = ActionLabelView()
    
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
    
    private var observer: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableView.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        tableView.delegate = self
        tableView.dataSource = self
        setupNoAlbumView()
        updateUI()
        getAlbumsData()
        addLongTapGesture()
        
        observer = NotificationCenter.default.addObserver(forName: .albumSavedNotification, object: nil, queue: .main, using: {[weak self] _ in
            self?.getAlbumsData()
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noAlbumView.frame = CGRect(x: 0, y: (view.height - 100) / 2, width: view.width, height: 100)
        activityIndicator.frame = CGRect(x: view.width / 2, y: view.height / 2, width: 0, height: 0)
        tableView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
    }

}

extension LibraryAlbumsViewController{
    
    private func getAlbumsData(){
        albums.removeAll()
        APICaller.shared.getCurrentUserAlbums { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let albums):
                    self?.albums = albums
                    self?.updateUI()
                case .failure(_):
                    showAlert(message: "Something went wrong when getting data", title: "Error", target: self)
                }
                self?.activityIndicator.stopAnimating()
            }
        }
    }
    
    private func setupNoAlbumView(){
        noAlbumView.configure(with: ActionLabelViewModel(text: "You don't have any albums yet.", actionTitle: "Browse"))
        noAlbumView.delegate = self
        view.addSubview(noAlbumView)
    }
    
    private func updateUI(){
        if albums.isEmpty{
            noAlbumView.isHidden = false
        }
        else{
            noAlbumView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    private func addLongTapGesture(){
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        tableView.addGestureRecognizer(gesture)
    }
    
    @objc private func didLongPress(_ gesture: UILongPressGestureRecognizer){
        if gesture.state == .began {
            let touchPoint = gesture.location(in: tableView)
            guard let indexPath = tableView.indexPathForRow(at: touchPoint) else { return }

            let model = albums[indexPath.row]
            let alertController = UIAlertController(title: model.name,
                                                    message: "Would you like remove this album?",
                                                    preferredStyle: .actionSheet)

            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alertController.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: {[weak self] _ in
                APICaller.shared.removeAlbumFromLibrary(album: model) { success in
                    DispatchQueue.main.async {
                        if success {
                            showAlert(message: "Album successfully removed", title: "Success", target: self)
                            self?.albums.remove(at: indexPath.row)
                            self?.tableView.reloadData()
                            HapticsManager.shared.vibrate(for: .success)
                        }
                        else {
                            showAlert(message: "Something went wrong when removing album", title: "Error", target: self)
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

extension LibraryAlbumsViewController: ActionLabelViewDelegate{
    
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        tabBarController?.selectedIndex = 0
    }
    
}

extension LibraryAlbumsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SearchResultTableViewCell.identifier,
            for: indexPath
        ) as? SearchResultTableViewCell else{
            return UITableViewCell()
        }
        
        let album = albums[indexPath.row]
        cell.configure(with: SearchResultCellViewModel(title: album.name,
                                                       subTitle: album.artists.first?.name ?? "",
                                                       imageUrl: URL(string: album.images.first?.url ?? "")))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        tableView.deselectRow(at: indexPath, animated: true)
        let album = albums[indexPath.row]
        
        let albumController = AlbumViewController(album: album)
        navigationController?.pushViewController(albumController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}
