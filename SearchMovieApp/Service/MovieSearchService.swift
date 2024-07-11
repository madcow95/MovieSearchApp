//
//  MovieSearchService.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/2.
//

import UIKit
import Combine

class MovieSearchService {
    
    private var movieKey: String? = nil
    private var youtubeKey: String? = nil
    
    init() {
        guard let movieAPIKey = Bundle.main.object(forInfoDictionaryKey: "TOKEN_KEY") as? String,
              let youtubeAPIKey = Bundle.main.object(forInfoDictionaryKey: "YOUTUBE_KEY") as? String else {
            
            return
        }
        self.movieKey = movieAPIKey
        self.youtubeKey = youtubeAPIKey
    }
    
    func fetchMovie(searchType: SearchType, page: Int, query: String = "") -> AnyPublisher<MovieModel, any Error> {
        
        let url = URL(string: searchType.getSearchURL())!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = searchType.getSearchQuery(page: page, query: query)
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer \(movieKey!)"
        ]
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap{ (data, response) in
                guard let responseStatus = response as? HTTPURLResponse else {
                    throw MovieSearchError.urlError
                }
                
                switch responseStatus.statusCode {
                case 300..<400:
                    throw MovieSearchError.urlError
                case 400..<500:
                    throw MovieSearchError.serverError
                default:
                    break
                }
                
                return try JSONDecoder().decode(MovieModel.self, from: data)
            }
            .share()
            .eraseToAnyPublisher()
    }
    
    func getMovieDetailInfo(id: Int) throws -> AnyPublisher<MovieDetail?, any Error> {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(id)") else {
            throw MovieSearchError.urlError
        }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = SearchType.detail.getSearchQuery()
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer \(movieKey!)"
        ]
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .receive(on: DispatchQueue.global())
            .tryMap{ (data, response) in
                guard let responseStatus = response as? HTTPURLResponse else {
                    throw MovieSearchError.urlError
                }
                
                switch responseStatus.statusCode {
                case 300..<400:
                    throw MovieSearchError.urlError
                case 400..<500:
                    throw MovieSearchError.serverError
                default:
                    break
                }
                
                return try JSONDecoder().decode(MovieDetail.self, from: data)
            }
            .share()
            .eraseToAnyPublisher()
    }
    
    func getPosterImage(posterURL: String) throws -> AnyPublisher<UIImage?, Never> {
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500/\(posterURL)") else {
            throw MovieSearchError.urlError
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.global())
            .tryMap{ (data, _) in
                // MARK: TODO - response 에러처리
                return UIImage(data: data)
            }
            .replaceError(with: nil)
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }
}
