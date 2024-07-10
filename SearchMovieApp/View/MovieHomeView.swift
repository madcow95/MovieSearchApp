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
    private let searchController = UISearchController()
    private lazy var popularMovieButton = LabelButton(label: "주간 인기 영화")
    private lazy var popularMovieCollection = CustomHorizontalScroll()
    private lazy var famousMovieButton = LabelButton(label: "역대 평점 높은 영화")
    private lazy var famousMovieCollection = CustomHorizontalScroll()
    private lazy var upComingMovieButton = LabelButton(label: "개봉 예정 영화")
    private lazy var upComingMovieCollection = CustomHorizontalScroll()
    let resultsTableViewController = UITableViewController()
    let resultsTableView = UITableView()
    private var prevBottomAnchor: NSLayoutYAxisAnchor!
    
    // Data Source
    private let viewModel = MovieHomeViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchDatas()
        setLabelButtonAction()
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
        
        viewModel.$famousMovies
            .receive(on: DispatchQueue.main)
            .map{ $0.count > 0 }
            .sink { [weak self] movieExist in
                guard let self = self else { return }
                if movieExist {
                    self.famousMovieCollection.reloadData()
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
        
        viewModel.$searchedMovies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] movies in
                guard let self = self else { return }
                if movies.count > 0 {
                    self.resultsTableViewController.tableView.reloadData()
                }
            }
            .store(in: &cancellables)
        
        viewModel.fetchMovies(searchType: .weeklyPopular, page: 1)
        viewModel.fetchMovies(searchType: .famous, page: 1)
        viewModel.fetchMovies(searchType: .upComing, page: 1)
    }
    
    func setLabelButtonAction() {
        // MARK: - 반복문으로 처리?
        popularMovieButton.addAction(UIAction{ [weak self] _ in
            guard let self = self else { return }
            let detailListView = MovieDetailListViewController()
            detailListView.loadedMovies = viewModel.popularMovies
            self.navigationController?.pushViewController(detailListView, animated: true)
        }, for: .touchUpInside)
        
        famousMovieButton.addAction(UIAction{ [weak self] _ in
            guard let self = self else { return }
            let detailListView = MovieDetailListViewController()
            detailListView.loadedMovies = viewModel.famousMovies
            self.navigationController?.pushViewController(detailListView, animated: true)
        }, for: .touchUpInside)
    
        upComingMovieButton.addAction(UIAction{ [weak self] _ in
            guard let self = self else { return }
            let detailListView = MovieDetailListViewController()
            detailListView.loadedMovies = viewModel.upComingMovies!.results
            self.navigationController?.pushViewController(detailListView, animated: true)
        }, for: .touchUpInside)
    }
    
    func configureUI() {
        
//        print(self.navigationController!.navigationItem.titleView!.frame.height)
//        print(self.searchController.searchBar.frame.height)
//        let y = self.navigationController!.navigationBar.frame.height + self.searchController.searchBar.frame.height
        self.view.backgroundColor = .black
        setNavigationBar()
        setMainScrollView()
        setPopularMovieScrollView()
        setFamousMovieScrollView()
        setUpComingMovieScrollView()
        
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.frame = CGRect(x: 0, y: view.frame.height / 9, width: view.frame.width, height: view.frame.height)
        resultsTableView.alpha = 0.0
        resultsTableViewController.tableView = resultsTableView
        
        // 결과 테이블뷰를 뷰에 추가
        view.addSubview(resultsTableView)
    }
    
    func setNavigationBar() {
        // MARK: TODO - button item 선택 -> 검색창 생성 -> 영화 검색 목록
        self.title = "Movie Search"
        
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.sizeToFit()
        navigationItem.searchController = searchController
        definesPresentationContext = true
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
        popularMovieCollection.delegate = self
        
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
    
    func setFamousMovieScrollView() {
        famousMovieCollection.register(MovieHomeViewCell.self, forCellWithReuseIdentifier: "FamousMovieHomeViewCell")
        famousMovieCollection.dataSource = self
        famousMovieCollection.delegate = self
        
        let divider = CustomDivider()
        [famousMovieButton, famousMovieCollection, divider].forEach{ contentView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            famousMovieButton.topAnchor.constraint(equalTo: prevBottomAnchor, constant: 10),
            famousMovieButton.leadingAnchor.constraint(equalTo: popularMovieCollection.leadingAnchor, constant: 10),
            
            famousMovieCollection.topAnchor.constraint(equalTo: famousMovieButton.bottomAnchor, constant: 10),
            famousMovieCollection.leadingAnchor.constraint(equalTo: popularMovieCollection.leadingAnchor),
            famousMovieCollection.trailingAnchor.constraint(equalTo: popularMovieCollection.trailingAnchor),
            famousMovieCollection.heightAnchor.constraint(equalToConstant: 250),
            
            divider.topAnchor.constraint(equalTo: famousMovieCollection.bottomAnchor, constant: 10),
            divider.leadingAnchor.constraint(equalTo: famousMovieCollection.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: famousMovieCollection.trailingAnchor)
        ])
        
        prevBottomAnchor = divider.bottomAnchor
    }
    
    func setUpComingMovieScrollView() {
        upComingMovieCollection.register(MovieHomeViewCell.self, forCellWithReuseIdentifier: "UpComingMovieHomeViewCell")
        upComingMovieCollection.dataSource = self
        upComingMovieCollection.delegate = self
        
        let divider = CustomDivider()
        [upComingMovieButton, upComingMovieCollection, divider].forEach{ contentView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            upComingMovieButton.topAnchor.constraint(equalTo: prevBottomAnchor, constant: 10),
            upComingMovieButton.leadingAnchor.constraint(equalTo: famousMovieCollection.leadingAnchor, constant: 10),
            
            upComingMovieCollection.topAnchor.constraint(equalTo: upComingMovieButton.bottomAnchor, constant: 10),
            upComingMovieCollection.leadingAnchor.constraint(equalTo: famousMovieCollection.leadingAnchor),
            upComingMovieCollection.trailingAnchor.constraint(equalTo: famousMovieCollection.trailingAnchor),
            upComingMovieCollection.heightAnchor.constraint(equalToConstant: 250),
            
            divider.topAnchor.constraint(equalTo: upComingMovieCollection.bottomAnchor, constant: 10),
            divider.leadingAnchor.constraint(equalTo: upComingMovieCollection.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: upComingMovieCollection.trailingAnchor),
            divider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        prevBottomAnchor = divider.bottomAnchor
    }
}

