//
//  NewReleasesResponse.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 05.05.23.
//

import Foundation

struct NewReleasesResponse: Codable{
    let albums: Album
}
struct AlbumsResponse: Codable{
    let items: [Album]
}
