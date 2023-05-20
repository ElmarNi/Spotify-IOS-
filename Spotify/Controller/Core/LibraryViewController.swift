//
//  LibraryViewController.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 01.05.23.
//

import UIKit

class LibraryViewController: UIViewController {

    private let segmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: ["Playlists", "Albums"])
        segmentControl.selectedSegmentIndex = 0
        return segmentControl
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Library"
        label.textAlignment = .left
        label.textColor = .black
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private let playlistsVc = LibraryPlaylistsViewController()
    private let albumsVc = LibraryAlbumsViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        navigationItem.title = ""
        
        view.backgroundColor = .systemBackground
        view.addSubview(segmentControl)
        view.addSubview(scrollView)
        scrollView.addSubview(playlistsVc.view)
        scrollView.addSubview(albumsVc.view)
        scrollView.delegate = self
        addChild(playlistsVc)
        addChild(albumsVc)
        segmentControl.addTarget(self, action: #selector(segmentControlChange(_:)), for: .valueChanged)
        updateButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        segmentControl.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.width - 20, height: 40)
        
        scrollView.frame = CGRect(x: 0,
                                  y: segmentControl.bottom,
                                  width: view.width,
                                  height: view.height - segmentControl.height - view.safeAreaInsets.bottom - view.safeAreaInsets.top)
        
        scrollView.contentSize = CGSize(width: scrollView.width * 2, height: scrollView.height)
        
        playlistsVc.view.frame = CGRect(x: 0, y: 0, width: scrollView.width, height: scrollView.height)
        albumsVc.view.frame = CGRect(x: scrollView.width, y: 0, width: scrollView.width, height: scrollView.height)
    }
    
    @objc private func segmentControlChange(_ segmentControl: UISegmentedControl){
        scrollView.setContentOffset(CGPoint(x: (Int(view.width) * segmentControl.selectedSegmentIndex), y: 0), animated: false)
        updateButton()
    }
    
    @objc private func didTapAdd(){
        playlistsVc.showCreateAlert()
    }
    
}

extension LibraryViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > view.width / 2 {
            segmentControl.selectedSegmentIndex = 1
        }
        else{
            segmentControl.selectedSegmentIndex = 0
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        }
        updateButton()
    }
    
    private func updateButton(){
        navigationItem.rightBarButtonItem =
            segmentControl.selectedSegmentIndex == 0 ? UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd)) : nil
    }
}
