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
    @Published var searchText: String = ""
    @Published var searchedMovies: [MovieInfo] = []
    
    private var cancellable = Set<AnyCancellable>()
    let service = MovieSearchService()
    
    init() {
        $searchText
            .debounce(for: 0.5, scheduler: RunLoop.current)
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
            .sink { [weak self] title in
                guard let self = self, !title.isEmpty else { return }
                self.searchMovieBy(searchType: .search, page: 1, title: title)
            }
            .store(in: &cancellable)
    }
    
    // 이미지 캐싱, 프리 패칭?, Alamofire 뜯어봐
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
    
    func searchMovieBy(searchType: SearchType, page: Int, title: String) {
        service.fetchMovie(searchType: searchType, page: page, query: title)
            .receive(on: DispatchQueue.global())
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { [weak self] movies in
                guard let self = self else { return }
                searchedMovies = movies.results
            }
            .store(in: &cancellable)
    }
}
