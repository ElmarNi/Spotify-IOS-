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
    
    private let imageView: UIImageView = {
        let imageView = UIImageView();
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "albums_background")
        return imageView
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView();
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "logo")
        return imageView
    }()
    
    private let overlayView: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = .black
        overlay.alpha = 0.7
        return overlay
    }()
    
    private let viewTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 35, weight: .bold)
        label.text = "Spotify"
        label.textColor = .white
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.text = "Listen to Millions\nof Songs on\nthe go"
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(imageView)
        view.addSubview(overlayView)
        view.addSubview(viewTitleLabel)
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(signInButton)
        
        signInButton.addTarget(self, action: #selector(signInButtonOnClick), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        titleLabel.sizeToFit()
        imageView.frame = view.bounds
        overlayView.frame = view.bounds
        viewTitleLabel.frame = CGRect(x: 0, y: view.safeAreaInsets.bottom + 20, width: view.width, height: 50)
        logoImageView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        logoImageView.center = view.center
        titleLabel.frame = CGRect(x: 0, y: logoImageView.bottom + 20, width: view.width, height: titleLabel.height)
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
