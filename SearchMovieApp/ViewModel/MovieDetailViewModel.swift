//
//  MovieDetailViewModel.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/11.
//

import UIKit
import Combine
import CoreData

class MovieDetailViewModel {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @Published var movieDetail: MovieDetail?
    @Published var bookmarkedMovie: MovieInfo?
    
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
    
    func saveBookmark(movie: MovieInfo) {
        if let entity = NSEntityDescription.entity(forEntityName: "BookmarkMovie", in: context) {
            let newBookmark = NSManagedObject(entity: entity, insertInto: context)
            newBookmark.setValue(movie.adult, forKey: "adult")
            newBookmark.setValue(movie.backdropPath, forKey: "backdropPath")
            newBookmark.setValue(movie.genreIDS.map{ String($0) }.joined(), forKey: "genreIDS")
            newBookmark.setValue(movie.id, forKey: "id")
            newBookmark.setValue(movie.originalLanguage, forKey: "originalLanguage")
            newBookmark.setValue(movie.originalTitle, forKey: "originalTitle")
            newBookmark.setValue(movie.overview, forKey: "overview")
            newBookmark.setValue(movie.popularity, forKey: "popularity")
            newBookmark.setValue(movie.posterPath, forKey: "posterPath")
            newBookmark.setValue(movie.releaseDate, forKey: "releaseDate")
            newBookmark.setValue(movie.title, forKey: "title")
            newBookmark.setValue(movie.video, forKey: "video")
            newBookmark.setValue(movie.voteAverage, forKey: "voteAverage")
            newBookmark.setValue(movie.voteCount, forKey: "voteCount")
            newBookmark.setValue(Date(), forKey: "bookmarkedDate")
        }
        
        do {
            try context.save()
            // 저장 후 상세 화면의 bookmark 버튼 image 변경
            loadBookmarkedMovieBy(id: movie.id)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func loadBookmarkedMovieBy(id: Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BookmarkMovie")
        let predicate = NSPredicate(format: "id == %@", "\(id)")
        fetchRequest.predicate = predicate
        
        do {
            let bookmarkedMovie = try context.fetch(fetchRequest) as! [NSManagedObject]
            if bookmarkedMovie.count > 0, let movie = bookmarkedMovie.first {
                let adult = movie.value(forKey: "adult") as! Bool
                let backdropPath = movie.value(forKey: "backdropPath") as! String
                let genreIDS = movie.value(forKey: "genreIDS") as! String
                let id = movie.value(forKey: "id") as! Int
                let originalLanguage = movie.value(forKey: "originalLanguage") as! String
                let originalTitle = movie.value(forKey: "originalTitle") as! String
                let overview = movie.value(forKey: "overview") as! String
                let popularity = movie.value(forKey: "popularity") as! Double
                let posterPath = movie.value(forKey: "posterPath") as! String
                let releaseDate = movie.value(forKey: "releaseDate") as! String
                let title = movie.value(forKey: "title") as! String
                let video = movie.value(forKey: "video") as! Bool
                let voteAverage = movie.value(forKey: "voteAverage") as! Double
                let voteCount = movie.value(forKey: "voteCount") as! Int
                
                
                let movieInfo = MovieInfo(adult: adult,
                                 backdropPath: backdropPath,
                                 genreIDS: genreIDS.components(separatedBy: ",").map{ Int($0)! },
                                 id: id,
                                 originalLanguage: originalLanguage,
                                 originalTitle: originalTitle,
                                 overview: overview,
                                 popularity: popularity,
                                 posterPath: posterPath,
                                 releaseDate: releaseDate,
                                 title: title,
                                 video: video,
                                 voteAverage: voteAverage,
                                 voteCount: voteCount)
                
                self.bookmarkedMovie = movieInfo
            }
        } catch let error as NSError {
            print("데이터 가져오기 실패: \(error), \(error.userInfo)")
        }
    }
}
