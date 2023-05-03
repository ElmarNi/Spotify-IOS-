//
//  WelcomeViewController.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 01.05.23.
//

import UIKit

class WelcomeViewController: UIViewController {

    private let signInButton: UIButton = {
        let button: UIButton = UIButton()
        button.backgroundColor = .white
        button.setTitle("Sign In with Spotify", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Spotify"
        view.backgroundColor = .systemGreen
        
        view.addSubview(signInButton)
        signInButton.addTarget(self, action: #selector(signInButtonOnClick), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        signInButton.frame = CGRect(x: 40, y: view.height - 60 - view.safeAreaInsets.bottom, width: view.width - 80, height: 50)
    }
    
    @objc func signInButtonOnClick(){
        let authViewController = AuthViewController()
        authViewController.compliationHandler = {[weak self] success in
            DispatchQueue.main.async {
                self?.handleSignIn(success: success)
            }
        }
        authViewController.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(authViewController, animated: true)
    }
    
    private func handleSignIn(success: Bool){
        guard success else {
            let alert = UIAlertController(title: "Error", message: "Something went wrong when attempting to sign in", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        
        let tabBarViewController = TabBarViewController()
        tabBarViewController.modalPresentationStyle = .fullScreen
        present(tabBarViewController, animated: true)
    }
}
