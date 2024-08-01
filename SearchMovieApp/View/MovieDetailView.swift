//
//  MovieDetailView.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/8.
//

import UIKit
import Combine
import SnapKit

class MovieDetailView: UIViewController {
    
    var movieInfo: MovieInfo?
    
    private var isBookmarked: Bool = false
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.popViewController(animated: true)
    }
    
    func fetchMovie(id: Int) {
        detailViewModel.$movieDetail
            .receive(on: DispatchQueue.main)
            .sink { [weak self] detail in
                guard let self = self, let detail = detail else { return }
                self.setDataToUIComponents(detail: detail)
            }
            .store(in: &cancellable)
        
        detailViewModel.$bookmarkedMovie
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self = self else { return }
                if result != nil {
                    isBookmarked = true
                    self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "bookmark.fill")
                } else {
                    isBookmarked = false
                    self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "bookmark")
                }
            }
            .store(in: &cancellable)
        
        detailViewModel.fetchMovieDetail(id: id)
        detailViewModel.loadBookmarkedMovieBy(id: id)
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
    }
    
    func setScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints { [weak self] scroll in
            guard let self = self else { return }
            scroll.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            scroll.left.equalTo(self.view.snp.left)
            scroll.right.equalTo(self.view.snp.right)
            scroll.bottom.equalTo(self.view.snp.bottom)
        }
        
        contentView.snp.makeConstraints { [weak self] content in
            guard let self = self else { return }
            content.top.equalTo(self.scrollView.snp.top)
            content.left.equalTo(self.scrollView.snp.left)
            content.right.equalTo(self.scrollView.snp.right)
            content.bottom.equalTo(self.scrollView.snp.bottom)
            content.width.equalTo(self.scrollView.snp.width)
        }
    }
    
    func setMovieDetailView() {
        [posterImage, titleStackView, averageImageStackView,
         trailerButton, movieGenres, movieSummary].forEach{ self.view.addSubview($0) }
        
        posterImage.snp.makeConstraints { [weak self] poster in
            guard let self = self else { return }
            poster.top.equalTo(self.contentView.snp.top).offset(20)
            poster.centerX.equalTo(self.contentView.snp.centerX)
        }
        
        titleStackView.snp.makeConstraints { [weak self] stack in
            guard let self = self else { return }
            stack.top.equalTo(self.posterImage.snp.bottom).offset(8)
            stack.left.equalTo(self.contentView.snp.left).offset(15)
            stack.right.equalTo(self.contentView.snp.right).offset(-15)
        }
        
        averageImageStackView.snp.makeConstraints { [weak self] stack in
            guard let self = self else { return }
            stack.top.equalTo(self.titleStackView.snp.bottom).offset(8)
            stack.left.equalTo(self.titleStackView.snp.left)
        }
        
        trailerButton.snp.makeConstraints { [weak self] btn in
            guard let self = self else { return }
            btn.centerY.equalTo(self.averageImageStackView.snp.centerY)
            btn.left.equalTo(self.averageImageStackView.snp.right).offset(8)
        }
        
        movieGenres.snp.makeConstraints { [weak self] movie in
            guard let self = self else { return }
            movie.top.equalTo(self.averageImageStackView.snp.bottom).offset(10)
            movie.left.equalTo(self.titleStackView.snp.left)
            movie.right.equalTo(self.titleStackView.snp.right)
        }
        
        movieSummary.snp.makeConstraints { [weak self] summary in
            guard let self = self else { return }
            summary.top.equalTo(self.movieGenres.snp.bottom).offset(8)
            summary.left.equalTo(self.movieTitle.snp.left)
            summary.right.equalTo(self.titleStackView.snp.right)
            summary.bottom.equalTo(self.contentView.snp.bottom)
        }
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
        if isBookmarked {
            detailViewModel.deleteBookmark(movie: selectedMovie)
        } else {
            detailViewModel.saveBookmark(movie: selectedMovie)
        }
        isBookmarked.toggle()
    }
}
