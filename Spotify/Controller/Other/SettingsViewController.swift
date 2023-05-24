//
//  SettingsViewController.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 01.05.23.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var sections = [Section]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureModels()
        title = "Settings"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    //MARK: - append models to sections
    private func configureModels(){
        sections.append(Section(title: "Profile", options: [Option(title: "View your profile", handler: { [weak self] in
            self?.viewProfile()
        })]))
        
        sections.append(Section(title: "Account", options: [Option(title: "Sign out", handler: { [weak self] in
            self?.signOutTapped()
        })]))
    }
    
    //MARK: - handle view profile row click
    private func viewProfile(){
        let profileViewController = ProfileViewController()
        profileViewController.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    private func signOutTapped(){
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            AuthManager.shared.signOut {[weak self] isSignedOut in
                if isSignedOut {
                    DispatchQueue.main.async {
                        let welcomeNavViewController = UINavigationController(rootViewController: WelcomeViewController())
                        welcomeNavViewController.navigationBar.prefersLargeTitles = true
                        welcomeNavViewController.viewControllers.first?.navigationItem.largeTitleDisplayMode = .always
                        welcomeNavViewController.modalPresentationStyle = .fullScreen
                        self?.present(welcomeNavViewController, animated: true, completion: {
                            self?.navigationController?.popToRootViewController(animated: true)
                        })
                    }
                }
            }
        }))
        present(alert, animated: true)
        HapticsManager.shared.vibrateForSelection()
    }
    
    //MARK: - tableview datasource and delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sections[indexPath.section].options[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = model.title
        cell.contentConfiguration = content
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = sections[indexPath.section].options[indexPath.row]
        model.handler()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let model = sections[section]
        return model.title
    }
}
