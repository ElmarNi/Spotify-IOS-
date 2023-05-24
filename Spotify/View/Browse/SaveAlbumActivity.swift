//
//  SaveAlbumActivity.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 24.05.23.
//

import UIKit

class SaveAlbumActivity: UIActivity {
    
    var action: () -> Void
    
    init(performAction: @escaping () -> Void) {
        action = performAction
        super.init()
    }
    
    override var activityTitle: String? {
        return "Save album"
    }
    
    override var activityImage: UIImage? {
        return UIImage(systemName: "rectangle.stack.fill.badge.plus")
    }
    
    override class var activityCategory: UIActivity.Category {
        return .action
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func perform() {
        action()
        activityDidFinish(true)
    }
}
