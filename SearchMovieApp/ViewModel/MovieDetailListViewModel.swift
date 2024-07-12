//
//  MovieDetailListViewModel.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/11.
//

import Combine

class MovieDetailListViewModel {
    
    @Published var searchedMovies: [MovieInfo] = []
    private var cancellable = Set<AnyCancellable>()
}
