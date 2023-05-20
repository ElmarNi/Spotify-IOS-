//
//  SearchResultResponse.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 15.05.23.
//

import Foundation

struct SearchResultResponse: Codable{
    let albums: SearchAlbumResponse
    let artists: SearchArtistResponse
    let playlists: SearchPlaylistResponse
    let tracks: SearchTrackResponse
}

struct SearchAlbumResponse: Codable{
    let items: [Album]
}

struct SearchArtistResponse: Codable{
    let items: [Artist]
}

struct SearchPlaylistResponse: Codable{
    let items: [PlayList]
}

struct SearchTrackResponse: Codable{
    let items: [AudioTrack]
}
