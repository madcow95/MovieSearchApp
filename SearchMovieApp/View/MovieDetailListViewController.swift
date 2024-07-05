//
//  MovieDetailListViewController.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/5.
//

import UIKit

class MovieDetailListViewController: UIViewController {
    
    var loadedMovies: [MovieInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(loadedMovies.count)
    }
}
