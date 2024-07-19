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
        label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)        
        
        return label
    }()
    private lazy var averageImageStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        for _ in 0...4 {
            let image = UIImage(systemName: "star")
            let imageView = UIImageView(image: image)
            imageView.tintColor = .systemYellow
            
            stack.addArrangedSubview(imageView)
        }
        
        return stack
    }()
    private lazy var trailerButton = LabelButton(label: "트레일러 재생",
                                                 buttonImage: UIImage(systemName: "play.fill"),
                                                 buttonColor: .white)
    private lazy var movieReleaseLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        label.textColor = .lightGray
        label.numberOfLines = 1
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return label
    }()
    private lazy var titleStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 8
        stack.addArrangedSubview(movieTitle)
        stack.addArrangedSubview(movieReleaseLabel)
        
        return stack
    }()
    private lazy var movieGenres: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .lightGray
        label.numberOfLines = 1
        label.textAlignment = .left
        
        return label
    }()
    private lazy var movieSummary: UILabel = {
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
        setNavigationUI()
        setScrollView()
        setMovieDetailView()
    }
    
    func setNavigationUI() {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "bookmark"),
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(self.addToBookmark))
//        if let selectedMovie = self.movieInfo {
//            detailViewModel.loadBookmarkBy(id: selectedMovie.id) { [weak self] info in
//                guard let self = self else { return }
//                DispatchQueue.main.async {
//                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: info == nil ? "bookmark" : "bookmark.fill"),
//                                                                        style: .plain,
//                                                                        target: self,
//                                                                        action: #selector(self.addToBookmark))
//                }
//            }
//        }
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
        [posterImage, titleStackView, averageImageStackView,
         trailerButton, movieGenres, movieSummary].forEach{ self.view.addSubview($0) }
        
        NSLayoutConstraint.activate([
            posterImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            posterImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            titleStackView.topAnchor.constraint(equalTo: posterImage.bottomAnchor, constant: 8),
            titleStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            titleStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            averageImageStackView.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 8),
            averageImageStackView.leadingAnchor.constraint(equalTo: titleStackView.leadingAnchor),
            
            trailerButton.centerYAnchor.constraint(equalTo: averageImageStackView.centerYAnchor),
            trailerButton.leadingAnchor.constraint(equalTo: averageImageStackView.trailingAnchor, constant: 8),
            
            movieGenres.topAnchor.constraint(equalTo: averageImageStackView.bottomAnchor, constant: 10),
            movieGenres.leadingAnchor.constraint(equalTo: titleStackView.leadingAnchor),
            movieGenres.trailingAnchor.constraint(equalTo: titleStackView.trailingAnchor),
            
            movieSummary.topAnchor.constraint(equalTo: movieGenres.bottomAnchor, constant: 8),
            movieSummary.leadingAnchor.constraint(equalTo: movieTitle.leadingAnchor),
            movieSummary.trailingAnchor.constraint(equalTo: titleStackView.trailingAnchor),
            movieSummary.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
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
        
        movieTitle.text = "\(detail.title)"
        movieReleaseLabel.text = "(\(detail.releaseDate.components(separatedBy: "-")[0]))"
        movieGenres.text = "\(detail.genres.map{ $0.name }.joined(separator: ", ")) (\(detail.runtime.minuteToHour))"
        movieSummary.text = detail.overview
        let starPoint: Double = detail.voteAverage / 2
        for i in 0...Int(starPoint) {
            guard let starImage = averageImageStackView.subviews[i] as? UIImageView else {
                continue
            }
            if i < Int(starPoint) {
                starImage.image = UIImage(systemName: "star.fill")
            } else {
                if starPoint.getOnlyDecimalPoint > 0.5 {
                    starImage.image = UIImage(systemName: "star.leadinghalf.filled")
                }
            }
        }
        let averageLabel = UILabel()
        averageLabel.text = " (\(starPoint.getTwoDecimal))"
        averageLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        averageLabel.textColor = .lightGray
        averageImageStackView.addArrangedSubview(averageLabel)
        trailerButton.addAction(UIAction { /*[weak self]*/ _ in
            // guard let self = self else { return }
            // MARK: TODO - trailer 재생 화면 띄우기(modal(webVie) or popup(avkit))
        }, for: .touchUpInside)
        trailerButton.titleLabel?.textColor = .lightGray
        trailerButton.tintColor = .white
        trailerButton.semanticContentAttribute = .forceLeftToRight
    }
    
    // CoreData or SwiftData로 영화정보 저장
    @objc func addToBookmark() {
        guard let selectedMovie = movieInfo else { return }
//        detailViewModel.saveBookmark(movie: selectedMovie) { [weak self] result in
//            guard let self = self else { return }
//            DispatchQueue.main.async {            
//                self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: result ? "bookmark.fill" : "bookmark")
//            }
//        }
    }
}