extension MovieHomeView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.popularMovieCollection {
            return viewModel.popularMovies.count
        } else if collectionView == self.famousMovieCollection {
            return viewModel.famousMovies.count
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
        } else if collectionView == self.famousMovieCollection {
            identifier = "FamousMovieHomeViewCell"
        } else if collectionView == self.upComingMovieCollection {
            identifier = "UpComingMovieHomeViewCell"
        }
        
        guard !identifier.isEmpty, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? MovieHomeViewCell else {
            return UICollectionViewCell()
        }
        
        if collectionView == self.popularMovieCollection {
            let movie = viewModel.popularMovies[indexPath.row]
            cell.configureCell(movie: movie)
        } else if collectionView == self.famousMovieCollection {
            let movie = viewModel.famousMovies[indexPath.row]
            cell.configureCell(movie: movie)
        } else if collectionView == self.upComingMovieCollection {
            if let movie = viewModel.upComingMovies {
                let movie = movie.results[indexPath.row]
                cell.configureCell(movie: movie)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // MARK: TODO - 영화 상세 목록 페이지로 이동
        var movie: MovieInfo? = nil
        if collectionView == self.popularMovieCollection {
            movie = viewModel.popularMovies[indexPath.row]
        } else if collectionView == self.famousMovieCollection {
            movie = viewModel.famousMovies[indexPath.row]
        } else if collectionView == self.upComingMovieCollection {
            if let movieInfo = viewModel.upComingMovies {
                movie = movieInfo.results[indexPath.row]
            }
        }
        
        print(movie!.title)
    }
}

extension MovieHomeView: UISearchBarDelegate {
    // MARK: TODO - 키보드에서 입력할 때마다 debounce로 api호출로 수정
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            viewModel.searchText = searchText
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.3) {
            self.resultsTableViewController.tableView.alpha = 1.0
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.3) {
            self.resultsTableViewController.tableView.alpha = 0.0
        }
    }
}

extension MovieHomeView: UITableViewDelegate, UITableViewDataSource {
    
    // 테이블뷰 데이터 소스 메서드
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 결과 데이터의 개수를 반환
        return viewModel.searchedMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        if viewModel.searchedMovies.count > 0 {
            let movie = viewModel.searchedMovies[indexPath.row]
            cell.textLabel?.text = movie.title
        }
        return cell
    }
}
