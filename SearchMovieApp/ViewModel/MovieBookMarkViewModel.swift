//
//  MovieBookMarkViewModel.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/16.
//

import UIKit
import CoreData
import Combine

class MovieBookMarkViewModel {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @Published var bookmarkMovies: [MovieInfo] = []
    @Published var posterImage: UIImage?
    
    private let service = MovieSearchService()
    private var cancellable = Set<AnyCancellable>()
    
    func loadAllBookmarkMovies() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BookmarkMovie")
        do {
            var movies = try context.fetch(fetchRequest) as! [NSManagedObject]
            movies.sort { first, second in
                let firstDate = first.value(forKey: "bookmarkedDate") as! Date
                let secondDate = second.value(forKey: "bookmarkedDate") as! Date
                
                return firstDate < secondDate
            }
            if movies.count > 0 {
                bookmarkMovies = movies.map{ movie in
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
                    
                    return MovieInfo(adult: adult,
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
                }
            }
        } catch let error as NSError {
            print("데이터 가져오기 실패: \(error)")
        }
    }
    
    func deleteBookmark(movie: MovieInfo) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BookmarkMovie")
        let predicate = NSPredicate(format: "id == %@", "\(movie.id)")
        fetchRequest.predicate = predicate
        
        do {
            let deleteTargetMovies = try context.fetch(fetchRequest) as! [NSManagedObject]
            if deleteTargetMovies.count > 0, let targetMovie = deleteTargetMovies.first {
                let target = try context.existingObject(with: targetMovie.objectID)
                context.delete(target)
                try context.save()
                loadAllBookmarkMovies()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchPosterImage(posterURL: String) {
        do {
            try self.service.getPosterImage(posterURL: posterURL)
                .sink { [weak self] poster in
                    guard let self = self else { return }
                    self.posterImage = poster
                }
                .store(in: &cancellable)
        } catch {
            print(error.localizedDescription)
        }
    }
}
