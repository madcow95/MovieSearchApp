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
    
    func fetchPopularMovie(page: Int) async {
        let url = URL(string: "https://api.themoviedb.org/3/discover/movie")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
          URLQueryItem(name: "include_adult", value: "true"),
          URLQueryItem(name: "include_video", value: "false"),
          URLQueryItem(name: "language", value: "ko-KR"),
          URLQueryItem(name: "page", value: "\(page)"),
          URLQueryItem(name: "sort_by", value: "popularity.desc"),
//          URLQueryItem(name: "year", value: "2020"),
        ]
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
          "accept": "application/json",
          "Authorization": "Bearer \(movieKey!)"
        ]

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let result = try JSONDecoder().decode(MovieModel.self, from: data)
        } catch {
            print(error)
        }
    }
    
    func getPosterImage(posterURL: String) throws -> AnyPublisher<UIImage?, Error> {
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500/\(posterURL)") else {
            throw MovieSearchError.urlError
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap{ (data, _) in
                // MARK: TODO - response 에러처리
                return UIImage(data: data)
            }
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }
}
