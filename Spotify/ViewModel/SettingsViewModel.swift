//
//  SettingsViewModel.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 04.05.23.
//

import Foundation

struct Section{
    let title: String
    let options: [Option]
}

struct Option{
    let title: String
    let handler: () -> Void
}
