//
//  APICaller.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 01.05.23.
//

import Foundation

final class APICaller{
    public static let shared = APICaller()
    private init() {}
    
    struct Constants{
        static let baseUrl: String = "https://api.spotify.com/v1"
    }
    
    enum APIError: Error{
        case failedToGetData
    }
    
    enum HTTPMethod: String {
        case GET
        case POST
    }
    
    //MARK: - get current user's profile data
    public func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void){
        createRequest(with: URL(string: Constants.baseUrl + "/me"), type: .GET) { baserRequest in
            URLSession.shared.dataTask(with: baserRequest) { data, _, error in
                guard let data = data, error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(UserProfile.self, from: data)
                    completion(.success(result))
                }
                catch{
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    //MARK: - get new releases
    public func getNewReleases(completion: @escaping (Result<NewReleasesResponse, Error>) -> Void){
        createRequest(with: URL(string: Constants.baseUrl + "/browse/new-releases?limit=50"), type: .GET) { request in
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do{
                    let result = try JSONDecoder().decode(NewReleasesResponse.self, from: data)
                    completion(.success(result))
                }
                catch{
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    //MARK: - get featured playlist
    public func getFeaturedPlaylists(completion: @escaping (Result<FeaturedPlayListResponse, Error>) -> Void){
        createRequest(with: URL(string: Constants.baseUrl + "/browse/featured-playlists?limit=20"), type: .GET) { request in
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
               
                do{
                    let result = try JSONDecoder().decode(FeaturedPlayListResponse.self, from: data)
                    completion(.success(result))
                }
                catch{
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    //MARK: - get genres
    public func getGenres(completion: @escaping (Result<GenresResponse, Error>) -> Void){
        createRequest(with: URL(string: Constants.baseUrl + "/recommendations/available-genre-seeds"), type: .GET) { request in
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do{
                    let result = try JSONDecoder().decode(GenresResponse.self, from: data)
                    completion(.success(result))
                }
                catch{
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    //MARK: - get recommendations
    public func getRecommendations(genres: Set<String>, completion: @escaping (Result<RecommendationsResponse, Error>) -> Void){
        
        let seeds = genres.joined(separator: ",")
        createRequest(with: URL(string: Constants.baseUrl + "/recommendations?limit=40&seed_genres=\(seeds)"), type: .GET, completion: {request in
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do{
                    let result = try JSONDecoder().decode(RecommendationsResponse.self, from: data)
                    completion(.success(result))
                }
                catch{
                    completion(.failure(error))
                }
            }.resume()
        })
    }
    
    //MARK: - common function for request
    private func createRequest(with url: URL?, type:HTTPMethod, completion: @escaping (URLRequest) -> Void){
        AuthManager.shared.withValidToken { token in
            guard let url = url else {return}
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            completion(request)
        }
    }
}
