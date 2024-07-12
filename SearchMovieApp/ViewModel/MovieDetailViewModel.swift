//
//  MovieDetailViewModel.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/11.
//

import Foundation
import Combine

class MovieDetailViewModel {
    
    @Published var movieDetail: MovieDetail?
    private var cancellable = Set<AnyCancellable>()
    
    let service = MovieSearchService()
    
    func fetchMovieDetail(id: Int) {
        do {
            try service.getMovieDetailInfo(id: id)
                .receive(on: DispatchQueue.global())
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("error in MovieDetailViewModel - fetchMovieDetail() > \(error.localizedDescription) \(#line) \(#function)")
                    }
                } receiveValue: { [weak self] movieDetail in
                    guard let self = self else { return }
                    self.movieDetail = movieDetail
                }
                .store(in: &cancellable)
        } catch {
            print(error)
        }
    }
}
