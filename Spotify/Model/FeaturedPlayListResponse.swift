//
//  FeaturedPlaslistResponse.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 05.05.23.
//

import Foundation

struct FeaturedPlayListResponse: Codable{
    let playlists: PlayList
}

struct PlayListResponse: Codable{
    let items: [PlayList]
}



struct User: Codable{
    let display_name: String
    let external_urls: [String: String]
    let id: String
}
