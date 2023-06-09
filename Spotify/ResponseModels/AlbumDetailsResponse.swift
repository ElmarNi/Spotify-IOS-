//
//  AlbumDetailsResponse.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 11.05.23.
//

import Foundation

struct AlbumDetailsResponse:Codable{
    let album_type: String
    let artists: [Artist]
    let available_markets: [String]
    let external_urls: [String: String]
    let id: String
    let images: [APIImage]
    let label: String
    let name: String
    var tracks: TracksResponse
}
struct TracksResponse:Codable{
    var items: [AudioTrack]
}
