//
//  MovieHomeView.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/8.
//

import UIKit
import Combine

class MovieHomeView: UIViewController {
    
    // UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private lazy var popularMovieButton = LabelButton(label: "주간 인기 영화")
    private lazy var popularMovieCollection = CustomHorizontalScroll()
    private lazy var onPlayingMovieButton = LabelButton(label: "현재 상영 영화")
    private lazy var onPlayingMovieCollection = CustomHorizontalScroll()
    private lazy var upComingMovieButton = LabelButton(label: "개봉 예정 영화")
    private lazy var upComingMovieCollection = CustomHorizontalScroll()
    private var prevBottomAnchor: NSLayoutYAxisAnchor!
    
    // Data Source
    private let viewModel = MovieHomeViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchDatas()
        configureUI()
    }
    
    func fetchDatas() {
        viewModel.$popularMovies
            .receive(on: DispatchQueue.main)
            .map{ $0.count > 0 }
            .sink { [weak self] movieExist in
                guard let self = self else { return }
                if movieExist {
                    self.popularMovieCollection.reloadData()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$onPlayingMovies
            .receive(on: DispatchQueue.main)
            .map{ $0.count > 0 }
            .sink { [weak self] movieExist in
                guard let self = self else { return }
                if movieExist {
                    self.onPlayingMovieCollection.reloadData()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$upComingMovies
            .receive(on: DispatchQueue.main)
            .compactMap{ $0 }
            .sink { [weak self] movieInfo in
                guard let self = self else { return }
                if let dates = movieInfo.dates {
                    let minimumDate = dates.minimum
                    let maximumDate = dates.maximum
                    self.upComingMovieButton.setTitle("개봉 예정 영화 (\(minimumDate) ~ \(maximumDate))", for: .normal)
                    if movieInfo.results.count > 0 {
                        self.upComingMovieCollection.reloadData()
                    }
                }
            }
            .store(in: &cancellables)
        
        viewModel.fetchMovies(searchType: .weeklyPopular, page: 1)
        viewModel.fetchMovies(searchType: .onPlaying, page: 1)
        viewModel.fetchMovies(searchType: .upComing, page: 1)
    }
    
    func configureUI() {
        self.view.backgroundColor = .black
        self.title = "Movie Search"
        setMainScrollView()
        setPopularMovieScrollView()
        setOnPlayingMovieScrollView()
        setUpComingMovieScrollView()
    }
    
    func setMainScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    func setPopularMovieScrollView() {
        popularMovieCollection.register(MovieHomeViewCell.self, forCellWithReuseIdentifier: "PopularMovieHomeViewCell")
        popularMovieCollection.dataSource = self
        
        let divider = CustomDivider()
        [popularMovieButton, popularMovieCollection, divider].forEach{ contentView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            popularMovieButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            popularMovieButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            
            popularMovieCollection.topAnchor.constraint(equalTo: popularMovieButton.bottomAnchor, constant: 10),
            popularMovieCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            popularMovieCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            popularMovieCollection.heightAnchor.constraint(equalToConstant: 250),
            
            divider.topAnchor.constraint(equalTo: popularMovieCollection.bottomAnchor, constant: 15),
            divider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            divider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
        
        prevBottomAnchor = divider.bottomAnchor
    }
    
    func setOnPlayingMovieScrollView() {
        onPlayingMovieCollection.register(MovieHomeViewCell.self, forCellWithReuseIdentifier: "OnPlayingMovieHomeViewCell")
        onPlayingMovieCollection.dataSource = self
        
        let divider = CustomDivider()
        [onPlayingMovieButton, onPlayingMovieCollection, divider].forEach{ contentView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            onPlayingMovieButton.topAnchor.constraint(equalTo: prevBottomAnchor, constant: 10),
            onPlayingMovieButton.leadingAnchor.constraint(equalTo: popularMovieCollection.leadingAnchor, constant: 10),
            
            onPlayingMovieCollection.topAnchor.constraint(equalTo: onPlayingMovieButton.bottomAnchor, constant: 10),
            onPlayingMovieCollection.leadingAnchor.constraint(equalTo: popularMovieCollection.leadingAnchor),
            onPlayingMovieCollection.trailingAnchor.constraint(equalTo: popularMovieCollection.trailingAnchor),
            onPlayingMovieCollection.heightAnchor.constraint(equalToConstant: 250),
            
            divider.topAnchor.constraint(equalTo: onPlayingMovieCollection.bottomAnchor, constant: 10),
            divider.leadingAnchor.constraint(equalTo: onPlayingMovieCollection.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: onPlayingMovieCollection.trailingAnchor)
        ])
        
        prevBottomAnchor = divider.bottomAnchor
    }
    
    func setUpComingMovieScrollView() {
        upComingMovieCollection.register(MovieHomeViewCell.self, forCellWithReuseIdentifier: "UpComingMovieHomeViewCell")
        upComingMovieCollection.dataSource = self
        
        let divider = CustomDivider()
        [upComingMovieButton, upComingMovieCollection, divider].forEach{ contentView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            upComingMovieButton.topAnchor.constraint(equalTo: prevBottomAnchor, constant: 10),
            upComingMovieButton.leadingAnchor.constraint(equalTo: onPlayingMovieCollection.leadingAnchor, constant: 10),
            
            upComingMovieCollection.topAnchor.constraint(equalTo: upComingMovieButton.bottomAnchor, constant: 10),
            upComingMovieCollection.leadingAnchor.constraint(equalTo: onPlayingMovieCollection.leadingAnchor),
            upComingMovieCollection.trailingAnchor.constraint(equalTo: onPlayingMovieCollection.trailingAnchor),
            upComingMovieCollection.heightAnchor.constraint(equalToConstant: 250),
            
            divider.topAnchor.constraint(equalTo: upComingMovieCollection.bottomAnchor, constant: 10),
            divider.leadingAnchor.constraint(equalTo: upComingMovieCollection.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: upComingMovieCollection.trailingAnchor),
            divider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        prevBottomAnchor = divider.bottomAnchor
    }
}

extension MovieHomeView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.popularMovieCollection {
            return viewModel.popularMovies.count
        } else if collectionView == self.onPlayingMovieCollection {
            return viewModel.onPlayingMovies.count
        } else if collectionView == self.upComingMovieCollection {
            if let movie = viewModel.upComingMovies {
                return movie.results.count
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var identifier: String = ""
        
        if collectionView == self.popularMovieCollection {
            identifier = "PopularMovieHomeViewCell"
        } else if collectionView == self.onPlayingMovieCollection {
            identifier = "OnPlayingMovieHomeViewCell"
        } else if collectionView == self.upComingMovieCollection {
            identifier = "UpComingMovieHomeViewCell"
        }
        
        guard !identifier.isEmpty, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? MovieHomeViewCell else {
            return UICollectionViewCell()
        }
        
        if collectionView == self.popularMovieCollection {
            let movie = viewModel.popularMovies[indexPath.row]
            cell.configureCell(movie: movie)
        } else if collectionView == self.onPlayingMovieCollection {
            let movie = viewModel.onPlayingMovies[indexPath.row]
            cell.configureCell(movie: movie)
        } else if collectionView == self.upComingMovieCollection {
            if let movie = viewModel.upComingMovies {
                let movie = movie.results[indexPath.row]
                cell.configureCell(movie: movie)
            }
        }
        
        return cell
    }
}
