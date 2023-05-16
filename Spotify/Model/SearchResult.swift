//
//  SearchResult.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 15.05.23.
//

import Foundation

enum SearchResult{
    case artist(model: Artist)
    case album(model: Album)
    case track(model: AudioTrack)
    case playlist(model: PlayList)
}
