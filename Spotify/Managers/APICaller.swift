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
    
    //MARK: - Category
    public func getCategories(completion: @escaping (Result<[Category], Error>) -> Void){
        createRequest(with: URL(string: Constants.baseUrl + "/browse/categories?limit=50"), type: .GET, completion: {request in
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(CategoriesResponse.self, from: data)
                    completion(.success(result.categories.items))
                }
                catch{
                    completion(.failure(error))
                }
            }.resume()
        })
    }

    public func getCategoryPlaylists(category: Category, completion: @escaping (Result<[PlayList], Error>) -> Void){
        createRequest(with: URL(string: Constants.baseUrl + "/browse/categories/\(category.id)/playlists?limit=50"), type: .GET, completion: {
            request in
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(FeaturedPlayListResponse.self, from: data)
                    completion(.success(result.playlists.items))
                }
                catch{
                    completion(.failure(error))
                }
            }.resume()
        })
    }
    
    //MARK: - Search
    public func search(with query: String, completion: @escaping (Result<[SearchResult], Error>) -> Void){
        createRequest(with: URL(string: Constants.baseUrl + "/search?limit=10&type=album,artist,playlist,track&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"), type: .GET) { request in
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(SearchResultResponse.self, from: data)
                    var searchResults: [SearchResult] = []
                    searchResults.append(contentsOf: result.tracks.items.compactMap({SearchResult.track(model: $0)}))
                    searchResults.append(contentsOf: result.albums.items.compactMap({SearchResult.album(model: $0)}))
                    searchResults.append(contentsOf: result.playlists.items.compactMap({SearchResult.playlist(model: $0)}))
                    searchResults.append(contentsOf: result.artists.items.compactMap({SearchResult.artist(model: $0)}))
                    
                    completion(.success(searchResults))
                }
                catch{
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    //MARK: - Album
    public func getAlbumDetails(for album: Album, completion: @escaping (Result<AlbumDetailsResponse, Error>) -> Void){
        createRequest(with: URL(string: Constants.baseUrl + "/albums/" + album.id), type: .GET) { request in
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(AlbumDetailsResponse.self, from: data)
                    completion(.success(result))
                }
                catch{
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    //MARK: - Playlist
    public func getPlaylistDetails(for playlist: PlayList, completion: @escaping (Result<PlayListDetailsResponse, Error>) -> Void){
        createRequest(with: URL(string: Constants.baseUrl + "/playlists/" + playlist.id), type: .GET) { request in
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(PlayListDetailsResponse.self, from: data)
                    completion(.success(result))
                }
                catch{
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    //MARK: - Profile
    public func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void){
        createRequest(with: URL(string: Constants.baseUrl + "/me"), type: .GET) { request in
            URLSession.shared.dataTask(with: request) { data, _, error in
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
    
    //MARK: - Browse
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
