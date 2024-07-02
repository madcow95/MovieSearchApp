//
//  MovieHomeViewModel.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/2.
//

import Foundation

class MovieHomeViewModel {
    private let service = MovieSearchService()
    
    func fetchPopularMovie() async {
        await service.fetchPopularMovie(page: 1)
    }
}
