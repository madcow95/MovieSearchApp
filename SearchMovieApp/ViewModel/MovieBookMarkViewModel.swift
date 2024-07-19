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
    
    func loadAllBookmarkMovies() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BookmarkMovie")
        do {
            let movies = try context.fetch(fetchRequest) as! [NSManagedObject]
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
                print(bookmarkMovies)
            }
        } catch let error as NSError {
            print("데이터 가져오기 실패: \(error), \(error.userInfo)")
        }
    }
}
