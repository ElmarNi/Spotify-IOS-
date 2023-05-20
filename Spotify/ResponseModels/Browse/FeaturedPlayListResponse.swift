//
//  FeaturedPlaslistResponse.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 05.05.23.
//

import Foundation

struct FeaturedPlayListResponse: Codable{
    let playlists: PlayListResponse
}

struct PlayListResponse: Codable{
    let items: [PlayList]
}
