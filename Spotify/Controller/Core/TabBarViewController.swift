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

        //MARK: - set tab and nav bars to default bg
        tabBarAppearance.configureWithDefaultBackground()
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        navBarAppearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        
        //MARK: - set title display mods to controllers
        homeViewController.navigationItem.largeTitleDisplayMode = .never
        searchViewController.navigationItem.largeTitleDisplayMode = .always
        libraryViewController.navigationItem.largeTitleDisplayMode = .always
        
        //MARK: - set titles
        homeViewController.title = "Home"
        searchViewController.title = "Search"
        libraryViewController.title = "Library"
        
        //MARK: - create navigationControllers
        let homeViewControllerNav = UINavigationController(rootViewController: homeViewController)
        let searchViewControllerNav = UINavigationController(rootViewController: searchViewController)
        let libraryViewControllerNav = UINavigationController(rootViewController: libraryViewController)
        
        //MARK: - set navigationControllers title
        homeViewControllerNav.navigationBar.prefersLargeTitles = false
        searchViewControllerNav.navigationBar.prefersLargeTitles = true
        libraryViewControllerNav.navigationBar.prefersLargeTitles = true
        
        //MARK: - create bar items
        homeViewControllerNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        searchViewControllerNav.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 2)
        libraryViewControllerNav.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "music.note.list"), tag: 3)
        
        setViewControllers([homeViewControllerNav, searchViewControllerNav, libraryViewControllerNav], animated: false)

    }

}
