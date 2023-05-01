//
//  TabBarViewController.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 01.05.23.
//

import UIKit

class TabBarViewController: UITabBarController {
    let homeViewController = HomeViewController()
    let searchViewController = SearchViewController()
    let libraryViewController = LibraryViewController()
    let tabBarAppearance = UITabBarAppearance()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarAppearance.configureWithOpaqueBackground()
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        homeViewController.navigationItem.largeTitleDisplayMode = .always
        searchViewController.navigationItem.largeTitleDisplayMode = .always
        libraryViewController.navigationItem.largeTitleDisplayMode = .always
        
        homeViewController.title = "Browse"
        searchViewController.title = "Search"
        libraryViewController.title = "Library"
        
        let homeViewControllerNav = UINavigationController(rootViewController: homeViewController)
        let searchViewControllerNav = UINavigationController(rootViewController: searchViewController)
        let libraryViewControllerNav = UINavigationController(rootViewController: libraryViewController)
        
        homeViewControllerNav.navigationBar.prefersLargeTitles = true
        searchViewControllerNav.navigationBar.prefersLargeTitles = true
        libraryViewControllerNav.navigationBar.prefersLargeTitles = true
        
        homeViewControllerNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        searchViewControllerNav.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 2)
        libraryViewControllerNav.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "music.note.list"), tag: 3)
        
        setViewControllers([homeViewControllerNav, searchViewControllerNav, libraryViewControllerNav], animated: false)

    }

}
