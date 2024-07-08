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
    case onPlaying
    case upComing
    
    var searchURL: String {
        get {
            let baseURL: String = "https://api.themoviedb.org/3"
            switch self {
            case .weeklyPopular:
                return "\(baseURL)/trending/movie/week"
            case .onPlaying:
                return "\(baseURL)/movie/now_playing"
            case .upComing:
                return "\(baseURL)/movie/upcoming"
            }
        }
    }
    
    var searchQuery: [URLQueryItem] {
        get {
            let baseQueryItem = URLQueryItem(name: "language", value: "ko-KR")
            switch self {
            case .weeklyPopular:
                return [
                    baseQueryItem,
                    URLQueryItem(name: "page", value: "1")
                ]
            case .onPlaying:
                return [
                    baseQueryItem,
                    URLQueryItem(name: "page", value: "1")
                ]
            case .upComing:
                return [
                    baseQueryItem,
                    URLQueryItem(name: "page", value: "1")
                ]
            }
        }
    }
    
    func getSearchQuery(page: Int) -> [URLQueryItem] {
        let baseQueryItem = URLQueryItem(name: "language", value: "ko-KR")
        switch self {
        case .weeklyPopular:
            return [
                baseQueryItem,
                URLQueryItem(name: "page", value: "\(page)")
            ]
        case .onPlaying:
            return [
                baseQueryItem,
                URLQueryItem(name: "page", value: "\(page)")
            ]
        case .upComing:
            return [
                baseQueryItem,
                URLQueryItem(name: "page", value: "\(page)")
            ]
        }
    }
}
