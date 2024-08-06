//
//  MovieHomeView.swift
//  SearchMovieApp
//
//  Created by MadCow on 2024/7/8.
//

import UIKit
import Combine
import SnapKit

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
    private lazy var searchResultsTableViewController = UITableViewController()
    private lazy var searchResultsTableView = UITableView()
    private var prevBottomAnchor: ConstraintItem!
    
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
                self.searchResultsTableView.reloadData()
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
            let detailListView = MovieDetailListView()
            detailListView.loadedMovies = viewModel.popularMovies
            self.navigationController?.pushViewController(detailListView, animated: true)
        }, for: .touchUpInside)
        
        famousMovieButton.addAction(UIAction{ [weak self] _ in
            guard let self = self else { return }
            let detailListView = MovieDetailListView()
            detailListView.loadedMovies = viewModel.famousMovies
            self.navigationController?.pushViewController(detailListView, animated: true)
        }, for: .touchUpInside)
    
        upComingMovieButton.addAction(UIAction{ [weak self] _ in
            guard let self = self else { return }
            let detailListView = MovieDetailListView()
            detailListView.loadedMovies = viewModel.upComingMovies!.results
            self.navigationController?.pushViewController(detailListView, animated: true)
        }, for: .touchUpInside)
    }
    
    func configureUI() {
        
        self.view.backgroundColor = .black
        setNavigationBar()
        setMainScrollView()
        setPopularMovieScrollView()
        setFamousMovieScrollView()
        setUpComingMovieScrollView()
        setSearchResultTable()
    }
    
    func setNavigationBar() {
        // MARK: TODO - button item 선택 -> 검색창 생성 -> 영화 검색 목록
//        self.title = "Movie Search"
        
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
        
        scrollView.snp.makeConstraints { [weak self] scroll in
            guard let self = self else { return }
            scroll.top.equalTo(self.view.snp.top)
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
    
    func setPopularMovieScrollView() {
        popularMovieCollection.register(MovieHomeViewCell.self, forCellWithReuseIdentifier: "PopularMovieHomeViewCell")
        popularMovieCollection.dataSource = self
        popularMovieCollection.delegate = self
        
        let divider = CustomDivider()
        [popularMovieButton, popularMovieCollection, divider].forEach{ contentView.addSubview($0) }
        
        popularMovieButton.snp.makeConstraints { [weak self] btn in
            guard let self = self else { return }
            btn.top.equalTo(self.contentView.snp.top).offset(10)
            btn.left.equalTo(self.contentView.snp.left).offset(10)
        }
        
        popularMovieCollection.snp.makeConstraints { [weak self] col in
            guard let self = self else { return }
            col.top.equalTo(self.popularMovieButton.snp.bottom).offset(10)
            col.left.equalTo(self.contentView.snp.left)
            col.right.equalTo(self.contentView.snp.right)
            col.height.equalTo(250)
        }
        
        divider.snp.makeConstraints { [weak self] div in
            guard let self = self else { return }
            div.top.equalTo(self.popularMovieCollection.snp.bottom).offset(15)
            div.left.equalTo(self.contentView.snp.left).offset(10)
            div.right.equalTo(self.contentView.snp.right).offset(-10)
        }
        
        prevBottomAnchor = divider.snp.bottom
    }
    
    func setFamousMovieScrollView() {
        famousMovieCollection.register(MovieHomeViewCell.self, forCellWithReuseIdentifier: "FamousMovieHomeViewCell")
        famousMovieCollection.dataSource = self
        famousMovieCollection.delegate = self
        
        let divider = CustomDivider()
        [famousMovieButton, famousMovieCollection, divider].forEach{ contentView.addSubview($0) }
        
        famousMovieButton.snp.makeConstraints { [weak self] btn in
            guard let self = self else { return }
            btn.top.equalTo(self.prevBottomAnchor).offset(10)
            btn.left.equalTo(self.popularMovieCollection.snp.left).offset(10)
        }
        
        famousMovieCollection.snp.makeConstraints { [weak self] col in
            guard let self = self else { return }
            col.top.equalTo(self.famousMovieButton.snp.bottom).offset(10)
            col.left.equalTo(self.popularMovieCollection.snp.left)
            col.right.equalTo(self.popularMovieCollection.snp.right)
            col.height.equalTo(250)
        }
        
        divider.snp.makeConstraints { [weak self] div in
            guard let self = self else { return }
            div.top.equalTo(self.famousMovieCollection.snp.bottom).offset(10)
            div.left.equalTo(self.famousMovieCollection.snp.left)
            div.right.equalTo(self.famousMovieCollection.snp.right)
        }
        
        prevBottomAnchor = divider.snp.bottom
    }
    
    func setUpComingMovieScrollView() {
        upComingMovieCollection.register(MovieHomeViewCell.self, forCellWithReuseIdentifier: "UpComingMovieHomeViewCell")
        upComingMovieCollection.dataSource = self
        upComingMovieCollection.delegate = self
        
        let divider = CustomDivider()
        [upComingMovieButton, upComingMovieCollection, divider].forEach{ contentView.addSubview($0) }
        
        upComingMovieButton.snp.makeConstraints { [weak self] btn in
            guard let self = self else { return }
            btn.top.equalTo(self.prevBottomAnchor).offset(10)
            btn.left.equalTo(self.famousMovieCollection.snp.left).offset(10)
        }
        
        upComingMovieCollection.snp.makeConstraints { [weak self] col in
            guard let self = self else { return }
            col.top.equalTo(self.upComingMovieButton.snp.bottom).offset(10)
            col.left.equalTo(self.famousMovieCollection.snp.left)
            col.right.equalTo(self.famousMovieCollection.snp.right)
            col.height.equalTo(250)
        }
        
        divider.snp.makeConstraints { [weak self] div in
            guard let self = self else { return }
            div.top.equalTo(self.upComingMovieCollection.snp.bottom).offset(10)
            div.left.equalTo(self.upComingMovieCollection.snp.left)
            div.right.equalTo(self.upComingMovieCollection.snp.right)
            div.bottom.equalTo(self.contentView.snp.bottom)
        }
        
        prevBottomAnchor = divider.snp.bottom
    }
    
    func setSearchResultTable() {
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        // MARK: ERROR - 기기별로 table의 위치가 조금씩 다름
//        searchResultsTableView.frame = CGRect(x: 0, y: 104, width: view.frame.width, height: view.frame.height - 180)
        self.view.addSubview(searchResultsTableView)
        searchResultsTableView.snp.makeConstraints { [weak self] make in
            guard let self = self else { return }
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.equalTo(self.view.snp.left)
            make.right.equalTo(self.view.snp.right)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        searchResultsTableView.alpha = 0.0
        searchResultsTableViewController.tableView = searchResultsTableView
        searchResultsTableView.register(MovieSearchListCell.self, forCellReuseIdentifier: "MovieSearchListCell")
        
        // 결과 테이블뷰를 뷰에 추가
        view.addSubview(searchResultsTableView)
    }
}

// 주간 인기, 평점 높은, 개봉 예정 영화 목록
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
        
        cell.viewModel = self.viewModel
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
        
        let detailView = MovieDetailView()
        detailView.movieInfo = movie
        navigationController?.pushViewController(detailView, animated: true)
    }
}

// 영화 검색
extension MovieHomeView: UISearchBarDelegate {
    // MARK: TODO - 키보드에서 입력할 때마다 debounce로 api호출로 수정
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            viewModel.searchText = searchText
        } else {
            viewModel.searchedMovies = []
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.3) {
            self.searchResultsTableViewController.tableView.alpha = 1.0
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.viewModel.searchedMovies = []
        UIView.animate(withDuration: 0.3) {
            self.searchResultsTableViewController.tableView.alpha = 0.0
        }
    }
}

// 검색 결과 목록
extension MovieHomeView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchedMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieSearchListCell", for: indexPath) as? MovieSearchListCell else {
            return UITableViewCell()
        }
        
        if viewModel.searchedMovies.count > 0 {
            let movie = viewModel.searchedMovies[indexPath.row]
            cell.configureUI(movie: movie)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailView = MovieDetailView()
        let selectedMovie = viewModel.searchedMovies[indexPath.row]
        detailView.movieInfo = selectedMovie
        self.navigationController?.pushViewController(detailView, animated: true)
    }
}
