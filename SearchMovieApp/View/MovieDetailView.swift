//
//  MovieDetailView.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/8.
//

import UIKit

class MovieDetailView: UIViewController {
    
    var movieInfo: MovieInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let movieInfo = self.movieInfo else { return }
        print(movieInfo.title)
    }
}
