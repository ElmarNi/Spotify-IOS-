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
    
    enum APIError: Error {
        case failedToGetData
    }
    
    enum HTTPMethod: String {
        case GET
        case POST
        case DELETE
        case PUT
    }
    
    //MARK: - Library -> Playlist
    public func getCurrentUserPlaylists(completion: @escaping(Result<[PlayList], Error>) -> Void){
        createRequest(with: URL(string: Constants.baseUrl + "/me/playlists/?limit=50"), type: .GET) { requst in
            URLSession.shared.dataTask(with: requst) { data, _, error in
                guard let data = data, error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(LibraryPlaylistResponse.self, from: data)
                    completion(.success(result.items))
                }
                catch{
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    public func createPlaylist(with name: String, completion: @escaping (Bool) -> Void){
        getCurrentUserProfile { [weak self] result in
            switch result{
            case .success(let profile):
                self?.createRequest(with: URL(string: Constants.baseUrl + "/users/\(profile.id)/playlists"), type: .POST, completion: { baseRequest in
                    
                    var request = baseRequest
                    let json = ["name": name]
                    request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
                    
                    URLSession.shared.dataTask(with: request) { data, _, error in
                        
                        guard let data = data, error == nil else {
                            completion(false)
                            return
                        }
                        
                        do{
                            let result = try JSONSerialization.jsonObject(with: data)
                            if let response = result as? [String: Any], response["id"] as? String != nil {
                                completion(true)
                            }
                            else{
                                completion(false)
                            }
                        }
                        catch{
                            completion(false)
                        }
                        
                    }.resume()
                })
            case .failure(_):
                completion(false)
            }
        }
    }
    
    public func addTrackToPlaylist(track: AudioTrack, playlist: PlayList, completion: @escaping (Bool) -> Void){
        createRequest(with: URL(string: Constants.baseUrl + "/playlists/\(playlist.id)/tracks"), type: .POST) { baseRequest in
            var request = baseRequest
            let json = ["uris": ["spotify:track:\(track.id)"]]
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else{
                    completion(false)
                    return
                }
                
                do{
                    let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                    if let response = result as? [String: Any], response["snapshot_id"] as? String != nil {
                        completion(true)
                    }
                    else {
                        completion(false)
                    }
                }
                catch{
                    completion(false)
                }
            }.resume()
        }
    }
    
    public func removeTrackFromPlaylist(track: AudioTrack, playlist: PlayList, completion: @escaping (Bool) -> Void){
        
        createRequest(with: URL(string: Constants.baseUrl + "/playlists/\(playlist.id)/tracks"), type: .DELETE) { baseRequest in
            var request = baseRequest
            let json: [String: Any] = ["tracks": [["uri": "spotify:track:\(track.id)"]]]
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else{
                    completion(false)
                    return
                }
                
                do{
                    let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                    if let response = result as? [String: Any], response["snapshot_id"] as? String != nil {
                        completion(true)
                    }
                    else {
                        completion(false)
                    }
                }
                catch{
                    completion(false)
                }
            }.resume()
        }
    }
    
    public func unfollowPlaylist(playlist: PlayList, completion: @escaping (Bool) -> Void){
        createRequest(with: URL(string: Constants.baseUrl + "/playlists/\(playlist.id)/followers"), type: .DELETE) { request in
            URLSession.shared.dataTask(with: request) { _, response, error in
                guard let code = (response as? HTTPURLResponse)?.statusCode, error == nil else{
                    completion(false)
                    return
                }
                completion(code == 200)
            }.resume()
        }
    }
    
    public func getCurrentUserAlbums(completion: @escaping(Result<[Album], Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseUrl + "/me/albums/?limit=50"), type: .GET) { requst in
            URLSession.shared.dataTask(with: requst) { data, _, error in
                guard let data = data, error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(LibraryAlbumResponse.self, from: data)
                    completion(.success(result.items.compactMap({ $0.album })))
                }
                catch{
                    completion(.failure(error))
                    print(error)
                }
            }.resume()
        }
    }
    
    public func saveAlbum(album: Album, completion: @escaping (Bool) -> Void) {
        createRequest(with: URL(string: Constants.baseUrl + "/me/albums?ids=\(album.id)"), type: .PUT) { baseRequest in
            var request = baseRequest
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            URLSession.shared.dataTask(with: request) { _, response, error in
                guard let code = (response as? HTTPURLResponse)?.statusCode, error == nil else {
                    completion(false)
                    return
                }
                completion(code == 200)
            }.resume()
        }
    }
    
    public func removeAlbumFromLibrary(album: Album, completion: @escaping (Bool) -> Void){
        createRequest(with: URL(string: Constants.baseUrl + "/me/albums?ids=\(album.id)"), type: .DELETE) { request in
            URLSession.shared.dataTask(with: request) { _, response, error in
                guard let code = (response as? HTTPURLResponse)?.statusCode, error == nil else{
                    completion(false)
                    return
                }
                completion(code == 200)
            }.resume()
        }
    }
    
    //MARK: - Category
    public func getCategories(completion: @escaping (Result<[Category], Error>) -> Void) {
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
                    
                    searchResults.append(contentsOf: result.tracks.items.filter({ $0.preview_url != nil }).compactMap({SearchResult.track(model: $0)}))
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
                    var result = try JSONDecoder().decode(AlbumDetailsResponse.self, from: data)
                    
                    result.tracks.items = result.tracks.items.filter({
                        $0.preview_url != nil
                    })
                    
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
                    var result = try JSONDecoder().decode(PlayListDetailsResponse.self, from: data)
                    
                    result.tracks.items = result.tracks.items.filter({
                        $0.track.preview_url != nil
                    })
                    
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
        createRequest(with: URL(string: Constants.baseUrl + "/recommendations?limit=100&seed_genres=\(seeds)"), type: .GET, completion: {request in
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do{
                    var result = try JSONDecoder().decode(RecommendationsResponse.self, from: data)
                    result.tracks = result.tracks.filter({
                        $0.preview_url != nil
                    })
                    completion(.success(result))
                }
                catch{
                    completion(.failure(error))
                }
            }.resume()
        })
    }
    
    //MARK: - common function for request
    private func createRequest(with url: URL?, type: HTTPMethod, completion: @escaping (URLRequest) -> Void){
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
