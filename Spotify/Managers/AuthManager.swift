//
//  AuthManager.swift
//  Spotify
//
//  Created by Elmar Ibrahimli on 01.05.23.
//

import Foundation

final class AuthManager{
    static let shared = AuthManager()
    private init() {}
    private var isRefreshingToken = false
    struct Constants{
        static let clientId = "c48594b8efdb4c929e37359cfbcc986a"
        static let clientSecret = "f9e936976aed423b97f712769a8dd567"
        static let tokenApiUrl = "https://accounts.spotify.com/api/token"
        static let redirectURI = "http://localhost/"
        static let scopes = "user-read-private%20playlist-modify-public%20playlist-read-private%20playlist-modify-private%20user-follow-read%20user-library-modify%20user-library-read%20user-read-email"
    }
    
    public var signInUrl: URL? {
        let baseUrl = "https://accounts.spotify.com/authorize"
        
        let url = "\(baseUrl)?response_type=code&client_id=\(Constants.clientId)&scope=\(Constants.scopes)&redirect_uri=\(Constants.redirectURI)&show_dialog=TRUE"
        
        return URL(string: url)
    }
    
    public var isSignedIn: Bool{
        return accessToken != nil
    }
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    private var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    private var tokenExpirationDate: Date? {
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }
    private var shouldRefreshToken: Bool {
        guard let expDate = tokenExpirationDate else{ return false }
        return Date().addingTimeInterval(TimeInterval(300)) >= expDate
    }
    
    //MARK: - common function for refresh and exchnage token
    private func postRequestForToken(_ isRefreshMethod: Bool, components: URLComponents, completion: @escaping ((Bool) -> Void)){
        guard let url = URL(string: Constants.tokenApiUrl) else { return }
        
        guard let base64String = (Constants.clientId + ":" + Constants.clientSecret).data(using: .utf8)?.base64EncodedString() else{
            completion(false)
            print("Failure to get base64")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = components.query?.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request, completionHandler: {[weak self] data, _, error in
            if isRefreshMethod{
                self?.isRefreshingToken = false
            }
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                if isRefreshMethod{
                    self?.onRefreshBlocks.forEach({$0(result.access_token)})
                    self?.onRefreshBlocks.removeAll()
                }
                self?.cacheToken(result: result)
                completion(true)
            }
            catch{
                print(error.localizedDescription)
                completion(false)
            }
        }).resume()
    }
    
    public func exchangeCodeForToken(code: String, completion: @escaping ((Bool) -> Void)){
        
        var components = URLComponents()
        
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI)
        ]
        
        postRequestForToken(false, components: components, completion: {success in
            completion(success)
        })
        
    }
    
    private var onRefreshBlocks = [((String) -> Void)]()
    
    public func withValidToken(completion: @escaping (String) -> Void){
        guard !isRefreshingToken else{
            onRefreshBlocks.append(completion)
            return
        }
        if shouldRefreshToken{
            refreshIfNeeded(completion: {[weak self] success in
                if let token = self?.accessToken, success{
                    completion(token)
                }
            })
        }
        else if let token = accessToken{
            completion(token)
        }
    }
    
    public func refreshIfNeeded(completion: @escaping (Bool) -> Void){
        guard !isRefreshingToken else {return}
        guard shouldRefreshToken else {
            completion(true)
            return
        }
        guard let refreshToken = self.refreshToken else {return}
        
        var components = URLComponents()
        
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken)
        ]
        isRefreshingToken = true
        postRequestForToken(true, components: components, completion: {success in
            completion(success)
        })
    }
    
    public func cacheToken(result: AuthResponse){
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        if result.refresh_token != nil{
            UserDefaults.standard.setValue(result.refresh_token, forKey: "refresh_token")
        }
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: "expirationDate")
    }
}
