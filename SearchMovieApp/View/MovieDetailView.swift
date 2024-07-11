//
//  MovieDetailView.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/8.
//

import UIKit
import Combine

class MovieDetailView: UIViewController {
    
    var movieInfo: MovieInfo?
    
    private var cancellable = Set<AnyCancellable>()
    private let detailViewModel = MovieDetailViewModel()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        
        return scroll
    }()
    private lazy var contentView: UIView = {
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        
        return content
    }()
    private lazy var posterImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.widthAnchor.constraint(equalToConstant: view.frame.width / 2).isActive = true
        image.heightAnchor.constraint(equalToConstant: view.frame.height / 3).isActive = true
        
        return image
    }()
    private lazy var movieTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .left
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let movieInfo = self.movieInfo else { return }
        
        fetchMovie(id: movieInfo.id)
        configureUI()
    }
    
    func fetchMovie(id: Int) {
        detailViewModel.$movieDetail
            .receive(on: DispatchQueue.main)
            .sink { [weak self] detail in
                guard let self = self, let detail = detail else { return }
                self.setDataToUIComponents(detail: detail)
            }
            .store(in: &cancellable)
        
        detailViewModel.fetchMovieDetail(id: id)
    }
    
    func configureUI() {
        setScrollView()
        setMovieDetailView()
    }
    
    func setScrollView() {
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
    
    func setMovieDetailView() {
        [posterImage, movieTitle].forEach{ self.view.addSubview($0) }
        
        NSLayoutConstraint.activate([
            posterImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            posterImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            
            movieTitle.topAnchor.constraint(equalTo: posterImage.topAnchor),
            movieTitle.leadingAnchor.constraint(equalTo: posterImage.trailingAnchor, constant: 10),
            movieTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    func setDataToUIComponents(detail: MovieDetail) {
        do {
            try detailViewModel.service.getPosterImage(posterURL: movieInfo!.posterPath)
                .receive(on: DispatchQueue.main)
                .assign(to: \.image, on: posterImage)
                .store(in: &cancellable)
        } catch {
            print(error)
        }
        
        movieTitle.text = "\(detail.title) (\(detail.releaseDate.components(separatedBy: "-")[0]))"
    }
}
