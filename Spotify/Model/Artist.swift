//
//  Artist.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 01.05.23.
//

import Foundation

struct Artist:Codable{
    let id: String
    let name: String
    let type: String
    let external_urls: [String: String]
}
