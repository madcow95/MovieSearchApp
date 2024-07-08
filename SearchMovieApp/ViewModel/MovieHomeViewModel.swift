//
//  MovieHomeViewModel.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/2.
//

import Foundation
import Combine

class MovieHomeViewModel {
    @Published var popularMovies: [MovieInfo] = []
    @Published var famousMovies: [MovieInfo] = []
    @Published var upComingMovies: MovieModel? = nil
    
    private var cancellable = Set<AnyCancellable>()
    let service = MovieSearchService()
    
    func fetchMovies(searchType: SearchType, page: Int) {
        service.fetchMovie(searchType: searchType, page: page)
            .receive(on: DispatchQueue.global())
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("error while fetchMovies : \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] movie in
                guard let self = self else { return }
                if searchType == .weeklyPopular {
                    self.popularMovies = movie.results
                } else if searchType == .famous {
                    self.famousMovies = movie.results
                } else if searchType == .upComing {
                    self.upComingMovies = movie
                }
            }
            .store(in: &cancellable)
    }
}
