//
//  ProfileViewController.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 01.05.23.
//

import SDWebImage
import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView:UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isHidden = true
        return tableView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.startAnimating()
        return indicator
    }()
    
    private var models = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Profile"
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchProfileData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        activityIndicator.center = view.center
    }
    
    //MARK: - fetching profile data from APICaller
    private func fetchProfileData(){
        APICaller.shared.getCurrentUserProfile {[weak self] result in
            DispatchQueue.main.async {
                switch result{
                case .success(let model):
                    self?.updateUi(with: model)
                case .failure(_):
                    self?.failedToGetProfileData()
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
        models.append("Username: \(model.display_name)")
        models.append("Email: \(model.email)")
        models.append("Country: \(model.country)")
        models.append("Product: \(model.product)")
        createTableHeader(with: model.images.first?.url)
        tableView.reloadData()
    }
    
    private func createTableHeader(with stringUrl: String?){
        guard let stringUrl = stringUrl, let url = URL(string: stringUrl) else {return}
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 130))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: headerView.height - 20, height: headerView.height - 20))
        
        imageView.center = headerView.center
        imageView.sd_setImage(with: url) {[weak self] _,_,_,_ in
            self?.tableView.isHidden = false
            self?.activityIndicator.stopAnimating()
        }
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.clipsToBounds = true
        imageView.backgroundColor = .red
        
        headerView.addSubview(imageView)
        tableView.tableHeaderView = headerView
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
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }

}
