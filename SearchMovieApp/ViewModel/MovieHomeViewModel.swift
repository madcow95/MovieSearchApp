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
    
    private var cancellable = Set<AnyCancellable>()
    let service = MovieSearchService()
    
    func fetchPopularMovie() {
        service.fetchPopularMovie(page: 1)
            .receive(on: DispatchQueue.global())
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("error in fetchPopularmovie : \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] movies in
                guard let self = self else { return }
                self.popularMovies = movies
            }
            .store(in: &cancellable)
    }
    
    func fetchPosterImage(posterURL: String) {
        do {
            try service.getPosterImage(posterURL: posterURL)
                .sink { [weak self] poster in
                    guard let self = self else { return }
                    
                }
                .store(in: &cancellable)
        } catch {
            
        }
    }
}
