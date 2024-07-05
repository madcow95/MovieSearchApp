//
//  MovieHomeViewController.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/2.
//

import UIKit
import Combine

class MovieHomeViewController: UIViewController {
    // ViewModel
    private let viewModel = MovieHomeViewModel()
    
    // UIComponent
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var prevBottomAnchor: NSLayoutYAxisAnchor!
    private let popularMovieButton = LabelButton(label: "주간 인기 영화")
    private let popularScrollView = HorizontalScrollView(height: 250)
    private let onPlayingMovieButton = LabelButton(label: "현재 상영 영화")
    private let onPlayingScrollView = HorizontalScrollView(height: 250)
    private let upComingMovieButton = LabelButton(label: "개봉 예정 영화")
    private let upComingScrollView = HorizontalScrollView(height: 250)
    
    // Combine
    private var cancellable = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        fetchMovieDatas()
        configureUI()
    }
    
    func fetchMovieDatas() {
        viewModel.$popularMovies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] movies in
                guard let self = self else { return }
                self.setMovies(parentView: popularScrollView.subviews.first!, movies: movies)
            }
            .store(in: &cancellable)
        
        viewModel.$onPlayingMovies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] movies in
                guard let self = self else { return }
                self.setMovies(parentView: onPlayingScrollView.subviews.first!, movies: movies)
            }
            .store(in: &cancellable)
        
        viewModel.$upComingMovies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] movies in
                guard let self = self else { return }
                self.setMovies(parentView: upComingScrollView.subviews.first!, movies: movies)
            }
            .store(in: &cancellable)
        
        viewModel.fetchMovies(searchType: .weeklyPopular, page: 1)
        viewModel.fetchMovies(searchType: .onPlaying, page: 1)
        viewModel.fetchMovies(searchType: .upComing, page: 1)
    }
    
    func configureUI() {
        setScrollView()
        setButtonAction()
        setPopularMovieScrollView()
        setOnPlayingMovieScrollView()
        setUpcomingMovieScrollView()
    }
    
    func setScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    func setButtonAction() {
        popularMovieButton.addAction(UIAction{ [weak self] _ in
            guard let self = self else { return }
            let detailView = MovieDetailListViewController()
            detailView.loadedMovies = viewModel.popularMovies
            self.navigationController?.pushViewController(detailView, animated: true)
        }, for: .touchUpInside)
        
        onPlayingMovieButton.addAction(UIAction{ [weak self] _ in
            guard let self = self else { return }
            let detailView = MovieDetailListViewController()
            detailView.loadedMovies = viewModel.onPlayingMovies
            self.navigationController?.pushViewController(detailView, animated: true)
        }, for: .touchUpInside)
        
        upComingMovieButton.addAction(UIAction{ [weak self] _ in
            guard let self = self else { return }
            let detailView = MovieDetailListViewController()
            detailView.loadedMovies = viewModel.upComingMovies
            self.navigationController?.pushViewController(detailView, animated: true)
        }, for: .touchUpInside)
    }
    
    func setPopularMovieScrollView() {
        let divider = CustomDivider()
        [popularMovieButton, popularScrollView, divider].forEach{ contentView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            popularMovieButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            popularMovieButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
            
            popularScrollView.topAnchor.constraint(equalTo: popularMovieButton.bottomAnchor, constant: 5),
            popularScrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            popularScrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            divider.topAnchor.constraint(equalTo: popularScrollView.bottomAnchor, constant: 10),
            divider.leadingAnchor.constraint(equalTo: popularScrollView.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: popularScrollView.trailingAnchor)
        ])
        prevBottomAnchor = divider.bottomAnchor
    }
    
    func setOnPlayingMovieScrollView() {
        let divider = CustomDivider()
        [onPlayingMovieButton, onPlayingScrollView, divider].forEach{ contentView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            onPlayingMovieButton.topAnchor.constraint(equalTo: prevBottomAnchor, constant: 20),
            onPlayingMovieButton.leadingAnchor.constraint(equalTo: popularScrollView.leadingAnchor),
            
            onPlayingScrollView.topAnchor.constraint(equalTo: onPlayingMovieButton.bottomAnchor, constant: 5),
            onPlayingScrollView.leadingAnchor.constraint(equalTo: popularScrollView.leadingAnchor),
            onPlayingScrollView.trailingAnchor.constraint(equalTo: popularScrollView.trailingAnchor),
            
            divider.topAnchor.constraint(equalTo: onPlayingScrollView.bottomAnchor, constant: 10),
            divider.leadingAnchor.constraint(equalTo: onPlayingScrollView.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: onPlayingScrollView.trailingAnchor)
        ])
        prevBottomAnchor = divider.bottomAnchor
    }
    
    func setUpcomingMovieScrollView() {
        let divider = CustomDivider()
        [upComingMovieButton, upComingScrollView, divider].forEach{ contentView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            upComingMovieButton.topAnchor.constraint(equalTo: prevBottomAnchor, constant: 20),
            upComingMovieButton.leadingAnchor.constraint(equalTo: popularScrollView.leadingAnchor),
            
            upComingScrollView.topAnchor.constraint(equalTo: upComingMovieButton.bottomAnchor, constant: 5),
            upComingScrollView.leadingAnchor.constraint(equalTo: popularScrollView.leadingAnchor),
            upComingScrollView.trailingAnchor.constraint(equalTo: popularScrollView.trailingAnchor),
            
            divider.topAnchor.constraint(equalTo: upComingScrollView.bottomAnchor, constant: 10),
            divider.leadingAnchor.constraint(equalTo: upComingScrollView.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: upComingScrollView.trailingAnchor),
            divider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        prevBottomAnchor = divider.bottomAnchor
    }
    
    func setMovies(parentView: UIView, movies: [MovieInfo]) {
        var prevTrailingAnchor = parentView.leadingAnchor
        
        for i in 0..<movies.count {
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.distribution = .equalSpacing
            stackView.isUserInteractionEnabled = true
            let tapGesture = CustomTapGesture(target: self, action: #selector(stackTapped(_:)))
            tapGesture.movie = movies[i]
            stackView.addGestureRecognizer(tapGesture)
            
            let posterView = UIImageView()
            posterView.translatesAutoresizingMaskIntoConstraints = false
            posterView.contentMode = .scaleAspectFit
            posterView.heightAnchor.constraint(equalToConstant: 210).isActive = true
            
            let titleLabel = UILabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.text = movies[i].title
            titleLabel.textColor = .white
            titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            titleLabel.textAlignment = .center
            titleLabel.numberOfLines = 2
            titleLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            stackView.addArrangedSubview(posterView)
            stackView.addArrangedSubview(titleLabel)
            parentView.addSubview(stackView)
            
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: parentView.topAnchor),
                stackView.leadingAnchor.constraint(equalTo: prevTrailingAnchor, constant: i == 0 ? 0 : 10),
                stackView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
                stackView.widthAnchor.constraint(equalToConstant: 150),
            ])
            
            do {
                try viewModel.service.getPosterImage(posterURL: movies[i].posterPath)
                    .receive(on: DispatchQueue.main)
                    .sink { poster in
                        posterView.image = poster
                    }
                    .store(in: &cancellable)
            } catch {
                print("error > \(error.localizedDescription)")
            }
            
            if i == movies.count - 1 {
                stackView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
            }
            prevTrailingAnchor = stackView.trailingAnchor
        }
    }
    
    @objc func stackTapped(_ sender: CustomTapGesture) {
        guard let movie = sender.movie else {
            print("no movie created")
            return
        }
        
        print(movie)
    }
}
