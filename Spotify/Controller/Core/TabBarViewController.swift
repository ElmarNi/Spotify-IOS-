//
//  TabBarViewController.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 01.05.23.
//

import UIKit

class TabBarViewController: UITabBarController {
    //MARK: - create controllers
    let homeViewController = HomeViewController()
    let searchViewController = SearchViewController()
    let libraryViewController = LibraryViewController()
    //MARK: - create appearances
    let tabBarAppearance = UITabBarAppearance()
    let navBarAppearance = UINavigationBarAppearance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - set title display mods to controllers
        homeViewController.navigationItem.largeTitleDisplayMode = .always
        searchViewController.navigationItem.largeTitleDisplayMode = .always
        libraryViewController.navigationItem.largeTitleDisplayMode = .always
        
        //MARK: - set titles
        homeViewController.title = "Browse"
        searchViewController.title = "Search"
        libraryViewController.title = "Library"
        
        //MARK: - create navigationControllers
        let homeViewControllerNav = UINavigationController(rootViewController: homeViewController)
        let searchViewControllerNav = UINavigationController(rootViewController: searchViewController)
        let libraryViewControllerNav = UINavigationController(rootViewController: libraryViewController)
        
        //MARK: - set navigationControllers title mode and color
        homeViewControllerNav.navigationBar.prefersLargeTitles = true
        searchViewControllerNav.navigationBar.prefersLargeTitles = true
        libraryViewControllerNav.navigationBar.prefersLargeTitles = true
        
        homeViewControllerNav.navigationBar.tintColor = .label
        searchViewControllerNav.navigationBar.tintColor = .label
        libraryViewControllerNav.navigationBar.tintColor = .label
        
        //MARK: - create bar items
        homeViewControllerNav.tabBarItem = UITabBarItem(title: "Browse", image: UIImage(systemName: "house"), tag: 1)
        searchViewControllerNav.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 2)
        libraryViewControllerNav.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "music.note.list"), tag: 3)
        
        setViewControllers([homeViewControllerNav, searchViewControllerNav, libraryViewControllerNav], animated: false)

    }

}
