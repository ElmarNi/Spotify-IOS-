//
//  PlayListDetailsResponse.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 11.05.23.
//

import Foundation

struct PlayListDetailsResponse:Codable{
    let description: String
    let external_urls: [String: String]
    let id: String
    let images: [APIImage]
    let name: String
    let tracks: PlayListTracksResponse
}

struct PlayListTracksResponse:Codable{
    let items: [PlayListItem]
}

struct PlayListItem:Codable{
    let track: AudioTrack
}
