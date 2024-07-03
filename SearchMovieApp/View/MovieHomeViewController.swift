//
//  MovieHomeViewController.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/2.
//

import UIKit
import Combine

class MovieHomeViewController: UIViewController {
    
    private var cancellable = Set<AnyCancellable>()
    private let popularMovieButton = LabelButton(label: "주간 인기 영화")
    private let popularScrollView = HorizontalScrollView(height: 250)
    private let onPlayingMovieButton = LabelButton(label: "현재 상영 영화")
    private let onPlayingScrollView = HorizontalScrollView(height: 250)
    
    private var prevBottomAnchor: NSLayoutYAxisAnchor!
    
    private let viewModel = MovieHomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        fetchMovieDatas()
        configureUI()
    }
    
    func fetchMovieDatas() {
        viewModel.$popularMovies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] movies in
                guard let self = self else { return }
                self.setWeeklyPopularMovies(movies: movies)
            }
            .store(in: &cancellable)
        
        viewModel.$onPlayingMovies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] movies in
                guard let self = self else { return }
                self.setOnPlayingMovies(movies: movies)
            }
            .store(in: &cancellable)
        
        viewModel.fetchMovies(searchType: .weeklyPopular, page: 1)
        viewModel.fetchMovies(searchType: .onPlaying, page: 1)
    }
    
    func configureUI() {
        setPopularMovie()
//        setOnPlayingMovie()
    }
    
    func setPopularMovie() {
        [popularMovieButton, popularScrollView].forEach{ view.addSubview($0) }
        
        NSLayoutConstraint.activate([
            popularMovieButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            popularMovieButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            
            popularScrollView.topAnchor.constraint(equalTo: popularMovieButton.bottomAnchor, constant: 5),
            popularScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            popularScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            popularScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//            popularScrollView.heightAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    func setOnPlayingMovie() {
        [onPlayingMovieButton, onPlayingScrollView].forEach{ view.addSubview($0) }
        
        NSLayoutConstraint.activate([
            onPlayingMovieButton.topAnchor.constraint(equalTo: popularScrollView.bottomAnchor, constant: 20),
            onPlayingMovieButton.leadingAnchor.constraint(equalTo: popularScrollView.leadingAnchor),
            
            onPlayingScrollView.topAnchor.constraint(equalTo: onPlayingMovieButton.bottomAnchor, constant: 5),
            onPlayingScrollView.leadingAnchor.constraint(equalTo: popularScrollView.leadingAnchor),
            onPlayingScrollView.trailingAnchor.constraint(equalTo: popularScrollView.trailingAnchor),
            onPlayingScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setWeeklyPopularMovies(movies: [MovieInfo]) {
        let parentView = popularScrollView.subviews.first!
        var prevTrailingAnchor = parentView.leadingAnchor
        
        for i in 0..<movies.count {
            let posterView = UIImageView()
            posterView.translatesAutoresizingMaskIntoConstraints = false
            posterView.contentMode = .scaleAspectFit
            
            let titleLabel = UILabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.text = movies[i].title
            titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            titleLabel.textAlignment = .center
            titleLabel.numberOfLines = 2
            
            parentView.addSubview(posterView)
            parentView.addSubview(titleLabel)
            
            NSLayoutConstraint.activate([
                posterView.topAnchor.constraint(equalTo: parentView.topAnchor),
                posterView.leadingAnchor.constraint(equalTo: prevTrailingAnchor, constant: i == 0 ? 0 : 10),
                posterView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
                posterView.widthAnchor.constraint(equalToConstant: 150),
                
                titleLabel.centerXAnchor.constraint(equalTo: posterView.centerXAnchor),
                titleLabel.topAnchor.constraint(equalTo: posterView.bottomAnchor, constant: 5),
                titleLabel.widthAnchor.constraint(equalToConstant: 150),
            ])
            
            do {
                try viewModel.service.getPosterImage(posterURL: movies[i].posterPath)
                    .receive(on: DispatchQueue.main)
                    .sink { poster in
                        posterView.image = poster
                        posterView.layer.shadowColor = UIColor.black.cgColor
                        posterView.layer.shadowRadius = 3.0
                        posterView.layer.shadowOpacity = 1.0
                        posterView.layer.shadowOffset = CGSize(width: 4, height: 4)
                        posterView.layer.masksToBounds = false
                    }
                    .store(in: &cancellable)
            } catch {
                print("error > \(error.localizedDescription)")
            }
            
            if i == movies.count - 1 {
                posterView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
                prevBottomAnchor = titleLabel.bottomAnchor
            }
            prevTrailingAnchor = posterView.trailingAnchor
        }
    }
    
    func setOnPlayingMovies(movies: [MovieInfo]) {
        
    }
}
