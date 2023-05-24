//
//  LibraryAlbumResponse.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 24.05.23.
//

import Foundation

struct LibraryAlbumResponse: Codable {
    let items: [ItemsResponse]
}

struct ItemsResponse: Codable {
    let added_at: String
    let album: Album
}
