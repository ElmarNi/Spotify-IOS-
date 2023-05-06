//
//  ViewController.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 01.05.23.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(didTapSettings))
        fetchNewReleasesData()
        fetchFeaturedPlasylistsData()
        fetchGenresData()
    }
    
    private func fetchNewReleasesData(){
        APICaller.shared.getNewReleases { result in
            switch result {
                case .success(let _): break
                case .failure(let _): break
            }
        }
    }
    
    private func fetchFeaturedPlasylistsData(){
        APICaller.shared.getFeaturedPlaylists { result in
            switch result {
                case .success(let _): break
                case .failure(let _): break
            }
        }
    }
    
    private func fetchGenresData(){
        APICaller.shared.getGenres{ result in
            switch result {
            case .success(let model):
                let genres = model.genres
                var seeds = Set<String>()
                while seeds.count < 5 {
                    if let random = genres.randomElement(){
                        seeds.insert(random)
                    }
                }
                APICaller.shared.getRecommendations(genres: seeds) { result in
                    
                }
            case .failure(let _): break
            }
        }
    }
    
    @objc func didTapSettings() {
        let settingsViewController = SettingsViewController()
        settingsViewController.title = "Settings"
        settingsViewController.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(settingsViewController, animated: true)
    }

}

