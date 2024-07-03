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
    private let popularMovieButton = LabelButton(label: "인기 영화")
    private let horizontalScrollView = HorizontalScrollView(width: 3200, height: 200)
    
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
                self.fillScrollViewWithPoster(movies: movies)
            }
            .store(in: &cancellable)
        
        viewModel.fetchPopularMovie()
    }
    
    func configureUI() {
        setPopularMovie()
    }
    
    func setPopularMovie() {
        [popularMovieButton, horizontalScrollView].forEach{ view.addSubview($0) }
        
        NSLayoutConstraint.activate([
            popularMovieButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            popularMovieButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            horizontalScrollView.topAnchor.constraint(equalTo: popularMovieButton.bottomAnchor, constant: 5),
            horizontalScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            horizontalScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            horizontalScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func fillScrollViewWithPoster(movies: [MovieInfo]) {
        let parentView = horizontalScrollView.subviews.first!
        var prevTrailingAnchor = parentView.leadingAnchor
        
        for i in 0..<movies.count {
            let contentView = UIImageView()
            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.contentMode = .scaleAspectFit
            
            let titleLabel = UILabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.text = movies[i].originalTitle
            titleLabel.textAlignment = .center
            titleLabel.numberOfLines = 2
            
            parentView.addSubview(titleLabel)
            parentView.addSubview(contentView)
            
            NSLayoutConstraint.activate([
                contentView.topAnchor.constraint(equalTo: parentView.topAnchor),
                contentView.leadingAnchor.constraint(equalTo: prevTrailingAnchor, constant: i == 0 ? 0 : 10),
                contentView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
                contentView.widthAnchor.constraint(equalToConstant: 150),
                
                titleLabel.widthAnchor.constraint(equalToConstant: 150),
                titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                titleLabel.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 5),
            ])
            
            do {
                try viewModel.service.getPosterImage(posterURL: movies[i].posterPath)
                    .receive(on: DispatchQueue.main)
                    .sink { poster in
                        contentView.image = poster
                    }
                    .store(in: &cancellable)
            } catch {
                print("error > \(error.localizedDescription)")
            }
            
            if i == movies.count - 1 {
                contentView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
            }
            prevTrailingAnchor = contentView.trailingAnchor
        }
    }
}
