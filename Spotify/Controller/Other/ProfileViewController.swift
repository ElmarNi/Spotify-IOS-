//
//  ProfileViewController.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 01.05.23.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView:UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isHidden = true
        return tableView
    }()
    
    private var models = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Profile"
        view.backgroundColor = .systemBackground
        fetchProfileData()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    //MARK: - fetching profile data from APICaller
    private func fetchProfileData(){
        APICaller.shared.getCurrentUserProfile {[weak self] result in
            DispatchQueue.main.async {
                switch result{
                case .success(let model):
                    self?.updateUi(with: model)
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    self?.failedToGetProfileData()
                    break
                }
            }
        }
    }
    
    
    //MARK: - show error in label when failed to get profile data
    private func failedToGetProfileData(){
        let label: UILabel = {
            let label = UILabel()
            label.text = "Failed to load profile"
            label.sizeToFit()
            label.textColor = .secondaryLabel
            label.center = view.center
            return label
        }()
        view.addSubview(label)
    }
    
    //MARK: - updateing ui
    private func updateUi(with model: UserProfile){
        tableView.isHidden = false
        models.append("FullName: \(model.display_name)")
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        var content = cell.defaultContentConfiguration()
        content.text = models[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }

}
