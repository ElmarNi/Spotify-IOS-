//
//  RecommendationsResponse.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 05.05.23.
//

import Foundation

struct RecommendationsResponse: Codable{
    let tracks: [AudioTrack]
}
