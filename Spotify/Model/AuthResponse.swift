//
//  AuthResponse.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 03.05.23.
//

import Foundation

struct AuthResponse: Codable{
    let access_token: String
    let expires_in: Int
    let refresh_token: String?
    let scope: String
    let token_type: String
}
