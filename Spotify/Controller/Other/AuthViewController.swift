//
//  AuthViewController.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 01.05.23.
//

import UIKit
import WebKit

class AuthViewController: UIViewController, WKNavigationDelegate {
    
    private let webView: WKWebView = {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = preferences
        
        let webView = WKWebView(frame: .zero, configuration: config)
        
        return webView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sign In"
        view.backgroundColor = .systemBackground
        
        webView.navigationDelegate = self
        
        view.addSubview(webView)
        
        activityIndicator.startAnimating()
        webView.addSubview(activityIndicator)
        
        guard let url = AuthManager.shared.signInUrl else { return }
        
        webView.load(URLRequest(url: url))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        activityIndicator.center = webView.center
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else { return }
        guard let code = URLComponents(string: url.absoluteString)?.queryItems?.first(where: {$0.name == "code"})?.value else { return }
        webView.isHidden = true
        AuthManager.shared.exchangeCodeForToken(code: code) { [weak self] success in
            DispatchQueue.main.async {
                self?.navigationController?.popToRootViewController(animated: true)
                self?.compliationHandler?(success)
            }
        }
    }
    
    public var compliationHandler: ((Bool) -> Void)?
    
}
