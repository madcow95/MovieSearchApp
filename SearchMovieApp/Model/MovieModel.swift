//
//  MovieModel.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/2.
//

import UIKit

struct MovieModel: Decodable {
    let dates: Dates?
    let page: Int
    let results: [MovieInfo]
    let totalPages, totalResults: Int

    enum CodingKeys: String, CodingKey {
        case dates
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct Dates: Decodable {
    let maximum, minimum: String
}

// MARK: - Result
struct MovieInfo: Decodable {
    let adult: Bool
    let backdropPath: String?
    let genreIDS: [Int]
    let id: Int
    let originalLanguage, originalTitle, overview: String
    let popularity: Double
    let posterPath, releaseDate, title: String
    let video: Bool
    let voteAverage: Double
    let voteCount: Int
    
    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case genreIDS = "genre_ids"
        case id
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview, popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title, video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}

enum SearchType {
    case weeklyPopular
    case famous
    case upComing
    case search
    case detail
    
    func getSearchURL(id: Int = 0) -> String {
        let baseURL: String = "https://api.themoviedb.org/3"
        switch self {
        case .weeklyPopular:
            return "\(baseURL)/trending/movie/week"
        case .famous:
            return "\(baseURL)/movie/top_rated"
        case .upComing:
            return "\(baseURL)/movie/upcoming"
        case .search:
            return "\(baseURL)/search/movie"
        case .detail:
            return "\(baseURL)/movie/\(id)"
        }
    }
    
    func getSearchQueries(page: Int = 1, query: String = "") -> [String: Any] {
        var queries: [String: Any] = [
            "language": "ko-KR"
        ]
        switch self {
        case .weeklyPopular:
            queries["page"] = page
        case .famous:
            queries["page"] = page
        case .upComing:
            queries["page"] = page
        case .search:
            queries["query"] = query
            queries["include_adult"] = "true"
            queries["page"] = page
        case .detail:
            break
        }
        return queries
    }
    
    func getSearchQuery(page: Int = 1, query: String = "") -> [URLQueryItem] {
        let baseQueryItem = URLQueryItem(name: "language", value: "ko-KR")
        switch self {
        case .weeklyPopular:
            return [
                baseQueryItem,
                URLQueryItem(name: "page", value: "\(page)")
            ]
        case .famous:
            return [
                baseQueryItem,
                URLQueryItem(name: "page", value: "\(page)")
            ]
        case .upComing:
            return [
                baseQueryItem,
                URLQueryItem(name: "page", value: "\(page)")
            ]
        case .search:
            return [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "include_adult", value: "true"),
                baseQueryItem,
                URLQueryItem(name: "page", value: "\(page)")
            ]
        case .detail:
            return [
                baseQueryItem
            ]
        }
    }
}
